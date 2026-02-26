@ Constantes

    .equ    fopen,0x66
    .equ    gets,0x6c
    .equ    fclose,0x68
	.equ	putint,	0x6b
	.equ	exit,	0x11
	.equ	stdout,	1
    .equ    strstdout, 0x69

@ Variables

	.data

msgSuma:	.asciz "Resultado Suma = "
msgResta:	.asciz "Resultado Resta = "
msgMult:	.asciz "Resultado Multiplicación = "
msgAnd:	.asciz "Resultado & = "
msgOr:	.asciz "Resultado | = "
msgXor:	.asciz "Resultado XOR = "
msgLeft:	.asciz "Resultado << = "
msgRight:	.asciz "Resultado >> = "
msgAsr:	.asciz "Resultado ASR = "
enter:	.asciz "\n"
archivo:	.asciz "dosEnteros.txt"
msgErrorArchivo:	.asciz "Error al abrir archivo"
.align

numero1:	.word 0
numero2:	.word 0
punteroArchivo:	.word 0

@ Codigo

	.text
	.global _start


imprimirString:
@ Precondiciones: tener cargado en el registro r11 un string
@ Postcondiciones: imprime el string por la standard output.
	stmfd	sp!, {r0,lr}
    mov r0,#1
	mov	r1, r11
	swi	strstdout

	ldr	r1, =enter
	swi	strstdout
	ldmfd	sp!, {r0,pc}

imprimirInt:
@ Precondiciones: tener cargado en el registro r12 un int
@ Postcondiciones: imprime el entero por la standard output.
    stmfd   sp!, {r0, r1, lr}
    mov     r0, #1           @ Destino: Pantalla
    mov     r1, r12          @ Valor: El número que queres ver
    swi     putint             @ Llamada a imprimir entero

	ldr	r1, =enter
	swi	strstdout
    ldmfd   sp!, {r0, r1, pc}

sumar:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R2 la suma de R0 (numero1) con R1 (numero2).
	stmfd	sp!, {r0,r1,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	add	r2, r0, r1
	ldmfd	sp!, {r0,r1,pc}

restar:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R3 la resta de R0 (numero1) con R1 (numero2).
	stmfd	sp!, {r0,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	sub	r3, r0, r1
	ldmfd	sp!, {r0,pc}

multiplicar:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R4 la multiplicacion de R0 (numero1) con R1 (numero2).
	stmfd	sp!, {r0,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	mul	r4, r0, r1
	ldmfd	sp!, {r0,pc}

and_op:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R5 el resultado de R0 (numero1) AND R1 (numero2).
	stmfd 	sp!, {r0,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	and	r5, r0, r1
	ldmfd	sp!, {r0,pc}

or_op:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R6 el resultado de R0 (numero1) OR R1 (numero2).
	stmfd	sp!, {r0,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	orr	r6, r0, r1
	ldmfd	sp!, {r0,pc}

xor_op:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R7 el resultado de R0 (numero1) XOR R1 (numero2).
	stmfd sp!, {r0,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	eor	r7, r0, r1
	ldmfd sp!, {r0,pc}

leftShift:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R8 el resultado de R0 (numero1) << R1 (numero2).
	stmfd sp!, {r0,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	mov	r8, r0, lsl r1
	ldmfd sp!, {r0,pc}

rightShift:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R9 el resultado de R0 (numero1) >> R1 (numero2).
	stmfd sp!, {r0,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	mov	r9, r0, lsr r1
	ldmfd sp!, {r0,pc}

rightShiftAr:
@ Precondicion: tener dos numeros enteros en las variables 'numero1' y 'numero2', respectivamente.
@ Postcondición: guarda en el registro R10 el resultado de R0 (numero1) ASR R1 (numero2).
	stmfd sp!, {r0,lr}

	ldr	r0, =numero1	@ Cargamos dir. memoria de 'numero1'
	ldr	r0, [r0]	@ Cargamos el contenido de la dir. memoria de 'numero1'

	ldr	r1, =numero2	@ Cargamos dir. memoria de 'numero2'
	ldr	r1, [r1]	@ Cargamos el contenido de la dir. memoria de 'numero2'

	mov	r10, r0, asr r1
	ldmfd sp!, {r0,pc}

errorApertura:
	mov	r0,#1
	ldr	r1,=msgErrorArchivo

	swi	strstdout
	swi exit

_start:
	@ Abrir archivo
	ldr	r0,=archivo
	mov	r1,#0
	swi	fopen

	bcs	errorApertura

	ldr	r1,=punteroArchivo
	str	r0,[r1]

	@ Leer Primer numeor
	ldr	r0,=punteroArchivo
	ldr	r0,[r0]

	swi	gets

	ldr	r1,=numero1
	str	r0,[r1]

	@ Leer segundo numero

	ldr	r0,=punteroArchivo
	ldr	r0,[r0]

	swi	gets

	ldr	r1,=numero2
	str	r0,[r1]

	@ Cerrar Archivo
	ldr	r0,=punteroArchivo
	ldr	r0,[r0]
	swi	fclose

@ A la hora de imprimir me imprime el texto por una consola y los numeros por otra
	ldr	r11, =msgSuma
	bl	imprimirString
	bl	sumar
	mov	r12, r2
	bl	imprimirInt

	ldr	r11, =msgResta
	bl	imprimirString
	bl	restar
	mov	r12, r3
	bl	imprimirInt

	ldr	r11, =msgMult
	bl	imprimirString
	bl	multiplicar
	mov	r12, r4
	bl	imprimirInt

	ldr	r11, =msgAnd
	bl	imprimirString
	bl	and_op
	mov	r12, r5
	bl	imprimirInt

	ldr	r11, =msgOr
	bl	imprimirString
	bl	or_op
	mov	r12, r6
	bl	imprimirInt

	ldr	r11, =msgXor
	bl	imprimirString
	bl	xor_op
	mov	r12, r7
	bl	imprimirInt

	ldr	r11, =msgLeft
	bl	imprimirString
	bl	leftShift
	mov	r12, r8
	bl	imprimirInt

	ldr	r11, =msgRight
	bl	imprimirString
	bl	rightShift
	mov	r12, r9
	bl	imprimirInt

	ldr	r11, =msgAsr
	bl	imprimirString
	bl	rightShiftAr
	mov	r12, r10
	bl	imprimirInt

	swi	exit
	.end
