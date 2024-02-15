.model tiny
.code
.286
org 100h

locals @@

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


control_str     db 0c9h, 0cdh, 0bbh, 0bah, 20h, 0bah, 0c8h, 0cdh, 0bch 
                db 0dah, 0c4h, 0bfh, 0b3h, 20h, 0b3h, 0c0h, 0c4h, 0d9h



read_args   proc

            push bp
            mov bp, sp

            mov si, 80h             ; args address
            lodsb                   ; al = len of args
            xor cx, cx              ; cx = 0
            mov cl, al              ; al = cl

            add si, 1
            call read_num               
            push ax                 

            add si, 1
            call read_num
            push ax                 ; push ah - width, al - height

            ;call skip_spaces
            ;call read_num
            ;push ax                 ; push al - attributes

            ;call skip_spaces
            ;call read_param
            ;push ax                 ; string address
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

read_param  proc

            lodsb
            cmp al, '*'
            je @@new_param

            sub al, '0'
            mov bx, 9                                                   
            mul bl
            add ax, offset control_str
            
@@new_param:
            push ax
            mov ax, si
            add si, 9
            pop ax            

@@end:
            ret
            endp



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



end start
