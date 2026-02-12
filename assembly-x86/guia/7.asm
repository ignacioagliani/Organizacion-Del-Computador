global main

extern printf

section .data
	matriz dd 1,2,3,4,5,6,7,8,9
	i dd 0
	traza dd 0
	msg db "Tr(A)=%d",10,0

section .text
main:
	sub	r14,r14
	.loop:
		cmp	r14,3
		je	imprimir_resultado

		; Calculamos indice: matriz[i][j] = [Dir. Matriz + ÍndiceLineal * Escala]
		; IndiceLineal = i * cant. Cols + j. en este caso, i=j
		mov	eax,dword [i]
		imul	eax,3
		add	eax,dword [i]

		cdqe	; Pasamos valor de eax a rax, asi podemos operar con la dir de memoria de 'matriz'

		mov	ebx, [matriz + rax*4]
		add	dword [traza],ebx
		inc	r14
		inc	dword [i]
		jmp	.loop

imprimir_resultado:
	mov	rdi,msg
	mov	esi,dword [traza]
	sub	rsp,8
	call	printf
	add	rsp,8
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
