section .text
    global _start

_start:
    ; Étape 1 : Créer un socket
    ; socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
    ; AF_INET = 2, SOCK_STREAM = 1, IPPROTO_IP = 0
    
    mov eax, 102        ; syscall socketcall
    mov ebx, 1          ; SYS_SOCKET (sous-fonction pour créer un socket)
    
    ; Préparer les arguments pour socket() dans un tableau sur la pile
    push dword 0        ; IPPROTO_IP (protocole)
    push dword 1        ; SOCK_STREAM (type)
    push dword 2        ; AF_INET (domaine)
    
    mov ecx, esp        ; ecx pointe vers les arguments sur la pile
    int 0x80            ; appel système
    
    ; Le descripteur de fichier du socket est maintenant dans eax
    ; Nous allons le préserver dans edi pour une utilisation ultérieure
    mov edi, eax
    
    ; Vérification d'erreur (si eax < 0, il y a eu une erreur)
    test eax, eax
    js socket_error     ; jump if sign (négatif)
    
    ; À ce stade, le socket est créé avec succès

    ; Nous ajouterons les étapes suivantes dans les prochaines parties

    ; Pour le moment, terminons proprement
    jmp exit

socket_error:
    ; Gérer l'erreur du socket ici
    ; Pour simplifier, nous allons simplement sortir avec un code d'erreur
    
exit:
    ; exit(0) ou exit(1) en cas d'erreur
    mov eax, 1          ; syscall exit
    xor ebx, ebx        ; code de sortie 0 si tout va bien
    int 0x80
