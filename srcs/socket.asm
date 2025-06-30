; =============================================================================
; socket.asm – routines de création et gestion de socket TCP IPv4
; =============================================================================
; Exportées :
;   - socket_build
;   - socket_bind
;   - socket_listen
;   - socket_accept_connection
;   - socket_close_client_connection
;   - socket_close_server_connection
;
; Conventions :
;   - r12 ← fd du socket serveur (callee-saved)
;   - r13 ← fd du socket client (après accept)
;   - sockaddr_in est construite temporairement sur la stack
; =============================================================================

%include "constants.asm"  ; définitions SYS_*, AF_*, SOCK_*, PORT_HTTP, etc.

BITS 64

section .text

global socket_build
global socket_bind
global socket_listen
global socket_accept_connection
global socket_close_client_connection
global socket_close_server_connection

; =============================================================================
; socket_build
; -----------------------------------------------------------------------------
; Crée un socket IPv4 TCP.
; Sortie :
;   - r12 ← fd du socket serveur
; =============================================================================
socket_build:
    mov     rax, SYS_SOCKET           ; socket(AF_INET, SOCK_STREAM, 0)
    mov     rdi, AF_INET
    mov     rsi, SOCK_STREAM
    xor     rdx, rdx                  ; protocole 0 = IP
    syscall

    mov     r12, rax                  ; sauvegarde du fd socket
    ret


; =============================================================================
; socket_bind
; -----------------------------------------------------------------------------
; Lie le socket serveur (r12) à 0.0.0.0:PORT_HTTP
; Utilise une struct sockaddr_in sur la stack.
; =============================================================================
socket_bind:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16                   ; struct sockaddr_in = 16 octets

    ; struct sockaddr_in {
    ;     sa_family (2 bytes), port (2),
    ;     address (4), padding (8)
    ; }
    mov     word  [rsp],     AF_INET
    mov     word  [rsp + 2], PORT_HTTP
    mov     dword [rsp + 4], INADDR_ANY

    mov     rax, SYS_BIND
    mov     rdi, r12                  ; socket fd
    mov     rsi, rsp                  ; sockaddr_in*
    mov     rdx, 16                   ; sizeof(sockaddr_in)
    syscall

    leave
    ret


; =============================================================================
; socket_listen
; -----------------------------------------------------------------------------
; Met le socket serveur en écoute (backlog = 0).
; =============================================================================
socket_listen:
    mov     rax, SYS_LISTEN
    mov     rdi, r12
    mov     rsi, 0
    syscall
    ret


; =============================================================================
; socket_accept_connection
; -----------------------------------------------------------------------------
; Accepte une connexion entrante.
; Sortie :
;   - r13 ← fd du client
; =============================================================================
socket_accept_connection:
    mov     rax, SYS_ACCEPT
    mov     rdi, r12
    xor     rsi, rsi                  ; sockaddr* NULL
    xor     rdx, rdx                  ; addrlen* NULL
    syscall

    mov     r13, rax
    ret


; =============================================================================
; socket_close_client_connection
; -----------------------------------------------------------------------------
; Ferme le socket client (r13).
; =============================================================================
socket_close_client_connection:
    mov     rdi, r13
    mov     rax, SYS_CLOSE
    syscall
    ret


; =============================================================================
; socket_close_server_connection
; -----------------------------------------------------------------------------
; Ferme le socket serveur (r12).
; =============================================================================
socket_close_server_connection:
    mov     rdi, r12
    mov     rax, SYS_CLOSE
    syscall
    ret
