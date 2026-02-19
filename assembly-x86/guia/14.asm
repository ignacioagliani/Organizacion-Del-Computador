global main

extern printf

section .data
	DIR1 dw 0xF
	DIR2 dw 0xA
	RESULT dw 0
	msg db "%d",10,0

section .text
sumar:
	mov	ax,[rdi]
	mov	bx,[rsi]
	add	word[RESULT],ax
	add	word[RESULT],bx
	ret

main:
	mov	rdi,DIR1
	mov	rsi,DIR2
	sub	rsp,8
	call	sumar
	add	rsp,8
	mov	rdi,msg
	movzx	rsi,word[RESULT]	;mueve RESULT de 16bits a rsi de 64bits, llenando con ceros a izquierda
	sub	rsp,8
	call	printf
	add	rsp,8
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
