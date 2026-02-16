global main

extern puts

section .data
	MES db 1
	meses_validos db 1,2,3,4,5,6,7,8,9,10,11,12
	RESULT db "N",0

section .text
validar_mes:
	sub	eax,eax
	.loop:
		cmp	eax,12
		je	fin

		mov	bl, byte [meses_validos + eax]
		cmp	bl,dil				; compara con parametro dil
		je	valido

		inc	eax
		jmp	.loop

fin:
	ret

valido:
	mov	byte [RESULT],'S'
	ret

main:
	mov	dil,byte[MES]
	sub	rsp,8
	call	validar_mes
	add	rsp,8
	mov	rdi, RESULT
        sub     rsp,8
        call    puts
        add     rsp,8
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
