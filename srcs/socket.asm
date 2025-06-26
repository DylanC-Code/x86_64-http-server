; socket.asm – routines de création de socket
; Exporte : socket_build, socket_bind

%include "constants.asm"

BITS 64
section .text

global socket_build
global socket_bind

; -------------------------------------------------
; socket_build
; r12 ← socket fd
; -------------------------------------------------
socket_build:
    mov     rax, SYS_SOCKET
    mov     rdi, AF_INET
    mov     rsi, SOCK_STREAM
    xor     rdx, rdx
    syscall
    mov     r12, rax        ; conserver dans un registre callee-saved
    ret

; -------------------------------------------------
; socket_bind
; bind r12 à 0.0.0.0:80
; -------------------------------------------------
socket_bind:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16                     ; struct sockaddr_in

    ; struct sockaddr_in
    mov     word [rsp], AF_INET
    mov     word [rsp + 2], PORT_HTTP
    mov     dword [rsp + 4], INADDR_ANY

    ; appel système bind
    mov     rax, SYS_BIND
    mov     rdi, r12                   ; socket fd
    mov     rsi, rsp                   ; ptr sockaddr
    mov     rdx, 16                    ; len
    syscall

    leave
    ret
