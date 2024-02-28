;-----Entry settings------------------------------------------------------------
.model tiny
.code
.286
.org 100h
locals @@
;-----End of entry settings-----------------------------------------------------

start:      jmp main



















main:   mov ax, offset entry_msg
        mov ds, ax
        mov ah, 09h
        lea dx, entry_msg
        int 21h
        






entry_msg     db 10, 13, 'Enter your password: $'
correct_msg   db 10, 13, 'Correct password, welcome! $'
incorrect_msg db 10, 13, 'Incorrect password, please try again! $'
pass          db 'hello$'
pass_length   equ ($-pass)
end start



