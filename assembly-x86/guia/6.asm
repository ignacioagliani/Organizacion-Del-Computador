global main

extern printf

section .data
	vector dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30
	indice_ultimo dd 29
	msg db "%d  ",0

section .text
main:
	sub	r15,r15					; contador = 0
	.loop:
		cmp	r15,16
		je	imprimir_resultado

		mov	eax,dword [vector + r15*4]	; eax tiene elemento 0
		
		mov	ecx,dword[indice_ultimo]
		mov	ebx,dword [vector + ecx*4]	; ebx tiene al ultimo

		mov	dword [vector + r15*4], ebx	; se invierten elementos
		mov	dword [vector + ecx*4], eax

		dec	ecx				; se actualizan indices
		mov	dword[indice_ultimo],ecx
		inc	r15

		jmp	.loop



imprimir_resultado:
	sub	r14,r14
	.loop:
		cmp	r14,30
		je	fin

		mov	rdi,msg
		mov	esi,dword [vector + r14*4]
		sub	rsp,8
		call	printf
		add	rsp,8
		inc	r14
		jmp	.loop

fin:
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
