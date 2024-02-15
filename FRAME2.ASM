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
            
            .dos_exit

draw_frame  proc

            push bp
            mov bp, sp

            mov ah, [bp + 6]        ; color

            mov si, [bp + 4]        ; address 

            mov bl, [bp + 8]        ; height

            mov dl, [bp + 10]       ; width

            xor di, di
            add di, .default_width
            add di, .default_width
            ; sub di, dx
            ; shr di, 1

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

            push bp
            mov bp, sp

            mov si, 80h             ; args address
            lodsb                   ; al = len of args
            xor cx, cx              ; cx = 0
            mov cl, al              ; al = cl

            add si, 1
            call read_num           
            push ax                 ; push width

            add si, 1
            call read_num           
            push ax                 ; push height

            add si, 1
            call read_num           
            push ax                 ; push color

            push offset control_str ; push frame address

            call draw_frame

            pop ax
            pop ax
            pop ax
            pop ax

            pop bp
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

            sub al, '0'
            mov bx, 9                                                   
            mul bl
            add ax, offset control_str
            
@@new_cfg:
            push ax
            mov ax, si
            add si, 9
            pop ax            

@@end:
            ret
            endp



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
