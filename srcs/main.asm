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
    call    socket_accept_connection
    ; call    create_child
    call    http_handle_request
    call    socket_close_client_connection
    call    exit_program

create_child:
    mov     rax, SYS_FORK
    syscall

    cmp     rax, 0
    jne     .in_parent
    ret

.in_parent:
    call    socket_close_client_connection
    jmp     handle_connection


