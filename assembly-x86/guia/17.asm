global main

extern sscanf
extern printf
extern fopen
extern fclose
extern fgets
extern puts

;Archivo que voy a usar como ejemplo:

;Los Galacticos       12 125C 098F
;Rayos Villa Tachito  10 112A 105E
;Pibes del Barrio     08 089F 120C
;Club Atletico Sur    15 140E 084A
;Halcones del Norte   06 075E 110A
;	^                  ^   ^   ^
;     Equipo       Rtado  Fav  Contra 

section .data
	msg db "Campeon: %s | Part. Ganados: %hd | Part. Perdidos: %hd | Diferencia de Tantos: %hd",10,0
	formato db "%20c %hd %4c %4c",0
	;Cant Ganados -> Cada bits de resultado es un doparti, 1 si gano, 0 si perdio
	nombre_archivo db "partidos.txt",0
	lectura db "r",0
	msg_err_open db "No se pudo abrir archivo",0
	msg_invalidos db "Archivo con info invalida",0
	formato_numero db "%hd",0
section .bss
	; Info equipo ganador
	buffer resb 128
	equipo resb 21
	resultado resw 1
	a_favor resw 1
	en_contra resw 1
	a_favorString resb 5
	en_contraString resb 5

	puntero_archivo resq 1
	diferencia_tantos resw 1
	ganados resw 1
	perdidos resw 1

	; Info equipos para usar sscanf
	equipo_siguiente resb 21
	rtado resw 1
	aFavor resw 1
	enContra resw 1
	diffTantos resw 1
	ganadosSiguiente resw 1
	perdidosSiguiente resw 1

	aFavorString resb 5
	enContraString resb 5
	decimal resw 1
section .text
error_apertura:
	mov		rdi,msg_err_open
	sub		rsp,8
	call	puts
	add		rsp,8
	ret

convertir_empaquetado_decimal:
; Precondicion: Cargar emp en r15 
; Postcondicion: Lo devuelve en r14w
	mov		rdi,r15
	mov		rsi,formato_numero
	mov		rdx,decimal

	sub		rsp,8
	call	sscanf	; como el numero termina en letra, la ignora
	add		rsp,8

	mov		r14w, word[decimal]
	ret

fin_archivo:
; imprimir datos y cerrar archivo
	mov		rdi,msg
	mov		rsi,equipo
	movzx	rdx,word[ganados]
	movzx	rcx,word[perdidos]
	movzx	r8,word[diferencia_tantos]
    sub     rsp,8
    call	printf
    add     rsp,8

	mov		rdi, qword[puntero_archivo]
	sub		rsp,8
	call	fclose
	add		rsp,8
	ret

datos_invalidos:
	mov		rdi,msg_invalidos
	sub		rsp,8
	call	puts
	add		rsp,8
	ret

fin:
	ret

calcular_ganados_perdidos:
; Precondicion: resultado = tira de 1 y 0 que indican el resultado
; cargado en r13w
; Postcondicion: carga ganados en r15w y perdidos en r14w
	sub		r15w,r15w	;ganados = 0
	sub		r14w,r14w	;perdidos = 0
	sub		r12,r12
	.loop:
		cmp		r12,16
		je		fin

		sub		rax,rax
		mov		ax,r13w
		and		ax,1b	;ax = digito

		cmp		ax,1
		je		aumentar_ganado
		jl		aumentar_perdido

aumentar_ganado:
	inc		r15w
	inc		r12
	shr     r13w,1  ;muevo a la derecha un digito de resultado
	jmp		calcular_ganados_perdidos.loop

aumentar_perdido:
	inc		r14w
	inc		r12
	shr     r13w,1
	jmp 	calcular_ganados_perdidos.loop

modificar_campeon:
; Cambiar nombre
	mov		rcx,21
	lea		rsi,[equipo_siguiente]
	lea		rdi,[equipo]
	rep		movsb
        
;Cambiar resultado
    mov     rcx,2
    lea     rsi,[rtado]
    lea     rdi,[resultado]
    rep		movsb

;Cambiar a favor
    mov     rcx,2
    lea     rsi,[aFavor]
    lea     rdi,[a_favor]
    rep     movsb

