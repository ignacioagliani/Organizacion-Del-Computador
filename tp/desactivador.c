#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdint.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

#define BOMB_PATH "./Bomba"

/* Offsets de breakpoint obtenidos del desensamblado */
#define OFFSET_FASE1  0x176eUL
#define OFFSET_FASE2  0x17c8UL
#define OFFSET_FASE3  0x182fUL
#define OFFSET_FASE4  0x18aeUL
#define OFFSET_FASE5  0x1911UL
#define OFFSET_FASE6  0x195fUL

/*
obtener_direccion_bomba recibe el ID de un proceso (la bomba).
Devuelve la direccion de memoria donde se cargo la bomba.

Primero, se guarda en 'path' la ruta del proceso con un determinado formato,
que es el que usa Linux. Si no se encuentra el archivo de mapas (el que contiene
a los segmentos de memoria del proceso), imprime por la stderror un mensaje y
termina el programa.

Si se encuetra el código de proceso, se hace un ciclo while. En este ciclo,
se itera hasta encontrar el ejecutable de la bomba. Si lo encuentra, guarda en
base esa direccion.
*/
unsigned long obtener_direccion_bomba(pid_t id_proceso_bomba) {
    char path[64];
    snprintf(path, sizeof(path), "/proc/%d/maps", (int)id_proceso_bomba);
    FILE *procesos = fopen(path, "r");
    if (!procesos) {
        perror("Proceso no se Encuentra");
        exit(1);
    }

    unsigned long base = 0;
    char linea[512];
    while (fgets(linea, sizeof(linea), procesos)) {
        if (strstr(linea, "Bomba")) {
            sscanf(linea, "%lx-", &base);
            break;
        }
    }
    fclose(procesos);

    return base;
}

/*
colocar_breakpoint recibe el ID de un proceso y la direccion de memoria donde se quiere poner un breakpoint.
La función devuelve los 8 bytes originales de 'direccion_breakpoint' antes de modificarse.
Un breakpoint es un punto de parada, donde el programa se detiene en vez de seguir ejecutando.

(a) Primero, setea la variable 'errno' en 0 y se almacena en 'bytes_originales' el contenido en memoria
de 'direccion_breakpoint'. Si errno sigue valiendo 0, no hubo errores. Si cambio,
si hubo.

(b) Luego, se modifica esa direccion usando una mascara de bits para poner el numero 0xCC en el
primer byte de esa direccion. Cuando el CPU ejecute ese byte, se va a generar un SIGTRAP
(una interrupcion al proceso. Esto nos ayuda a inyectar la clave correcta).

Despues, se pone en 'direccion_breakpoint' la nueva memoria con la interrupcion. Si no se
puede hacer esto, se imprime un mensaje por la salida de error y se sale del programa.
Por ultimo, se devulven los bytes originales.
*/
long colocar_breakpoint(pid_t id_proceso_bomba, unsigned long direccion_breakpoint) {
    // (a)
    errno = 0;
    long bytes_originales = ptrace(PTRACE_PEEKTEXT, id_proceso_bomba, (void *)direccion_breakpoint, NULL);
    if (errno != 0) {
        perror("No se pudo copiar los bytes de 'direccion_breakpoint'");
        exit(1);
    }

    // (b)
    long interrupcion = (bytes_originales & ~0xFFL) | 0xCCL;
    if (ptrace(PTRACE_POKETEXT, id_proceso_bomba, (void *)direccion_breakpoint, (void *)interrupcion) < 0) {
        perror("No se pudo generar interrupcion");
        exit(1);
    }

    return bytes_originales;
}

/*
quitar_breakpoint recibe un ID de proceso, una direccion de memoria a cambiar y el contenido por el cual
queremos remplazar. No devuelve nada. En caso de error, imprime un mensaje por la salida de error
y sale del programa.
*/
void quitar_breakpoint(pid_t id_proceso_bomba, unsigned long direccion_breakpoint_modificada, long bytes_originales) {
    if (ptrace(PTRACE_POKETEXT, id_proceso_bomba, (void *)direccion_breakpoint_modificada, (void *)bytes_originales) < 0) {
        perror("No se pudieron restaurar los bytes originales");
        exit(1);
    }
}

