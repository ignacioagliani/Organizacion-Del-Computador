    @ Constantes

    .equ    stdout,1
    .equ    exit,0x11
    .equ    putint,0x6b

    @ Variables

    .data
    vector: .word 8,4,9,1,4
    long_vector: .word 5
    minimo: .word 0

    @ Codigo
    .text
    .global _start

_start:
    mov r9,#0   @ R9 = Offset
    @ Poner primer elemento de vector como minimo
    ldr r5,=vector
    ldr r5,[r5,r9]
    ldr r6,=minimo
    str r5,[r6]

    @ Actualizar Offset
    add r9,r9,#4

    @ Decrementar longitud

    ldr r7,=long_vector
    ldr r7,[r7]
    sub r7,r7,#1
    ldr r8,=long_vector
    str r7,[r8]

    @ Iterar el resto de los elementos
    ldr r5,=long_vector
    ldr r5,[r5]
    cmp r5,#0
    beq imprimir
    b   loop

loop:
    @ Si llegamos al final, imprimimos
    ldr r5,=long_vector
    ldr r5,[r5]
    cmp r5,#0
    beq imprimir

    ldr r6,=vector  @ R6 = elemento actual vector
    ldr r6,[r6,r9]
    ldr r7,=minimo  @ R7 = minimo
    ldr r7,[r7]
    cmp r6,r7
    
    blt cambiar_minimo  @ if (R6 < R7) -> Actualizar minimo

    @ else -> Avanzar una posicion (Actualizar Offset)
    add r9,r9,#4

    @ Decrementar longitud

    ldr r7,=long_vector
    ldr r7,[r7]
    sub r7,r7,#1
    ldr r8,=long_vector
    str r7,[r8]

    @ y seguir buscando minimo
    b   loop

cambiar_minimo:
    ldr r5,=minimo
    ldr r6,=vector
    ldr r6,[r6,r9]
    str r6,[r5]

    @ Avanzar una posicion
    add r9,r9,#4

    @ Decrementar longitud

    ldr r7,=long_vector
    ldr r7,[r7]
    sub r7,r7,#1
    ldr r8,=long_vector
    str r7,[r8]

    @ y seguir buscando minimo
    b   loop


imprimir:
    ldr r1,=minimo
    ldr r1,[r1]
    mov r0,#stdout

    swi putint

    swi exit

    .end

