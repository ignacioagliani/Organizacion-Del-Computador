global main

extern fopen
extern fread
extern sscanf
extern printf
extern puts
extern fclose

section .data
    signoMenos  db "-",0
    archivo     db "carbina.dat",0
    lectura     db "rb",0

    matriz times 400 dw 0

    formatoNumero db "%d",0
    suma dd 0
    msg db "Suma = %d",10,0
    error_apertura db "Error al Abrir Archivo Binario",0

section .bss
    aValidar   resd 1
    convertido resw 1

    puntero_archivo resq 1
    buffer resb 128

section .text
validar_ascii:
;Precondicion: recibe un ascii de 16 caracteres en r15
;Postcondicion: si es valido, lo devuelve 1 en rax. En caso contrario, carga 0 en rax
    sub     r11,r11
    cmp     byte[r15],"-"
    je      continuar
    cmp     byte[r15],0x00 ; espacio vacio
    je      es_invalido
    .loop:
        cmp     r11,16
        je      es_valido
        cmp     byte[r15 + r11],0x00
        je      es_valido
        cmp     byte[r15 + r11],"0"
        jl      es_invalido
        cmp     byte[r15 + r11],"9"
        jg      es_invalido
        inc     r11
        jmp     .loop

continuar:
    cmp     byte[r15+1],0x00
    je      es_invalido
    inc     r11
    jmp     validar_ascii.loop

es_valido:
    mov     rax,1
    ret

es_invalido:
    mov     rax,0
    ret

convertir_ascii_bpf:
;Precondicion: se tiene ascii valido a convetir en r15
;Postcondicion: lo devulve en formato bpfcs 16bits en r14w. Devuelve 1 en rax si el valido o 0 en otro caso.
    mov     rdi,r15
    mov     rsi,formatoNumero
    mov     rdx,aValidar

    sub     rsp,8
    call    sscanf
    add     rsp,8

    mov     r14d, dword[aValidar]
    cmp     r14d,32767
    jg      error_overflow
    cmp     r14d,-32768
    jl      error_overflow

    mov     r14w, word[aValidar]
    mov     word [convertido],r14w
    mov     rax,1
    ret

error_overflow:
    mov     rax,0
    ret

sumar_diagonal_secundaria:
;Precondicion: recibe la direccion de memoria de una matriz en r15.
;Postcondicion: devuelve en r14w la suma de la diagonal secundaria.
    
    mov     r12,0   ;indice fila
    mov     r13,19   ;indice columna
;Formula acceso indices = matriz[i][j] = Dir. Memoria Matriz + (Ind. Fila * Ancho Fila + Ind. Columna) * Tamaño Elemento
    .loop:
        mov     eax, dword[suma]
        cmp     r13d,0
        jl      imprimir_suma

        mov     r11,0   ; aca se indice del elemento a sumar
        imul    r11,r12,20
        add     r11,r13
        imul    r11,2
        mov     dx,word[r15 + r11]
        movsx   edx,dx
        add     eax,edx
        mov     dword[suma],eax
        inc     r12
        dec     r13
        jmp     .loop

imprimir_suma:
    mov     rdi,msg
    movsx   rsi, dword[suma]
    sub     rsp,8
    call    printf
    add     rsp,8
    ret

err_open:
    mov     rdi,error_apertura
    sub     rsp,8
    call    puts
    add     rsp,8
    ret

cerrar_archivo:
    mov     rdi,qword[puntero_archivo]
    sub     rsp,8
    call    fclose
    add     rsp,8
    jmp     sumar_diagonal_secundaria

VALREG:
; Precondiciones: tener en buffer la informacion de los bytes a procesar
; Postcondiciones: cargar en la matriz el dato pertininte.
    mov     r15,buffer
    sub     rsp,8
    call    validar_ascii
    add     rsp,8
    cmp     rax,0
    je      fin

    movzx   r12w,byte[buffer + 16]   ;r12w = fila

    movzx   r13w,byte[buffer + 17]   ;r13w = columna

    mov     r15,buffer
    sub     rsp,8
    call    convertir_ascii_bpf
    add     rsp,8
    cmp     rax,0
    je      fin
;r14w tiene numero a insertar
;Formula acceso indices = matriz[i][j] = Dir. Memoria Matriz + (Ind. Fila * Ancho Fila + Ind. Columna) * Tamaño Elemento
    mov     r15,matriz
    movzx   r12,r12w
    movzx   r13,r13w
    imul    r12,20
    add     r12,r13
    imul    r12,2
    mov     word[r15 + r12],r14w
    ret

fin:
    ret

main:
    mov     rdi,archivo
    mov     rsi,lectura

    sub     rsp,8
    call    fopen
    add     rsp,8

    cmp     rax,0
    je      err_open

    mov     qword[puntero_archivo],rax

    .loop:
        mov     rdi,buffer
        mov     rsi,1
        mov     rdx,18
        mov     rcx,qword[puntero_archivo]

        sub     rsp,8
        call    fread
        add     rsp,8

        cmp     rax,0
        je      cerrar_archivo

        sub     rsp,8
        call    VALREG
        add     rsp,8

        jmp     .loop

section .note.GNU-stack noalloc noexec nowrite progbits