global main

extern printf

section .data
	NUM dw 1101b
	rebatido dw 0
	msg db "%b",10,0

section .text

;Ejercicio en C

;#include <stdio.h>
;#include <stdint.h>

;int main(void) {
;       uint16_t NUM = 0b1101;
;       uint16_t rebatido = 0;
;       uint16_t ultimo_digito = NUM & 0b1;
;       rebatido = ultimo_digito;
;       NUM >>= 1;
;       while (NUM > 0) {
;               ultimo_digito = NUM & 0b1;
;               rebatido = (rebatido << 1) | ultimo_digito;
;               NUM >>= 1;
;       }
;       printf("Rebatido: %b\n",rebatido);
;       return 0;
;}

imprimir:
	mov	rdi,msg
	movzx	rsi, word[rebatido]
	sub	rsp,8
	call	printf
	add	rsp,8
	ret

main:
	sub	rax,rax			;RAX = 0
	sub	rbx,rbx			;RBX = 0
	mov	ax,[NUM]		;AX = NUM
	and	ax,1b			;AX = NUM & 0b1
	mov	word [rebatido],ax	;rebatido = NUM
	mov	ax,[NUM]		;AX = NUM
	shr	ax,1			;AX >> 1
	mov	word [NUM],ax		;NUM = AX>>1
	.loop:
		cmp	word [NUM],0	;Si NUM es 0, imprimimos rebatido
		je	imprimir

		sub	ax,ax
		mov     ax,[NUM]
		and	ax,1b		; Ultimo digito

		sub	rbx,rbx
		sub	rcx,rcx

                mov     bx,[rebatido]   ; rebatido en BX
		shl	bx,1		; rebatido << 1
		or	bx,ax		; (rebatido << 1) | ultimo_digito
		mov	word [rebatido],bx

                mov     cx,[NUM]        ; NUM en CX
                shr     cx,1            ; NUM >> 1
		mov	word [NUM],cx	; NUM >>=1
		jmp	.loop

section .note.GNU-stack noalloc noexec nowrite progbits

