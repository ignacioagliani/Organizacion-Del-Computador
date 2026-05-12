global main

extern puts
extern fopen
extern fread
extern fclose
extern gets
extern printf

section .data

	nombreArchivo    db    "ENCUESTA.DAT",0
	msjErrAbrir      db    "No se puedo abrir archivo!",10,0
	modo             db    "rb",0

	recurso          dw    "**"
	compania         dw    0
	fila             dq    0
	desplazamiento   dq    0
	votos            dq    0
	cantTotalComps   dq    0
	companiaMasElijio db   0
	mensaje          db    "Compania: %d, Votos: %d%%",10,0
	columnaUsuario   dq    0
	totalColumna     dq    0
	porcentaje       dq    0
	matriz           times    40     dw    0 

 	vectorRecursos      db    "IN"
						db    "CO"
						db    "SI"
						db    "LU"

section .bss

	ptrArchivo        resq    1
	registroValido    resb    1
	datoValido        resb    1
	buffer            resb    10

section .text

main:

	; Abro Archivo

	mov		rdi,nombreArchivo
	mov		rsi,modo
	sub		rsp,8
	call	fopen
	add		rsp,8
	cmp		rax,0
	jle		errorApertura
	mov		qword[ptrArchivo],rax

leerRegistro:

	; Proceso Contenido

	mov    rdi,recurso
	mov    rsi,2
	mov    rdx,1
	mov    rcx,qword[ptrArchivo]
	sub    rsp,8
	call   fread
	add    rsp,8
	cmp    rax,0
	jle    finArchivo

	mov    rdi,compania
	mov    rsi,2          ; Leo 2 Por Padding
	mov    rdx,1
	mov    rcx,qword[ptrArchivo]
	sub    rsp,8
	call   fread
	add    rsp,8
	cmp    rax,0
	jle    finArchivo

	; Valido Registro

	sub    rsp,8
	call   VALREG
	add    rsp,8
	cmp    byte[registroValido],'N'
	je     leerRegistro

	; Si llego aca, registros son validos

	sub    rsp,8
	call   escribirMatriz
	add    rsp,8

	; DEBUG - borrar después

	jmp    leerRegistro

finArchivo:

	; Cierro Archivo

	mov    rdi,qword[ptrArchivo]
	sub    rsp,8
	call   fclose
	add    rsp,8

	; Pido Dato a Usuario

	mov    rdi,buffer
	sub    rsp,8
	call   gets
	add    rsp,8

    sub    rsp, 8
    call   recursoUsuario
    add    rsp, 8

	mov    rdi,mensaje
	movsx  rsi, byte[companiaMasElijio]
	mov    rdx,[porcentaje]
	sub    rsp,8
	call   printf
	add    rsp,8

finDePrograma:
	ret

errorApertura:
	mov    rdi,msjErrAbrir
	sub    rsp,8
	call   puts
	add    rsp,8
	jmp    finDePrograma

calcularDesplazamiento:
	mov    rbx,0
	mov    rbx,qword[fila]     ; (fila-1)
	imul   rbx,rbx,20          ; (fila-1) * Cant. Elem. Filas -> 20 = 10 * 2
	                           ; Donde 10 es cantidad de colmunas y 2 la longitud del elemento
	mov    rax,0
	add    ax,[compania]       ; columna
	dec    ax                  ; (columna-1)
	imul   ax,ax,2                ; (columna-1) * Long. Elem
	cwde
	cdqe
	add    rbx,rax             ; (fila-1) * Cant. Elem. Filas + (columna-1) * Long. Elem
	mov    [desplazamiento],rbx
	ret

escribirMatriz:
	sub    rsp,8
	call   calcularDesplazamiento
	add    rsp,8

	mov    r9,matriz
	mov    r10,[desplazamiento]
	xor    rax,rax
	mov    ax,[r9+r10]
	inc    ax
	mov    [r9 + r10],ax
	ret

VALREG:
	mov    byte[registroValido],'N'

	; Valido Recurso

	sub    rsp,8
	call   validarRecurso
	add    rsp,8
	cmp    byte[datoValido],'N'
	je     finValidarRegistro
	
	; Valido Compania

    sub    rsp,8
    call   validarCompania
    add    rsp,8
	cmp    byte[datoValido],'N'
	je     finValidarRegistro

	inc    qword[cantTotalComps]
	mov    byte[registroValido],'S'

finValidarRegistro:
	ret

validarRecurso:
	mov    byte[datoValido],'N'
	mov    qword[fila],0
	mov    rbx,0
	mov    rcx,4    ; Cant. Iteraciones

cicloRecurso:
	push   rcx
	mov    rcx,2
	lea    rsi,[recurso]
	lea    rdi,[vectorRecursos + rbx]
	repe   cmpsb
	pop    rcx

	je     recursoValido
	add    rbx,2
	inc    qword[fila]
	loop   cicloRecurso
	ret

recursoValido:
	mov    byte[datoValido],'S'
    ret

validarCompania:
    mov    byte[datoValido],'N'
	mov    al,byte[compania]
	cmp    al,1
	jl     companiaInvalida
	cmp    al,10
	jg     companiaInvalida
    mov    byte[datoValido],'S'

companiaInvalida:
	ret

recursoUsuario:
	mov ax, word[buffer]

	cmp ax, word[vectorRecursos]
	je  internet
	cmp ax, word[vectorRecursos+2]
	je  compu
	cmp ax, word[vectorRecursos+4]
	je  silla
	cmp ax, word[vectorRecursos+6]
	je  luz

	jmp    opcionInvalida

internet:
    mov    qword[columnaUsuario],0
	jmp    analizarColumna

compu:
    mov    qword[columnaUsuario],1
	jmp    analizarColumna
	
silla:
	mov    qword[columnaUsuario],2
	jmp    analizarColumna
luz:  
    mov    qword[columnaUsuario],3

analizarColumna:
    mov    r14, qword[columnaUsuario]
    imul   r14, r14, 2
    lea    rsi, [matriz + r14]
    mov    rcx, 10                 ; Cant. Iter.

    mov    qword[votos], 0          ; Max votos hasta ahora
    mov    qword[totalColumna], 0 ; total votos columna
    mov    rbx, 1                   ; compania actual (1 a 10)

ciclo:
    xor    rax, rax
    mov    ax,[rsi]              ; votos de esta compania en esa columna

    add    qword[totalColumna], rax  ; acumulo total

    cmp    ax, word[votos]        ; es mayor al maximo?
    jle    noEsMayor

    mov    word[votos], ax        ; actualizo maximo
    mov    byte[companiaMasElijio], bl ; guardo que compania es

noEsMayor:
    inc    rbx
    add    rsi, 20               ; siguiente fila (10 columnas * 2 bytes)
    loop   ciclo

calcularPct:
    xor    rdx,rdx
    mov    rax,qword[votos]
    imul   rax,rax,100
    idiv   qword[totalColumna]
    mov    qword[porcentaje],rax
    ret

finIter:
	ret

opcionInvalida:
    ret
