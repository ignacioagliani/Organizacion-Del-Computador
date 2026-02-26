    @ Constantes

    .equ    fopen,0x66
    .equ    gets,0x6c
    .equ    fclose,0x68
	.equ	putint,	0x6b
	.equ	exit,	0x11
    .equ    strstdout, 0x69

    @ Variables
    .data

    nombreArchivo:  .asciz "entero.txt"
    msgErrOpen: .asciz "Error abrir archivo"
    .align
    punteroArchivo: .word 0

    @ Codigo
    .text
    .global _start

error:
    mov r0,#1
    ldr r1,=msgErrOpen
    swi strstdout
    swi exit

_start:
    @ abrir

    ldr r0,=nombreArchivo
    mov r1,#0

    swi fopen

    bcs error

    ldr r1,=punteroArchivo
    str r0,[r1]

    @ Leer digito

    ldr r0,=punteroArchivo
    ldr r0,[r0]

    swi gets

    @ Si numero (R1) es menor a 0, R2 vale -1. Sino, vale 1
    mov r2,#1
    mov r1,r0   @ R1 tiene numero archivo
    cmp r1,#0
    movmi   r2,#-1
    mul r1,r1,r2
    
    @ Imprimir
    mov r0,#1
    @ R1 ya tiene numero a imprimir
    swi putint

    @ Cerrar archivo

    ldr r0,=punteroArchivo
    ldr r0,[r0]

    swi fclose

    swi exit
    .end