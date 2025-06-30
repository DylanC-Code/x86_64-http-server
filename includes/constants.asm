%ifndef CONSTANTS_ASM
%define CONSTANTS_ASM

; =====================
; Syscall Numbers
; =====================
%define SYS_SOCKET    41
%define SYS_BIND      49
%define SYS_LISTEN    50
%define SYS_ACCEPT    43
%define SYS_FORK      57
%define SYS_WRITE     1
%define SYS_READ      0
%define SYS_EXIT      60
%define SYS_CLOSE     3
%define SYS_OPEN      2

; =====================
; Socket Domain / Types
; =====================
%define AF_INET       2           ; IPv4
%define SOCK_STREAM   1           ; TCP

; =====================
; Network Constants
; =====================
%define PORT_HTTP     0x80      ; Port 80 (big endian)
;%define PORT_HTTP    0x5100      ; Port 80 (big endian)
%define INADDR_ANY    0x00000000

; =====================
; HTTP Constants
; =====================
%define GET_METHOD 1
%define POST_METHOD 2

; =====================
; File Constants
; =====================
%define O_RDONLY 0

%endif
