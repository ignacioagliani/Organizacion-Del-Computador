global main

extern puts

section .data
	DIA db "LU"
	dias_validos db "LU","MA", "MI", "JU", "VI", "SA", "DO"
	RESULT db "N",0

section .text
validar_dia:
	sub	eax,eax				;int contador = 0;
	.loop:					;for (;;) {
		cmp	eax,7			;if (contador == 7) {
		je	fin			;return fin}

		mov	rcx,2			;Comparar dos bytes
		mov	rsi,DIA			;de rsi con
		mov	rdi,dias_validos	;dos bytes de rdi
		repe	cmpsb
		je	valido			;si es igual anda a 'valido'

		inc	eax			;contador++
		jmp	.loop

fin:
	ret

valido:
	mov	byte [RESULT],'S'		;el primer byte de RESULT pasa a ser 'S'
	ret
main:
	mov	rdi,DIA
	sub	rsp,8
	call	validar_dia
	add	rsp,8
	mov	rdi,RESULT
	sub	rsp,8
	call	puts
	add	rsp,8
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
