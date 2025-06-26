.intel_syntax noprefix

socket_syscall  = 41
socket_domain   = 2     # IPv4 Internet protocols
socket_type     = 1     # TCP


.section .text
.global build_socket


build_socket:
    mov     rax, socket_syscall
    mov     rdi, socket_domain
    mov     rsi, socket_type
    mov     rdx, 0
    syscall
    ret
