%include "constants.asm"

BITS 64


section .text
global exit_program
global ft_strlen


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


; =============================================================================
; exit_program
; -----------------------------------------------------------------------------
; Termine proprement le programme avec un code de retour 0.
; =============================================================================
exit_program:
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall


