%include "constants.asm"

BITS 64

; =============================================================================
; Section .data : Buffers et réponse HTTP
; =============================================================================
section .data
    request_buffer     times 1024 db 0                ; Buffer de réception de la requête
    parsed_request     times 1026 db 0                ; [0] = méthode, [1..] = route, [1025] = content_len
    file_buffer        times 1024 db 0                ; Contenu du fichier lu
    http_header:           db "HTTP/1.0 200 OK", 13, 10, 13, 10  ; Réponse HTTP minimale

; =============================================================================
; Section .text : Code exécutable
; =============================================================================
section .text

global http_handle_request

extern parse_request
extern ft_strlen

; -----------------------------------------------------------------------------
; http_handle_request
; -----------------------------------------------------------------------------
; Point d'entrée principal pour gérer une requête HTTP.
; Attend :
;   - r13 : descripteur de socket client
; Effet :
;   - Lit la requête dans request_buffer
;   - Parse la méthode et la route dans parsed_request
;   - Appelle le handler selon la méthode
; -----------------------------------------------------------------------------
http_handle_request:
    push    rbp
    mov     rbp, rsp

    call    read_request
    push    rax                        ; sauvegarde adresse du buffer

    mov     rdi, rax                   ; rdi ← buffer de requête
    mov     rsi, parsed_request        ; rsi ← structure de sortie
    call    parse_request

    mov     rdi, rsi                   ; rdi ← parsed_request
    call    handle_method

    add     rsp, 8                     ; restore stack
    leave
    ret

; -----------------------------------------------------------------------------
; read_request
; -----------------------------------------------------------------------------
; Lit jusqu’à 1024 octets depuis le socket client.
; Entrée :
;   - r13 : socket client
; Sortie :
;   - rax ← pointeur vers request_buffer
; -----------------------------------------------------------------------------
read_request:
    mov     rax, SYS_READ
    mov     rdi, r13
    mov     rsi, request_buffer
    mov     rdx, 1024
    syscall

    mov     rax, request_buffer
    ret

; -----------------------------------------------------------------------------
; handle_method
; -----------------------------------------------------------------------------
; Traite la méthode HTTP contenue dans parsed_request.
; Entrée :
;   - rdi : pointeur vers parsed_request
; Effet :
;   - Appelle handle_get_method si méthode = GET
; -----------------------------------------------------------------------------
handle_method:
    cmp     BYTE [rdi], GET_METHOD
    je      handle_get_method
    ret

; -----------------------------------------------------------------------------
; handle_get_method
; -----------------------------------------------------------------------------
; Gère une requête GET. Lit le fichier demandé et l’envoie au client.
; Entrée :
;   - rdi : ignoré
;   - rsi : pointeur vers parsed_request
; Effets :
;   - Ouvre, lit, ferme le fichier demandé
;   - Envoie un header HTTP, puis le contenu du fichier
; -----------------------------------------------------------------------------
handle_get_method:
    push    rbp
    mov     rbp, rsp

    ; ---------------------------------------------------------
    ; Ouverture du fichier (route stockée à [rsi + 1])
    ; ---------------------------------------------------------
    push    rsi
    sub     rsp, 8

    mov     rdi, rsi
    add     rdi, 1                     ; rdi ← route (skip méthode)

    mov     rax, SYS_OPEN
    mov     rsi, O_RDONLY
    syscall

    mov     [rsp], rax                ; sauvegarde fd

    ; ---------------------------------------------------------
    ; Lecture du fichier dans file_buffer
    ; ---------------------------------------------------------
    mov     rdi, rax                  ; fd fichier
    mov     rsi, file_buffer
    mov     rdx, 1024
    mov     rax, SYS_READ
    syscall

    ; ---------------------------------------------------------
    ; Fermeture du fichier
    ; ---------------------------------------------------------
    mov     rdi, [rsp]
    mov     rax, SYS_CLOSE
    syscall

    ; ---------------------------------------------------------
    ; Envoi du header HTTP
    ; ---------------------------------------------------------
    mov     rdi, r13                  ; socket client
    mov     rsi, http_header
    mov     rdx, 19                   ; taille du header
    mov     rax, SYS_WRITE
    syscall

    ; ---------------------------------------------------------
    ; Calcul de la taille du fichier lu
    ; ---------------------------------------------------------
    mov     rdi, file_buffer
    call    ft_strlen                 ; rax ← taille

    ; ---------------------------------------------------------
    ; Envoi du contenu du fichier
    ; ---------------------------------------------------------
    mov     rdi, r13                  ; socket client
    mov     rsi, file_buffer
    mov     rdx, rax                  ; taille lue
    mov     rax, SYS_WRITE
    syscall

    ; ---------------------------------------------------------
    ; Nettoyage
    ; ---------------------------------------------------------
    add     rsp, 8
    leave
    ret
