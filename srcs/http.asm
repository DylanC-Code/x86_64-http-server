%include "constants.asm"

BITS 64

; ============================================================================
; Section .data : Buffers et réponse HTTP
; ============================================================================
section .data
    request_buffer times 1024 db 0
    parsed_request times 2    dq 0

; ============================================================================
; Section .text : Code exécutable
; ============================================================================
section .text

global http_handle_request

extern parse_request

; ----------------------------------------------------------------------------
; http_handle_request
; ----------------------------------------------------------------------------
; Point d'entrée principal pour gérer une requête HTTP.
; Attend :
;   - r13 : descripteur de fichier du socket client (int)
; Effet :
;   - Appelle `read_request` pour lire la requête HTTP dans `request_buffer`
;   - Appelle `parse_request` pour traiter la requête
; ----------------------------------------------------------------------------
http_handle_request:
    push    rbp
    mov     rbp, rsp
    call    read_request
    sub     rsp, 8
    mov     [rsp], rax

    mov     rdi, rax
    mov     rsi, parsed_request
    call    parse_request
    ; mov     rax, SYS_WRITE
    ; mov     rdi, r13
    ; mov     rsi, response
    ; mov     rdx, response_len
    ; syscall

    add     rsp, 8
    leave
    ret
    ; call    read_request
    ; call    handle_method

; ----------------------------------------------------------------------------
; read_request
; ----------------------------------------------------------------------------
; Lit 1024 octets depuis le socket client dans `request_buffer`.
; Attend :
;   - r13 : descripteur de fichier (socket)
; Retour :
;   - pointeur vers le buffer contenant la requête (request_buffer)
; ---------------------------------------------------------------------------
read_request:
    mov     rax, SYS_READ
    mov     rdi, r13
    mov     rsi, request_buffer
    mov     rdx, 1024
    syscall

    mov     rax, request_buffer
    ret

; ----------------------------------------------------------------------------
; handle_method
; ----------------------------------------------------------------------------
; Traite la méthode HTTP (ex: GET, POST...)
; Attend :
;   - rdi : valeur de méthode (ex: GET_METHOD)
; Effet :
;   - Si GET, saute vers handle_get_method
; ----------------------------------------------------------------------------
handle_method:
    cmp     rdi, GET_METHOD
    je      handle_get_method

; ----------------------------------------------------------------------------
; handle_get_method
; ----------------------------------------------------------------------------
; Point de traitement pour la méthode GET (non implémentée ici)
; --------------------------------------------------------------------------
handle_get_method:

