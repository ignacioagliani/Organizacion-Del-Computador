global main
extern puts

section .data
    msg db "Hello",0; // db -> 'define byte' reserva los suficientes bytes para almacenar la cadena

section .text
main:
    mov     rdi,msg ; // Cargo en el registro rdi la dirección de memoria del 'msg'
    sub	    rsp,8
    call    puts; // 'call' bifurca a otro programa. En este caso, llamamos a la función de C 'puts'
    add     rsp,8
    ret
section .note.GNU-stack noalloc noexec nowrite progbits; Sin esto me tira warning. Sin esto anda igual.

