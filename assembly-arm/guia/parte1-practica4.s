    @ Constantes

    .equ    fopen,0x66
    .equ    gets,0x6c
    .equ    fclose,0x68
    .equ    putint,0x6b
    .equ    puts,0x02
    .equ    exit,0x11

    @ Variables

    .data
nombreArchivo:  .asciz "entero.txt"
msgError:   .asciz "Error al abrir archivo!"
.align
leido:  .word 0
punteroArchivo: .word 0

    @ Codigo

    .text
    .global _start


errorApertura:
    ldr r0,=msgError
    swi puts
    swi exit

_start:
    @ Abrir
    ldr r0,=nombreArchivo
    mov r1,#0   @ #0 es modo entrada
    
    swi fopen
    @ Devuelve FILE* en R0 si sale bien.
    @ Si sale mal, setea el flag Carry

    @ BCS -> Branch if Carry Set: Bifurca a errorApertura
    bcs errorApertura
    ldr r1, =punteroArchivo
    str r0,[r1] @ str -> Store Register. Guarda lo que está en R0 en la direccion de memoria de R1

    @ Leer
    ldr r0,=punteroArchivo  @ Guarda en R0 el puntero
    ldr r0,[r0] @ Guarda en R0 lo apuntado por puntero archivo
    swi gets
    // Guarda el numero en R0 el numero leido
    ldr r1,=leido
    str r0,[r1]

    @ Imprimir
    mov     r0, #1           @ Destino: Pantalla
    ldr     r1, =leido          @ Valor: El número que quieres ver
    ldr     r1,[r1]
    swi     putint             @ Llamada a imprimir entero

    @ Cerrar
    ldr r0,=punteroArchivo  @ Guarda en R0 el puntero
    ldr r0,[r0] @ Guarda en R0 lo apuntado por puntero archivo
    swi fclose

    swi exit
    .end
