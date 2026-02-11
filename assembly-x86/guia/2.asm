global main

extern printf
extern gets

section .data
	mensaje db "El alumno %s de Padrón N°%s tiene %s años",10,0
	str_nombre_apell db "Nombre y Apellido (maximo 99 caracteres)",10,0
	str_padron db "Padron (sin punto): ",10,0
	str_edad db "Edad: ",10,0

section .bss
	nombre_apellido resb 128
	padron resb 128
	edad resb 128

section .text
main:
	mov	rdi,str_nombre_apell
	sub	rsp,8
	call	printf
	add	rsp,8
	mov	rdi,nombre_apellido
	sub	rsp,8
	call	gets
	add	rsp,8
	
        mov     rdi,str_padron
        sub     rsp,8
        call    printf
        add     rsp,8
        mov     rdi,padron
        sub     rsp,8
        call    gets
        add     rsp,8

        mov     rdi,str_edad
        sub     rsp,8
        call    printf
        add     rsp,8
        mov     rdi,edad
        sub     rsp,8
        call    gets
        add     rsp,8

	mov	rdi,mensaje
	mov	rsi,nombre_apellido
	mov	rdx,padron
	mov	rcx,edad
	sub	rsp,8
	call	printf
	add	rsp,8
	ret

section .note.GNU-stack noalloc noexec nowrite progbits
