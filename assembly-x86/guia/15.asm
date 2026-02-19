global main

extern fopen
extern fgets
extern sscanf
extern printf
extern puts
extern fclose

section .data
	msg db "Resultado: suma=%d | cant. validos=%d | cant.invalidos=%d",10,0
	suma dd 0
	validos dd 0
	invalidos dd 0
	formato db "%d",0
	nombre_archivo db "numeros.txt",0
	modo db "r",0
	msg_err_ap db "No se pudo abrir archivo",10,0
	buffer db "********",0

section .bss
	numero resb 4
	puntero_archivo resq 1

section .text
error_apertura:
	mov	rdi,msg_err_ap
        sub     rsp,8
        call    puts
        add     rsp,8
	ret

fin:
	;imprimir resultados
        mov     rdi,msg
        mov     esi,dword [suma]
	mov	edx,dword [validos]
	mov	ecx,dword [invalidos]
        sub     rsp,8
        call    printf
        add     rsp,8

	;cerrar archivo
	mov	rdi,qword[puntero_archivo]
        sub     rsp,8
        call    fclose
        add     rsp,8
	ret

dato_valido:
	sub	rsp,8
	call	valido
	add	rsp,8
	jmp	main.loop

valido:
	inc	dword [validos]
	mov	r15d, dword[numero]
	add	dword [suma],r15d
	ret

dato_invalido:
	inc	dword [invalidos]
	ret

fallo:
        inc     dword [invalidos]
	mov	rax,0
        ret


validar_numeros:
	cmp	byte[buffer],'0'
	jl	fallo
	cmp	byte[buffer],'9'
	jg	fallo
        cmp     byte[buffer+1],'0'
        jl      fallo
        cmp     byte[buffer+1],'9'
        jg      fallo
	cmp     byte[buffer+2],'0'
        jl      fallo
        cmp     byte[buffer+2],'9'
        jg      fallo

	mov	rax,1		;Si salio bien, RAX=1
	ret

main:
	; abrimos archivo
	mov	rdi,nombre_archivo
	mov	rsi,modo
	sub	rsp,8
	call	fopen
	add	rsp,8
	cmp	rax,0			;fopen devuelve 0 si falla
	je	error_apertura
	mov	qword[puntero_archivo],rax

	; leemos archivo
	.loop:
		mov	rdi,buffer
		mov	rsi,4				; Dejamos lugar extra para \0
		mov	rdx,qword[puntero_archivo]

        	sub     rsp,8
        	call    fgets
        	add     rsp,8

		cmp	rax,0
		je	fin

		sub	rsp,8
		call	validar_numeros
		add	rsp,8

		cmp	rax,0
		je	.loop

		; convertimos lo leido de char a int
                mov     rdi,buffer
                mov     rsi,formato
                mov     rdx,numero

                sub     rsp,8
                call    sscanf
                add     rsp,8

		cmp	rax,1
		je	dato_valido

		sub	rsp,8
		call	dato_invalido
		add	rsp,8
		jmp .loop

section .note.GNU-stack noalloc noexec nowrite progbits
