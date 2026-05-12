global main

extern puts
extern fopen
extern fread
extern fclose
extern gets
extern printf

section .data

	nombreArch		db	"ENCUESTA.DAT",0
	modo			db	"rb",0
	rec0			dw	"IN"
	rec1			dw	"CO"
	rec2			dw	"SI"
	rec3			dw	"LU"
	mensaje			db	"Para la opcion %s, la compania %d elijio ese recurso con un %d %%",10,0

	fmtRecurso		db	"%s",0
	fmtCompania		db	"%d",0

	abriendoArch	db	"Abriendo Archivo ...",10,0
	errorAbriendo	db	"Ha ocurrido un error al abrir archivo",10,0
	cerrandoArch	db	"Cerrando Archivo",10,0
	invalidoRec		db	"Recurso Invalido",10,0
	leyendoComp		db	"Leyendo Compania",10,0
	invalidaComp	db	"Compania Invalida",10,0
	ingreseRecurso	db	"Ingrese Un Recurso",10,0

	cantidadTotalProcesada			dq 		0

section .bss
	matriz		times	40	resw 1
	ptrArchivo		resq	1
	recursoActual	resw	1
	companiaActual	resb	1

	fila		resq	1
	columna		resb	1

	buffer		resb	16

section .text

main:
	sub		rsp,8
	call	abrirArch
	add		rsp,8

	sub		rsp,8
	call	procesar
	add		rsp,8

	sub		rsp,8
	call	cerrarArch
	add		rsp,8

	sub		rsp,8
	call	solicitarRecurso
	add		rsp,8

	ret

abrirArch:
	mov		rdi,abriendoArch

	sub		rsp,8
	call	puts
	add		rsp,8

	mov		rdi,nombreArch
	mov		rsi,modo

	sub		rsp,8
	call	fopen
	add		rsp,8

	cmp		rax,0
	jle		errorApertura

	mov		qword[ptrArchivo],rax

	ret

errorApertura:
	mov		rdi,errorAbriendo

	sub		rsp,8
	call	puts
	add		rsp,8

	ret

procesar:
	mov		rdi,recursoActual	; Donde se Almacena lo Leido
	mov		rsi,2			; Tamaño Elemento a Leer
	mov		rdx,1			; Cantidad Elementos a Leer
	mov		rcx,[ptrArchivo]	; De que Archivo los lee

	sub		rsp,8
	call	fread
	add		rsp,8

	cmp		rax,0
	je		EOF

	mov		rdi,companiaActual
	mov		rsi,1
	mov		rdx,1
	mov		rcx,[ptrArchivo]

	sub		rsp,8
	call	fread
	add		rsp,8

	cmp		rax,0
	je		EOF

	sub		rsp,8
	call	VALREG
	add		rsp,8

	jmp		procesar

EOF:
	ret

VALREG:
	movzx	rbx, byte[companiaActual]
	dec		rbx	; Columna
	cmp		rbx,0
	jl		campoInvalido
	cmp		rbx,9
	jg		campoInvalido

	mov		ax,[recursoActual]

	cmp		ax,[rec0]
	je		internet

	cmp		ax,[rec1]
	je		compu

	cmp		ax,[rec2]
	je		silla

	cmp		ax,[rec3]
	je		luz

	mov		rax,-1
	ret

internet:
	; A[i][j] = A[( ( i * cnt(j) ) + j ) * sizeof(elemento)]
	inc		word [matriz + rbx * 2]
    inc     qword[cantidadTotalProcesada]

    jmp     finProcesar

compu:
    add     rbx,10
    inc     word [matriz + rbx * 2]
	inc     qword[cantidadTotalProcesada]
    jmp     finProcesar

silla:
    add     rbx,20
    inc     word [matriz + rbx * 2]
	inc     qword[cantidadTotalProcesada]
	jmp		finProcesar

luz:
    add     rbx,30
    inc     word [matriz + rbx * 2]
	inc     qword[cantidadTotalProcesada]

finProcesar:
	mov		rax,1
	ret

campoInvalido:
	mov		rax,-1
	ret

cerrarArch:
	mov		rdi,cerrandoArch

	sub		rsp,8
	call	puts
	add		rsp,8

	mov		rdi,[ptrArchivo]

	sub		rsp,8
	call	fclose
	add		rsp,8

	ret

solicitarRecurso:
	mov		rdi,ingreseRecurso

	sub		rsp,8
	call	puts
	add		rsp,8

	mov		rdi,buffer

	sub		rsp,8
	call	gets
	add		rsp,8

	; Agarro Primeros dos Bytes del Usuario

	sub		rsp,8
	call	obtenerFila
	add		rsp,8

	; RAX Tiene Numero Recurso (Fila)
	imul	rax,10	; i * cnt(j)
	mov		r15,0	; Acumula Cantidad de Ese Recurso
	mov		r14,0	; Guarda el Numero de Compania (Columna)
	mov 	r13,0	; Contador

bucle:
	mov		rbx,0
	cmp		r13,10
	je		imprimirResultados

	; A[i][j] = A[( ( i * cnt(j) ) + j ) * sizeof(elemento)]
	add		rbx,rax
	add		rbx,r13
	imul	rbx,2

	movzx	r11,word[matriz + rbx]	; Cantidad Actual
	cmp		r11,r15
	jg		cambiarMax

	inc		r13
	jmp		bucle

cambiarMax:
	mov		r15,r11
	mov		r14,r13
	inc		r14		; Compania Es Indice+1
	inc		r13
	jmp		bucle

obtenerFila:
	mov		ax,[buffer]

	cmp		ax,[rec0]
	je		raxEn0

	cmp		ax,[rec1]
	je		raxEn1

	cmp		ax,[rec2]
	je		raxEn2

	cmp		ax,[rec3]
	je		raxEn3

	mov		rax,-1	; No lo voy a validar. La consigna no lo indica.
	ret

raxEn0:
	mov		rax,0
	ret

raxEn1:
	mov		rax,1
	ret

raxEn2:
	mov		rax,2
	ret

raxEn3:
	mov		rax,3
	ret

imprimirResultados:
    imul	rax,r15,100
	xor		rdx,rdx
	mov		rbx,[cantidadTotalProcesada]

	cmp		rbx,0
	je		final_error
	
	div		rbx
	; RAX tiene parte entera (porcentaje)

	mov		rdi,mensaje
	mov		rsi,buffer
	mov		rdx,r14
	mov		rcx,rax

	sub		rsp,8
	call	printf
	add		rsp,8

	ret

final_error:
	ret