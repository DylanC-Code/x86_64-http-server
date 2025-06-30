%include "constants.asm"

BITS 64


section .text
global exit_program
global ft_strlen
global ft_isdigit
global ft_chartodigit

extern socket_close_server_connection

; =============================================================================
; ft_strlen
; -----------------------------------------------------------------------------
; Calcule la longueur d’une chaîne terminée par \0 (comme strlen en C).
; Entrée : rdi = adresse de la chaîne
; Sortie : rax = longueur (hors \0)
; =============================================================================
ft_strlen:
    xor     rax, rax

.loop:
    cmp     BYTE [rdi + rax], 0
    je      .ft_strlen_end
    inc     rax
    jmp     .loop

.ft_strlen_end:
    ret


ft_isdigit:
    xor     rax, rax

    cmp     dl, '0'
    jge     .is_lower_than_nine
    ret

.is_lower_than_nine:
    cmp     dl, '9'
    jle     .success
    ret

.success:
    mov     rax, 1
    ret


ft_chartodigit:
    xor     rax, rax
    mov     al, dl
    sub     al, '0'
    ret

; =============================================================================
; exit_program
; -----------------------------------------------------------------------------
; Termine proprement le programme avec un code de retour 0.
; =============================================================================
exit_program:
    ; call    socket_close_server_connection
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall


