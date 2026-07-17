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

#define OFFSET_FASE1  0x176eUL
#define OFFSET_FASE2  0x17c8UL
#define OFFSET_FASE3  0x182fUL
#define OFFSET_FASE4  0x18aeUL
#define OFFSET_FASE5  0x1911UL
#define OFFSET_FASE6  0x195fUL

/*
obtener_direccion_bomba recibe el ID de un proceso (la bomba).
Devuelve la direccion de memoria donde se cargo la bomba.
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
*/
long colocar_breakpoint(pid_t id_proceso_bomba, unsigned long direccion_breakpoint) {
    errno = 0;
    long bytes_originales = ptrace(PTRACE_PEEKTEXT, id_proceso_bomba, (void *)direccion_breakpoint, NULL);
    if (errno != 0) {
        perror("No se pudo copiar los bytes de 'direccion_breakpoint'");
        exit(1);
    }

    long interrupcion = (bytes_originales & ~0xFFL) | 0xCCL;
    if (ptrace(PTRACE_POKETEXT, id_proceso_bomba, (void *)direccion_breakpoint, (void *)interrupcion) < 0) {
        perror("No se pudo generar interrupcion");
        exit(1);
    }

    return bytes_originales;
}

/*
quitar_breakpoint recibe un ID de proceso, una direccion de memoria a cambiar y el contenido por el cual
queremos remplazar.
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
*/
uint32_t leer_direccion_memoria(pid_t id_proceso_bomba, unsigned long direccion_a_leer) {
    unsigned long alineado = direccion_a_leer & ~7UL;

    errno = 0;
    long leido = ptrace(PTRACE_PEEKTEXT, id_proceso_bomba, (void *)alineado, NULL);
    if (errno != 0) {
        perror("No se pudo leer la memoria de interes");
        exit(1);
    }

    int desplazamiento = (int)((direccion_a_leer & 7) * 8);
    return (uint32_t)((uint64_t)leido >> desplazamiento);
}

/*
inyectar recibe el ID de un proceso, una direccion donde se quiere escribir y que se quiere escribir.
No devuelve nada.
*/
void inyectar(pid_t id_proceso_bomba, unsigned long direccion_a_escribir, uint32_t contenido_a_escribir) {
    unsigned long alineado = direccion_a_escribir & ~7UL;

    errno = 0;
    uint64_t leido = (uint64_t)ptrace(PTRACE_PEEKTEXT, id_proceso_bomba, (void *)alineado, NULL);
    if (errno != 0) {
        perror("No se pudo leer memoria");
        exit(1);
    }

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
    padre con el hijo (la bomba).
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

    close(canal[0]);
    int info_hijo;
    waitpid(proceso_hijo, &info_hijo, 0);
    if (!WIFSTOPPED(info_hijo)) {
        fprintf(stderr, "El hijo no se detuvo tras execve\n");
        return 1;
    }

    unsigned long base = obtener_direccion_bomba(proceso_hijo);
    if (base == 0) {
        fprintf(stderr, "No se pudo determinar la direccion base de la bomba\n");
        return 1;
    }

    unsigned long vector_direcciones_breakpoints[6] = {
        base + OFFSET_FASE1,
        base + OFFSET_FASE2,
        base + OFFSET_FASE3,
        base + OFFSET_FASE4,
        base + OFFSET_FASE5,
        base + OFFSET_FASE6,
    };

    // Colocacion de breakpoints
    long vector_contido_previo[6];
    for (int i = 0; i < 6; i++) {
        vector_contido_previo[i] = colocar_breakpoint(proceso_hijo, vector_direcciones_breakpoints[i]);
    }

    const char *respuestas = "0\n0.0\n0\nEstoSeSobreescribe\n0\n0.0\n";
    write(canal[1], respuestas, strlen(respuestas));
    close(canal[1]);

    struct user_regs_struct registros;

    for (int fase = 0; fase < 6; fase++) {
        // Desactivacion por fase
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

        // Se quita breakpint, restaura RIP y continua ejecución
        quitar_breakpoint(proceso_hijo, vector_direcciones_breakpoints[indice], vector_contido_previo[indice]);
        registros.rip = rip;
        ptrace(PTRACE_SETREGS, proceso_hijo, NULL, &registros);
    }

    // Dejar correr al hijo hasta que termine.
    ptrace(PTRACE_CONT, proceso_hijo, NULL, NULL);
    waitpid(proceso_hijo, &info_hijo, 0);
    return 0;
}
