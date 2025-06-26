; socket.asm – routines de création et gestion de socket TCP IPv4
; Exportées : socket_build, socket_bind, socket_listen, socket_accept_connection
; Conventions :
; - Registre r12 contient le fd socket serveur (callee-saved)
; - Registre r13 contient le fd socket client (après accept)
; - Structure sockaddr_in construite sur la stack

%include "constants.asm"       ; contient SYS_*, AF_*, SOCK_*, PORT_HTTP, INADDR_ANY, etc.

BITS 64

section .text

global socket_build
global socket_bind
global socket_listen
global socket_accept_connection

; -------------------------------------------------
; socket_build
; Crée un socket IPv4 TCP.
; Résultat : fd socket serveur dans r12
; -------------------------------------------------
socket_build:
    mov     rax, SYS_SOCKET       ; numéro syscall socket
    mov     rdi, AF_INET          ; domaine IPv4
    mov     rsi, SOCK_STREAM      ; type TCP
    xor     rdx, rdx              ; protocole 0 (IP)
    syscall                      ; appel système

    mov     r12, rax             ; sauvegarde fd socket dans r12 (callee-saved)
    ret

; -------------------------------------------------
; socket_bind
; Lie le socket serveur (fd en r12) à 0.0.0.0:80 (PORT_HTTP)
; Utilise sockaddr_in struct sur stack
; -------------------------------------------------
socket_bind:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16              ; alloue struct sockaddr_in (16 octets)

    ; sockaddr_in fields
    mov     word [rsp], AF_INET          ; sa_family = AF_INET
    mov     word [rsp + 2], PORT_HTTP    ; port en little endian (attention ordre bytes)
    mov     dword [rsp + 4], INADDR_ANY  ; adresse IP 0.0.0.0 (any)

    ; appel système bind(socket_fd, sockaddr_in*, 16)
    mov     rax, SYS_BIND
    mov     rdi, r12            ; socket fd
    mov     rsi, rsp            ; pointeur sockaddr_in
    mov     rdx, 16             ; taille sockaddr_in
    syscall

    leave
    ret

; -------------------------------------------------
; socket_listen
; Met le socket serveur (fd en r12) en mode écoute (backlog 0)
; -------------------------------------------------
socket_listen:
    mov     rax, SYS_LISTEN
    mov     rdi, r12            ; socket fd
    mov     rsi, 0              ; backlog
    syscall
    ret

; -------------------------------------------------
; socket_accept_connection
; Accepte une connexion entrante sur socket serveur (r12)
; Résultat : fd socket client dans r13
; -------------------------------------------------
socket_accept_connection:
    mov     rax, SYS_ACCEPT
    mov     rdi, r12            ; socket serveur
    xor     rsi, rsi            ; sockaddr* NULL (pas d’info client)
    xor     rdx, rdx            ; addrlen NULL
    syscall

    mov     r13, rax            ; sauvegarde fd client dans r13
    ret
