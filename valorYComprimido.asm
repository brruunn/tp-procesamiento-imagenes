; double valorYcomprimido (double valorYlineal);
;
; double valorYcomprimido (double valorYlineal) {
;     double resultado;
;     double a, b;
;     if (isless(valorYlineal,0.0031308)) {
;         resultado = valorYlineal * 12.92;
;     } else {
;         a = pow(valorYlineal,(1/2.4));
;         b = 1.055 * a;
;         resultado =  b - 0.055;
;     }
;     return (resultado);
; }

global valorYcomprimido
extern pow

section .data
    umbralLineal        dq 0.0031308
    multiplicadorLineal dq 12.92
    cteA                dq 0.41666666666666669 ; 1 / 2.4 con mayor precisión
    cteB                dq 1.055
    correccion           dq 0.055

section .text
valorYcomprimido:
    ; CAMBIO: xmm0 ya tiene el valor como double, no rdi como entero
    ; cargamos en registro la constante para comparar
    movsd xmm1,[umbralLineal]

    ; comparamos
    comisd xmm0,xmm1
    ; Si valorYlineal >= umbral, saltamos a no_acotado
    jae no_acotado

acotado:
    ; resultado = RGBComprimido * 12.92
    movsd xmm1,[multiplicadorLineal]

    mulsd xmm0,xmm1

    jmp fin

no_acotado:
    ; a = pow(valorYlineal,(1/2.4));
    movsd xmm1,[cteA]

    sub rsp,8 ; alineo el stack
    call pow
    add rsp,8 ; devuelvo el stack a su posicion


    ; b = 1.055 * a;
    movsd xmm1,[cteB]

    mulsd xmm0,xmm1

    ; resultado =  b - 0.055;
    movsd xmm1,[correccion]
    subsd xmm0,xmm1

fin:
    ; CAMBIO: resultado ya está en xmm0, no convertir a entero
    ret