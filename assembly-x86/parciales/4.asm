global main

extern fopen
extern fread
extern fclose
extern puts
extern printf
extern sscanf

section    .data

    filaNum          dq    0
    fila             db    "**",0
    columna          db    0
    sentido          db    0

    nombreArchivo    db    "FICHAS.DAT",0
    modo             db    "rb"
    formatoScan      db    "%li",0
    msjError         db    "Error. No se pudo abrir archivo",10,0
    msjFila          db    "%li",10,0
    tablero          times    300     db    ' '
    desplazamiento   dq    1

section    .bss

    ptrArchivo        resq    1
    registroValido    resb    1
    datoValido        resb    1

section    .text
main:
	; Abro Archivo

	mov    rdi,nombreArchivo
	mov    rsi,modo
	sub    rsp,8
	call   fopen
	add    rsp,8
	cmp    rax,0
	jle    errorAbrir
	mov    qword[ptrArchivo],rax

leerRegistro:
	
	; Proceso Contenido

	mov    rdi,fila
	mov    rsi,2
	mov    rdx,1
	mov    rcx,qword[ptrArchivo]
	sub    rsp,8
	call   fread
	add    rsp,8
	cmp    rax,0
	jle    finArchivo

	mov    rdi,columna
	mov    rsi,1
	mov    rdx,1
	mov    rcx,qword[ptrArchivo]
	sub    rsp,8
	call   fread
	add    rsp,8
	cmp    rax,0
	jle    finArchivo

	mov    rdi,sentido
	mov    rsi,1
	mov    rdx,1
	mov    rcx,qword[ptrArchivo]
	sub    rsp,8
	call   fread
	add    rsp,8
	cmp    rax,0
	jle    finArchivo

	; Valido Registro

	sub    rsp,8
	call   VALFICHA
	add    rsp,8
	cmp    byte[registroValido],'N'
	je     leerRegistro

	; Si llego aca, registros son validos

	sub    rsp,8
	call   cargarTablero
	add    rsp,8

	jmp    leerRegistro

finArchivo:

    ; Cierro Archivo

	mov    rdi,qword[ptrArchivo]
	sub    rsp,8
	call   fclose
	add    rsp,8

    ; Analizo Filas e Imprimo Resultado

    sub    rsp, 8
    call   obtenerNrosFilas
    add    rsp, 8

finDePrograma:
	ret

errorAbrir:
	mov    rdi,msjError
	sub    rsp,8
	call   puts
	add    rsp,8
	jmp    finDePrograma

calcularDesplazamiento:
	mov    rbx,[filaNum]    ; fila
	dec    rbx              ; (fila-1)
	imul   rbx,rbx,10       ; (fila-1) * longitdFila,  longitdFila=longitudElemento*cantidadColumnas
	
    mov    al,byte[columna] ; (columna)
	dec    al               ; (columna-1)
	cbw                     ; long elemento = 1, porque es byte
    cwd
	cdqe
    add    rbx,rax
	mov    qword[desplazamiento],rbx
	ret

cargarTablero:
	sub    rsp,8
	call   calcularDesplazamiento
	add    rsp,8

    ; Analizo Todos los Posibles Casos de Sentidos

    cmp    byte[sentido],'D'
    je     escribirDerecha

    cmp    byte[sentido],'I'
    je     escribirIzquierda

    cmp    byte[sentido],'B'
    je     escribirAbajo

    cmp    byte[sentido],'A'
    je     escribirArriba

    ret


escribirDerecha:
    mov    rbx,[desplazamiento]

    mov    byte[tablero+rbx],'*'
    mov    byte[tablero+rbx+1],'*'
    mov    byte[tablero+rbx+2],'*'
    mov    byte[tablero+rbx+3],'*'

    ret


escribirIzquierda:
    mov    rbx,[desplazamiento]

    mov    byte[tablero+rbx],'*'
    mov    byte[tablero+rbx-1],'*'
    mov    byte[tablero+rbx-2],'*'
    mov    byte[tablero+rbx-3],'*'

    ret


escribirAbajo:

    mov    rbx,[desplazamiento]

    mov    byte[tablero+rbx],'*'
    mov    byte[tablero+rbx+10],'*'
    mov    byte[tablero+rbx+20],'*'
    mov    byte[tablero+rbx+30],'*'

    ret

escribirArriba:
    mov    rbx,[desplazamiento]

    mov    byte[tablero+rbx],'*'
    mov    byte[tablero+rbx-10],'*'
    mov    byte[tablero+rbx-20],'*'
    mov    byte[tablero+rbx-30],'*'

    ret

