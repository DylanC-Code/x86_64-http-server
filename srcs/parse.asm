%include "constants.asm"

BITS 64

section .text
global parse_request

; -----------------------------------------------------------------------------
; parse_request
; -----------------------------------------------------------------------------
; Analyse une requête HTTP brute pour en extraire :
;   - La méthode (GET, etc.)  → stockée à [rsi]
;   - La route               → stockée à partir de [rsi + 1]
;
; Entrées :
;   - rdi : pointeur vers la requête (request_buffer)
;   - rsi : pointeur vers parsed_request (1 byte pour méthode, reste pour route)
; Effets :
;   - parse_method écrit la méthode à [rsi]
;   - parse_route écrit la route à [rsi + 1]
; -----------------------------------------------------------------------------
parse_request:
    call    parse_method
    call    parse_route
    ret

; -----------------------------------------------------------------------------
; parse_method
; -----------------------------------------------------------------------------
; Détecte la méthode HTTP (actuellement uniquement GET)
; Entrée :
;   - rdi : pointeur vers la requête (ex: "GET /...")
; Sortie :
;   - écrit GET_METHOD dans [rsi] si trouvé
; -----------------------------------------------------------------------------
parse_method:
    call    is_get
    ret

; -----------------------------------------------------------------------------
; is_get
; -----------------------------------------------------------------------------
; Vérifie si la requête commence par "GET"
; Entrée :
;   - rdi : pointeur vers la requête
; Sortie :
;   - écrit GET_METHOD (1) dans [rsi] si correspond, ne fait rien sinon
; -----------------------------------------------------------------------------
is_get:
    cmp     BYTE [rdi],     'G'
    jne     .is_get_end
    cmp     BYTE [rdi + 1], 'E'
    jne     .is_get_end
    cmp     BYTE [rdi + 2], 'T'
    jne     .is_get_end

    mov     BYTE [rsi], GET_METHOD

.is_get_end:
    ret

; -----------------------------------------------------------------------------
; parse_route
; -----------------------------------------------------------------------------
; Extrait la route de la requête HTTP (si méthode == GET)
; Entrées :
;   - rdi : requête originale
;   - rsi : buffer de destination (méthode à [rsi], route à [rsi + 1])
; -----------------------------------------------------------------------------
parse_route:
    cmp     BYTE [rsi], GET_METHOD
    je      .parse_get_route
    ret

; -----------------------------------------------------------------------------
; .parse_get_route
; -----------------------------------------------------------------------------
; Copie la route trouvée dans la requête à partir de "/..." jusqu'à l'espace
; Entrée :
;   - rdi : buffer contenant la requête ("GET /path HTTP/1.1")
;   - rsi : buffer de sortie (route à partir de [rsi + 1])
; -----------------------------------------------------------------------------
.parse_get_route:
    mov     rdx, 5             ; Commence après "GET " (4) + '/' (1)
    mov     rax, 1             ; Offset pour route (à partir de [rsi + 1])

.get_loop:
    mov     bl, [rdi + rdx]
    cmp     bl, ' '
    je      .parse_get_route_end

    mov     [rsi + rax], bl
    inc     rdx
    inc     rax
    jmp     .get_loop

.parse_get_route_end:
    ret
