%ifndef CONSTANTS_ASM
%define CONSTANTS_ASM

; =====================
; Syscall Numbers
; =====================
%define SYS_SOCKET    41
%define SYS_BIND      49
%define SYS_LISTEN    50
%define SYS_ACCEPT    43
%define SYS_WRITE     1
%define SYS_EXIT      60

; =====================
; Socket Domain / Types
; =====================
%define AF_INET       2           ; IPv4
%define SOCK_STREAM   1           ; TCP

; =====================
; Network Constants
; =====================
%define PORT_HTTP     0x5000      ; Port 80 (big endian)
%define INADDR_ANY    0x00000000

%endif
