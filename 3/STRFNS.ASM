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
; [assumes]: cdecl, df = 0
;
;\----------------------------/

my_strlen proc						

		push bp
		mov bp, sp

		mov di, [bp + 4]
	
		max_len equ 100h		; max length equals 256d
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
; [entry]: arg1 - bytes count, arg2 - symbol, arg3 - address
;
; [destroy]: ax, cx, di
;
; [return]: ax - byte address or 0 if not found
;
; [assumes]: cdecl, df = 0
;
;\----------------------------/

my_memchr proc

		push bp
		mov bp, sp

		mov di, [bp + 4]
		mov al, [bp + 6]
		mov cx, [bp + 8]

		repne scasb

		je @@found	

		xor ax, ax
		jmp @@notfound

		pop bp
		ret

@@found:
		mov ax, di
		dec ax

		pop bp
		ret 

@@notfound:
		pop bp
		ret 

		endp
		
;/----------[memset]----------\
;
; [entry]: arg1 - bytes count, arg2 - symbol, arg3 - addres 
;
; [destroy]: di, al, cx
;
; [return]: ax - dest address
;
; [assumes]: cdecl, df = 0 
;
;\----------------------------/

my_memset proc 		

		push bp
		mov bp, sp

		mov di, [bp + 4]		; address
		mov al, [bp + 6]		; which symbol
		mov cx, [bp + 8]		; byte count

		mov dx, di				; copy address

		rep stosb				; fill

		mov ax, dx				; move result to ax

		pop bp
		ret

		endp

;/----------[memcpy]-----------\
;
; [entry]:  arg1 - address, arg2 - src address, arg3 - byte count
;
; [destroy]: cx, si, di, 
;
; [return]: ax - dest address
;
; [assumes]: pascal, df = 0
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

		pop bp
		ret 6

@@end:
		pop bp
		ret 6

		endp

;/----------[memcmp]----------\
;
; [entry]: arg1 - address of 1st str (es), arg2 - address of 2nd str (ds), arg3 - byte count
;
; [destroy]: 
;
; [return]:
;
; [assumes]: pascal, df = 0
;
;\----------------------------/

my_memcmp proc

		push bp
		mov bp, sp

		mov cx, [bp + 4]
		mov si, [bp + 6]
		mov di, [bp + 8]

		cmp si, di				; si == di
		je @@end
		
		test cx, cx				; cx == 0
		je @@end

		repe cmpsb


		pop bp
		ret 6

@@end:
		pop bp
		ret 6

		endp

my_memmove proc
		push bp
		mov bp, sp

		mov cx, [bp + 4]
		mov si, [bp + 6]
		mov di,

		cmp di, si				; si == di
		je @@end

		
@@end:
		pop bp
		ret 6


		endp
main proc
		cld						; set df = 0

		push offset msg
		call my_strlen
		add sp, 02h

		.dos_exit
		

main endp

end 	start