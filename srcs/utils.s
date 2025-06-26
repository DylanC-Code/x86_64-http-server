.intel_syntax noprefix


.section .text
.global utils_exit


utils_exit:
    mov     rax, 60
    mov     rdi, 0
    syscall
