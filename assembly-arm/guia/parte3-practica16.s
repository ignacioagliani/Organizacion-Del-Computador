    @ Constantes
    .equ    stdout,1
    .equ    putint,0x6b
    .equ    exit,0x11
    @ Variables
    .data
    vector: .word 1,2,3,4
    @ Codigo
    .text
    .global _start

_start:
    ldr r5,=vector  @ R5 -> Puntero al primer elemento de 'vector'
    mov r6,#4   @ R6 -> Longitud vector

loop:
    bl  imprimir

    add r5,r5,#4    @ #4 porque para hay que avanzar 4 bytes
    sub r6,r6,#1    @ Le restamos 1 a len vector
    cmp r6,#0
    beq fin
    b   loop


imprimir:
    stmfd 	sp!,{r0,r1,lr}
    mov r0,#stdout
    ldr r1,[r5]

    swi putint

    ldmfd 	sp!, {r0,r1,pc}

fin:
    swi exit
    .end
