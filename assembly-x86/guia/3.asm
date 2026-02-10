global main

extern printf

section .data
	x dd 3
	y dd -3
	mensaje db "%d ^ %d = %d/%d",10,0	;Mensaje de impresion (lleva fraccion por lo negativos. Si el resultado es positivo, el denominador va a ser 1)

section .bss
	unsigned_y_menos_uno resb 4
	numerador resb 4
	denominador resb 4
	resultado resb 4

section .text
main:
	mov	eax, dword[x]
	mov	dword [resultado],eax
	sub	rsp,8
	call	analizar_signo_potencia
	add	rsp,8
	mov	rdi,mensaje
	mov	esi,dword [x]	; En vez de usar RSI, se usa la parte de 32bits del registro RSI. Lo mismo para RDX,ECX y R8.
	mov	edx,dword [y]
	mov	ecx,dword [numerador]
	mov	r8d,dword [denominador]
	sub	rsp,8
	call	printf
	add	rsp,8
	ret

analizar_signo_potencia:
	mov	eax, dword[y]
	cmp	eax,0
	je	cero
	jg	mayor
	jl	menor
	ret

mayor:
	mov	eax, dword[y]
	dec	eax
	mov	dword [unsigned_y_menos_uno],eax
	sub	rsp,8
	call	potencia
	add	rsp,8
	mov	eax,dword [resultado]
	mov	dword [numerador],eax
	mov	dword [denominador],1
	ret

cero:
	mov	dword [numerador],1
	mov	dword [denominador],1
	ret
menor:
	mov	eax,dword[y]
	imul	eax,-1
	dec	eax
	mov	dword [unsigned_y_menos_uno],eax
	sub	rsp,8
	call	potencia
	add	rsp,8
	mov	ebx, dword[resultado]
	mov	dword [numerador], 1
	mov	dword [denominador],ebx
	ret
potencia:
	sub	rcx,rcx		;Se inicia contador en 0.
	.loop:
		mov	eax,dword [unsigned_y_menos_uno]	;se carga en registro de 32bits, pero se extiende a 64bits en RAX para poder ser comparado con RCX
		cmp	rcx,rax
		je	fin

		mov	ebx,dword [resultado]
		mov	edx,dword [x]
		imul	edx,ebx
		mov	dword [resultado], edx
		inc	rcx
		jmp	.loop

fin:
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
