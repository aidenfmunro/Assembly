.model tiny
.code
.286
org 100h

locals @@

;/---------[constants]----------\
default_width equ 80d

default_height equ 25d

end_symbol equ 0dh

vram equ 0b800h

exit_code equ 4c00h
;\------------------------------/



;/----------[macros]----------\
dos_exit    macro
            mov ax, exit_code
            int 21h
            endm

vram_init   macro
            mov bx, vram          ; vram address
            mov es, bx
            endm
;\----------------------------/



start:
            vram_init

            call read_args

            call draw_frame

            add sp, 8

            call draw_text
            
            dos_exit

;/----------[frame_init]-------------\
;
; [entry]: stack
;
; [destroy]: ax, bx, cx, dx, si 
;
; [return]: -
;
; [assumes]: stack frame:
;            -> [bp + 4]: address of the cfg string
;            -> [bp + 6]: color number
;            -> [bp + 8]: height
;            -> [bp + 10]: width
;
;\---------------------------------/


draw_text   proc

            call skip_spaces

            xor ax, ax
            add ax, default_width * default_height
            mov di, ax

            call @@draw_symbol
            jmp @@end

@@draw_symbol:

            lodsb
            cmp al, end_symbol
            je @@end
            stosw

            jmp @@draw_symbol
@@end:
            ret
            endp

;/----------[frame_init]---------\
;
; [entry]: -
;
; [destroy]: ax, bx, cx, dx, si, di 
;
; [return]: -
;
; [assumes]: -
;
;\-------------------------------/     


frame_init  proc

            mov si, [bp + 4]        ; get the address of the cfg string 

            mov ax, default_height  
            sub ax, [bp + 8]        ; get height
            shr ax, 1               ; (default_height - height) / 2

            mov cx, default_width  
            mul cx                  ; y * default_width

            sub cx, [bp + 10]       ; get width
            shr cx, 1               ; (default_width - width) / 2
            add ax, cx              ; y * defaul_width * x
            shl ax, 1               ; (y * default_width * x) * 2

            mov di, ax

            xor al, al              ; clean al to prevent +3 hrs debugging 
            mov ah, [bp + 6]        ; get color

            xor bh, bh              ; clean bh to prevent +3 hrs debugging
            mov bl, [bp + 8]        ; get height

            xor dh, dh              ; clean bh to prevent +3 hrs debugging
            mov dl, [bp + 10]       ; get width
            sub dl, 2               ; - 2 corners

            ret

            endp

;/----------[draw_frame]---------\
;
; [entry]: -
;
; [destroy]: ax, bx, cx, dx, si, di 
;
; [return]: -
;
; [assumes]: -
;
;\-------------------------------/      

draw_frame  proc

            push bp
            mov bp, sp

            call frame_init

            call draw_line

            call draw_middle
            
            call draw_line

            pop bp

            ret

            endp

;/----------[draw_line]-------------\
;
; [entry]: dl - width
;
; [destroy]: cx
;
; [return]: -
;
; [assumes]: di is set
;
;\----------------------------------/

draw_line   proc

            lodsb
            stosw

            lodsb
            mov cl, dl
            rep stosw

            lodsb
            stosw

            mov cx, -2d             ; -2 corners
            add cx, default_width   ;  
            sub cx, dx              ;
            shl cx, 1               ; / 2
            
            add di, cx
            
            ret
            endp

;/----------[draw_middle]-------------\
;
; [entry]: si, di, bx - height
;
; [destroy]: bx (will be 0)
;
; [return]: -
;
; [assumes]: si, di are set
;
;\------------------------------------/

draw_middle proc
            call draw_line

            sub si, 3               ; get back to the middle 3 symbols
            dec bx
            cmp bx, 0

            jne draw_middle
    
            add si, 3               ; get back 
            
            ret
            endp

;/----------[read_args]------------\
;
; [entry]: -
;
; [destroy]: ax
;
; [return]: stack frame
;
; [assumes]: -
;
;\---------------------------------/

read_args   proc

            pop bp                  ; push bp; mov bp, sp; pop bp

            mov si, 80h             ; args address
            lodsb                   ; al = len of args
            xor cx, cx              ; cx = 0
            mov cl, al              ; al = cl

            call skip_spaces
            call read_num           
            push ax                 ; push width

            call skip_spaces
            call read_num           
            push ax                 ; push height

            call skip_spaces
            call read_num           
            push ax                 ; push color

            call skip_spaces
            call read_cfg           ; push read
            push ax                 

            push bp

            ret
            endp

;/----------[read_cfg]----------\
;
; [entry]: si
;
; [destroy]: ax, bx
;
; [return]: cfg string address
;
; [assumes]: -
;
;\---------------------------------/

read_cfg  proc

            lodsb
            cmp al, '*'
            je @@new_cfg

            xor ah, ah              
            sub al, '0'

            mov bx, 9                                                   
            mul bl
            add ax, offset control_str ; retrun  

            ret
            
@@new_cfg:
            mov ax, si            

            ret



;/----------[skip_spaces]----------\ 
;
; [entry]: si
;
; [destroy]: -
;
; [return]: si
;
; [assumes]: -
;
;\---------------------------------/

skip_spaces proc

            push ax
            jmp @@skip
@@skip:
            lodsb                  ; al = symbol
            cmp al, ' '            
            je  @@skip             ; find more spaces
            dec si                 ; si has been incremented, but al != ' '

            pop ax                  
            ret

            endp

;/----------[read_num]-------------\
;
; [entry]: -
;
; [destroy]: ax, bx
;
; [return]: number in ax
;
; [assumes]: -
;
;\---------------------------------/

read_num    proc

            xor bx, bx              ; bx = 0
            xor ax, ax              ; ax = 0

            call read_dig
            mov bx, ax
            shl bx, 4

            call read_dig
            add ax, bx

            ret
            endp

;/----------[read_dig]-------------\
;
; [entry]: 
;
; [destroy]: ax
;
; [return]: digit in al
;
; [assumes]: di is set
;
;\---------------------------------/

read_dig    proc 
            lodsb
            sub al, '0'             ; 0 <= ... <= 9
            
            cmp al, 10d
            jb @@end

            sub al, -'0' + 'a' - 10 ; a ... f
            ret
@@end:
            ret
            endp



control_str     db 0c9h, 0cdh, 0bbh, 0bah, 20h, 0bah, 0c8h, 0cdh, 0bch, 0dh
                db 03h, 03h, 03h, 03h, 20h, 03h, 03h, 03h, 03h, 0dh

end start
