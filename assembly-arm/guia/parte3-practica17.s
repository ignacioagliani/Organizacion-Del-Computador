    @ Constantes
    .equ    stdout,1
    .equ    putint,0x6b
    .equ    exit,0x11
    @ Variables
    .data
    vector: .word 5,6,7,8
    @ Codigo
    .text
    .global _start

_start:
    ldr r5,=vector  @ R5 -> Puntero al primer elemento de 'vector'
    mov r6,#4   @ R6 -> Longitud vector

loop:
    bl  imprimir

    sub r6,r6,#1
    cmp r6,#0
    beq fin
    b   loop

imprimir:
    stmfd 	sp!,{r0,r1,lr}
    mov r0,#stdout
    ldr r1,[r5],#4
    
    swi putint
    
    ldmfd 	sp!, {r0,r1,pc}

fin:
    swi exit
    .end