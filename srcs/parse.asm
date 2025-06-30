%include "constants.asm"

BITS 64

section .data:
    header_content_len: db "Content-Length: "
    header_len: db 16

section .text
global parse_request

extern ft_isdigit
extern ft_chartodigit

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
    call    parse_body
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
    call    is_post
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

is_post:
    cmp     BYTE [rdi],     'P'
    jne     .is_post_end
    cmp     BYTE [rdi + 1], 'O'
    jne     .is_post_end
    cmp     BYTE [rdi + 2], 'S'
    jne     .is_post_end
    cmp     BYTE [rdi + 3], 'T'
    jne     .is_post_end

    mov     BYTE [rsi], POST_METHOD

.is_post_end:
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
    cmp     BYTE [rsi], POST_METHOD
    je      .parse_post_route
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
    mov     rdx, 4             ; Commence après "GET " (4)
    mov     rax, 1             ; Offset pour route (à partir de [rsi + 1])
    jmp     .parse_route_loop

.parse_post_route:
    mov     rdx, 5             ; Commence après "POST " (5)
    mov     rax, 1             ; Offset pour route (à partir de [rsi + 1])
    jmp      .parse_route_loop

.parse_route_loop:
    mov     bl, [rdi + rdx]
    cmp     bl, ' '
    je      .parse_route_loop_end

    mov     [rsi + rax], bl
    inc     rdx
    inc     rax
    jmp     .parse_route_loop

.parse_route_loop_end:
    ret


parse_body:
    push    rdi
    push    rsi

    cmp     BYTE [rsi], POST_METHOD
    jne     .skip_parse_body
    call    parse_content_length

    pop     rsi
    pop     rdi
    mov     BYTE [rsi + 1025], al

    

.skip_parse_body:
    ret

parse_content_length:
    mov     rcx, 5                  ;  index dans la requête (rdi)
    xor     rdx, rdx                ; index dans le header "Content-Length: "

.reset_header_index:
    xor     rdx, rdx                ;

.scan:
    inc     rcx
    mov     al, [rdi + rcx]                   ; Caractere de la requete
    mov     bl, [header_content_len + rdx]    ; Caractere du header
    cmp     al, bl

    jne     .reset_header_index
    inc     rdx

    cmp     rdx, [header_len]

    jne     .scan
    call     get_content_len
    ret

get_content_len:
    xor     rbx, rbx
    inc     rcx

.loop:
    push    rdi

    mov     dl, [rdi + rcx]
    call    ft_isdigit

    cmp     al, 1
    pop     rdi
    jne     .end

    push    rdi
    mov     dl, [rdi + rcx]
    call    ft_chartodigit
    add     rbx, rax

    pop     rdi
    inc     rcx
    jmp     .loop

.end:
    mov     rax, rbx
    ret
