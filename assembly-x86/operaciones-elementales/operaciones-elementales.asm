global main
extern printf

section .data
	n1 dd 100; en la variable 'n1' reservo una doble palabra (4 bytes), la cual contiene el numero 100 
	n2 dd 20
	n3 dd 10
	n4 dd 5

	; Texto para printf
	resultado_suma db `%d + %d = %d\n`,0; con backticks ` me reconoce el \n, con comillas dobles no.
	resultado_resta db "%d - %d = %d\n",0
	resultado_multiplicacion db "%d X %d = %d\n",0
	resultado_division db "%d / %d: Cociente = %d | Resto = %d\n",0

section .bss
	n1masn2: resd 1; Reservo una doble palabra para almacenar el resultado de n1 + n2	
	n3masn4: resd 1;
	suma_inmediato: resd 1;
	n2_menos_n3: resd 1;
	multiplicacion: resd 1;
	cociente: resd 1;
	resto: resd 1;
	resultado_neg: resd 1;

section .text
main:
	; Sumar registro + memoria
	mov eax,[n1]; Paso el contenido de 'n1' al registro de 32 bits (4 bytes) EAX 
	add eax,[n2]; Sumo EAX (n1) con el contenido de la variable 'n2'. El resultado queda en EAX
	mov [n1masn2],eax; Almaceno el resultado en 'n1masn2'

	; Sumar registro mas registro
	mov eax,[n3]
	mov ebx,[n4]
	add eax,ebx
	mov [n3masn4],eax

	; Sumar registo y numero inmediato
	mov eax,[n1];
	add eax,25; Hacemos n1 + 25
	mov [suma_inmediato],eax

	; Resta (Funciona igual que ADD)
	mov eax,[n2]
	mov ebx,[n3]
	sub eax,ebx
	mov [n2_menos_n3],eax
	
	; INC (suma 1), DEC (resta 1)
	inc eax; Lo mismo que ADD EAX,1
	dec eax; Lo mismo que SUB EAX,1

	; Multiplicar (IMUL) funciona igual que ADD y SUB
	mov eax,[n3]
	imul eax,2; n3 * 2
	mov [multiplicacion],eax
	
	; Division (IDIV). Funciona como un solo operando. En este ejemplo, hacemos 25 / 5.
	mov eax,25; Dividendo en EAX
	cdq       ; Extiende el bit de signo de eax a edx, preparando la operación idiv de 32 bits.
	mov ebx,5; Divisor en EBX

	idiv ebx; Realiza la divisio.n

	mov [cociente], eax ; Cociente queda en EAX. Lo movemos a la variable 'cociente'
	mov [resto], edx; Lo mismo hacemos con resto, que queda en EDX

	; NEG (cambia signo)
	mov eax,10
	neg eax
	mov [resultado_neg],eax

	; Imprimimos todos los resultados
	mov rdi,resultado_suma
	mov rsi, [n1]
	mov rdx, [n2]
	mov rcx, [n1masn2]

	sub rsp, 8
	call printf
	add rsp, 8

	ret
section .note.GNU-stack noalloc noexec nowrite progbits; Sin esto me tira warning. Sin esto anda igual.









