global main

extern printf

section .data
	n1 dd 10
	n2 dd 20
	es_mayor db "%d es mayor que %d",10,0
	es_menor db "%d es menor que %d",10,0
	igual db "Los numeros son iguales",10,0	

section .bss

section .text

; Dados dos numeros 'n1' y 'n2', hacer una funcion que imprima la comparacion.
comparar_numeros:
	mov	eax,[n1]
	mov	ebx,[n2]
	cmp	eax,ebx
	je	iguales
	jg	mayor
	jl	menor

iguales:
	mov	rdi,igual
	sub	rsp,8
	call	printf
	add	rsp,8
	ret

mayor:
	mov	rdi,es_mayor
	mov	rsi,[n1]
	mov	rdx,[n2]
	sub	rsp,8
	call	printf
	add	rsp,8
	ret

menor:
	mov	rdi,es_menor
	mov	rsi,[n1]
	mov	rdx,[n2]
	sub	rsp,8
	call	printf
	add	rsp,8
	ret

main:
	sub	rsp,8
	call	comparar_numeros
	add	rsp,8
	ret
section .note.GNU-stack noalloc noexec nowrite progbits;
