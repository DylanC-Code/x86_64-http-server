.intel_syntax noprefix


.section .text
.global _start


# R12 = Main socket


_start:
    call    build_socket
    call    bind_socket
    call    utils_exit
