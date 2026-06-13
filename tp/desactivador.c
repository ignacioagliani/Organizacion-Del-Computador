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
#define OFF_PH1  0x176eUL
#define OFF_PH2  0x17c8UL
#define OFF_PH3  0x182fUL
#define OFF_PH4  0x18aeUL
#define OFF_PH5  0x1911UL
#define OFF_PH6  0x195fUL

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
set_bp recibe el ID de un proceso y la direccion de memoria donde se quiere poner un breakpoint.
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
long set_bp(pid_t id_proceso_bomba, unsigned long direccion_breakpoint) {
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
rm_bp recibe un ID de proceso, una direccion de memoria a cambiar y el contenido por el cual
queremos remplazar. No devuelve nada. En caso de error, imprime un mensaje por la salida de error
y sale del programa.
*/
void rm_bp(pid_t id_proceso_bomba, unsigned long direccion_breakpoint_modificada, long bytes_originales) {
    if (ptrace(PTRACE_POKETEXT, id_proceso_bomba, (void *)direccion_breakpoint_modificada, (void *)bytes_originales) < 0) {
        perror("No se pudieron restaurar los bytes originales");
        exit(1);
    }
}

/*
peek32 recibe un ID de proceso y una direccion de memoria la cual queremos leer.
Devuelve los 4 primeros bytes de esa direccion.

(I) Como PEEKTEXT lee solo 8 bytes y solo nos interesan 4 bytes, hay que modificar
la direccion mediante operaciones de bits para extraer lo que nos interesa.

(II) Una vez alineada la memoria, se lee su contenido. Si falla la lectura, imprime por
la salida de error un mensaje y sale del programa.

(III) Se calcula un desplazamiento. Este se usa para desplazar la memoria de 8 bytes
leida y quedarnos con los 4 bytes que nos interesan.
*/
uint32_t peek32(pid_t id_proceso_bomba, unsigned long direccion_a_leer) {
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
poke32 recibe el ID de un proceso, una direccion donde se quiere escribir y que se quiere escribir.
No devuelve nada.

(*) Al igual que en el caso anterior, debemos alinear la direccion a 8 bytes.
(**) Leemos la direccion de memoria. Si falla, imprimimos mensaje y salimos del programa.
(***) Calculamos 'desplazamiento', el cual usaremos en operaciones de bits para quedarnos
    con los 4 bytes de interes. Tambien, mediante la operacion:
    
    (leido & ~(0xFFFFFFFFULL << desplazamiento)) | ((uint64_t)contenido_a_escribir << desplazamiento);

    Se limpian los 4 bytes de destino y se pone el valor a inyectar.
    Si no se pudo escribir, se imprime una mensaje por al salida de error y sale del programa.
*/
void poke32(pid_t id_proceso_bomba, unsigned long direccion_a_escribir, uint32_t contenido_a_escribir) {
    // (*) 
    unsigned long aligned = direccion_a_escribir & ~7UL;
    // (**)
    errno = 0;
    uint64_t leido = (uint64_t)ptrace(PTRACE_PEEKTEXT, id_proceso_bomba, (void *)aligned, NULL);
    if (errno != 0) {
        perror("No se pudo leer memoria");
        exit(1);
    }

    // (***)
    int desplazamiento = (int)((direccion_a_escribir & 7) * 8);
    leido = (leido & ~(0xFFFFFFFFULL << desplazamiento)) | ((uint64_t)contenido_a_escribir << desplazamiento);
    if (ptrace(PTRACE_POKETEXT, id_proceso_bomba, (void *)aligned, (void *)leido) < 0) {
        perror("No se pudo escribir memoria");
        exit(1);
    }
}

int main(void) {
    /* Pipe para stdin del hijo — escribimos respuestas ficticias */
    int pfd[2];
    if (pipe(pfd) < 0) {
        perror("pipe");
        return 1;
    }

    pid_t proceso_hijo = fork();
    if (proceso_hijo < 0) {
        perror("fork");
        return 1;
    }

    if (proceso_hijo == 0) {
        /* ---- HIJO ---- */
        /* Conectar stdin al extremo lector del pipe */
        dup2(pfd[0], STDIN_FILENO);
        close(pfd[0]);
        close(pfd[1]);
        /* Autorizar al padre a tracearlo */
        ptrace(PTRACE_TRACEME, 0, NULL, NULL);
        char *av[] = { BOMB_PATH, NULL };
        execve(BOMB_PATH, av, NULL);
        perror("execve");
        _exit(1);
    }

    /* ---- PADRE ---- */
    close(pfd[0]);

    /* Esperar el SIGTRAP inicial generado por execve */
    int status;
    waitpid(proceso_hijo, &status, 0);
    if (!WIFSTOPPED(status)) {
        fprintf(stderr, "[-] El hijo no se detuvo tras execve\n");
        return 1;
    }

    /* Obtener base de carga del ELF PIE */
    unsigned long base = obtener_direccion_bomba(proceso_hijo);
    fprintf(stderr, "[*] Base de Bomba: 0x%lx\n", base);
    if (!base) {
        fprintf(stderr, "[-] No se pudo determinar la base\n");
        return 1;
    }

    /* Calcular direcciones absolutas de los 6 breakpoints */
    unsigned long bp_addr[6] = {
        base + OFF_PH1,
        base + OFF_PH2,
        base + OFF_PH3,
        base + OFF_PH4,
        base + OFF_PH5,
        base + OFF_PH6,
    };

    /* Poner los 6 breakpoints y guardar bytes originales */
    long bp_orig[6];
    for (int i = 0; i < 6; i++) {
        bp_orig[i] = set_bp(proceso_hijo, bp_addr[i]);
        fprintf(stderr, "[*] BP fase %d @ 0x%lx\n", i + 1, bp_addr[i]);
    }

    /*
     * Escribir entradas ficticias en el pipe (una por fase).
     * El contenido exacto no importa porque lo sobreescribimos
     * via ptrace antes de que se evalúe la comparación.
     */
    const char *dummy = "0\n0.0\n0\nAAAAAAAAAAAAAAAA\n0\n0.0\n";
    write(pfd[1], dummy, strlen(dummy));
    close(pfd[1]);   /* EOF para que fgets no bloquee al final */

    struct user_regs_struct regs;

    /* Procesar los 6 breakpoints en orden */
    for (int phase = 0; phase < 6; phase++) {
        /*
         * Reanudar el hijo y esperar el próximo SIGTRAP (nuestro breakpoint).
         * Si recibe otra señal (ej. del linker dinámico), la reenviamos y
         * seguimos esperando en lugar de abortar.
         */
        void *sig_to_deliver = NULL;
        for (;;) {
            if (ptrace(PTRACE_CONT, proceso_hijo, NULL, sig_to_deliver) < 0) {
                perror("PTRACE_CONT"); return 1;
            }
            waitpid(proceso_hijo, &status, 0);

            if (WIFEXITED(status)) {
                fprintf(stderr, "[-] El hijo terminó en fase %d (código %d)\n",
                        phase + 1, WEXITSTATUS(status));
                return 1;
            }
            if (!WIFSTOPPED(status)) {
                fprintf(stderr, "[-] Estado inesperado en fase %d\n", phase + 1);
                return 1;
            }
            if (WSTOPSIG(status) == SIGTRAP)
                break;   /* Es nuestro breakpoint, salir del loop interno */

            /* Otra señal — reenviarla al hijo y continuar esperando */
            sig_to_deliver = (void *)(long)WSTOPSIG(status);
        }

        /* Leer registros — rip apunta al byte DESPUÉS del 0xCC */
        ptrace(PTRACE_GETREGS, proceso_hijo, NULL, &regs);
        unsigned long rip = regs.rip - 1;   /* dirección real del breakpoint */
        unsigned long rsp = regs.rsp;

        /* Identificar cuál breakpoint se disparó */
        int idx = -1;
        for (int i = 0; i < 6; i++)
            if (rip == bp_addr[i]) { idx = i; break; }

        if (idx < 0) {
            fprintf(stderr, "[-] SIGTRAP en dirección desconocida: 0x%lx\n", rip);
            return 1;
        }

        fprintf(stderr, "\n[*] === FASE %d (bp idx=%d) ===\n", idx + 1, idx);
        fprintf(stderr, "    rip=0x%lx  rsp=0x%lx\n", rip, rsp);

        switch (idx) {

        case 0:
            /*
             * Fase 1 — entero
             * Instrucción: cmp DWORD PTR [rsp+0x44], r15d
             * El valor esperado está en r15d.
             * Inyectamos r15d en [rsp+0x44] (la respuesta leída por sscanf).
             */
            {
                uint32_t key = (uint32_t)regs.r15;
                fprintf(stderr, "    Clave (int): %d\n", (int32_t)key);
                poke32(proceso_hijo, rsp + 0x44, key);
            }
            break;

        case 1:
            /*
             * Fase 2 — float
             * Instrucción: ucomiss xmm3, DWORD PTR [rsp+0x48]
             * xmm3 contiene el float esperado (cargado desde [rsp+0x1c]).
             * Inyectamos esos mismos bits en [rsp+0x48] (input del usuario).
             */
            {
                uint32_t fb = peek32(proceso_hijo, rsp + 0x1c);
                float fv;
                memcpy(&fv, &fb, 4);
                fprintf(stderr, "    Clave (float): %f  (bits=0x%08x)\n", fv, fb);
                poke32(proceso_hijo, rsp + 0x48, fb);
            }
            break;

        case 2:
            /*
             * Fase 3 — entero
             * Instrucción: cmp DWORD PTR [rsp+0x44], ebx
             * Valor esperado en ebx.
             */
            {
                uint32_t key = (uint32_t)regs.rbx;
                fprintf(stderr, "    Clave (int): %d\n", (int32_t)key);
                poke32(proceso_hijo, rsp + 0x44, key);
            }
            break;

        case 3:
            /*
             * Fase 4 — texto (strcmp)
             * Instrucción: call strcmp(rdi=buffer_usuario, rsi=string_esperado)
             * Truco: hacemos rdi = rsi, así strcmp compara el string esperado
             * consigo mismo → siempre retorna 0 (igual).
             */
            fprintf(stderr, "    String esperado en rsi=0x%lx — redirigiendo rdi\n",
                    (unsigned long)regs.rsi);
            regs.rdi = regs.rsi;
            break;

        case 4:
            /*
             * Fase 5 — entero
             * Instrucción: cmp DWORD PTR [rsp+0x44], ebx
             * Valor esperado en ebx (diferente al de fase 3).
             */
            {
                uint32_t key = (uint32_t)regs.rbx;
                fprintf(stderr, "    Clave (int): %d\n", (int32_t)key);
                poke32(proceso_hijo, rsp + 0x44, key);
            }
            break;

        case 5:
            /*
             * Fase 6 — float
             * Instrucción: ucomiss xmm4, DWORD PTR [rsp+0x4c]
             * xmm4 = [rsp+0x3c] (float esperado).
             * Inyectamos esos bits en [rsp+0x4c] (input del usuario).
             */
            {
                uint32_t fb = peek32(proceso_hijo, rsp + 0x3c);
                float fv;
                memcpy(&fv, &fb, 4);
                fprintf(stderr, "    Clave (float): %f  (bits=0x%08x)\n", fv, fb);
                poke32(proceso_hijo, rsp + 0x4c, fb);
            }
            break;
        }

        /* Restaurar instrucción original y corregir rip */
        rm_bp(proceso_hijo, bp_addr[idx], bp_orig[idx]);
        regs.rip = rip;
        ptrace(PTRACE_SETREGS, proceso_hijo, NULL, &regs);
    }

    /* Dejar correr al hijo hasta que termine */
    fprintf(stderr, "\n[*] Todos los breakpoints procesados — continuando...\n\n");
    ptrace(PTRACE_CONT, proceso_hijo, NULL, NULL);
    waitpid(proceso_hijo, &status, 0);

    if (WIFEXITED(status))
        fprintf(stderr, "\n[*] Hijo terminó con código %d\n", WEXITSTATUS(status));

    return 0;
}
