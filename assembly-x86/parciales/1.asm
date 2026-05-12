global main

extern fopen
extern fread
extern fclose
extern gets
extern puts
extern printf
extern sscanf

section .data

	nombreArchivo    db    "mundiales.dat",0
	modo             db    "rb",0
	msjErrAbrir      db    "Error Abrir",10,0
	desplazamiento   dq    0
	msjNoMejores     db    "%d",10,0
	cantidad         dd    0
	columna          dw    0
	formatoScan      db    "%d",0
	instSF           dw    "SF"
	instFI           dw    "FI"
	matriz           times    450     dw    "**" 
	paisGetsInt      dd    1
	
	pais             dw    0
	anio             dw    0
	inst             dw    "**"
		
	vectorInstancias    db    "NP"
						db    "FG"
						db    "OF"
						db    "CF"
						db    "SF"
						db    "FI"
 
	anios dw 1986,1990,1994,1998,2002,2006,2010,2014,2018

section .bss

	ptrArchivo        resq    1
	registroValido    resb    1
	datoValido        resb    1
	buffer            resb    100
	
section .text
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

	mov    rdi,pais
	mov    rsi,2     ; Archivo binario tiene 1 byte padding. necesito leer 2.
	mov    rdx,1
	mov    rcx,qword[ptrArchivo]
	sub    rsp,8
	call   fread
	add    rsp,8
	cmp    rax,0
	jle    finArchivo

	mov    rdi,anio
	mov    rsi,2
	mov    rdx,1
	mov    rcx,qword[ptrArchivo]
	sub    rsp,8
	call   fread
	add    rsp,8
	cmp    rax,0
	jle    finArchivo

	mov    rdi,inst
	mov    rsi,2
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

	jmp    leerRegistro

finArchivo:
	mov    rdi,qword[ptrArchivo]
	sub    rsp,8
	call   fclose
	add    rsp,8

	mov    rdi,buffer
	sub    rsp,8
	call   gets
	add    rsp,8

    mov    rdi, buffer
    mov    rsi, formatoScan
    mov    rdx, paisGetsInt
    sub    rsp, 8
    call   sscanf
    add    rsp, 8

    sub    rsp, 8
    call   obtenerNoMejores
    add    rsp, 8

	mov    rdi,msjNoMejores
	mov    rsi,[cantidad]
	sub    rsp,8
	call   printf
	add    rsp,8

finDePrograma:
	ret

errorAbrir:
	mov    rdi,msjErrAbrir
	sub    rsp,8
	call   puts
	add    rsp,8
	jmp    finDePrograma

calcularDesplazamiento:
	; Como IMUL no funciona con registros de 8 bits, extiendo a 16 bits.
	mov    al,byte[pais]
	dec    al
	cbw
	imul   ax,ax,9
	add    ax,[columna]
	imul   ax,2
	cwde
	cdqe
	mov    rbx,rax
	mov    [desplazamiento],rbx
	ret

escribirMatriz:
	sub    rsp,8
	call   calcularDesplazamiento
	add    rsp,8

	lea    r9,[matriz]
	mov    r10,[desplazamiento]
	mov    ax,[inst]
	mov    [r9 + r10],ax
	ret

obtenerNoMejores:
	mov    dword[cantidad],0

	mov    eax,[paisGetsInt]
	dec    eax
	imul   eax,eax,18

	lea    rsi,[matriz + rax]
	mov    rcx,9

cicloColumnas:
    mov ax, word[rsi]

    cmp ax, word[instSF]
    je  esMejor

    cmp ax, word[instFI]
    je  esMejor

noMejor:
    inc dword[cantidad]

esMejor:
    add rsi,2
    loop cicloColumnas
    ret

VALREG:
	mov    byte[registroValido],'N'

	; Valido Pais

	sub    rsp,8
	call   validarPais
	add    rsp,8
	cmp    byte[datoValido],'N'
	je     finValidarRegistro
	
	; Valido Anio

        sub    rsp,8
        call   validarAnio
        add    rsp,8
	cmp    byte[datoValido],'N'
	je     finValidarRegistro

	; Valido Instacia

        sub    rsp,8
        call   validarInstancia
        add    rsp,8
	cmp    byte[datoValido],'N'
	je     finValidarRegistro

	mov    byte[registroValido],'S'

finValidarRegistro:
	ret

validarPais:
	mov    byte[datoValido],'S'
	cmp    byte[pais],1
	jl     paisNoEsValido
	cmp    byte[pais],50
	jg     paisNoEsValido
	ret

paisNoEsValido:
	mov    byte[datoValido],'N'
	ret

validarAnio:
        mov    byte[datoValido],'N'
		mov    word[columna],0
        xor    rbx,rbx
        mov    rcx,9
		mov    ax,[anio]

cicloResultadosAnio:
	cmp    ax,[anios + rbx]
	je     anioValido

	add    rbx,2
	inc    word[columna]
	loop   cicloResultadosAnio

	ret

anioValido:
        mov    byte[datoValido],'S'
        ret

validarInstancia:
	mov    byte[datoValido],'N'
        mov    rbx,0
        mov    rcx,6

cicloResultadosInst:
        push   rcx
        mov    rcx,2
        lea    rsi,[inst]
        lea    rdi,[vectorInstancias + rbx]
        repe   cmpsb
        pop    rcx

        je     instValida
        add    rbx,2
        loop   cicloResultadosInst
	ret

instValida:
	mov    byte[datoValido],'S'
        ret
