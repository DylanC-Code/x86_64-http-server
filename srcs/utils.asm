%include "constants.asm"

BITS 64


section .text
global utils_exit


utils_exit:
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall
