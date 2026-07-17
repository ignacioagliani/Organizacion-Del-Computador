    .equ    Swi_Open_File, 0x66
    .equ    Swi_Read_Int, 0x6C
    .equ    Swi_Close_File, 0x68
    .equ    Swi_Print_Int, 0x6B
    .equ    Swi_Print_String, 0x02
    .equ    Swi_Exit, 0x11

    .data

        filename:    .asciz    "numeros.txt"
        par:         .asciz    "PAR\n"

    .text
    .global _start
_start:
    @ R2 -> Ptr. al Archivo; R3 -> Leido
    ldr    r0, =filename
    mov    r1, #0

    swi    Swi_Open_File

    mov    r2, r0

loop:
    mov    r0,r2
    swi    Swi_Read_Int

    bcs    eof
    
    mov    r1, r0
    mov    r0, #1
    swi    Swi_Print_Int

    and    r1, r1, #1
    cmp    r1, #0
    bleq   imprimir_par
    b      loop

imprimir_par:
    stmfd  sp!, {r0, lr}
    ldr    r0, =par
    swi    Swi_Print_String
    ldmfd  sp!, {r0, pc}

eof:
    mov    r0, r2
    swi    Swi_Close_File

    swi    Swi_Exit
    .end
