.intel_syntax noprefix

socket_syscall  = 41
socket_domain   = 2         # IPv4 Internet protocols
socket_type     = 1         # TCP

bind_syscall    = 49
sa_family       = 2
port            = 0x5000    # Big endian
ip            = 0

.section .text
.global build_socket
.global bind_socket


build_socket:
    mov     rax, socket_syscall
    mov     rdi, socket_domain
    mov     rsi, socket_type
    mov     rdx, 0
    syscall
    mov     r12, rax                    # Main Socket
    ret

bind_socket:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16                     # Allocate a struct `sockaddr_in` of 16 bytes
    mov     rax, bind_syscall
    mov     rdi, r12
    mov     WORD PTR [rsp], sa_family
    mov     WORD PTR [rsp + 2], port
    mov     DWORD PTR [rsp + 4], ip
    mov     rsi, rsp
    mov     rdx, 16                     # sockaddr_in len
    syscall
    leave
    ret
