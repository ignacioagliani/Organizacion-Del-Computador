    @ Constantes
    
    .equ    fopen,0x66
    .equ    gets,0x6c
    .equ    fclose,0x68
    .equ    putint,0x6b
    .equ    puts,0x02
    .equ    exit,0x11
    .equ    strstdout, 0x69

    @ Variables

    .data
    file:   .asciz "dosEnteros.txt"
    err:    .asciz "Error al abrir archivo\n"
    enter:  .asciz "\n"
    .align

    n1: .word 0
    n2:  .word 0

    filePointer:    .word 0

    @ Codigo

    .text
    .global _start

errorApertura:
    ldr r0,=err
    swi puts
    swi exit

_start:
    @ Abrir
    ldr r0, =file
    mov r1,#0

    swi fopen

    bcs errorApertura

    ldr r1, =filePointer
    str r0, [r1]

    @ Leemos primer numero
    ldr r0,=filePointer
    ldr r0,[r0]

    swi gets

    @ Imprimimos Primer numero
    mov r1,r0
    mov r0,#1

    swi putint

    ldr r0,=n1
    str r1,[r0]

    @ Espacio
    mov r0,#1
    ldr r1,=enter
    swi strstdout

    @ Calculamos su NOT
    ldr r1, =n1
    ldr r1,[r1]
    mov r3,#-1
    eor r1,r1,r3
    mov r0,#1

    swi putint
    
    @ Espacio
    mov r0,#1
    ldr r1,=enter
    swi strstdout

    @ Leemos segundo numero
    ldr r0,=filePointer
    ldr r0,[r0]

    swi gets

    ldr r1,=n2
    str r0,[r1]

    @ Imprimimos segundo numero
    mov r1,r0
    mov r0,#1

    swi putint

    @ Espacio
    mov r0,#1
    ldr r1,=enter
    swi strstdout

    @ Calculamos su NOT
    ldr r1, =n2
    ldr r1,[r1]
    mov r3,#-1
    eor r1,r1,r3
    mov r0,#1

    swi putint

    @ Cerramos archivo
    ldr r0,=filePointer
    ldr r0,[r0]

    swi fclose

    swi exit
    .end
