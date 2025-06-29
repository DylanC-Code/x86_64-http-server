; ============================================================================
; socket.asm – routines de création et gestion de socket TCP IPv4
; ============================================================================
; Exportées :
;   - socket_build
;   - socket_bind
;   - socket_listen
;   - socket_accept_connection
;   - socket_close_connection
;
; Conventions :
;   - r12 contient le fd du socket serveur
;   - r13 contient le fd du socket client après accept
;   - sockaddr_in est construite sur la stack
; ============================================================================

%include "constants.asm"       ; définitions SYS_*, AF_*, SOCK_*, PORT_HTTP, etc.

BITS 64

section .text

global socket_build
global socket_bind
global socket_listen
global socket_accept_connection
global socket_close_connection

; ============================================================================
; socket_build
; ----------------------------------------------------------------------------
; Crée un socket IPv4 TCP.
; Résultat :
;   - r12 ← fd du socket serveur
; ============================================================================
socket_build:
    mov     rax, SYS_SOCKET       ; syscall: socket(int domain, int type, int protocol)
    mov     rdi, AF_INET          ; AF_INET (IPv4)
    mov     rsi, SOCK_STREAM      ; SOCK_STREAM (TCP)
    xor     rdx, rdx              ; protocole = 0 (IP)
    syscall

    mov     r12, rax              ; sauvegarder le fd dans r12
    ret

; ============================================================================
; socket_bind
; ----------------------------------------------------------------------------
; Lie le socket serveur (r12) à l'adresse 0.0.0.0:PORT_HTTP
; Utilise une struct sockaddr_in placée sur la stack.
; ============================================================================
socket_bind:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16               ; réserver 16 octets pour sockaddr_in

    ; struct sockaddr_in
    mov     word  [rsp],     AF_INET         ; sa_family
    mov     word  [rsp + 2], PORT_HTTP       ; sin_port (attention: little endian)
    mov     dword [rsp + 4], INADDR_ANY      ; sin_addr = 0.0.0.0

    mov     rax, SYS_BIND
    mov     rdi, r12             ; socket fd
    mov     rsi, rsp             ; pointeur vers sockaddr_in
    mov     rdx, 16              ; taille de sockaddr_in
    syscall

    leave
    ret

; ============================================================================
; socket_listen
; ----------------------------------------------------------------------------
; Met le socket serveur (r12) en mode écoute avec backlog = 0.
; ============================================================================
socket_listen:
    mov     rax, SYS_LISTEN
    mov     rdi, r12             ; socket fd
    mov     rsi, 0               ; backlog = 0
    syscall
    ret

; ============================================================================
; socket_accept_connection
; ----------------------------------------------------------------------------
; Accepte une connexion entrante sur le socket serveur (r12).
; Résultat :
;   - r13 ← fd du client
; ============================================================================
socket_accept_connection:
    mov     rax, SYS_ACCEPT
    mov     rdi, r12             ; socket serveur
    xor     rsi, rsi             ; sockaddr = NULL
    xor     rdx, rdx             ; addrlen = NULL
    syscall

    mov     r13, rax             ; stocker le fd client dans r13
    ret

; ============================================================================
; socket_close_connection
; ----------------------------------------------------------------------------
; Ferme les sockets client (r13) et serveur (r12).
; ============================================================================
socket_close_connection:
    ; fermer socket client
    mov     rdi, r13
    mov     rax, SYS_CLOSE
    syscall

    ; fermer socket serveur
    mov     rdi, r12
    mov     rax, SYS_CLOSE
    syscall
    ret
