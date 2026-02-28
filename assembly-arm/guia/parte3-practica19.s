    @ Constantes

    .equ    exit,0x11
    .equ    putint,0x6b
    .equ    stdout,1

    @ Variables
    
    .data
    vector: .word   1,2,3,4,5,6,7,8,9

    @ Codigo
    .text
    .global _start

_start:
    ldr r5,=vector  @ Puntero primer elemento vect
    mov r6,#9   @ Len(vect)
    mov r7,#0   @ Offset

loop:
    bl  imprimir

    sub r6,r6,#1
    cmp r6,#0
    beq fin
    b   loop

imprimir:
  	stmfd 	sp!, {r0,r1,lr}

    mov r0,#stdout
    ldr r1,[r5,r7, LSL #2] @ r1 = r5[r7×4]
    add r7,r7,#1

    swi putint

    ldmfd 	sp!, {r0,r1,pc}

fin:
    swi exit
    .end