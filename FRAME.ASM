;/---------------------------------------------------------------------\
;				Task # 2.
;			 Create a rectangle frame 
;			       Aiden Munro
;\---------------------------------------------------------------------/

.model tiny	; generates a COM file

;/---------------------------------------------------------------------\
; 			   Usable constants

vid_seg		 = 0b800h	; video segment code

left_bottom      = 0ec8h	; <------------------------------------|
right_bottom   	 = 0ebch	; 	    frame symbol codes
left_top       	 = 0ec9h	; 
right_top 	 = 0ebbh	; 
side_pipe	 = 0ecdh	; 
stand_pipe	 = 0ebah	; <------------------------------------|

x1		 = 10		;	  top left coordinates
y1		 = 5		;
	
x2		 = 70		;	  bottom right coordinates
y2		 = 10		;

;\---------------------------------------------------------------------/

.286		; 16-bit microprocessor
 			
.code		; code segment

org 100h

start:		mov bx, vid_seg
		mov es, bx

		mov di, (y1 * 80 + x1) * 2
		mov cx, x2 - x1			; width
		mov ax, side_pipe
		call print_row

		
		mov cx, x2 - x1
		call print_row

 																																
		mov ax, 4c00h
		int 21h

print_row:	stosw
		loop print_row
		ret

end start