;Cambiar en contra
    mov     rcx,2
    lea     rsi,[enContra]
    lea     rdi,[en_contra]
    rep     movsb

;Cambiar diferencia tantos
    mov     rcx,2
    lea     rsi,[diffTantos]
    lea     rdi,[diferencia_tantos]
    rep     movsb

;Cambiar ganados y perdidos (?)
    mov     rcx,2
    lea     rsi,[ganadosSiguiente]
    lea     rdi,[ganados]
    rep     movsb

    mov     rcx,2
    lea     rsi,[perdidosSiguiente]
    lea     rdi,[perdidos]
    rep     movsb

	jmp     main.loop

main:
; Abrir archivo
	mov		rdi,nombre_archivo
	mov		rsi,lectura
	sub		rsp,8
	call	fopen
	add		rsp,8

	cmp		rax,0
	je		error_apertura

	mov	qword[puntero_archivo], rax
; Leer linea
	mov		rdi,buffer
	mov		rsi,40		
	mov		rdx,qword[puntero_archivo]

	sub		rsp,8
	call	fgets
	add		rsp,8

	cmp		rax,0
	je		fin_archivo

; Obtener datos
	mov		rdi,buffer
	mov		rsi,formato
	mov		rdx,equipo
	mov		rcx,resultado
	mov		r8,a_favorString
	mov		r9,en_contraString

	sub		rsp,8
	call	sscanf
	add		rsp,8

	cmp	rax,4
	jl	datos_invalidos

; Cargar Primeros datos:
	mov	byte[equipo+20],0		;pongo \0 en equipo

	mov		r15,a_favorString
	sub		rsp,8
	call	convertir_empaquetado_decimal	; saco la letra del empaquetado
	add		rsp,8
	mov		word [a_favor],r14w	

	mov		r15,en_contraString
	sub		rsp,8
	call	convertir_empaquetado_decimal	; saco la letra del empaquetado
	add		rsp,8
	mov		word [en_contra],r14w	

	mov		ax,word [a_favor]
	mov		bx,word [en_contra]
	sub		ax,bx
	mov		word [diferencia_tantos],ax

	mov		r13w,word[resultado]
	sub		rsp,8
	call	calcular_ganados_perdidos
	add		rsp,8

	mov		word [ganados],r15w
	mov		word [perdidos],r14w

	.loop:
; Leemos el resto del archivo
	        mov     rdi,buffer
	        mov     rsi,40          
	        mov     rdx,qword[puntero_archivo]

	        sub     rsp,8
        	call    fgets
	        add     rsp,8

        	cmp     rax,0
	        je      fin_archivo

	        mov     rdi,buffer
	        mov     rsi,formato
	        mov     rdx,equipo_siguiente
	        mov     rcx,rtado
	        mov     r8,aFavorString
	        mov     r9,enContraString

	        sub     rsp,8
	        call    sscanf
	        add     rsp,8

	        cmp     rax,4
	        jl     datos_invalidos

			mov		r15,aFavorString
			sub		rsp,8
			call	convertir_empaquetado_decimal	; saco la letra del empaquetado
			add		rsp,8
			mov		word [aFavor],r14w	

			mov		r15,enContraString
			sub		rsp,8
			call	convertir_empaquetado_decimal	; saco la letra del empaquetado
			add		rsp,8
			mov		word [enContra],r14w	

			mov		ax,word [aFavor]
			mov		bx,word [enContra]
			sub		ax,bx
			mov		word [diffTantos],ax

	mov		r13w,word[rtado]
	sub		rsp,8
	call	calcular_ganados_perdidos
	add		rsp,8

	mov		word [ganadosSiguiente],r15w
	mov		word [perdidosSiguiente],r14w

; Averiguar cantidad partidos ganados. Si es mayor al campeon actual,
; lo cambio.
	mov		r12w, word[ganados]	;r12 tiene la canidad de part. ganados del actual campeon
	cmp     r15w,r12w	;r15 tiene los partidos ganados del equipo que estamos analizando
	jg		modificar_campeon
	jmp		.loop

section .note.GNU-stack noalloc noexec nowrite progbits
