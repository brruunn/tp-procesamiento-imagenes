global procesarImagen
extern valorYcomprimido
extern valorRGBlineal

; constantes
section .data
const_255: dq 255.0
const_coef_R: dq 0.2126
const_coef_G: dq 0.7152
const_coef_B: dq 0.0722
const_0_5: dq 0.5

section .text
; parámetros:
;   rdi = puntero imagen
;   rsi = filas
;   rdx = columnas
;   rcx = canales (siempre 3)
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
    mov r15, rcx   ; canales (3)
    
    ; calcular ancho útil por fila en bytes (columnas * canales)
    mov rax, r14   ; columnas
    imul rax, r15  ; * canales
    mov r11, rax   ; r11 = bytes por fila
    
    xor r8, r8     ; i = 0 (contador filas)

bucle_filas:
    cmp r8, r13
    jge fin_procesamiento
    
    xor r9, r9      ; j = 0 (posición en la fila, incrementa de 3 en 3)

bucle_columnas:
    cmp r9, r11     ; ¿j < bytes por fila?
    jge fin_bucle_columnas
    
    ; Calcular dirección exactamente como en C++: p + j + i*nCols*channels
    mov rax, r8     ; i (fila actual)
    imul rax, r11   ; i * (nCols * channels)
    add rax, r9     ; + j (posición en fila)
    lea rbx, [r12 + rax] ; rbx = p + j + i*nCols*channels
    
    ; procesar píxel (preservar registros)
    push r8
    push r9
    push r11
    mov rdi, rbx    ; pasar dirección del píxel
    call procesarPixel
    pop r11
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
    sub rsp, 48
    
    ; guardar dirección del píxel
    mov [rbp - 8], rdi
    
    ; --- leer componentes en orden BGR ---
    movzx eax, byte [rdi]      ; B
    movzx ebx, byte [rdi + 1]  ; G
    movzx ecx, byte [rdi + 2]  ; R

    ; --- convertir B a lineal ---
    cvtsi2sd xmm0, eax
    divsd xmm0, [const_255]
    movsd [rbp - 16], xmm0 ; guardar B_lineal
    
    ; --- convertir G a lineal ---
    cvtsi2sd xmm0, ebx
    divsd xmm0, [const_255]
    movsd [rbp - 24], xmm0 ; guardar G_lineal
    
    ; --- convertir R a lineal ---
    cvtsi2sd xmm0, ecx
    divsd xmm0, [const_255]
    movsd [rbp - 32], xmm0      ; R normalizado
    
    ; Procesar B
    movsd xmm0, [rbp - 16]
    call valorRGBlineal
    mulsd xmm0, [const_coef_B]
    movsd [rbp - 40], xmm0      ; componente B
    
    ; Procesar G
    movsd xmm0, [rbp - 24]
    call valorRGBlineal
    mulsd xmm0, [const_coef_G]
    addsd xmm0, [rbp - 40]      ; B + G
    movsd [rbp - 40], xmm0      ; suma parcial
    
    ; Procesar R
    movsd xmm0, [rbp - 32]
    call valorRGBlineal
    mulsd xmm0, [const_coef_R]
    addsd xmm0, [rbp - 40]      ; Y lineal completo
    
    ; Y comprimido
    call valorYcomprimido
    mulsd xmm0, [const_255]
    addsd xmm0, [const_0_5]
    cvttsd2si eax, xmm0
    
    ; Clampear
    cmp eax, 0
    jge .verificar_max
    xor eax, eax
    jmp .guardar_pixel
    
.verificar_max:
    cmp eax, 255
    jle .guardar_pixel
    mov eax, 255
    
.guardar_pixel:
    mov rdi, [rbp - 8]
    mov byte [rdi], al
    mov byte [rdi + 1], al
    mov byte [rdi + 2], al
    
    leave
    ret