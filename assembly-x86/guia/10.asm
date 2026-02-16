global main

extern puts

section .data
	PACK db "123C" ; En base 10 seria 123 positivo
	letra_validas db 'A','B','C','D','E','F'
	RESULT db "N",0

section .text

es_empaquetado:
	sub	eax,eax
	.loop:
		cmp	eax,3
		je	verificar_letra

		cmp	byte [PACK+eax],'0'
		jl	invalido

		cmp	byte [PACK+eax],'9'
		jg	invalido

		inc	eax
		jmp	.loop
	ret

invalido:
	ret

verificar_letra:
	sub	ebx,ebx
	.loop1:
		cmp	ebx,6
		je	invalido
		mov	dl, byte [PACK+eax]
		cmp	dl,byte [letra_validas+ebx]
		je	valido

		inc	ebx
		jmp	.loop1
	ret

valido:
	mov     byte [RESULT],'S'
	ret

main:
	mov	rdi,PACK
	sub	rsp,8
	call	es_empaquetado
	add	rsp,8
	mov	rdi,RESULT
	sub	rsp,8
	call	puts
	add	rsp,8
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
