    .equ    Swi_Open_File, 0x66
    .equ    Swi_Write_Int, 0x6b
    .equ    Swi_Close_File,0x68
    .equ    Swi_Exit, 0x11

    .data
        vector:    .word    1,2,3,3,8
        lenVec:    .word    5
        fileName:  .asciz   "and.txt"
        const:     .word    2
    .text
    .global _start
_start:
    @ R3 -> Ptr. Archivo; R4 -> Dir. Vector; R5 -> Len. Vec; R6 -> Contador; R7 -> Cont. Vec; R8 -> Const.
    ldr    r0, =fileName
    mov    r1, #1

    swi    Swi_Open_File

    mov    r3, r0
    ldr    r4, =vector
    ldr    r5, =lenVec
    ldr    r5, [r5]
    mov    r6, #0
    ldr    r8, =const
    ldr    r8, [r8]

loop:
    cmp    r5, r6
    beq    fin

    ldr    r7, [r4]
    and    r0, r7, r8
    mov    r1, r0
    mov    r0, r3
    swi    Swi_Write_Int

    add    r4, r4, #4
    add    r6, r6, #1
    b      loop

fin:
    mov    r0, r3
    swi    Swi_Close_File

    swi    Swi_Exit
    .end
