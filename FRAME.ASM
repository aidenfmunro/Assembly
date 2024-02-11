;/---------------------------------------------------------------------\
;				Task # 2.
;			 Create a rectangle frame 
;			       Aiden Munro
;\---------------------------------------------------------------------/

.model tiny	; generates a COM file

;/---------------------------------------------------------------------\;
; 			   Usable constants

vid_seg		 = 0b800h	

left_bottom      = 0ec8h	;	
right_bottom   	 = 0ebch	; 
left_top       	 = 0ec9h	; 
right_top 	 = 0ebbh	;

side_pipe	 = 0ecdh	;
stand_pipe	 = 0ebah	;

dos_width 	 = 80		;
dos_height	 = 50		;

x1		 = 10		;
y1		 = 5		;

x2		 = 70		;
y2		 = 10		;

;\---------------------------------------------------------------------/

.286		; 16-bit microprocessor
			
.code		; code segment

org 100h

start:
	mov bx, vid_seg
	mov es, bx
	mov di, (y1 * 80 + x1) * 2
	mov cx, x2 - x1			; width
	mov dx, y2 - y1			;
	call print_first_row 
	mov ax, side_pipe																																																		
	stosw

	mov ax, 4c00h
	int 21h

print_first_row:
	mov ax, side_pipe
	stosw
	push x2 - x1
	push di - cx * 
	jb print_first_row
	

	

end start

