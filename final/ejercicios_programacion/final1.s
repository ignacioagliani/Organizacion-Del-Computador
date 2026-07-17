    .equ    SWI_EXIT, 0x11
    
    .data
        vector:    .word    1,2,3,4
        len:       .word    4
        nuevoV:    .word    0,0,0,0
        const:     .word    2

    .text
    .global _start

_start:
    @ R2 -> Dir. Vector; R3 -> Len; R4 -> Dir. Nuevo; R5 -> Contador; R6 -> Cont. Vector; R7 -> Constante
    ldr    r2, =vector
    ldr    r3, =len
    ldr    r3, [r3]
    ldr    r4, =nuevoV
    mov    r5, #0
    ldr    r7, =const
    ldr    r7, [r7]

loop:
    cmp    r3, r5
    beq    fin

    ldr    r6, [r2]
    add    r6, r6, r7
    str    r6, [r4]

    add    r2, r2, #4
    add    r4, r4, #4
    add    r5, r5, #1
    b      loop

fin:
    swi    SWI_EXIT
    .end