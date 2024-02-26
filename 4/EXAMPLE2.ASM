.286
.model tiny
.code
org 100h
locals @@


start:		push 0
			pop es

			mov ax, 3509h
			int 21h					; get int vector addr: es:bx

			mov Old09Offs, bx
			mov bx, es
			mov Old09Seg, bx

			push ds 				; save ds
			mov dx, offset IntOverride09
			push cs
			pop ds
			mov ax, 2509h
			int 21h					; set int vector addr: ds: dx
			pop ds 					; restore ds

			mov dx, offset EndOfProg
			shr dx, 4
			inc dx 					; sizeof(prog) / 16 + 1
			mov ax, 3100h
			int 21h

IntOverride09	proc
				push ax bx es

				push 0b800h
				pop es

				mov bx, ((80 * 3) + 40) * 2
				mov ah, 4eh ; color

				in al, 60h ; symbol
				mov es:[bx], ax

				pop es bx ax

				db 0eah ; far jmp
				Old09Offs	dw 0
				Old09Seg	dw 0

				endp
EndOfProg:

end		start

