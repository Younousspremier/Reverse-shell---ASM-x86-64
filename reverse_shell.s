section .data
    msg db "Hello, World!", 10    ; 10 est le caractère de nouvelle ligne
    len equ $ - msg

section .text
    global _start

_start:
    ; write(1, msg, len)
    mov eax, 4          ; syscall write (4 en 32 bits)
    mov ebx, 1          ; stdout (descripteur de fichier 1)
    mov ecx, msg        ; buffer contenant le message
    mov edx, len        ; longueur du message
    int 0x80            ; interruption pour appel système

    ; exit(0)
    mov eax, 1          ; syscall exit (1 en 32 bits)
    mov ebx, 0          ; code de sortie 0
    int 0x80            ; interruption pour appel système
