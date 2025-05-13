; Fichier: hello.asm
section .data
    msg db "Hello, World!", 10  ; 10 est le caractère de nouvelle ligne
    len equ $ - msg

section .text
    global _start

_start:
    ; write(1, msg, len)
    mov rax, 1          ; syscall write
    mov rdi, 1          ; stdout
    mov rsi, msg        ; buffer
    mov rdx, len        ; longueur
    syscall

    ; exit(0)
    mov rax, 60         ; syscall exit
    mov rdi, 0          ; code de sortie 0
    syscall
