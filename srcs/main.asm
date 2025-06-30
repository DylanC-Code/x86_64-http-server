%include "constants.asm"

BITS 64

section .text
global _start
global handle_connection

extern socket_build
extern socket_bind
extern socket_listen
extern socket_accept_connection
extern socket_close_client_connection
extern http_handle_request
extern exit_program

; ---------------------------------------------------------------------------
; Registres utilisés :
;   - r12 : socket serveur (fd) défini dans socket_build
;   - r13 : socket client (fd)
; ---------------------------------------------------------------------------

_start:
    call    socket_build
    call    socket_bind
    call    socket_listen
    call    handle_connection


; ---------------------------------------------------------------------------
; handle_connection
; ---------------------------------------------------------------------------
; Boucle d’acceptation et traitement des connexions clients
; -----------------------------------------------------------------------------
handle_connection:
    call    socket_accept_connection      ; r13 ← fd client
    call    create_child                   ; fork

    ; enfant : traite la requête HTTP
    call    http_handle_request

    jmp     handle_connection              ; boucle pour accepter d'autres connexions

    call    exit_program                   ; (inaccessible ici, safeguard)


; ---------------------------------------------------------------------------
; create_child
; ---------------------------------------------------------------------------
; Fork et gestion des processus parent/enfant
; Enfant : retourne pour continuer traitement
; Parent  : ferme fd client et reboucle dans handle_connection
; -----------------------------------------------------------------------------
create_child:
    mov     rax, SYS_FORK
    syscall

    test    rax, rax
    jnz     .in_parent                     ; rax != 0 → parent

    ret                                   ; enfant → retourne pour traiter requête

.in_parent:
    call    socket_close_client_connection
    jmp     handle_connection              ; parent → reboucle accept
