%include "constants.asm"

BITS 64

section .data
    buffer times 1024 db 0
    response db "HTTP/1.0 200 OK\r\n\r\n"
    response_len equ $ - response

section .text

global http_handle_request

extern parse_request

http_handle_request:
    mov     rax, SYS_WRITE
    mov     rdi, r13
    mov     rsi, response
    mov     rdx, response_len
    syscall

    ret
    ; call    read_request
    ; call    parse_request
    ; call    handle_method

read_request:
    mov     rax, SYS_READ
    mov     rdi, r13
    mov     rsi, buffer
    mov     rdx, 1024
    syscall

    mov     rdi, buffer
    ret

handle_method:
    cmp     rdi, GET_METHOD
    je      handle_get_method

handle_get_method:

