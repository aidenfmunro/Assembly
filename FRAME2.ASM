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

            mov si, [bp + 4]        ; address 

            mov ax, .default_height ;
            sub ax, [bp + 8]        ;
            shr ax, 1               ; (default width - width) / 2

            mov cx, .default_width  
            mul cx                  ; y * default width

            sub cx, [bp + 10]       ; 
            shr cx, 1               ;
            add ax, cx              ;
            shl ax, 1

            mov di, ax

            xor al, al
            mov ah, [bp + 6]        ; color

            xor bh, bh            
            mov bl, [bp + 8]        ; height

            xor dh, dh
            mov dl, [bp + 10]       ; width

            lodsb
            stosw

            lodsb
            mov cl, dl
            rep stosw

            lodsb
            stosw

            pop bp
            ret
            endp


read_args   proc

            pop bp
            ; mov bp, sp

            mov si, 80h             ; args address
            lodsb                   ; al = len of args
            xor cx, cx              ; cx = 0
            mov cl, al              ; al = cl

            add si, 1               ; skip space
            call read_num           
            push ax                 ; push width

            add si, 1               ; skip space
            call read_num           
            push ax                 ; push height

            add si, 1               ; skip space
            call read_num           
            push ax                 ; push color

            ; call read_cfg           
            ; push ax                 ; push
            push offset control_str

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

            xor ah, ah              ; clean up
            sub al, '0'

            mov bx, 9                                                   
            mul bl
            add ax, offset control_str

            ret
            
@@new_cfg:
            ;push ax                 ; ?
            mov ax, si
            ;add si, 9
            ;pop ax            

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

end start
