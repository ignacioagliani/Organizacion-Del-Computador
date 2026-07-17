    .equ    Swi_Print_String, 0x02
    .equ    Swi_Exit, 0x11

    .data
        str1:    .asciz    "Primer Cadena\n"
        str2:    .asciz    "Segunda Cadena\n"
        str3:    .asciz    "Tercer Cadena\n"
    .text
    .global _start
_start:
    ldr    r2, =str1
    bl     imprimir
    ldr    r2, =str2
    bl     imprimir
    ldr    r2, =str3
    bl     imprimir
    
    swi    Swi_Exit

imprimir:
    stmfd  sp!, {r0,r1,lr}
    mov    r0, r2
    mov    r1, #0
    swi    Swi_Print_String
    ldmfd  sp!, {r0,r1,pc}
    .end
