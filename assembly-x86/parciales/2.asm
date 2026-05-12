global main

extern puts
extern printf
extern fopen
extern fclose
extern fread
extern sscanf
extern fwrite

section .data

	archivoListado    db    "listado.dat",0
	modoApertura      db    "rb",0
	archivoSalida     db    "seleccionados.dat",0
	modoEscritura     db    "wb",0
	msjErrApertura    db    "No se pudo abrir archivo",10,0
	fmtPrecio         db    "%i",0
	fmtAnio           db    "%hi",0
	anioInt           dw    0

	vectorMarcas    db    "Ford      "
					db    "Chevrolet "
					db    "Peugeot   "
					db    "Fiat      "

	regListado   times    0    db    ''
		marca    times    10   db    " "
		anio     times    4    db    " "
		patente  times    7    db    " "
		precio   times    7    db    " "

	regSeleccion     times    0    db    ''
        patenteSel   times  7  db    " "
        precioSel              dd    0

section .bss

	ptrArchListado         resq    1
	ptrArchSeleccionado    resq    1
	registroValido         resb    1
	datoValido             resb    1

section .text

main:

	; Abro listado.dat

	mov    rdi,archivoListado
	mov    rsi,modoApertura
	sub    rsp,8
	call   fopen
	add    rsp,8
	cmp    rax,0
	jle    errorAperturaList
	mov    qword[ptrArchListado],rax

	; Abro seleccionados.dat

	mov    rdi,archivoSalida
	mov    rsi,modoEscritura
	sub    rsp,8
	call   fopen
	add    rsp,8
	cmp    rax,0
	jle    cerrarList
	mov    qword[ptrArchSeleccionado],rax

leerRegistro:

	; Proceso Archivo Listado

	mov    rdi,regListado
	mov    rsi,28
	mov    rdx,1
	mov    rcx,qword[ptrArchListado]
	sub    rsp,8
	call   fread
	add    rsp,8
	cmp    rax,0
	jle    cerrarAmbos

	; Validar Registros Leidos

	sub    rsp,8
	call   validar 
	add    rsp,8
	cmp    byte[registroValido],'N'
	je     leerRegistro

	; Si llego aca, el registro es valido
	; Copiamos los 7 bytes de la patente a otra direccion de memoria

	mov    rcx,7
	lea    rsi,[patente]
	lea    rdi,[patenteSel]
	rep    movsb

	; Converto precio de str a int32

	mov    rdi,precio
	mov    rsi,fmtPrecio
	mov    rdx,precioSel
	sub    rsp,8
	call   sscanf
	add    rsp,8

	; Escribimos en seleccionado.dat
    mov    rdi,regSeleccion
    mov    rsi,11
    mov    rdx,1
    mov    rcx,qword[ptrArchSeleccionado]
	sub    rsp,8
	call   fwrite
	add    rsp,8

	; Repetimos ciclo

	jmp    leerRegistro

errorAperturaList:
    mov    rdi,msjErrApertura
	sub    rsp,8
	call   puts
	add    rsp,8
	jmp    finDePrograma

cerrarAmbos:
	mov    rdi,qword[ptrArchSeleccionado]
	sub    rsp,8
	call   fclose
	add    rsp,8

cerrarList:
	mov    rdi,qword[ptrArchListado]
	sub    rsp,8
	call   fclose
	add    rsp,8

finDePrograma:
	ret

validar:
	mov    byte[registroValido],'N'

	; Valido Marca

	sub    rsp,8
	call   validarMarca
	add    rsp,8
	cmp    byte[datoValido],'N'
	jle    finValidarRegistro

	; Valido Anio

	sub    rsp,8
	call   validarAnio
	add    rsp,8
	cmp    byte[datoValido],'N'
	jle    finValidarRegistro

	; Valido Precio

	sub    rsp,8
	call   validarPrecio
	add    rsp,8
	cmp    byte[datoValido],'N'
	jle    finValidarRegistro

	; Como todo es valido, modifico registroValido

	mov    byte[registroValido],'S'

finValidarRegistro:
	ret

validarMarca:
	mov    byte[datoValido],'S'
	mov    rbx,0    ; Offset. Suma de a 10.
	mov    rcx,4    ; RCX obligatorio para loop. Indica cantidad veces iterar.

cicloMarca:
	push   rcx    ; Como instruccion loop tambien usa RCX, guardamos valor anterior en pila
	
	; Comparo  (TODOS los regitros son IRREMPLAZABLES. Usar LEA)
	mov    rcx,10    ; Compara 10 bytes
	lea    rsi,[marca]    ; De aca
	lea    rdi,[vectorMarcas + rbx]    ; Con estos
	repe   cmpsb

	pop    rcx

	je     marcaOk
	add    rbx,10
	loop   cicloMarca

	; Si terminamos de iterar, 

	mov    byte[datoValido],'N'

marcaOk:
	ret

validarAnio:
	mov    byte[datoValido],'N'

	mov    rdi,anio
	mov    rsi,fmtAnio
	mov    rdx,anioInt
	sub    rsp,8
	call   sscanf
	add    rsp,8
	cmp    rax,1
	jl     anioError

	cmp    word[anioInt],2010
	jl     anioError
	cmp    word[anioInt],2020
	jg     anioError

	mov    byte[datoValido],'S'

anioError:
	ret

validarPrecio:
	mov    byte[datoValido],'N'
	mov    rcx,7
	mov    rbx,0

cicloDigitoPrecio:

	; Comparamos caracter a caracter

	cmp    byte[precio+rbx],'0'
	jl     precioError
	cmp    byte[precio+rbx],'9'
	jg     precioError

	inc    rbx
	loop   cicloDigitoPrecio

	mov    byte[datoValido],'S'

precioError:
	ret
