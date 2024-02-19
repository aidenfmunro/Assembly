.286
.model tiny
.code

org 100h

vram equ 0b800h

start:		push 0
			pop es
			mov bx, 4 * 09h

			cli
			mov es:[bx], offset my_int 
			mov ax, cs
			mov es:[bx + 2], ax
			sti

			mov ax, 3100h			 		; leave program in memory
			mov dx, offset EOP
			shr dx, 4
			inc dx
			int 21h 


my_int		proc
			push ax bx es

			mov bx, vram
			mov es, bx

			mov bx, (80 * 5 + 40) * 2
			mov ah, 4eh

			in al, 60h			; read from data port of kybd cntrlr
			mov es:[bx], ax

			in al, 61h			; blink hi bit in kybf cntrlr cmd port
			or al, 80h
			
			out 61h, al
			and al, not 80h 	; 01111111b
			out 61h, al

			mov al, 20h			; send EOI to intl cntrl
			out 20h, al

			pop es bx ax
			iret

			ret

			db 0eah
01d090fs	dw 0
01d09Seg	dw 0
			endp

EOP:
end			start	

		