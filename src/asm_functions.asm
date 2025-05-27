section .text
global procesarImagen, valorRGBlineal, valorYcomprimido

; --- constantes ---
%define PUNTERO_IMAGEN    rdi   ; registro con la direccion de los datos de la imagen
%define NUM_FILAS         rsi   ; numero de filas de la imagen
%define NUM_COLUMNAS      rdx   ; numero de columnas
%define NUM_CANALES       rcx   ; numero de canales (3 para BGR)

%define COEF_R      0.2126      ; coeficiente para el canal R
%define COEF_G      0.7152      ; coeficiente para el canal G
%define COEF_B      0.0722      ; coeficiente para el canal B

section .data
const_255:          dq 255.0    ; para normalizar valores
max_pixel_value:    dd 255      ; valor maximo de un pixel
min_pixel_value:    dd 0        ; valor minimo

section .text

;funcion principal que recorre la imagen y llama a procesarPixel para cada pixel.
procesarImagen:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; inicializar contador de filas
    xor r8, r8                 ; r8 = indice de fila

bucle_filas:
    cmp r8, NUM_FILAS
    jge fin_bucle_filas

    ; calcular desplazamiento de la fila
    mov rax, r8
    imul rax, NUM_COLUMNAS
    imul rax, 3
    mov r9, rax                

    ; inicializar contador de columnas (j = 0)
    xor r10, r10              ; r10 = indice de columna

bucle_columnas:
    cmp r10, NUM_COLUMNAS
    jge fin_bucle_columnas

    ; calcular direccion del pixel actual
    mov rax, r10
    imul rax, 3
    add rax, r9
    lea r11, [PUNTERO_IMAGEN + rax] ; r11 = direccion del pixel

    ; --- llamar a procesarPixel ---
    call procesarPixel

    ; Avanzar a la siguiente columna
    inc r10
    jmp bucle_columnas

fin_bucle_columnas:
    inc r8
    jmp bucle_filas

fin_bucle_filas:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

; procesa un pixel individual (dirección en r11) y xonvierte sus componentes BGR a escala de grises
procesarPixel:
    ; guardar registros que se van a modificar
    push rbx
    push r12

    ; --- convertir B, G, R a valores lineales ---

    ; procesar B (primer byte)
    movzx ebx, byte [r11]       ; cargar valor B
    cvtsi2sd xmm0, ebx
    divsd xmm0, [const_255]
    call valorRGBlineal          ; xmm0 = B_lineal

    ; procesar G (segundo byte)
    movzx r12d, byte [r11 + 1]  ; cargar valor G
    cvtsi2sd xmm1, r12d
    divsd xmm1, [const_255]
    call valorRGBlineal          ; xmm1 = G_lineal

    ; procesar R (tercer byte)
    movzx eax, byte [r11 + 2]   ; cargar valor R
    cvtsi2sd xmm2, eax
    divsd xmm2, [const_255]
    call valorRGBlineal          ; xmm2 = R_lineal

    ; --- calcular Y_lineal --- formula: Y = 0.2126*R + 0.7152*G + 0.0722*B
    mulsd xmm2, [const_coef_R]  ; R * 0.2126
    mulsd xmm1, [const_coef_G]  ; G * 0.7152
    mulsd xmm0, [const_coef_B]  ; B * 0.0722
    addsd xmm2, xmm1
    addsd xmm2, xmm0            ; xmm2 = Y_lineal

    ; calcular Y_comprimido
    movsd xmm0, xmm2
    call valorYcomprimido        ; xmm0 = Ysrgb (0-1)
    mulsd xmm0, [const_255]     ; escalar a 0-255

    ; convertir a entero
    cvtsd2si eax, xmm0
    cmp eax, 255
    cmovg eax, [max_pixel_value]
    cmp eax, 0
    cmovl eax, [min_pixel_value]

    ; actualizar píxel
    mov byte [r11], al          ; canal B
    mov byte [r11 + 1], al      ; canal G
    mov byte [r11 + 2], al      ; canal R

    ; restaurar registros y retornar
    pop r12
    pop rbx
    ret

valorRGBlineal:
    ; ...
    ret

valorYcomprimido:
    ; ...
    ret