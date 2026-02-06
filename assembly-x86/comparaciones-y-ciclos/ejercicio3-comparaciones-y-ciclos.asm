global main

extern printf
extern gets

section .data
	vector db 'a','b','c',0	; Creo mi vector de caracteres
	str_indice db "%d",10,0

section .bss
	buffer resb 10		; Reservo 10 bytes para el usuario
	letra_usuario resb 1	; Reservo 1 bytes para la letra

section .text
pedir_usuario:	
	mov	rdi,buffer	; Pongo como parametro de gets el buffer
	call	gets
	mov	al,[buffer]	; Uso AL (registro de 1 byte) para almacenar el primer caracter
	mov	[letra_usuario],al ; Guardo caracter en 'letra_usuario'
	ret

buscar_elemento:
	sub	rcx,rcx		; RCX va a hacer las veces de indice. Lo inicio en 0
	
	.loop:
	mov	al, [vector + rcx]; Vemos si se llego al final del vector
	cmp	al,0
	je	fin

	cmp	al,byte[letra_usuario]; Letra del vector es igual a la del usuario?
	je	encontrada

	inc	rcx		; rcx += 1
	jmp	.loop

fin:
	mov	rcx,-1	
	ret

encontrada:
	ret
main:
	call	pedir_usuario
	call	buscar_elemento
	mov	rdi,str_indice
	mov	rsi,rcx
	sub	rax,rax
	call	printf
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
