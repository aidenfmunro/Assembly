;===============================================================================
;
;                         Task # 3. Resident frame.
;
;===============================================================================

;-----Entry settings------------------------------------------------------------
.model tiny
.code
.286
org 100h
locals @@
;-----End of entry settings-----------------------------------------------------

;-----Constants-----------------------------------------------------------------
WINDOW_WIDTH  equ 80d

WINDOW_HEIGHT equ 25d                

END_SYMBOL    equ 0dh

VRAM_ADDR     equ 0b800h

ARGS_ADDR     equ 80h 

EXIT_CODE     equ 4c00h

ENTRY_SYM     equ 02h               ; '1'

FRAME_HEIGHT  equ 12d

FRAME_WIDTH   equ 13d

FRAME_COLOR   equ 05h
;-----End of constants----------------------------------------------------------

;-----Macros--------------------------------------------------------------------
DOS_EXIT    macro
            mov ax, EXIT_CODE
            int 21h
            endm

VRAM_INIT   macro
            mov bx, VRAM_ADDR
            mov es, bx
            endm
;-----End of macros-------------------------------------------------------------

start:      jmp main

;-----Draw_frame procedure------------------------------------------------------
;
;     brief: Draws the frame.
;
;     entry: si
;
;     destroys: ax, bx, cx, dx, si, di
;
;     return: frame in console, incremented si, di.
;
;-------------------------------------------------------------------------------
draw_frame  proc

            call frame_init                 

            call draw_line

            call draw_middle
            
            call draw_line

            ret

            endp
;-----End of draw_frame_procedure-----------------------------------------------

;-----Frame_init procedure------------------------------------------------------
;
;     brief: Initializes registers for frame drawing usage.
;
;     entry: -
;
;     destroys: ax, cx, bx, dx, si, si
;
;     return: set string address in si, video mem address in di,
;             frame height in dx, frame width in bx.
;             
;-------------------------------------------------------------------------------
frame_init  proc

            VRAM_INIT

            push cs
            pop ds

            mov si, offset control_str      ; get the address of the cfg string 

            mov di, 0

            mov ah, FRAME_COLOR             ; get color

            mov bx, FRAME_HEIGHT            ; get height

            mov dx, FRAME_WIDTH             ; get width
            sub dx, 2                       ; - 2 corners

            ret

            endp
;-------------------------------------------------------------------------------

;-----Draw_line procedure-------------------------------------------------------
;
;     brief: Draws a seperate line.
;
;     entry: si, di, ax, cx, dx
;
;     destroys: si, di
;
;     return: line of a frame, incremented di, si.
;
;-------------------------------------------------------------------------------
draw_line   proc

            lodsb
            mov cx, 1
            stosw

            lodsb
            mov cx, dx              ; set the width
            rep stosw

            lodsb
            mov cx, 1
            stosw

            mov cx, -2d             ; -2 corners        ; TODO: maybe remove this (do it above) use only 1 register
            add cx, WINDOW_WIDTH    ;  
            sub cx, dx              ;
            shl cx, 1               ; / 2
            
            add di, cx
            
            ret

            endp
;-----End of draw_line procedure----------------------------------------------------------


;-----Draw_middle procedure-----------------------------------------------------
; 
;     brief: Draws the middle section of the frame.
;    
;     entry: si, di, ax, cx, bx
;
;     destroys: si, di, ax, cx, bx
;
;     return: incremented di, si, middle section of the frame.
;
;-------------------------------------------------------------------------------
draw_middle proc

            call draw_line

            sub si, 3               ; get back to the middle 3 symbols
            dec bx
            cmp bx, 0

            jne draw_middle
    
            add si, 3               ; get back 
            
            ret

            endp
;-----End of draw_middle procedure----------------------------------------------

;-----Draw_regs procedure-------------------------------------------------------
; 
;     brief: Draws the middle section of the frame.
;    
;     entry: si, di, ax, cx, bx
;
;     destroys: si, di, ax, cx, bx
;
;     return: incremented di, si, middle section of the frame.
;
;-------------------------------------------------------------------------------
draw_regs   proc

            mov si, offset regs_names

            mov ah, FRAME_COLOR

            mov di, (WINDOW_WIDTH + 2) * 2
            
            mov bp, sp

            mov cx, 12
next:
            lodsb
            stosw

            lodsb
            stosw

            mov al, ' '
            stosw

            mov al, '='             
            stosw

            mov al, ' '
            stosw

            mov bx, [bp + 2]
            mov reg_val, bx

            shr bx, 12
            mov bl, cs:[offset hex_table + bx]
            mov al, bl
            stosw

            mov bx, reg_val
            and bx, 00f00h
            shr bx, 8
            mov bl, cs:[offset hex_table + bx]
            mov al, bl
            stosw

            mov bx, reg_val
            and bx, 000f0h
            shr bx, 4
            mov bl, cs:[offset hex_table + bx]
            mov al, bl
            stosw

            mov bx, reg_val
            and bx, 0000fh
            shr bx, 0
            mov bl, cs:[offset hex_table + bx]
            mov al, bl
            stosw

            add di, WINDOW_WIDTH * 2 - 18

            add bp, 2

            loop next

            ret 

            endp
;-----End of draw_regs procedure------------------------------------------------

main:       mov ax, 3509h               
			int 21h		                ; get interrupt vector address -> es:bx

			mov Old09Offs, bx
			mov bx, es
			mov Old09Seg, bx

			push ds                     ; save ds
			push cs
			pop ds
			mov dx, offset my_int09
			mov ax, 2509h
			int 21h		                ; set interrupt vector address -> ds:dx
			pop ds                      ; restore ds

			mov dx, offset end_of_prog
			shr dx, 4
			inc dx 		                ; sizeof(program) / 16 + 1

			mov ax, 3100h               
			int 21h                     ;  terminate and stay resident


my_int09	proc

            push ax                     ; save ax

            in al, 60h
            cmp al, ENTRY_SYM           ; '1'

            jne @@end

			in al, 61h                  ; symbol
            or al, 80h                  ; make higher bit 1
            out 61h, al

            and al, not 80h
            out 61h, al

;-----EOI------------------------------------------------------------------------

            mov al, 20h			        ; say to PPI that our interrupt is over
		    out 20h, al		            ; so other interrupts can play

;-----End of processing the interrupt-------------------------------------------
            
;-----
			push cs ds ss es sp bp di si dx cx bx ax

            call draw_frame

            call draw_regs

            pop ax bx cx dx si di bp sp es ss ds 

            add sp, 2 ; <-------------------------------------------------------

            pop ax

            iret        

@@end:      pop ax

            db 0eah                     ; far jmp ; TODO: why can't jmp otherwise?
Old09Offs	dw 0
Old09Seg	dw 0

			endp

;-----Variables-----------------------------------------------------------------
pop_up        db 0
;-----End of variables----------------------------------------------------------

;-----Default configuration string----------------------------------------------
control_str   db 0c9h, 0cdh, 0bbh, 0bah, 20h, 0bah, 0c8h, 0cdh, 0bch ; TODO: ASCII symbols
regs_names    db 'axbxcxdxsidibpspesssdscs'

hex_table     db '0123456789ABCDEF'
reg_val       dw 0
                
;-----End of default configuration string

end_of_prog:
end start
