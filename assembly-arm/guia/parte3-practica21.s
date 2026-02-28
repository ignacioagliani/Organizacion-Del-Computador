    @ Constantes

    .equ    stdout,1
    .equ    exit,0x11
    .equ    putint,0x6b
    .equ    strstdout,0x69

    @ Variables

    .data
    corchAb:    .asciz "[ "
    coma:    .asciz ", "
    corchCerr:    .asciz "]\n"
    .align
    vector: .word 2,4,6,8
    long_vector: .word 4
    valor: .word 1
    vector_suma:    .word 0,0,0,0
    @ Resultado final: [ 3, 5, 7, 9, ]

    @ Codigo
    .text
    .global _start

_start:
    @ Imprimir corchete apertura
    mov r0,#stdout
    ldr r1,=corchAb
    swi strstdout
    mov r9,#0   @ R9 = Offset

    b   iterar

iterar:
    mov r8,#0   @ R8 -> i = 0
    ldr r6,=valor   @ R6 -> valor = 1
    ldr r6,[r6]
    loop:
        ldr r7,=long_vector @ R7 -> len = 4
        ldr r7,[r7]
        cmp r8,r7   @ if (i == len)
        beq imprimir @ Termina

        ldr r5,=vector
        ldr r5,[r5,r9]  @ R5 = vector[i]
        add r5,r5,r6    @ R5 += valor
        ldr r4,=vector_suma
        str r5,[r4,r9] @ vector_suma[i] = R5
        add r9,r9,#4    @ R9 += 4
        add r8,r8,#1    @ R8 += 1
        b   loop

fin:
    @ Imprimir corchete cierre
    mov r0,#stdout
    ldr r1,=corchCerr
    swi strstdout

    swi exit

imprimir:
    mov r9,#0
    mov r8,#0
    ldr r7,=long_vector
    ldr r7,[r7]
    loopImprimir:
        cmp r8,r7
        beq fin @ Termina

        ldr r5,=vector_suma
        ldr r5,[r5,r9]
        mov r1,r5
        mov r0,#stdout

        swi putint

        add r8,r8,#1
        add r9,r9,#4

        @ Imprimir coma
        mov r0,#stdout
        ldr r1,=coma
        swi strstdout

        b   loopImprimir
    .end