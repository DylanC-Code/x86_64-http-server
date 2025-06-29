%include "constants.asm"

BITS 64

section .text

global parse_request

parse_request:
    call    is_get
    cmp     rax, GET_METHOD
    je      .parse_method_end

.parse_method_end:
    ret

is_get:
    xor     rax, rax
    cmp     BYTE [rdi], 'G'
    jne     .is_get_end
    cmp     BYTE [rdi + 1], 'E'
    jne     .is_get_end
    cmp     BYTE [rdi + 2], 'T'
    jne     .is_get_end
    mov     rax, GET_METHOD

.is_get_end:
    ret
