;-----Entry settings------------------------------------------------------------
.model tiny
.code
.286
org 100h
locals @@
;-----End of entry settings-----------------------------------------------------

start:  mov cx, pass_length
        mov bx, offset pass

        mov dx, offset entry_msg
        mov ah, 09h
        int 21h


again:	mov ah, 08h
		int 21h

		add al, 2d
		cmp al, [bx]
		jne error
		inc bx
		loop again

		mov dx, offset correct_msg
		mov ah, 09h
		int 21h

		jmp over

error:	mov dx, offset incorrect_msg
		mov ah, 09h
		int 21h

over:	mov ah,4ch
		int 21h


entry_msg     db 10, 13, 'Enter your password: $'
correct_msg   db 10, 13, 'Correct password, welcome! $'
incorrect_msg db 10, 13, 'Incorrect password, please try again! $'
pass          db 'hello'
pass_length   equ ($-pass)
end start


