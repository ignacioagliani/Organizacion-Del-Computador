    .equ    Swi_Print_Int, 0x6b
    .equ    Swi_Exit, 0x11

    .data

        vector:    .word    3,1,9,8,5,5
        lenVec:    .word    6
        nuevoV:    .word    0,0,0

    .text
    .global _start

_start:
    @ R2 -> Dir. Vector; R3 -> LenVector; R4 -> Dir. Nuevo Vec; R5 -> Contador; R6 -> Resultado; R7 -> Cont. Vector
    ldr    r2, =vector
    ldr    r3, =lenVec
    ldr    r3, [r3]
    ldr    r4, =nuevoV
    mov    r5, #0
    mov    r6, #0

loop:
    cmp    r5, r3
    beq    fin

    ldr    r7, [r2]
    add    r6, r6, r7
    ldr    r7, [r2, #4]
    sub    r6, r6, r7

    str    r6, [r4]
    mov    r1, r6
    mov    r0, #1

    swi    Swi_Print_Int

    add    r2, r2, #8
    add    r4, r4, #4
    add    r5, r5, #2
    mov    r6, #0
    b      loop

fin:
    swi    Swi_Exit
    .end
