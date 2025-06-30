%include "constants.asm"

BITS 64

; =============================================================================
; Section .data : Buffers et réponse HTTP
; =============================================================================
section .data
    request_buffer       times 1024 db 0                      ; Buffer réception requête
    parsed_request       times 2053 db 0                      ; [0]=méthode, [1..]=route, [1025..1028]=content_len, [1029..]=body
    file_buffer          times 1024 db 0                      ; Contenu du fichier lu
    http_header_response: db "HTTP/1.0 200 OK", 13, 10, 13, 10 ; Réponse HTTP minimale (CRLF CRLF)

; =============================================================================
; Section .text : Code exécutable
; =============================================================================
section .text

global http_handle_request

extern parse_request
extern ft_strlen
extern socket_close_server_connection
extern socket_close_client_connection

; -----------------------------------------------------------------------------
; http_handle_request
; -----------------------------------------------------------------------------
; Point d'entrée principal pour gérer une requête HTTP.
; Attendu :
;   - r13 : fd socket client
; Effets :
;   - Lit la requête dans request_buffer
;   - Parse méthode et route dans parsed_request
;   - Appelle handler selon méthode
; -----------------------------------------------------------------------------
http_handle_request:
    push    rbp
    mov     rbp, rsp

    ; call socket_close_server_connection       ; (commenté dans l’original)
    call    clear_buffers
    call    read_request

    push    rax                      ; sauvegarde adresse du buffer (request_buffer)

    mov     rdi, rax                 ; rdi ← buffer de requête
    mov     rsi, parsed_request      ; rsi ← structure de sortie
    call    parse_request

    mov     rdi, rsi                 ; rdi ← parsed_request
    call    handle_method

    call    socket_close_client_connection

    add     rsp, 8                   ; restauration pile
    leave
    ret


; -----------------------------------------------------------------------------
; read_request
; -----------------------------------------------------------------------------
; Lit jusqu’à 1024 octets depuis le socket client (r13).
; Sortie :
;   - rax ← adresse de request_buffer
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
; Effets :
;   - Appelle handle_get_method si méthode = GET
;   - Appelle handle_post_method si méthode = POST
; -----------------------------------------------------------------------------
handle_method:
    cmp     BYTE [rdi], GET_METHOD
    je      .call_get

    cmp     BYTE [rdi], POST_METHOD
    je      .call_post

    ret

.call_get:
    call    handle_get_method
    ret

.call_post:
    call    handle_post_method
    ret


; -----------------------------------------------------------------------------
; handle_get_method
; -----------------------------------------------------------------------------
; Gère une requête GET.
; Effets :
;   - Ouvre, lit, ferme le fichier demandé (route à [rsi + 1])
;   - Envoie un header HTTP puis contenu du fichier au client
; -----------------------------------------------------------------------------
handle_get_method:
    push    rbp
    mov     rbp, rsp

    push    rsi
    sub     rsp, 8

    mov     rdi, rsi
    add     rdi, 1                   ; rdi ← route (après méthode)

    mov     rax, SYS_OPEN
    mov     rsi, O_RDONLY
    syscall

    mov     [rsp], rax               ; sauvegarde fd fichier

    mov     rdi, rax                 ; fd fichier
    mov     rsi, file_buffer
    mov     rdx, 1024
    mov     rax, SYS_READ
    syscall

    mov     rdi, [rsp]
    mov     rax, SYS_CLOSE
    syscall

    mov     rdi, r13                 ; fd socket client
    mov     rsi, http_header_response
    mov     rdx, 19                  ; taille header
    mov     rax, SYS_WRITE
    syscall

    mov     rdi, file_buffer
    call    ft_strlen                ; rax ← taille fichier lu

    mov     rdi, r13                 ; socket client
    mov     rsi, file_buffer
    mov     rdx, rax                 ; taille lue
    mov     rax, SYS_WRITE
    syscall

    add     rsp, 8
    leave
    ret


; -----------------------------------------------------------------------------
; handle_post_method
; -----------------------------------------------------------------------------
; Gère une requête POST.
; Effets :
;   - Ouvre/crée le fichier (route à [r8 + 1])
;   - Écrit le body (stocké à [r8 + 1029]) dans le fichier
;   - Ferme le fichier
;   - Envoie réponse HTTP au client
; -----------------------------------------------------------------------------
handle_post_method:
    mov     r8, rdi

.open_dest_file:
    mov     rdi, r8
    inc     rdi                       ; fichier à ouvrir (route)

    mov     rsi, 65                  ; flags O_CREAT | O_WRONLY
    mov     rdx, 511                 ; mode 0777 octal (droits)
    mov     rax, SYS_OPEN
    syscall
    push    rax                      ; sauvegarde fd

.write_dest_file:
    mov     rdi, rax                 ; fd fichier
    mov     rsi, r8
    add     rsi, 1029                ; body
    mov     edx, DWORD [r8 + 1025]  ; longueur body
    mov     rax, SYS_WRITE
    syscall

.close_dest_file:
    pop     rdi                      ; fd fichier
    mov     rax, SYS_CLOSE
    syscall

.send_response:
    mov     rdi, r13                 ; socket client
    mov     rsi, http_header_response
    mov     rdx, 19
    mov     rax, SYS_WRITE
    syscall

    ret


; -----------------------------------------------------------------------------
; clear_buffers
; -----------------------------------------------------------------------------
; Réinitialise les buffers (request_buffer, parsed_request, file_buffer)
; -----------------------------------------------------------------------------
clear_buffers:
    mov     rdi, request_buffer
    mov     rcx, 1024
    xor     rax, rax
    rep stosb

    mov     rdi, parsed_request
    mov     rcx, 2053
    xor     rax, rax
    rep stosb

    mov     rdi, file_buffer
    mov     rcx, 1024
    xor     rax, rax
    rep stosb

    ret
