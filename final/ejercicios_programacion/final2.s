    .equ    Swi_Open_File, 0x66
    .equ    Swi_Read_Int, 0x6C
    .equ    Swi_Close_File, 0x68
    .equ    Swi_Print_Int, 0x6B
    .equ    Swi_Exit, 0x11

    .data

        filename:    .asciz    "numeros.txt"

    .text
    .global _start

_start:
    @ R2 -> Ptr. Archivo; R3 -> Productoria
    ldr    r0, =filename
    mov    r1, #0

    swi    Swi_Open_File

    mov    r2, r0
    mov    r3, #1
    
loopLeer:
    mov    r0, r2
    swi    Swi_Read_Int
    bcs    eof

    cmp    r0, #0
    mulge  r3, r3, r0

    b      loopLeer

eof:
    @ Cerrar archivo, imprimir y salir
    mov    r0, r2
    swi    Swi_Close_File

    mov    r0, #1
    mov    r1, r3
    swi    Swi_Print_Int

    swi    Swi_Exit
    .end
