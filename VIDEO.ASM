.model tiny	; generates a COM file
		; which is smaller in size the an exe file

.286		; 16-bit microprocessor
			
.code		;
org 100h

start:	mov bx, 0b800h
	mov es, bx
	mov bx, (5 * 80 + 80 / 2) * 2																																																		
	mov byte ptr es:[bx], 65d	; 'A'
	mov byte ptr es:[bx+1], 4ch 
	mov ax, 4c00h
	int 21h

end start
