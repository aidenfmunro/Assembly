.model tiny
.code
.286
org 100h
local @@

.dos_exit		macro
				mov ax, 4c00h
				int 21h
				endm


start:	jmp main

msg db 'Greetings!', 0

;/----------[strlen]----------\
;
; [entry]:   di - string address	
;
; [destroy]: ax, cx, di
;
; [return]:  ax - string length
;
;\----------------------------/

my_strlen proc						; cdecl

		push bp
		mov bp, sp

		mov di, [bp + 4]
	
		max_len equ 100h
		mov cx, max_len			
		xor al, al				; al = 0
		
		repne scasb				; while (cx-- && es:[di++] != al)
	
		dec di					; null terminator doesn't count
		mov ax, di 				; put the result in ax
		
		pop bp
		ret

		endp

;/----------[memchr]----------\
;
; [entry]: di - string address, cx - bytes count, al - symbol
;
; [destroy]: ax, cx, di
;
; [return]: ax - byte address or 0 if not found
;
;\----------[memchr]----------/

my_memchr proc						; cdecl
		push bp
		mov bp, sp

		mov di, [bp + 4]
		mov al, [bp + 6]
		mov cx, [bp + 8]

		repne scasb

		je @@found	

		xor ax, ax
		jmp @@notfound

		ret

@@found:
		mov ax, di
		dec ax
		ret 

@@notfound:
		pop bp
		ret 

		endp
		
;/----------[memset]----------\
;
; [entry]: di - address, cx - bytes count
;
; [destroy]:
;
; [return]: ?
;
;\----------------------------/

my_memset:
		push bp
		mov bp, sp

		mov di, [bp + 4]		; address
		mov al, [bp + 6]		; which symbol
		mov cx, [bp + 8]		; byte count

		mov dx, di


;/----------[memset]-----------\
;
; [entry]: 
;
; [destroy] cx, si, di, 
;
; [return]: ax - dest address
;
;\-----------------------------/

my_memcpy	proc
		push bp           		
        mov  bp, sp       

		mov  cx, [bp + 4]		; byte count
        mov  si, [bp + 6] 		; src address
        mov  di, [bp + 8]		; dest address

		cmp si, di				; si == di
		je @@end
		
		test cx, cx				; cx == 0
		je @@end

		rep movsw

@@end:
		pop bp
		ret 6
my_memcpy	endp

main proc
		cld
		push offset msg
		call my_strlen
		add sp, 02h

		.dos_exit
		

main endp
end 	start