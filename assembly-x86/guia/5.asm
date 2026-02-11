global main

extern printf

section .data
	vector dd 1,2,3,104,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,-20
	suma dd 0
	msg db "Minimo: %d; Maximo: %d; Promedio: %d",10,0

section .bss
	minimo resd 1
	maximo resd 1
	promedio resd 1

section .text

cambiar_minimo:
	mov	r15d,[vector + r13 * 4]
	mov	dword [minimo], r15d
	inc	r13
	jmp	main.loop

cambiar_maximo:
	mov	r15d,[vector + r13 * 4]
        mov     dword [maximo],r15d
        inc	r13
	jmp     main.loop

calcular_promedio:
        mov     eax, dword [suma]
        cdq
        mov     ebx, 20
        idiv    ebx
        mov     dword [promedio],eax

imprimir_promedio:
        mov     rdi,msg
        mov     esi,dword [minimo]
        mov     edx,dword [maximo]
        mov     ecx,dword [promedio]

        sub     rsp,8
        call    printf
        add     rsp,8

        ret


main:
	mov	r12d,[vector]		; Primer elemento del vector al registro R12d
	mov	dword [minimo],r12d	; Primer elemento como menor
	mov	dword [maximo],r12d	; Primer elemento como mayor
	mov	dword [suma],0		; suma = 1
	
	sub	r13,r13			; r13 = 0
	.loop:
		cmp	r13,20		; si r13 (el contador), llega a 20, fin.
		je	calcular_promedio;
		mov	r14d,[vector + r13*4]	; Guardamos elemento actual en r14d
		add	dword [suma], r14d	; sumamos a 'suma'
		cmp	dword [minimo],r14d	;
		jg	cambiar_minimo		; Si el minimo actual es mayor al elemento que estamos analizando, cambia el minimo.
		cmp	dword [maximo], r14d	;
		jl	cambiar_maximo		; Lo mismo, pero con maximo
		inc	r13
		jmp	.loop


section .note.GNU-stack noalloc noexec nowrite progbits
