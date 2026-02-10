global main

extern puts

section .data
	mensaje db "Organizacion del Computador",0

section .text
main:
	mov	rdi,mensaje
	sub	rsp,8
	call	puts
	add	rsp,8
	ret
section .note.GNU-stack noalloc noexec nowrite progbits
