;===============================================================================
;
;                         Task # 2. Customizable frame.
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

CFG_LEN       equ 9d
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



start:      VRAM_INIT

            call read_args

            call draw_frame

            call draw_text
            
            DOS_EXIT


;-----Read_args procedure-------------------------------------------------------
;
;     brief: Gets the length of arguments in command line, width,
;            height, attribute and the address of the string and
;            writes them in variables.
;
;     example: 10 10 0a *123456789 text (custom configuration).
;              10 10 0a 0 (0 or 1) text (default configuration,
;                                        currently 2 available).
;
;     entry: none
;
;     destroys: ax, bx, si
;
;     return: variables -> args_len, frame_width, frame_height, frame_color,
;                          frame_color, frame_address.
;
;-------------------------------------------------------------------------------

read_args   proc

            mov si, ARGS_ADDR             ; args address
            lodsb                         ; al = len of args
            mov args_len, ax              

            call skip_spaces
            call read_num           
            mov frame_width, ax               

            call skip_spaces
            call read_num           
            mov frame_height, ax                 

            call skip_spaces
            call read_num           
            mov frame_color, al                

            call skip_spaces        
            call read_cfg                      
            mov frame_address, ax
              
            ret

            endp
;-----End of read_args procedure------------------------------------------------

;-----Skip_spaces procedure-----------------------------------------------------
;
;     brief: Skips space symbols.
;
;     entry: si
;
;     destroys: ax, si
;
;     return: incremented si.
;
;-------------------------------------------------------------------------------
skip_spaces proc

            lodsb                   ; al = symbol
            cmp al, ' '            
            je skip_spaces          ; find more spaces
            dec si                  ; si has been incremented, but al != ' '

            ret

            endp
;-----End of skip_spaces procedure----------------------------------------------

;-----Read_num procedure--------------------------------------------------------
;
;     brief: Reads the number from the command line and puts into a variable.
;
;     entry: si
;
;     detroys: ax, bx, si
;
;     return: incremented si, the number in ax.
;
;-------------------------------------------------------------------------------
read_num    proc

            xor bx, bx              ; bx = 0
            xor ax, ax              ; ax = 0

            call read_dig
            mov bx, ax
            shl bx, 4

            call read_dig           ; TODO: What if it's 1 <= ... <= 9 read 1 digit
            add ax, bx

            ret
            endp
;------End of read_num procedure------------------------------------------------

;-----Read_dig procedure--------------------------------------------------------
;
;     brief: Reads a digit in hex.
;
;     entry: si
;
;     destroys: ax, si
;
;     return: incremented si, digit that's stored in ax
;
;-------------------------------------------------------------------------------
read_dig    proc 
            lodsb
            sub al, '0'             ; 0 <= ... <= 9
            
            cmp al, 10d
            jb @@end

            sub al, -'0' + 'a' - 10 ; a <= ... < = f
@@end:
            ret
            endp
;-----End of read_dig procedure-------------------------------------------------

;-----Read_cfg procedure--------------------------------------------------------
;
;     brief: Gets the address of the default configuration string or
;                                the custom /- - - - - - - - - -/
;
;     entry: si
;
;     destroys: ax, si
;
;     return: incremented si, address of the string in ax.
;
;-------------------------------------------------------------------------------
read_cfg    proc

            lodsb
            cmp al, '*'
            je @@new_cfg

            xor ah, ah              
            sub al, '0'

            mov bx, CFG_LEN                                                 
            mul bl
            add ax, offset control_str

            add si, 1
            mov text_address, si 

            ret
            
@@new_cfg:
            mov ax, si  

            add si, 9                   ;  *123456789 -> shift 9 symbols to right
            mov text_address, si           

            ret

            endp
;-----End of read_cfg procedure-------------------------------------------------

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

            mov si, frame_address           ; get the address of the cfg string 

            mov ax, WINDOW_HEIGHT  
            sub ax, frame_height            ; get height

            shr ax, 1                       ; (WINDOW_HEIGHT - height) / 2

            mov cx, WINDOW_WIDTH  
            mul cx                          ; y * WINDOW_WIDTH

            sub cx, frame_width             
            shr cx, 1                       ; (WINDOW_WIDTH - width) / 2
            add ax, cx                      ; y * defaul_width + x
            shl ax, 1                       ; (y * WINDOW_WIDTH + x) * 2; 2 byte slot

            mov di, ax

            mov ah, frame_color             ; get color

            mov bx, frame_height            ; get height

            mov dx, frame_width             ; get width
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
            stosw

            lodsb
            mov cl, dl              ; set the width
            rep stosw

            lodsb
            stosw

            mov cx, -2d             ; -2 corners        ; TODO: maybe remove this (do it above) use only 1 register
            add cx, WINDOW_WIDTH    ;  
            sub cx, dx              ;
            shl cx, 1               ; / 2
            
            add di, cx
            
            ret
            endp
;-----End of procedure----------------------------------------------------------


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

;-----Draw_text procedure-------------------------------------------------------
; 
;     brief: Draws centred text.
;    
;     entry: si, di, ax, cx
;
;     destroys: si, di, ax, cx
;
;     return: incremented di, si, text.
;
;-------------------------------------------------------------------------------
draw_text   proc

            mov si, [text_address]

            call skip_spaces                            ; TODO: more precise description

            mov cx, 80h
            add cx, [args_len]
            sub cx, si
            add cx, 1

            mov di, WINDOW_WIDTH * WINDOW_HEIGHT

            mov ax, cx
            shr ax, 1
            shl ax, 1

            sub di, ax

            mov ah, frame_color
            cmp cx, (WINDOW_WIDTH - 2) * (WINDOW_HEIGHT - 2)
            ja @@end

@@draw_symbol:
    
            lodsb                                      
            stosw
            loop @@draw_symbol

@@end:
            ret
            endp

;-----Default configuration string----------------------------------------------
control_str     db 0c9h, 0cdh, 0bbh, 0bah, 20h, 0bah, 0c8h, 0cdh, 0bch ; fix text
                db 03h, 03h, 03h, 03h, 20h, 03h, 03h, 03h, 03h         ; TODO: ASCII symbols
;-----End of default configuration string

;-----Variables-----------------------------------------------------------------
args_len      dw 0

frame_height  dw 0

frame_width   dw 0

frame_color   db 0

frame_address dw 0

text_address  dw 0
;-----End of variables-------------------------------------------------------------------------

end start
