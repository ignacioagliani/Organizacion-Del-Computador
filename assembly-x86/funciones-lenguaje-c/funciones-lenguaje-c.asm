global main

extern puts; int puts(const char* str)
extern gets;  char* gets(char* buffer)
extern printf; int printf(const char* str, p1, p2, ...)

section .data
        mensaje db "Hola Mundo!",0;
        texto_nombre db `Mi nombre es %s\n`,0

section .bss
        nombre resb 100; Reservo 100 bytes (pueden entrar 99 caracteres)

section .text

ejemplo_puts:
        mov rdi,mensaje; Movemos primer parametro a RDI. Como puts recibe un puntero, se pasa la direccion de memoria, es decir 'mensaje' y no '[mensaje]'
        call puts; Llamamos a la funcion.
        ret; Fin.

pedir_nombre: ;gets
        mov rdi,nombre
        call gets
        ret

imprimir_nombre: ; printf()
        call pedir_nombre
        mov  rdi,texto_nombre
        mov  rsi,nombre
        sub rax,rax
        call printf
        ret

main:
        call ejemplo_puts
        call imprimir_nombre
        ret

section .note.GNU-stack noalloc noexec nowrite progbits;

