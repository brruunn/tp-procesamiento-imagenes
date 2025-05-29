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

external pow

section .data
    ; constantes
    umbralDeCompresion  dq 0.04045  ; PD
    divisorLineal       dq 12.92    ; PD
    cteA                dq 0.055    ; PD
    cteEscalaA          dq 1.055    ; PD
    correcionGamma      dq 2.4      ; PD

section .bss
    ; variables
    resultado   dq  ; PD
    a           dq  ; PD
    b           dq  ; PD

section .text

valorRGBlineal:
    ; cargamos en registro el pasado por parametro
    CVTSI2SD xmm0,rdi ; rdi viene como entero
    ; cargamos en registro la constante para comparar
    CVTSI2SD xmm1,[cte_limite_componente_rgb]

    ; comparamos
    comisd xmm0,xmm1
    ; Si RGBComprimido >= cte. saltamos a el proceso debido
    jge no_acotado

acotado:
    ; resultado = RGBComprimido / 12.92
    CVTSI2SD xmm1,[cte_doce]

    divsd xmm0,xmm1

    j fin

no_acotado:
    ; a = (RGBcomprimido+0.055);
    movsd xmm1,[cteA]
    addsd xmm0,xmm1

    ; b = (a/1.055);
    movsd xmm1,[cteEscalaA]

    divsd xmm0,xmm1

    sub rsp,8 ; alineo el stack
    ; resultado = pow(b,(2.4));

    ; transformo xmm0 a entero para ponerlo en rdi
    ; transformo 2.4 a entero para ponerlo en rsi

    call pow

    add rsp,8 ; devuelvo el stack a su posicion

    ; resultado en rax, pasarlo a xmm0

fin:
    ; cargamos en el debido registro el numero de xmm0
    CVTSD2SI rax,xmm0

    ret
