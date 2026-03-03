    @ Constantes
    .equ    stdout,1
    .equ    putint,0x6b
    .equ    exit,0x11
    @ Variables
    .data
    vector: .word 11,12,13,14,15,16,17
    @ Codigo
    .text
    .global _start

_start:
    ldr r5,=vector  @ R5 -> Puntero al primer elemento de 'vector'
    mov r6,#7   @ R6 -> Longitud vector
    mov r7,#0   @ R7 -> Offset

loop:
    bl  imprimir  

    sub r6,r6,#1
    cmp r6,#0
    beq fin
    b   loop

imprimir:
	stmfd   sp!, {r0,r1,lr}
    mov r0,#stdout
    ldr r1,[r5,r7]
    add r7,r7,#4

    swi putint

	ldmfd 	sp!, {r0,r1,pc}


fin:
    swi exit
    .end