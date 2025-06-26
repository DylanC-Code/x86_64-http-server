BITS 64

section .text
global _start

extern socket_build
extern socket_bind
extern utils_exit

; R12 = Main socket fd (défini dans socket_build)

_start:
    call socket_build
    call socket_bind
    call utils_exit
