%include "constants.asm"

BITS 64

section .data:


section .text

global parse_request

; ----------------------------------------------------------------------------
; parse_request
; ----------------------------------------------------------------------------
; Analyse une requête HTTP brute pour en extraire la méthode et la route.
; Attend :
;   - rdi : pointeur vers la requête (request_buffer)
;   - rsi : pointeur vers l'endroit ou stocker la methode et la longueur de route
; Effet :
;   - appelle parse_method pour identifier la méthode HTTP (GET, etc.)
;   - appelle parse_route (non encore défini) pour extraire la route
; ----------------------------------------------------------------------------
parse_request:
    ;rdi = request_buffer
    ;rsi = parsed_request

    call    parse_method
    mov     [rsi], rax

    call    parse_route
    mov     [rsi + 8], rax

    ret


; ----------------------------------------------------------------------------
; parse_method
; ----------------------------------------------------------------------------
; Détecte la méthode HTTP dans la requête.
; Attend :
;   - rdi : pointeur vers la requête (ex: "GET /...")
; Retour :
;   - rax ← constante GET_METHOD si reconnue
; ----------------------------------------------------------------------------
parse_method:
    call    is_get
    cmp     rax, GET_METHOD
    je      .parse_method_end

.parse_method_end:
    ret


; ----------------------------------------------------------------------------
; is_get
; ----------------------------------------------------------------------------
; Vérifie si la chaîne pointée par rdi commence par "GET"
; Attend :
;   - rdi : pointeur vers la requête
; Retour :
;   - rax ← GET_METHOD si c’est bien "GET", 0 sinon
; ----------------------------------------------------------------------------

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

parse_route:
    cmp     rax, GET_METHOD
    je      .parse_get_route
    ; cmp     rax, POST_METHOD
    ; je      .parse_post_route
    ret

.parse_get_route:
    mov     rdx, 4

.get_loop:
    cmp     BYTE [rdi + rdx], ' '
    je      .parse_get_route_end
    inc     rdx
    jmp     .get_loop

.parse_get_route_end:
    sub     rdx, 4
    mov     rax, rdx
    ret