/*
leer_direccion_memoria recibe un ID de proceso y una direccion de memoria la cual queremos leer.
Devuelve los 4 primeros bytes de esa direccion.

(I) Como PEEKTEXT lee solo 8 bytes y solo nos interesan 4 bytes, hay que modificar
la direccion mediante operaciones de bits para extraer lo que nos interesa.

(II) Una vez alineada la memoria, se lee su contenido. Si falla la lectura, imprime por
la salida de error un mensaje y sale del programa.

(III) Se calcula un desplazamiento. Este se usa para desplazar la memoria de 8 bytes
leida y quedarnos con los 4 bytes que nos interesan.
*/
uint32_t leer_direccion_memoria(pid_t id_proceso_bomba, unsigned long direccion_a_leer) {
    // (I)
    unsigned long alineado = direccion_a_leer & ~7UL;
    // (II)
    errno = 0;
    long leido = ptrace(PTRACE_PEEKTEXT, id_proceso_bomba, (void *)alineado, NULL);
    if (errno != 0) {
        perror("No se pudo leer la memoria de interes");
        exit(1);
    }

    // (III)
    int desplazamiento = (int)((direccion_a_leer & 7) * 8);
    return (uint32_t)((uint64_t)leido >> desplazamiento);
}

/*
inyectar recibe el ID de un proceso, una direccion donde se quiere escribir y que se quiere escribir.
No devuelve nada.

(*) Al igual que en el caso anterior, debemos alinear la direccion a 8 bytes.
(**) Leemos la direccion de memoria. Si falla, imprimimos mensaje y salimos del programa.
(***) Calculamos 'desplazamiento', el cual usaremos en operaciones de bits para quedarnos
    con los 4 bytes de interes. Tambien, mediante la operacion:
    
    (leido & ~(0xFFFFFFFFULL << desplazamiento)) | ((uint64_t)contenido_a_escribir << desplazamiento);

    Se limpian los 4 bytes de destino y se pone el valor a inyectar.
    Si no se pudo escribir, se imprime una mensaje por al salida de error y sale del programa.
*/
void inyectar(pid_t id_proceso_bomba, unsigned long direccion_a_escribir, uint32_t contenido_a_escribir) {
    // (*) 
    unsigned long alineado = direccion_a_escribir & ~7UL;
    // (**)
    errno = 0;
    uint64_t leido = (uint64_t)ptrace(PTRACE_PEEKTEXT, id_proceso_bomba, (void *)alineado, NULL);
    if (errno != 0) {
        perror("No se pudo leer memoria");
        exit(1);
    }

    // (***)
    int desplazamiento = (int)((direccion_a_escribir & 7) * 8);
    leido = (leido & ~(0xFFFFFFFFULL << desplazamiento)) | ((uint64_t)contenido_a_escribir << desplazamiento);
    if (ptrace(PTRACE_POKETEXT, id_proceso_bomba, (void *)alineado, (void *)leido) < 0) {
        perror("No se pudo escribir memoria");
        exit(1);
    }
}

