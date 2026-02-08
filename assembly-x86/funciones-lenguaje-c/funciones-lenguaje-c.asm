global main

extern puts;	int puts(const char* str)
extern gets;	char* gets(char* buffer)
extern printf;	int printf(const char* str, *p1, *p2, ...)
extern system;	int system(const char* comando)
extern sscanf;	int sscanf(const char* buffer, const char* formato, *p1, *p2, ...)
extern sprintf;	char* sprintf(char* str, const char* formato, *pi, *p2, ...)
extern fopen;	char* fopen(char* nombre_archivo, char* modo_apertura)
extern fgets;	char* fgets(char* buffer, int tamaño_buffer, FILE* archivo)
extern fread;	int fread(void* puntero_donde_almacena_info, int cantidad_bytes_leer, int cantidad_elementos, FILE* archivo)
extern fputs;	char* fputs(const char* str, FILE* archivo)
extern fwrite;	int fwrite(void* puntero_info, int cantidad_bytes, int cantidad_elementos, FILE* archivo)
extern fclose;	void fclose(FILE* archivo)


section .data
        mensaje db "Hola Mundo!",0;
        texto_nombre db `Mi nombre es %s\n`,0

section .bss
        nombre resb 100; Reservo 100 bytes (pueden entrar 99 caracteres)

section .text

ejemplo_puts:
        mov	rdi,mensaje; Movemos primer parametro a RDI. Como puts recibe un puntero, se pasa la direccion de memoria, es decir 'mensaje' y no '[mensaje]'
	sub	rsp,8
        call	puts; Llamamos a la funcion.
	add	rsp,8
        ret; Fin.

pedir_nombre: ;gets
        mov	rdi,nombre
        sub	rsp,8
	call	gets
	add	rsp,8
        ret

imprimir_nombre: ; printf()
        call	pedir_nombre
        mov 	rdi,texto_nombre
        mov	rsi,nombre
        sub	rsp,8
        call	printf
	add	rsp,8
        ret

main:
	sub	rsp,8
        call	ejemplo_puts
	add	rsp,8
	sub	rsp,8
        call imprimir_nombre
	add	rsp,8        
	ret

section .note.GNU-stack noalloc noexec nowrite progbits;

