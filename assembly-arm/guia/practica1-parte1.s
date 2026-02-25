@ Constantes
	.equ 	puts,	0x02
	.equ	exit,	0x11

@Variables
	.data
msg:
	.asciz "Hola Mundo"

@Codigo
	.text
	.global _start
_start:
	ldr	r0, =msg	@ Con = pasas direccion de momoria. Sin = pasas contenido
	swi	puts
	swi	exit
	.end
