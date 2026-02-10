global main

extern sscanf
extern gets
extern puts
extern printf

section .data
	formato_ingreso db "%d",0
	mensaje_error db "Algo salio mal. No se pudieron leer 15 numeros",10,0
	max_numeros dd 15
	msg_err_conv db "ERROR: no se pudo convertir a entero",10,0
	msg_imprimir db "%d  ",0
	i db 0
	j db 0

section .bss
	buffer resb 16
	vector resd 15
	cant_numeros resd 1
	numero resd 1
	minimo resd 1
	
	
section .text
main:
	sub	rsp,8
	call	pedir_numeros
	add	rsp,8
	mov	eax, dword[cant_numeros]
	cmp	eax,15
	je	ordenar
	jl	error
	ret

ordenar:
	.loop1:	
		mov	eax,dword[i]
		cmp	eax,dword [max_numeros]
		je	imprimir
		mov     dword [j],0 
		.loop2:
			mov	r12d,dword [j]
			mov	r13d,dword [max_numeros]
			dec	r13d
			cmp	r12d,r13d
			je	incrementar_i
			
			mov	r14d,dword [vector + r12*4]
			mov	r15d,dword [vector + r12*4 + 4]
			cmp	r14d,r15d
			jg	swap
			
			inc	r12d
			mov	dword [j],r12d
			jmp	.loop2		
		jmp	.loop1

	sub	rsp,8
	call	imprimir
	add	rsp,8
	ret

swap:
	mov	dword[vector + r12*4],r15d
	mov	dword[vector + r12*4 +4],r14d
        inc     r12d
        mov     dword [j], r12d
	jmp	ordenar.loop2

incrementar_i:
	 inc     eax
         mov     dword [i],eax
         jmp	ordenar.loop1

imprimir:
	sub	r12d,r12d
	.loop:
		cmp	r12d,dword [max_numeros]
		je	fin
		
		mov	r10d,[vector + r12*4]
		mov	dword [numero],r10d

		mov	rdi,msg_imprimir
		mov	esi,[numero]
		sub	rsp,8
		call	printf
		add	rsp,8		

		inc	r12d
		jmp	.loop

error:
	mov	rdi,mensaje_error
	sub	rsp,8
	call	puts
	add	rsp,8
	ret

pedir_numeros:
	.loop:
		mov	r12d,dword [cant_numeros]
		mov	edx,dword [max_numeros]
		cmp	r12d,edx
		je	fin

		mov	rdi,buffer
        	sub     rsp,8
		call	gets
        	add     rsp,8
		
		mov	rdi,buffer
		mov	rsi,formato_ingreso
		mov	rdx,numero
		sub	rsp,8
		call	sscanf
		add	rsp,8
		cmp	rax,0
		je	error_conversion
		
		mov	eax, dword[numero]
		mov	[vector + r12d*4],eax
		
		inc	r12d
		mov	dword [cant_numeros],r12d
		jmp	.loop

error_conversion:
	mov	rdi,msg_err_conv
	sub	rsp,8
	call	puts
	add	rsp,8
	ret

fin:
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
