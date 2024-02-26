.286
.model tiny
.code
org 100h
locals @@


start:		push 0
			pop es

			mov bx, 4 * 09h 				  ; IRQ1 interrupt vector address

			cli								  ; criss cross
			mov es:[bx], offset IntOverride09 ; addr offset 2 byte offset - 2 byte segment
			push cs
			pop ax							  ; делается вручную
			mov es:[bx + 2], ax 			  ; addr segment
			sti

			mov dx, offset EndOfProg
			shr dx, 4
			inc dx 							  ; sizeof(prog) / 16 + 1
			mov ax, 3100h
			int 21h

IntOverride09	proc
				push ax bx es

				push 0b800h
				pop es

				mov bx, ((80 * 3) + 40) * 2
				mov ah, 4eh 				  ; color

				in al, 60h 					  ; symbol
				mov es:[bx], ax

										      ; blink port 61h higher bit
				in al, 61h
											  ; mov ah, al ; thelp variant
				or al, 80h
				out 61h, al
				and al, not 80h 			  ; ded variant
				out 61h, al

				mov al, 20h
				out 20h, al

				pop es bx ax
				iret
				endp
EndOfProg:

end		start

