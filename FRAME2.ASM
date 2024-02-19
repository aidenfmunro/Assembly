.model tiny
.code
.286
org 100h

locals @@

WINDOW_WIDTH  equ 80d

WINDOW_HEIGHT equ 25d                ; change the name to window_height

END_SYMBOL    equ 0dh

VRAM_ADDR     equ 0b800h

ARGS_ADDR     equ 80h 

EXIT_CODE     equ 4c00h

CFG_LEN       equ 9d

dos_exit    macro
            mov ax, EXIT_CODE
            int 21h
            endm

vram_init   macro
            mov bx, VRAM_ADDR
            mov es, bx
            endm




start:
            vram_init

            call read_args

            call draw_frame

            ; call draw_text
            
            dos_exit



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

            call skip_spaces               ; TODO !!! VARIABLES !!!!!!!!
            call read_cfg                      
            mov frame_address, ax                 

            ret

            endp

draw_frame  proc

            call frame_init                 

            call draw_line

            call draw_middle
            
            call draw_line

            ret

            endp

frame_init  proc

            mov si, frame_address        ; get the address of the cfg string 

            mov ax, WINDOW_HEIGHT  
            sub ax, frame_height        ; get height

            shr ax, 1               ; (WINDOW_HEIGHT - height) / 2

            mov cx, WINDOW_WIDTH  
            mul cx                  ; y * WINDOW_WIDTH

            sub cx, frame_width       ; get width
            shr cx, 1               ; (WINDOW_WIDTH - width) / 2
            add ax, cx              ; y * defaul_width + x
            shl ax, 1               ; (y * WINDOW_WIDTH + x) * 2; 2 byte slot

            mov di, ax

            xor al, al              ; clean al to prevent +3 hrs debugging 
            mov ah, frame_color     ; get color

            mov bx, frame_height    ; get height

            mov dx, frame_width     ; get width
            sub dx, 2               ; - 2 corners

            ret

            endp

draw_line   proc

            lodsb
            stosw

            lodsb
            mov cl, dl
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



draw_middle proc
            call draw_line

            sub si, 3               ; get back to the middle 3 symbols
            dec bx
            cmp bx, 0

            jne draw_middle
    
            add si, 3               ; get back 
            
            ret
            endp


read_cfg  proc

            lodsb
            cmp al, '*'
            je @@new_cfg

            xor ah, ah              
            sub al, '0'

            mov bx, CFG_LEN                                                 
            mul bl
            add ax, offset control_str ; retrun  

            ret
            
@@new_cfg:
            mov ax, si            

            ret




skip_spaces proc

            lodsb                   ; al = symbol
            cmp al, ' '            
            je skip_spaces          ; find more spaces
            dec si                  ; si has been incremented, but al != ' '

            ret

            endp



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



read_dig    proc 
            lodsb
            sub al, '0'             ; 0 <= ... <= 9
            
            cmp al, 10d
            jb @@end

            sub al, -'0' + 'a' - 10 ; a ... f
@@end:
            ret
            endp


draw_text   proc

            call skip_spaces                            ; TODO: more precise description

            mov di, WINDOW_WIDTH * WINDOW_HEIGHT        ; TODO: change to mov

@@draw_symbol:

            lodsb
            cmp al, END_SYMBOL                          ; calculate the len of the tex for further exploit
            je @@end
            stosw

            jmp @@draw_symbol
@@end:
            ret
            endp

control_str     db 0c9h, 0cdh, 0bbh, 0bah, 20h, 0bah, 0c8h, 0cdh, 0bch ; fix text
                db 03h, 03h, 03h, 03h, 20h, 03h, 03h, 03h, 03h         ; TODO: ASCII symbols

args_len      dw 0

frame_height  dw 0

frame_width   dw 0

frame_color   db 0

frame_address dw 0

end start
