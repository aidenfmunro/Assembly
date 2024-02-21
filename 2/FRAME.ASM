;/---------------------------------------------------------------------\
;							  Task # 2.
;			 		  Create a rectangle frame 
;			       			 Aiden Munro
;\---------------------------------------------------------------------/

.model tiny	; generates a COM file

;/---------------------------------------------------------------------\
; 			   Usable constants

vid_seg		 	 = 0b800h	; video segment code

left_bottom      = 0c8h		; <----------------------------------------|
right_bottom   	 = 0bch		;  ¼É   frame symbol codes
left_top       	 = 0c9h		; 
right_top 	 	 = 0bbh		; 
side_pipe	 	 = 0cdh		; 
stand_pipe	 	 = 0bah		; <----------------------------------------|

x1		 		 = 10		;	  top left coordinates
y1		 		 = 5		;
	
x2		 		 = 70		;	  bottom right coordinates
y2		 		 = 10		;

dos_width	 	 = 80

;\---------------------------------------------------------------------/

.286		; 16-bit microprocessor
 			
.code		; code segment

org 100h

start:		mov bx, vid_seg
			mov es, bx



			mov di, (y1 * dos_width + x1) * 2
			mov cx, 1
			mov al, left_top
			mov ah, 01110011b
			call print_row

			mov cx, x2 - x1 - 2			; width
			mov al, side_pipe
			mov ah, 01110011b
			call print_row

			mov di, (y1 * dos_width + x2 - 1) * 2
			mov cx, 1
			mov al, right_top
			mov ah, 01110011b
			call print_row

			mov si, y1 + 1
			mov bx, y2
			mov dx, 80
			call print_mid

			mov di, (y2 * dos_width + x1) * 2
			mov cx, 1
			mov al, left_bottom
			mov ah, 01110011b
			call print_row

			mov cx, x2 - x1 - 2			; width
			mov al, side_pipe
			mov ah, 01110011b
			call print_row

			mov di, (y2 * dos_width + x2 - 1) * 2
			mov cx, 1
			mov al, right_bottom
			mov ah, 01110011b
			call print_row
	
			mov ax, 4c00h
			int 21h

print_row:	mov es:[di], ax
			add di, 2
			loop print_row
			ret
		
print_mid:  add di, (80d - (x2 - x1)) * 2

			mov al, stand_pipe
			mov es:[di], ax
			add di, 2

			mov cx, x2 - x1 - 2
			mov al, 32d
			call print_row

			mov al, stand_pipe
			mov es:[di], ax
			add di, 2
			
			add si, 1
			cmp si, bx
			jne  print_mid
			
			ret			

end start