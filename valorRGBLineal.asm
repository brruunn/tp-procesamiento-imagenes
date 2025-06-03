; double valorRGBlineal (double RGBcomprimido);
;
; double valorRGBlineal (double RGBcomprimido) {
; 	double resultado;
; 	double a,b;
; 	if (isless(RGBcomprimido,0.04045)) {
; 		resultado = RGBcomprimido / 12.92;
; 	} else {
; 		a = (RGBcomprimido+0.055);
; 		b = (a/1.055);
; 		resultado = pow(b,(2.4));
; 	}
; 	return (resultado);
; }

global valorRGBlineal
extern pow

section .data
    ; constantes
    umbralDeCompresion  dq 0.04045  ; PD
    divisorLineal       dq 12.92    ; PD
    cteA                dq 0.055    ; PD
    cteEscalaA          dq 1.055    ; PD
    correcionGamma      dq 2.4      ; PD

section .text

valorRGBlineal:
    ; CAMBIO: xmm0 ya tiene el valor como double, no rdi como entero
    ; cargamos en registro la constante para comparar
    movsd xmm1,[umbralDeCompresion]

    ; comparamos
    comisd xmm0,xmm1
    ; Si RGBComprimido >= cte. saltamos a el proceso debido
    jge no_acotado

acotado:
    ; resultado = RGBComprimido / 12.92
    movsd xmm1,[divisorLineal]

    divsd xmm0,xmm1

    jmp fin

no_acotado:
    ; a = (RGBcomprimido+0.055);
    movsd xmm1,[cteA]
    addsd xmm0,xmm1

    ; b = (a/1.055);
    movsd xmm1,[cteEscalaA]

    divsd xmm0,xmm1

    sub rsp,8 ; alineo el stack
    ; resultado = pow(b,(2.4));

    ; CAMBIO: parámetros para pow van en xmm0 y xmm1, no rdi/rsi
    movsd xmm1,[correcionGamma]

    call pow

    add rsp,8 ; devuelvo el stack a su posicion

    ; CAMBIO: resultado en xmm0, no necesita conversion a rax

fin:
    ; CAMBIO: resultado ya esta en xmm0, no convertir a entero
    ret