global main

section .data
	n1 dd 100; en la variable 'n1' reservo una doble palabra (4 bytes), la cual contiene el numero 100 
	n2 dd 20
	n3 dd 10
	n4 dd 5

section .bss
	n1masn2: resd 1; Reservo una doble palabra para almacenar el resultado de n1 + n2	
	n3masn4: resd 1;
	suma_inmadiato: resd 1;
	n2_menos_n3: resd 1;

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
	mob [n2_menos_n3],eax
	
	; INC (suma 1), DEC (resta 1)
	inc eax; Lo mismo que ADD EAX,1
	dec eax; Lo mismo que SUB EAX,1


	
