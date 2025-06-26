BITS 64

section .text
global _start

extern socket_build
extern socket_bind
extern socket_listen
extern socket_accept_connection
extern utils_exit

; R12 = Main socket fd (défini dans socket_build)

_start:
    call socket_build
    call socket_bind
    call socket_listen
    call socket_accept_connection
    call utils_exit
