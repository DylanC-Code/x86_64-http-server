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
; Sortie  : rax = longueur (hors \0)
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
; ft_isdigit
; -----------------------------------------------------------------------------
; Vérifie si le caractère dans dl est un chiffre ASCII (0-9).
; Entrée : dl = caractère à tester
; Sortie  : rax = 1 si chiffre, 0 sinon
; =============================================================================
ft_isdigit:
    xor     rax, rax

    cmp     dl, '0'
    jl      .not_digit
    cmp     dl, '9'
    jg      .not_digit

    mov     rax, 1
    ret

.not_digit:
    ret


; =============================================================================
; ft_chartodigit
; -----------------------------------------------------------------------------
; Convertit un caractère chiffre ASCII en sa valeur numérique.
; Entrée : dl = caractère (ex: '0')
; Sortie  : rax = valeur numérique (ex: 0)
; =============================================================================
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
