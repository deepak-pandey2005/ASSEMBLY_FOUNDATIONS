section .data ; all the data are stored here 

message: db "hello world",10 ; it is a variable named 'message' and 'db' means define bytes and '10 is the \n in ASCII code'

section .text ; here resides the executable code
global _start ; entry point of an program

_start:
    mov rax,1  ; rax is a syscall number and 1 is write syscall for writing anything
    mov rdi,1  ; file descriptor stdout.
    mov rsi,message ; move the message label to rsi registor
    mov rdx,12 ; specifies the length 
    syscall
    mov rax,60 ; syscal = 60 'exit'
    xor rdi,rdi ; it is for cleaning the rdi as we know that the xor of same element is zero
    syscall


;  nasm -felf64 hello.asm
;  ld hello.o