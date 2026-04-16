global main

extern printf
extern fopen
extern fread
extern fclose
extern gets
extern sscanf

section .data
	valorDefault db "*",0
	instancias db "NP","FG","OF","CF","SF","FI"
	final db "FI",0
	semi db "SF",0
	anios dw 1986,1990,1994,1998,2002,2006,2010,2014,2018
	cantidadMundiales dd 9
	largoVectorInstancias dd 6
	nombreArchivo db "mundiales.dat",0
	modoApertura db "r",0
	msg db "%d",10,0
	formato db "%d",0

section .bss
	matriz times 450 resw 1 ; 50x9=450

	codigoPais resb 1
	anoMundial resw 1
	codigoInst resw 1

	punteroArchivo resq 1

	buffer resb 64

	colPais resq 1

section .text

main:
	sub rsp,8
	call abrirArchivo
	add rsp,8
	
	sub rsp,8
	call leerArchivo
	add rsp,8

	sub rsp,8
	call cerrarArchivo
	add rsp,8

	sub rsp,8
	call solicitarPais
	add rsp,8

	ret

solicitarPais:
	mov rdi,buffer

	sub rsp,8
	call gets
	add rsp,8

	mov rdi,buffer	; De donde se lee el dato
	mov rsi,formato	; Formato esperado
	mov rdx,colPais	; Variable donde se guarda valor convertido

	sub rsp,8
	call sscanf
	add rsp,8

	jmp contarMundiales

contarMundiales:
    ; Calcular inicio de fila del país en matriz
	; Rax es el indice.
	; A_ij = direccion A + (i * #cols  + j) * sizeof(A_ij)
    mov rax, [colPais]	;Carga contenido de colPais en RAX
    dec rax
    imul rax, 9*2
    lea r12, [matriz + rax]     ; r12 = inicio fila del país

    mov r11, 0                  ; contador de mundiales NO top4
    mov r15, 0                  ; contador de iteraciones
    mov r13w, word[semi]
    mov r14w, word[final]

loopMundiales:
    cmp r15, 9
    jge fin

    mov ax, word[r12]           ; celda actual
    cmp ax, word[semi]
    je esSFoFI
    cmp ax, word[final]
    je esSFoFI

    inc r11                     ; no fue SF ni FI → suma al contador
    jmp siguiente2

esSFoFI:
    jmp siguiente2

siguiente2:
    add r12, 2                  ; siguiente columna
    inc r15
    jmp loopMundiales

fin:
	mov rdi,msg
	mov rsi,r11

	sub rsp,8
	call printf
	add rsp,8

	ret

abrirArchivo:
	mov rdi,nombreArchivo
	mov rsi,modoApertura

	sub rsp,8
	call fopen
	add rsp,8

	cmp rax,0
	jle errorApertura
	mov qword[punteroArchivo],rax
	ret

errorApertura:
	; Aca podria ir un mensaje de error.
	ret

leerArchivo:
	; Precondicion: hay file pointer en "punteroArchivo"
	; Postcondicion: llena "codigoPais", "anoMundial" y "codigoInst".

	; Leer codigoPais
	mov rdi,buffer
	mov rsi,1
	mov rdx,1
	mov rcx,[punteroArchivo]

	sub rsp,8
	call fread
	add rsp,8

	cmp rax,0
	je EOF

	mov al,[buffer]
	mov [codigoPais],al

	; Leer anoMundial
	mov rdi,buffer	; Donde se almacena lo leido
	mov rsi,1		; Cantidad bloques a leer
	mov rdx,2		; Cantidad bytes a leer
	mov rcx,[punteroArchivo]

	sub rsp,8
	call fread
	add rsp,8

	mov ax,[buffer]
	mov [anoMundial],ax

	; Leer codigoInst
	mov rdi,buffer
	mov rsi,1
	mov rdx,2
	mov rcx,[punteroArchivo]

	sub rsp,8
	call fread
	add rsp,8

	mov ax,[buffer]
	mov [codigoInst],ax


	sub rsp,8
	call VALREG
	add rsp,8

	cmp rax,1
	; Ignoramos si es invalido
	je leerArchivo

	; Aca solo llegan entradas validas
	; Matriz[Pais][Mundial]
	movzx r10,word[anoMundial]	;movzx lleva contenido de registros pequeños a otros mas grandes
	mov rax,0
	lea r11,[anios]		; Carga la direccion de memoria donde comienza el array
	sub rsp,8
	call obtenerColumnaMundial
	add rsp,8

	;Formula acceso indices = matriz[i][j] = Dir. Memoria Matriz + (Ind. Fila * Ancho Fila + Ind. Columna) * Tamaño Elemento
    mov     r15,matriz
	mov		al,[codigoPais]
    movzx   r12,al	;r12 = fila
	dec r12
    imul    r12,9
    add     r12,rax		;rax = col
    imul    r12,2
	mov		r14w,word[codigoInst]
    mov     word[r15 + r12],r14w

	jmp leerArchivo

EOF:
	ret

obtenerColumnaMundial:
	; Precondicion: rax = 0, r10=mundial a analizar y r11=primer mundial en arreglo
	; Devuelve nro col en RAX.
	movzx rbx, word[r11]
	cmp r10,rbx
	je columnaEncontrada
	add r11,2	; salta 2 bytes
	inc rax
	jmp obtenerColumnaMundial

columnaEncontrada:
	ret

cerrarArchivo:
	mov rdi,qword[punteroArchivo]

	sub rsp,8
	call fclose
	add rsp,8

	ret

VALREG:
	; Precondicion: campos "codigoPais", "anoMundial" y "codigoInst" completos.
	; PostCondicion: RAX == 0 si es valido || RAX == 1 si es invalido

	; Validacion Pais
	mov rax,0
	mov bh,[codigoPais]
	mov dh,0
	cmp bh,dh
	jle campoInvalido
	mov dh,51
	cmp bh,dh
	jge campoInvalido

	; Validacion año
	mov bx,[anoMundial]
	mov dx,1985
	cmp bx,dx
	jle campoInvalido
	mov dx,2019
	cmp bx,dx
	jge campoInvalido

	; Validacion Instancia
	mov ecx,[largoVectorInstancias]	; ECX hace las veces de contador para loop
	mov edx,instancias
	sub rsp,8
	call validarInstancia
	add rsp,8
	ret
	
campoInvalido:
	mov rax,1
	ret

validarInstancia:
	mov bl,[codigoInst]
	cmp bl,[edx]
	jne siguiente

	mov bl,[codigoInst+1]
	cmp bl,[edx+1]
	jne siguiente

	jmp esValido

siguiente:
	add edx,2
	loop validarInstancia

	jmp campoInvalido

esValido:
	ret

section .note.GNU-stack noalloc noexec nowrite progbits