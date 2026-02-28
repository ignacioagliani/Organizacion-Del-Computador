    @ Constantes
    .equ    putint,0x6b
    .equ    exit,0x11
    .equ stdout,1
    @ Veriables

    .data

    @ Codigo

    .text
    .global _start

fin:
    swi exit

_start:
    sub r1,r1,r1
    .loop:
        cmp r1,#10
        beq fin

        mov r0,#stdout
        swi putint
        add r1,r1,#1
        b   .loop
    .end