int main(void) {
    /*
    Se crea un arreglo, el cual se va a usar para comunicar el proceso
    padre (el desactivador) con el hijo (la bomba). El padre las escribe
    por un extremo (canal[1]) y el hijo las lee del otro (canal[0])
    */
    int canal[2];
    if (pipe(canal) < 0) {
        perror("No se pudo crear canal padre - hijo");
        return 1;
    }

    /*
    Se crea un proceso hijo.
    */
    pid_t proceso_hijo = fork();
    if (proceso_hijo < 0) {
        perror("No se pudo crear proceso hijo");
        return 1;
    }

    // Si se pudo crear el proceso hijo, con la funcion 'dup2' hacemos
    // que el hijo (la bomba), en vez de leer por la stdin, lea los
    // datos enviados por el padre. Una vez hecha la conexion, se cierran
    // los extremos del canal del hijo.
    // Luego, con PTRACE_TRACEME hacemos que el hijo pueda ser traceado por
    // su padre. Con 'execve' se remplaza el proceso actual por el de la bomba.
    // Si no se rempazo el proceso, imprime un mensaje de error por stderr y sale del programa
    if (proceso_hijo == 0) {
        dup2(canal[0], STDIN_FILENO);
        close(canal[0]);
        close(canal[1]);

        ptrace(PTRACE_TRACEME, 0, NULL, NULL);
        char *av[] = { BOMB_PATH, NULL };
        execve(BOMB_PATH, av, NULL);
        perror("No se pudo remplazar el proceso por el de la bomba");
        _exit(1);
    }

    /*
    Ahora se cierra el canal de lectura del padre, ya que solo escribe. Despues,
    lo que deberia pasar es que el hijo se detenga. Si el hijo no se detiene,
    algo salio mal.
    */
    close(canal[0]);
    int info_hijo;
    waitpid(proceso_hijo, &info_hijo, 0);
    if (!WIFSTOPPED(info_hijo)) {
        fprintf(stderr, "El hijo no se detuvo tras execve\n");
        return 1;
    }

    /* Obtiene la direccion base donde esta la bomba. Si vale 0, algo salio mal */
    unsigned long base = obtener_direccion_bomba(proceso_hijo);
    if (base == 0) {
        fprintf(stderr, "No se pudo determinar la direccion base de la bomba\n");
        return 1;
    }

    /* Se colculan direcciones absolutas de los 6 breakpoints */
    unsigned long vector_direcciones_breakpoints[6] = {
        base + OFFSET_FASE1,
        base + OFFSET_FASE2,
        base + OFFSET_FASE3,
        base + OFFSET_FASE4,
        base + OFFSET_FASE5,
        base + OFFSET_FASE6,
    };

    /* Se colocan los 6 breakpoints y se guardan bytes originales */
    long vector_contido_previo[6];
    for (int i = 0; i < 6; i++) {
        vector_contido_previo[i] = colocar_breakpoint(proceso_hijo, vector_direcciones_breakpoints[i]);
    }

    /*
    Se crean 6 respuestas de fantasia, las cuales va a leer la bomba. Algunas
    son int, otros float y un string. Se escriben las respuestas en el extremo 
    de escritura del padre y se cierra, ya que no se va a escribir mas. Las claves
    no importan, ya que van a ser remplazadas por las claves inyectadas.
    */
    const char *respuestas = "0\n0.0\n0\nEstoSeSobreescribe\n0\n0.0\n";
    write(canal[1], respuestas, strlen(respuestas));
    close(canal[1]);

    // Estructura que contiene el contenido de los registros
    struct user_regs_struct registros;

    for (int fase = 0; fase < 6; fase++) {
        /*
        Por cada una de las fases se repite este ciclo infinito:
        se crea una variable, la cual contiene una señal (mecanismo que usa el sistema
        operativo para avisarle a un proceso que ocurrio algun evento) para el hijo.
        Al principio no se le envia ninguna. Luego, continua la ejecucion de la bomba.
        Con 'waitpid', esperamos que el hijo se detenga. Si se detiene porque el hijo
        termino (WIFEXITED) o no se detuvo (!WIFSTOPPED), algo salio mal y se termina el programa.
        En cambio, si se detiene por una SIGTRAP, está bien. Ese es nuestro breakpoint y
        sale del bucle. Si la interrupcion fue otra, la guarda para que se ejecute en PTRACE_CONT.
        */
        void *senial_hijo = NULL;
        for (;;) {
            if (ptrace(PTRACE_CONT, proceso_hijo, NULL, senial_hijo) < 0) {
                perror("No se pudo continuar con la ejecucion de la bomba"); return 1;
            }
            waitpid(proceso_hijo, &info_hijo, 0);

            if (WIFEXITED(info_hijo)) {
                fprintf(stderr, "El hijo terminó en fase %d\n", fase + 1);
                return 1;
            }
            if (!WIFSTOPPED(info_hijo)) {
                fprintf(stderr, "Estado inesperado en fase %d\n", fase + 1);
                return 1;
            }
            if (WSTOPSIG(info_hijo) == SIGTRAP)
                break;

            senial_hijo = (void *)(long)WSTOPSIG(info_hijo);
        }

        /*
        Al encontrar un breakpoint, obtenemos los registros en ese momento.
        Debemos restar 1 al RIP, debido a que el registro esta apuntando a la
        siguiente instruccion despues del breakpoint. Luego, guardamos en una 
        variable el valor del RSP, para sumarlo con un offset y obtener la clave
        esperada.
        Despues, creamos una variable 'indice' inicialmente en -1. En base al contenido
        del registro de instruccion, podemos ver a que fase corresponde. Si es una fase
        valida, cambia el contenido de la variable y sale. Si al terminar de iterar,
        sigue valiendo -1, algo salio mal. Por lo tanto, imprime un mensaje y termina el programa.
        */
        ptrace(PTRACE_GETREGS, proceso_hijo, NULL, &registros);
        unsigned long rip = registros.rip - 1;
        unsigned long rsp = registros.rsp;
        int indice = -1;
        for (int i = 0; i < 6; i++)
            if (rip == vector_direcciones_breakpoints[i]) {
                indice = i;
                break;
            }

        if (indice < 0) {
            fprintf(stderr, "SIGTRAP en dirección desconocida");
            return 1;
        }

        switch (indice) {

        case 0:
            // Fase 1: clave en r15d. Se inyecta en rsp+0x44
            {
                uint32_t clave_correcta = (uint32_t)registros.r15;
                inyectar(proceso_hijo, rsp + 0x44, clave_correcta);
            }
            break;

        case 1:
            // Fase 2 — clave en rsp + 0x1C. Se inyecta en rsp+0x48.
            {
                uint32_t clave_correcta = leer_direccion_memoria(proceso_hijo, rsp + 0x1c);
                inyectar(proceso_hijo, rsp + 0x48, clave_correcta);
            }
            break;

        case 2:
            // Fase 3 — clave en ebx. Se inyecta en rsp + 0x44.
            {
                uint32_t clave_correcta = (uint32_t)registros.rbx;
                inyectar(proceso_hijo, rsp + 0x44, clave_correcta);
            }
            break;

        case 3:
            // Fase 4 — clave en rsi. Se inyecta en rdi.
            registros.rdi = registros.rsi;
            break;

        case 4:
            // Fase 5 — clave en ebx. Se inyecta en rsp + 0x44.
            {
                uint32_t clave_correcta = (uint32_t)registros.rbx;
                inyectar(proceso_hijo, rsp + 0x44, clave_correcta);
            }
            break;

        case 5:
            // Fase 6 — clave en rsp + 0x3c. Se inyecta en rsp+0x4c.
            {
                uint32_t clave_correcta = leer_direccion_memoria(proceso_hijo, rsp + 0x3c);
                inyectar(proceso_hijo, rsp + 0x4c, clave_correcta);
            }
            break;
        }

        /* 
        Se restaura el contenido original en la direccion de memoria del breakpoint.
        Esto se hace para sacar ese byte 0xCC y dejar de generar SIGTRAPs. Tambien se
        restaura el rip para que apunte a la instruccion de comparacion con la clave ya
        inyectada. Por ultimo, haciendo PTRACE_SETREGS le aplicamos los cambios al proceso hijo.
        */
        quitar_breakpoint(proceso_hijo, vector_direcciones_breakpoints[indice], vector_contido_previo[indice]);
        registros.rip = rip;
        ptrace(PTRACE_SETREGS, proceso_hijo, NULL, &registros);
    }

    /* Dejar correr al hijo hasta que termine. */
    ptrace(PTRACE_CONT, proceso_hijo, NULL, NULL);
    waitpid(proceso_hijo, &info_hijo, 0);
    return 0;
}
