section .text
global procesarImagen
extern valorYcomprimido
extern valorRGBlineal

; constantes
section .data
const_255: dq 255.0
const_coef_R: dq 0.2126
const_coef_G: dq 0.7152
const_coef_B: dq 0.0722

section .text
; parámetros:
;   rdi = puntero imagen
;   rsi = filas
;   rdx = columnas
;   rcx = canales
;   r8  = ancho total de cada fila en bytes
procesarImagen:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; guardar parámetros
    mov r12, rdi   ; puntero imagen
    mov r13, rsi   ; filas
    mov r14, rdx   ; columnas
    mov rax, r14   ; columnas
    imul rax, rcx  ; * canales
    mov r15, rax   ; ancho útil = columnas * canales
    
    ; calcular ancho útil (columnas * canales)
    mov rax, rdx   ; columnas
    imul rax, rcx  ; * canales
    mov r11, rax   ; r11 = ancho útil (límite para j)
    
    xor r8, r8     ; i = 0 (contador filas)

bucle_filas:
    cmp r8, r13
    jge fin_procesamiento
    
    ; calcular dirección inicial de fila: imagen + i * ancho_total_fila
    mov rax, r8
    imul rax, r15   ; i * ancho total de la fila
    lea r10, [r12 + rax] ; r10 = inicio fila actual
    
    xor r9, r9      ; j = 0 (posición en la fila)

bucle_columnas:
    cmp r9, r11     ; ¿j < ancho útil?
    jge fin_bucle_columnas
    
    ; dirección del píxel: inicio fila + posición
    lea rbx, [r10 + r9] ; rbx = dirección píxel actual
    
    ; procesar píxel (preservar registros)
    push r8
    push r9
    push r10
    push r11
    mov rdi, rbx    ; pasar dirección del píxel
    call procesarPixel
    pop r11
    pop r10
    pop r9
    pop r8
    
    add r9, 3       ; avanzar al siguiente píxel (3 bytes: BGR)
    jmp bucle_columnas

fin_bucle_columnas:
    inc r8          ; siguiente fila
    jmp bucle_filas

fin_procesamiento:
    mov rax, 0      ; retornar 0 (éxito)
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

procesarPixel:
    push rbp
    mov rbp, rsp
    sub rsp, 32     ; espacio para 3 doubles (24 bytes) + alineación
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; guardar dirección del píxel
    mov [rbp - 32], rdi
    
    ; --- leer componentes en orden BGR ---
    movzx eax, byte [rdi]      ; B
    movzx ebx, byte [rdi + 1]  ; G
    movzx ecx, byte [rdi + 2]  ; R

    ; --- convertir B a lineal ---
    cvtsi2sd xmm0, eax
    divsd xmm0, [const_255]
    call valorRGBlineal
    movsd [rbp - 8], xmm0 ; guardar B_lineal
    
    ; --- convertir G a lineal ---
    cvtsi2sd xmm0, ebx
    divsd xmm0, [const_255]
    call valorRGBlineal
    movsd [rbp - 16], xmm0 ; guardar G_lineal
    
    ; --- convertir R a lineal ---
    cvtsi2sd xmm0, ecx
    divsd xmm0, [const_255]
    call valorRGBlineal
    movsd [rbp - 24], xmm0 ; guardar R_lineal
    
    ; --- calcular Y_lineal ---
    ; Y = 0.2126*R + 0.7152*G + 0.0722*B
    movsd xmm0, [rbp - 24] ; R_lineal
    mulsd xmm0, [const_coef_R]
    movsd xmm1, [rbp - 16] ; G_lineal
    mulsd xmm1, [const_coef_G]
    movsd xmm2, [rbp - 8]  ; B_lineal
    mulsd xmm2, [const_coef_B]
    addsd xmm0, xmm1
    addsd xmm0, xmm2 ; xmm0 = Y_lineal
    
    ; --- calcular Y_comprimido ---
    call valorYcomprimido
    mulsd xmm0, [const_255] ; escalar a 0-255
    
    ; --- convertir a entero con redondeo ---
    cvttsd2si eax, xmm0   ; convertir con truncamiento
    
    ; redondeo
    mov edx, eax
    cvtsi2sd xmm1, edx
    subsd xmm0, xmm1
    comisd xmm0, [const_0_5]
    jb .no_redondear
    inc eax
    
.no_redondear:
    ; asegurar rango 0-255
    cmp eax, 255
    jle .verificar_minimo
    mov eax, 255
    jmp .guardar_pixel

.verificar_minimo:
    cmp eax, 0
    jge .guardar_pixel
    mov eax, 0
    
.guardar_pixel:
    ; recuperar dirección del píxel
    mov r11, [rbp - 32]
    
    ; actualizar píxel (BGR -> escala de grises)
    mov byte [r11], al     ; B
    mov byte [r11 + 1], al ; G
    mov byte [r11 + 2], al ; R
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

section .data
const_0_5: dq 0.5