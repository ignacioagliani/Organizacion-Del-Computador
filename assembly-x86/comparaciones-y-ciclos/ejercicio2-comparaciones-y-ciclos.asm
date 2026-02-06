global main

extern printf

section .data
	n dd 5
	numero dd 5
	resultado dd 1
	str_resultado db "%d! = %d",10,0	
	str_error db "ERROR! No se puede calcular el factorial a un numero negativo",10,0

section .text
factorial:
	mov	eax,[n]
	cmp	eax,0
	jl      es_menor
	jg	es_mayor
	je	es_igual
	ret

es_mayor:
	imul	eax,[resultado]
	mov	[resultado],eax
	dec	dword [n]
	call	factorial

es_igual:
	mov 	eax,0
	ret

es_menor:
	mov	rdi,str_error
	sub	rax,rax
	call	printf
	mov	eax,-1
	ret

main:
	call	factorial
        cmp	eax,-1
	je	fin
	mov     rdi,str_resultado
        mov     rsi,[numero]
        mov     rdx,[resultado]
        sub     rax,rax
        call    printf
	ret
fin:
	ret
section .note.GNU-stack noalloc noexec nowrite progbits;
