    @ Constantes

    .equ    fopen,0x66
    .equ    gets,0x6c
    .equ    fclose,0x68
    .equ    strstdout,0x69
    .equ    putint,0x6b
    .equ    exit,0x11
    .equ    stdout,1

    @ Variables
    .data
    fileName:   .asciz "entero.txt"
    msgErr: .asciz "No se pudo abrir archivo"
    msgErrNeg:  .asciz "Error! No se puede calcular factorial a negativos"
    enter:  .asciz "\n"
    
    .align

    filePointer:    .word 0
    numero: .word 0

    @ Codigo

    .text
    .global _start

_start:
    @ Abrir
    ldr r0,=fileName
    mov r1,#0

    swi fopen

    bcs errorApertura

    ldr r1,=filePointer
    str r0,[r1]

    @ Leer
    ldr r0,=filePointer
    ldr r0,[r0]

    swi gets

    cmp r0,#0
    blt errNegativo
    cmp r0,#0
    beq ceroFactorial

    ldr r1,=numero
    str r0,[r1]

    @ Calcular Factorial
    mov r5,#1   @ n!
    .loop:
        ldr r3,=numero
        ldr r3,[r3] @ n
        cmp r3,#0
        beq fin

        @ Imprimir
        mov r0,#stdout
        mov r1,r5

        swi putint

        mul r5,r5,r3
        sub r3,r3,#1
        ldr r6,=numero
        str r3,[r6]

        @ Imprimir espacio
        mov r0,#stdout
        ldr r1,=enter
        swi strstdout

        b   .loop

errorApertura:
    mov r0,#stdout
    ldr r1,=msgErr

    swi strstdout

    swi exit

errNegativo:
    mov r0,#stdout
    ldr r1,=msgErrNeg

    swi strstdout

    ldr r0,=filePointer
    ldr r0,[r0]

    swi fclose

    swi exit

ceroFactorial:
    mov r0,#stdout
    mov r1,#1

    swi putint

    ldr r0,=filePointer
    ldr r0,[r0]

    swi fclose

    swi exit

fin:
    ldr r0,=filePointer
    ldr r0,[r0]

    swi fclose

    swi exit
    
    .end
