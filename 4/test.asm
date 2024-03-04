.model tiny
.code
.286
org 100h
locals @@

start:  mov  ax, 1111h
        mov  bx, 2222h
        mov  cx, 3333h
        mov  dx, 4444h
        mov  si, 5555h
        mov  di, 6666h
        mov  bp, 7777h
        push 8888h
        pop  ds
        push 9999h
        pop  es
        push 0aaaah
        pop  ss
        
        jmp start

end start