obtenerNrosFilas:
    ; Como mi padron es 114276, imprimo filas donde todos los elementos tienen *
    mov    rcx,0            ; fila = 0

recorrerFilas:
    cmp    rcx,30
    jge    finObtenerFilas
    mov    byte[datoValido],'S'   ; asumo fila completa
    mov    rdx,0   ; columna = 0

recorrerColumnas:
    ; Si ya se recorrieron todas la columnas, imprime si es valido
    cmp    rdx,10
    jge    verificarFila

    mov    rax,rcx
    imul   rax,10
    add    rax,rdx

    cmp    byte[tablero+rax],'*'
    jne    filaIncompleta

    inc    rdx
    jmp    recorrerColumnas

filaIncompleta:
    mov    byte[datoValido],'N'
    jmp    siguienteFila

verificarFila:
    cmp    byte[datoValido],'S'
    jne    siguienteFila

    mov    rsi,rcx
    inc    rsi

	mov    rdi,msjFila
    ; rsi ya tiene fila
	sub    rsp,8
	call   printf
	add    rsp,8

siguienteFila:
    inc    rcx
    jmp    recorrerFilas

finObtenerFilas:
    ret

; --- PARA PADRON IMPAR ---
; obtenerNrosColumnas:

;     mov    rcx,0

; recorrerColumnas:

;     cmp    rcx,10
;     jge    finObtenerColumnas

;     mov    byte[datoValido],'S'

;     mov    rdx,0

; recorrerFilas:

;     cmp    rdx,30
;     jge    verificarColumna

;     mov    rax,rdx
;     imul   rax,10
;     add    rax,rcx

;     cmp    byte[tablero+rax],'*'
;     jne    columnaIncompleta

;     inc    rdx
;     jmp    recorrerFilas


; columnaIncompleta:

;     mov    byte[datoValido],'N'


; verificarColumna:

;     cmp    byte[datoValido],'S'
;     jne    siguienteColumna

;     mov    rsi,rcx
;     inc    rsi

;     mov    rdi,formatoColumnaCompleta

;     sub    rsp,8
;     call   printf
;     add    rsp,8


; siguienteColumna:

;     inc    rcx
;     jmp    recorrerColumnas


; finObtenerColumnas:
;     ret

VALFICHA:
	mov    byte[registroValido],'N'

	; Valido Fila

	sub    rsp,8
	call   validarFil
	add    rsp,8
	cmp    byte[datoValido],'N'
	je     finValidarRegistro
	
	; Valido Columna

	sub    rsp,8
	call   validarCol
	add    rsp,8
	cmp    byte[datoValido],'N'
	je     finValidarRegistro

	; Valido Sentido

	sub    rsp,8
	call   validarSentido
	add    rsp,8
	cmp    byte[datoValido],'N'
	je     finValidarRegistro

	mov    byte[registroValido],'S'

finValidarRegistro:
	ret

validarFil:

    mov    rdi,fila
    mov    rsi,formatoScan
    mov    rdx,filaNum
    sub    rsp, 8
    call   sscanf
    add    rsp, 8
    cmp    rax,0
    je     filaNoValida

	mov    byte[datoValido],'S'
	cmp    qword[filaNum],1
	jl     filaNoValida
	cmp    qword[filaNum],30
	jg     filaNoValida
	ret

filaNoValida:
	mov    byte[datoValido],'N'
	ret

validarCol:
	mov    byte[datoValido],'S'
	cmp    byte[columna],1
	jl     ColNoValida
	cmp    byte[columna],10
	jg     ColNoValida
	ret

ColNoValida:
	mov    byte[datoValido],'N'
	ret

validarSentido:
	mov    byte[datoValido],'N'
    cmp    byte[sentido],'A'
    je     podriaEntrarArriba
    cmp    byte[sentido],'B'
    je     podriaEntrarAbajo
    cmp    byte[sentido],'D'
    je     podriaEntrarDerecha
    cmp    byte[sentido],'I'
    je     podriaEntrarIzquierda
    ret

podriaEntrarArriba:
    cmp    qword[filaNum],4
    jge    entraBien
    jmp    noEntra

podriaEntrarAbajo:
    cmp    qword[filaNum],27
    jle    entraBien
    jmp    noEntra

podriaEntrarDerecha:
    cmp    byte[columna],7
    jle    entraBien
    jmp    noEntra

podriaEntrarIzquierda:
    cmp    byte[columna],4
    jge    entraBien

noEntra:
    ret

entraBien:
    mov    byte[datoValido],'S'
    ret
