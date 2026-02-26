@ Constantes
	.equ	puts,	0x02
	.equ	exit,	0x11

@ Variables
	.data
msg1:
	.asciz "Hola"
msg2:
	.asciz "Chau"
enter:
	.asciz "\n"

@ Codigo
	.text
	.global _start

imprimir:
	stmfd sp!, {r0,lr}
	mov	r0,r3
	swi	puts
	ldr	r0, =enter
	swi	puts
	ldmfd sp!, {r0,pc}

_start:
	ldr	r3, =msg1
	bl	imprimir

	ldr	r3, =msg2
	bl	imprimir

	swi	exit
	.end
