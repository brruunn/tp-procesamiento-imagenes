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

section .data
section .bss
section .text
valorYcomprimido:
    ret
