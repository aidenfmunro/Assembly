.286
.model tiny
.code
org 100h
locals @@


start:		push 0b800h
			pop es

			mov bx, ((80 * 3) + 40) * 2
			mov ah, 4eh ; color

next:		in al, 60h ; symbol
			mov es:[bx], ax

			cmp al, 0eh ; backspace
			jne next

			ret

end		start

