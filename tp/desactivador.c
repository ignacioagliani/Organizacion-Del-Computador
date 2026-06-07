/*
 * desactivador.c — Desactivador de la Bomba personalizada
 *
 * Compilación (en Linux):
 *   gcc -o desactivador desactivador.c
 *
 * Ejecución (en el mismo directorio que el binario Bomba):
 *   ./desactivador
 *
 * Estrategia:
 *   1. Fork + execve de Bomba con stdin conectado a un pipe.
 *   2. ptrace para poner breakpoints justo antes de cada comparación.
 *   3. Al frenar en cada breakpoint, leer el valor esperado desde
 *      registros/memoria del proceso hijo e inyectarlo en el operando
 *      que representa la respuesta del usuario (también en memoria).
 *   4. Restaurar la instrucción original, corregir rip y continuar.
 *
 * Fases y breakpoints (offsets relativos a la base PIE):
 *   Fase 1 — 0x176e : cmp [rsp+0x44], r15d        (entero)
 *   Fase 2 — 0x17c8 : ucomiss xmm3, [rsp+0x48]    (float)
 *   Fase 3 — 0x182f : cmp [rsp+0x44], ebx          (entero)
 *   Fase 4 — 0x18ae : call strcmp(rdi, rsi)         (texto)
 *   Fase 5 — 0x1911 : cmp [rsp+0x44], ebx          (entero)
 *   Fase 6 — 0x195f : ucomiss xmm4, [rsp+0x4c]    (float)
 */

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

/* Offsets de breakpoint (desde la base de carga del ELF PIE) */
#define OFF_PH1  0x176eUL   /* cmp [rsp+0x44], r15d          */
#define OFF_PH2  0x17c8UL   /* ucomiss xmm3, [rsp+0x48]      */
#define OFF_PH3  0x182fUL   /* cmp [rsp+0x44], ebx           */
#define OFF_PH4  0x18aeUL   /* call strcmp(rdi=usuario, rsi=esperado) */
#define OFF_PH5  0x1911UL   /* cmp [rsp+0x44], ebx           */
#define OFF_PH6  0x195fUL   /* ucomiss xmm4, [rsp+0x4c]      */

/* Lee la dirección base del binario desde /proc/pid/maps */
static unsigned long get_base(pid_t pid)
{
    char path[64];
    snprintf(path, sizeof(path), "/proc/%d/maps", (int)pid);
    FILE *f = fopen(path, "r");
    if (!f) { perror("fopen maps"); exit(1); }

    unsigned long base = 0;
    char line[512];
    /* Buscar la primera línea que corresponda a Bomba */
    while (fgets(line, sizeof(line), f)) {
        if (strstr(line, "Bomba")) {
            sscanf(line, "%lx-", &base);
            break;
        }
    }
    fclose(f);

    if (!base) {
        /* Fallback: primera línea del mapa */
        f = fopen(path, "r");
        if (f && fgets(line, sizeof(line), f))
            sscanf(line, "%lx-", &base);
        if (f) fclose(f);
    }
    return base;
}

/*
 * Escribe un breakpoint (int3 = 0xCC) en addr.
 * Devuelve la palabra original de 8 bytes para restaurar luego.
 */
static long set_bp(pid_t pid, unsigned long addr)
{
    errno = 0;
    long orig = ptrace(PTRACE_PEEKTEXT, pid, (void *)addr, NULL);
    if (errno) { perror("PEEKTEXT set_bp"); exit(1); }
    /* Reemplazar solo el primer byte con 0xCC */
    long patched = (orig & ~0xFFL) | 0xCCL;
    if (ptrace(PTRACE_POKETEXT, pid, (void *)addr, (void *)patched) < 0) {
        perror("POKETEXT set_bp"); exit(1);
    }
    return orig;
}

