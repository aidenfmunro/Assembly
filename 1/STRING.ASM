.model tiny
.code
.286
org 100h

start:
	mov ah, 09h
	mov dx, offset somestr
	int 21h


	mov ax, 4C00h
	int 21h	

somestr db 'hello', 0dh, 0ah, '$'
end	start 