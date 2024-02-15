	cld	 	 	; df = 0 (di++)

	stosb		 	; es:[di++] = al;

	stosw		 	; es:[di]   = ax; di += 2;

	stosd		 	; ...       = eax

	stosq		 	; ...       = rax

	mov cx, 40d
next:	stosw
	loop next

	mov cx, 40d
	rep stosw		; while (cx--) {es:[di] = ax; di += 2;}

	lodsb			; al = ds:[si++]
	lodsw, lodsd, lodsq

	movsb, movsw, ... 	; es:[di++] = ds:[si++]

	rep movsb		; while (cx--) es:[di++] = ds:[si++]
	
	cmpsb			; cmp ds:[si++], es:[di++]

	rep cmpsb		; while (cx--) cmp es:[di++] == ds:[si++]

	repe cmpsb		; while (cx-- && es:[di++] == ds:[si++]) ; strcmp
			        ; repeat while equal

	scasb			; cmp al, es:[di++]

	xor al, al		; 0
	repne scasb		; while (cx-- && es:[di++] != al) ; strlen memchr

        ; TODO: strlen memchr memset memcpy memmove memcmp

	; cdecl & pascal (stack frame)

	; func (0x10, 0x20, 0x30)
	; func (P (0x10), P (0x20), P(0x30))

	push 40h ;	; 20 ;
	push 30h ; <- C ; 30 ; <- PASCAL
	push 20h ;	; 40 ;
	call func	call func
	add sp, 6 

	ret_address <- SP	func	 proc
	30h			     	 mov ax, [sp + 2] 
	20h				 push cx
	10h				 mov cx, [sp + 2] ; ???
	...
	 			func  	 proc
					 push bp 
					 mov bp, sp
					 mov ax, [bp + 4] ; 4 was 2
					 push cx
					 mov cx, [bp + 4] ; !!!
					 ...
					 pop bp
					 ret 6

ControlStrArray db '+-+| |+-+'	122222223
		db '/-\| |\_/'  455555556
				455555556
				788888889
		
		frame.com 40 15 4e *123456789 Hello Meow
		frame.com 40 15 4e 2