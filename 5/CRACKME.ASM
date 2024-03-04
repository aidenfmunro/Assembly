;-----Entry settings------------------------------------------------------------
.model tiny
.code
.286
org 100h
locals @@
;-----End of entry settings-----------------------------------------------------

DOS_EXIT	macro
			mov ah, 4ch
			int 21h
			endm

start:  mov dx, offset entry_msg
        mov ah, 09h
        int 21h


input:	mov dx, offset base
		mov ah, 0ah
		int 21h

		mov cx, pass_length
	
again:	mov si, offset base
		mov base, 11111111b
		add si, 2
		mov bx, offset pass			

		lodsb
		sub al, 2 
		cmp al, [bx]
		jne error	
		inc bx
		loop again

		mov dx, offset correct_msg
		mov ah, 09h
		int 21h

		DOS_EXIT

error:	mov dx, offset incorrect_msg
		mov ah, 09h
		int 21h
		
		DOS_EXIT


entry_msg     db 10, 13, 'Enter your password: $'
correct_msg   db 10, 13, 'Correct password, welcome! $'
incorrect_msg db 10, 13, 'Incorrect password, please try again! $'
base 		db 11111111b  
			db 10 dup(0)
pass          db 'hello'
pass_length   equ ($-pass)

end start