/* Restaura la instrucción original */
static void rm_bp(pid_t pid, unsigned long addr, long orig)
{
    if (ptrace(PTRACE_POKETEXT, pid, (void *)addr, (void *)orig) < 0) {
        perror("POKETEXT rm_bp"); exit(1);
    }
}

/*
 * Lee 4 bytes desde addr en el espacio del proceso hijo.
 * Maneja correctamente el alineamiento a 8 bytes que exige ptrace.
 */
static uint32_t peek32(pid_t pid, unsigned long addr)
{
    unsigned long aligned = addr & ~7UL;
    errno = 0;
    long w = ptrace(PTRACE_PEEKTEXT, pid, (void *)aligned, NULL);
    if (errno) { perror("peek32"); exit(1); }
    int shift = (int)((addr & 7) * 8);
    return (uint32_t)((uint64_t)w >> shift);
}

/*
 * Escribe 4 bytes en addr en el espacio del proceso hijo
 * sin tocar los otros 4 bytes de la misma palabra de 8.
 */
static void poke32(pid_t pid, unsigned long addr, uint32_t val)
{
    unsigned long aligned = addr & ~7UL;
    errno = 0;
    uint64_t w = (uint64_t)ptrace(PTRACE_PEEKTEXT, pid, (void *)aligned, NULL);
    if (errno) { perror("poke32 peek"); exit(1); }
    int shift = (int)((addr & 7) * 8);
    w = (w & ~(0xFFFFFFFFULL << shift)) | ((uint64_t)val << shift);
    if (ptrace(PTRACE_POKETEXT, pid, (void *)aligned, (void *)w) < 0) {
        perror("poke32 poke"); exit(1);
    }
}

int main(void)
{
    /* Pipe para stdin del hijo — escribimos respuestas ficticias */
    int pfd[2];
    if (pipe(pfd) < 0) { perror("pipe"); return 1; }

    pid_t child = fork();
    if (child < 0) { perror("fork"); return 1; }

    if (child == 0) {
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
    waitpid(child, &status, 0);
    if (!WIFSTOPPED(status)) {
        fprintf(stderr, "[-] El hijo no se detuvo tras execve\n");
        return 1;
    }

    /* Obtener base de carga del ELF PIE */
    unsigned long base = get_base(child);
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
        bp_orig[i] = set_bp(child, bp_addr[i]);
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
            if (ptrace(PTRACE_CONT, child, NULL, sig_to_deliver) < 0) {
                perror("PTRACE_CONT"); return 1;
            }
            waitpid(child, &status, 0);

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
        ptrace(PTRACE_GETREGS, child, NULL, &regs);
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
                poke32(child, rsp + 0x44, key);
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
                uint32_t fb = peek32(child, rsp + 0x1c);
                float fv;
                memcpy(&fv, &fb, 4);
                fprintf(stderr, "    Clave (float): %f  (bits=0x%08x)\n", fv, fb);
                poke32(child, rsp + 0x48, fb);
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
                poke32(child, rsp + 0x44, key);
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
                poke32(child, rsp + 0x44, key);
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
                uint32_t fb = peek32(child, rsp + 0x3c);
                float fv;
                memcpy(&fv, &fb, 4);
                fprintf(stderr, "    Clave (float): %f  (bits=0x%08x)\n", fv, fb);
                poke32(child, rsp + 0x4c, fb);
            }
            break;
        }

        /* Restaurar instrucción original y corregir rip */
        rm_bp(child, bp_addr[idx], bp_orig[idx]);
        regs.rip = rip;
        ptrace(PTRACE_SETREGS, child, NULL, &regs);
    }

    /* Dejar correr al hijo hasta que termine */
    fprintf(stderr, "\n[*] Todos los breakpoints procesados — continuando...\n\n");
    ptrace(PTRACE_CONT, child, NULL, NULL);
    waitpid(child, &status, 0);

    if (WIFEXITED(status))
        fprintf(stderr, "\n[*] Hijo terminó con código %d\n", WEXITSTATUS(status));

    return 0;
}
