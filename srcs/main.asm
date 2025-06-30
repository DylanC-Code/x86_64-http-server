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

; R12 = Main socket fd (défini dans socket_build)
; R13 = Client socket fd

_start:
    call    socket_build
    call    socket_bind
    call    socket_listen
    call    handle_connection

handle_connection:
    call    socket_accept_connection  ; r13 ← fd client
    call    create_child              ; fork

    ; si on est dans l’enfant, on traite la requête
    call    http_handle_request
    jmp     handle_connection
    call    exit_program            ;

; create_child:
;     mov     rax, SYS_FORK
;     syscall

;     cmp     rax, 0
;     jne     .in_parent
;     ret

; .in_parent:
;     call    socket_close_client_connection
;     jmp     handle_connection


create_child:
    mov     rax, SYS_FORK
    syscall
    test    rax, rax
    jnz     .in_parent                ; rax != 0 → parent

    ret                               ; enfant → continue dans handle_connection

.in_parent:
    call    socket_close_client_connection
    jmp     handle_connection         ; reboucle dans le parent


