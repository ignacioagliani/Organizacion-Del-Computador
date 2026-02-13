global main

extern printf

; La verdad, mucho no entendi lo que pide el ejercicio. Supongo que pide
; imprimir la diagonal empezando en a_15 hasta a_51.

section .data
	i dd 0
	j dd 4
	msg db "%d  ",0
	matriz dd 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25

section .bss
	diagonal resd 5

section .text
main:
	sub	edx,edx
	.loop:
		cmp	edx,5
		je	imprimir

		; Indice Lineal (eax = i x cant col + j)
		mov	eax,dword [i]
		imul	eax,5
		add	eax,dword [j]

		cdqe

		mov	ecx, [matriz + rax*4]
		mov	[diagonal + edx*4],ecx
		inc	edx
		inc	dword [i]
		dec	dword [j]
		jmp	.loop

imprimir:
	sub	r15,r15
	.loop:
		mov     rdi,msg
		cmp	r15,5
		je	fin
		mov	rsi,[diagonal + r15*4]
		sub	rsp,8
		call	printf
		add	rsp,8
		inc	r15
		jmp	.loop

fin:
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
