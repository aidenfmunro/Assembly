.model tiny
.code
.286
org 100h

locals @@

.default_width equ 80d

.default_height equ 25d

.dos_exit   macro
            mov ax, 4c00h
            int 21h
            endm

.vram_init  macro
            mov bx, 0b800h          ; vram address
            mov es, bx
            endm

start:
            .vram_init

            call read_args

            call draw_frame
            
            .dos_exit

draw_frame  proc

            push bp
            mov bp, sp

            mov si, [bp + 4]        ; get the address of the cfg string 

            mov ax, .default_height ;
            sub ax, [bp + 8]        ; get height
            shr ax, 1               ; (default_height - height) / 2

            mov cx, .default_width  
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


            call draw_line


            call draw_middle
            

            call draw_line

            pop bp
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

            mov cx, -2d 
            add cx, .default_width
            sub cx, dx
            shl cx, 1
            
            add di, cx
            
            ret
            endp

draw_middle proc
            call draw_line

            sub si, 3
            dec bx
            cmp bx, 0

            jne draw_middle

            add si, 3
            ret
            endp

read_args   proc

            pop bp
            ; mov bp, sp

            mov si, 80h             ; args address
            lodsb                   ; al = len of args
            xor cx, cx              ; cx = 0
            mov cl, al              ; al = cl

            inc si               ; skip space
            call read_num           
            push ax                 ; push width

            inc si               ; skip space
            call read_num           
            push ax                 ; push height

            inc si               ; skip space
            call read_num           
            push ax                 ; push color

            inc si               ; skip space
            call read_cfg           ; push read
            push ax

            push bp
            ret
            endp

;/----------[read_params]----------\
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

read_cfg  proc

            lodsb
            cmp al, '*'
            je @@new_cfg

            xor ah, ah              
            sub al, '0'

            mov bx, 9                                                   
            mul bl
            add ax, offset control_str ; 

            ret
            
@@new_cfg:
            mov ax, si            

            ret



;/----------[skip_spaces]----------\ <-------------------------------/ RIP /
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

;skip_spaces proc
;
;            push ax
;            jmp @@skip
;@@skip:
;            lodsb                  ; al = symbol
;            cmp al, ' '            
;            je  @@skip             ; find more spaces
;            dec si                 ; si has been incremented, but al != ' '
;
;            pop ax                  
;            ret
;
;            endp

;/----------[read_num]-------------\
;
; [entry]: -
;
; [destroy]: -
;
; [return]: -
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
; [entry]: -
;
; [destroy]: -
;
; [return]: -
;
; [assumes]: -
;
;\---------------------------------/

read_dig    proc 
            lodsb
            sub al, '0'             ; 0 <= ... <= 9
            
            cmp al, 10d
            jb @@end

            sub al, -'0' + 'a' - 10
            ret
@@end:
            ret
            endp



control_str     db 0c9h, 0cdh, 0bbh, 0bah, 20h, 0bah, 0c8h, 0cdh, 0bch 
                db 03h, 03h, 03h, 03h, 20h, 03h, 03h, 03h, 03h

end start
