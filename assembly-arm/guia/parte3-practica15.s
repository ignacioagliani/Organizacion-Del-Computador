    @ Constantes
    .equ    stdout,1
    .equ    putint,0x6b
    .equ    exit,0x11
    @ Variables
    .data
    n1: .word 1
    n2: .word 3
    @ Codigo
    .text
    .global _start

_start:
    @ Imprimimos n1 viejo
    ldr r1,=n1
    ldr r1,[r1]
    mov r0,#stdout

    swi putint

    @ Imprimimos n2 viejo

    ldr r1,=n2
    ldr r1,[r1]
    mov r0,#stdout

    swi putint

    @ Modificamos n1. Ahora vale 9

    mov r3,#9
    ldr r1,=n1
    str r3,[r1]

    @ Modificamos n2. Ahora vale 7

    mov r3,#7
    ldr r1,=n2
    str r3,[r1]

    @ Imprimimos n1 nuevo

    ldr r1,=n1
    ldr r1,[r1]
    mov r0,#stdout

    swi putint

    @ Imprimimos n2 nuevo

    ldr r1,=n2
    ldr r1,[r1]
    mov r0,#stdout

    swi putint    

    @ Aclaración: para simplificar, los numeros van a quedar uno al
    @ lado del otro. En el standard output van a ver: 1397

    @ Fin

    swi exit
    .end