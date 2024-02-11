;/---------------------------------------------------------------------\
;				Task # 2.
;			 Create a rectangle frame 
;			       Aiden Munro
;\---------------------------------------------------------------------/

.model tiny	; generates a COM file

;/---------------------------------------------------------------------\
;
; 			   Usable constants

vid_seg		 = 0b800h	

left_bottom      = 0ec8h	;	
right_bottom   	 = 0ebch	; 
left_top       	 = 0ec9h	; 
right_top 	 = 0ebbh	;

side_pipe	 = 0ecdh	;
stand_pipe	 = 0ebah	;

;\---------------------------------------------------------------------/

;/---------------------------------------------------------------------\
;
;			   Usable macros

.exit_m	macro
	mov ax, 4c00h
	int 21h
	endm

;\---------------------------------------------------------------------/

.286		; 16-bit microprocessor
			
.code		
org 100h

start:	mov bx, 0b800h
	mov																																																																																																																																																																 es, bx
	mov bx, (5 * 80 + 80 / 2) * 2																																																		
	mov byte ptr es:[bx], 65d	; 'A'
	mov byte ptr es:[bx+1], 4ch 
	mov ax, 4c00h
	int 21h

end start
