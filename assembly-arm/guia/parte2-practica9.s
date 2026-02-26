    @ Constantes

    .equ    fopen,0x66
    .equ    gets,0x6c
    .equ    fclose,0x68
    .equ    strstdout,0x69
    .equ    putint,0x6b
    .equ    exit,0x11

    @ Variables

    .data
    nombreArchivo:  .asciz "dosEnteros.txt"
    mensajeErrApertura: .asciz "Archivo no Encontrado. Try again! Insert Coin."
    msgMinimo:  .asciz "Min: "
    msgMaximo:  .asciz "Max: "
    enter:  .asciz "\n"
    .align

    n1: .word 0
    n2: .word 0
    punteroArchivo: .word 0

    @ Codigo
    .text
    .global _start

errorAbrir:
    mov r0,#1
    ldr r1,=mensajeErrApertura

    swi strstdout

    swi exit


n1Mayor:
    mov r5,r1
    mov r6,r2

    mov r0,#1
    ldr r1,=msgMinimo

    swi strstdout

    mov r0,#1
    mov r1,r6

    swi putint

    mov r0,#1
    ldr r1,=enter

    swi strstdout

    @ Max

    mov r0,#1
    ldr r1,=msgMaximo

    swi strstdout

    mov r0,#1
    mov r1,r5

    swi putint

    mov r0,#1
    ldr r1,=enter

    swi strstdout

    @ Cerrar
    ldr r0,=punteroArchivo
    ldr r0,[r0]

    swi fclose

    @ Fin
    swi exit


_start:
    @ Abrir arcgivo
    ldr r0,=nombreArchivo
    mov r1,#0

    swi fopen

    bcs errorAbrir

    ldr r1,=punteroArchivo
    str r0,[r1]

    @ Leer primer entero

    ldr r0,=punteroArchivo
    ldr r0,[r0]

    swi gets

    ldr r1,=n1
    str r0,[r1]

    @ Leer segundo entero

    ldr r0,=punteroArchivo
    ldr r0,[r0]

    swi gets

    ldr r1,=n2
    str r0,[r1]

    @ Comparar

    ldr r1,=n1
    ldr r1,[r1] @ R1 tiene a n1
    ldr r2,=n2
    ldr r2,[r2] @ R2 tiene a n2

    cmp r1,r2
    bgt n1Mayor

    @ Imprimir

    @ Muevo a n1 y n2 de registro porque swi los modifica
    mov r5,r1
    mov r6,r2

    mov r0,#1
    ldr r1,=msgMinimo

    swi strstdout

    mov r0,#1
    mov r1,r5

    swi putint

    mov r0,#1
    ldr r1,=enter

    swi strstdout

    @ Max

    mov r0,#1
    ldr r1,=msgMaximo

    swi strstdout

    mov r0,#1
    mov r1,r6

    swi putint

    mov r0,#1
    ldr r1,=enter

    swi strstdout

    @ Cerrar
    ldr r0,=punteroArchivo
    ldr r0,[r0]

    swi fclose

    @ Fin
    swi exit
    .end