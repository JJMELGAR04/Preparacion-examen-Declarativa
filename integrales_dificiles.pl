:- encoding(utf8).

% =====================================================================
%  INTEGRALES DIFÍCILES
% =====================================================================
%
%  Este archivo usa las reglas de integrales.pl (s/3) y agrega
%  integrales más pesadas en un predicado nuevo: d/3.
%
%      d(Var, F, R)  ->  R es la integral de F respecto a Var.
%
%  Si d/3 no tiene una regla "difícil" para F, le pasa el trabajo a s/3,
%  así que d/3 integra TODO lo que ya integraba s/3 y además lo nuevo.
%
%  Cómo usarlo:
%      ?- d(x, x^2*e^x, R).                 integral indefinida
%      ?- definida_d(x, sin(x)^2, 0, pi, V). integral definida de 0 a pi
%      ?- ejemplos.                         muestra todas las integrales
%                                           con su resultado y explicación
%
%  Notas:
%    - El logaritmo natural es log/1 (así se puede evaluar con is/2).
%    - Las potencias de funciones se escriben así: sin(x)^2, log(x)^2.
%    - Una constante por un producto va entre paréntesis: 3*(x^2*e^x).
%    - Se omite la constante de integración C.
% =====================================================================

:- ensure_loaded('integrales.pl').


% ---------------------------------------------------------------------
% 1. POR PARTES REPETIDA:  ∫ x^n · e^x dx
% ---------------------------------------------------------------------
% Por partes con u = x^n, dv = e^x dx sale la FÓRMULA DE REDUCCIÓN:
%
%     ∫ x^n e^x dx  =  x^n e^x  -  n · ∫ x^(n-1) e^x dx
%
% Cada vez el exponente baja en 1, hasta llegar a ∫ e^x dx = e^x.
% Por eso la regla es recursiva: se llama a sí misma con n-1.
% Ejemplo: ∫ x^2 e^x = x^2 e^x - 2(x e^x - e^x) = e^x (x^2 - 2x + 2)

d(Var, Var^0*e^Var, e^Var):-                 % caso base: ∫ e^x = e^x
    atom(Var), !.

d(Var, Var^N*e^Var, R):-                     % paso recursivo (n > 0)
    atom(Var), integer(N), N > 0, N1 is N-1,
    d(Var, Var^N1*e^Var, R1),
    pot(Var, N, P), por(N, R1, B), R = P*e^Var - B, !.


% ---------------------------------------------------------------------
% 2. POR PARTES DOS VECES:  ∫ x^2 · sin(x) dx   y   ∫ x^2 · cos(x) dx
% ---------------------------------------------------------------------
% Se hace por partes con u = x^2 (que se deriva hasta desaparecer):
%   1ª vez: u = x^2 -> du = 2x dx
%   2ª vez: u = 2x  -> du = 2 dx
%
%   ∫ x^2 sin(x) dx = -x^2 cos(x) + 2x sin(x) + 2 cos(x)
%   ∫ x^2 cos(x) dx =  x^2 sin(x) + 2x cos(x) - 2 sin(x)

d(Var, Var^2*sin(Var), 2*Var*sin(Var) + 2*cos(Var) - Var^2*cos(Var)):-
    atom(Var), !.

d(Var, Var^2*cos(Var), Var^2*sin(Var) + 2*Var*cos(Var) - 2*sin(Var)):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 3. POR PARTES "CÍCLICA":  ∫ e^x · sin(x) dx   y   ∫ e^x · cos(x) dx
% ---------------------------------------------------------------------
% Al hacer por partes dos veces vuelve a aparecer la integral original:
%
%     I = e^x sin(x) - e^x cos(x) - I
%
% Se despeja I como si fuera una ecuación:  2I = e^x (sin x - cos x)
%
%   ∫ e^x sin(x) dx = 1/2 · e^x · (sin(x) - cos(x))
%   ∫ e^x cos(x) dx = 1/2 · e^x · (sin(x) + cos(x))

d(Var, e^Var*sin(Var), 1/2*e^Var*(sin(Var)-cos(Var))):-
    atom(Var), !.

d(Var, e^Var*cos(Var), 1/2*e^Var*(sin(Var)+cos(Var))):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 4. POR PARTES CON LOGARITMOS:  ∫ x^n · ln(x) dx   (n distinto de -1)
% ---------------------------------------------------------------------
% Se elige u = ln(x) (porque al derivarlo queda 1/x, que es más simple)
% y dv = x^n dx:
%
%   ∫ x^n ln(x) dx = x^(n+1)/(n+1) · ln(x)  -  x^(n+1)/(n+1)^2
%
% Ejemplo: ∫ x ln(x) dx = 1/2 x^2 ln(x) - 1/4 x^2

d(Var, Var*log(Var), R):-                    % x·ln(x) es x^1·ln(x)
    atom(Var), d(Var, Var^1*log(Var), R), !.

d(Var, Var^N*log(Var), R):-
    atom(Var), number(N), N =\= -1, M is N+1, M2 is M*M,
    coef(1, M, C1), coef(1, M2, C2), pot(Var, M, P),
    por(C1, P*log(Var), A), por(C2, P, B), R = A - B, !.


% ---------------------------------------------------------------------
% 5. LOGARITMO AL CUADRADO:  ∫ ln(x)^2 dx
% ---------------------------------------------------------------------
% Por partes con u = ln(x)^2, dv = dx  ->  du = 2 ln(x)/x dx, v = x
%   = x ln(x)^2 - 2 ∫ ln(x) dx
%   = x ln(x)^2 - 2 (x ln(x) - x)
%
%   ∫ ln(x)^2 dx = x ln(x)^2 - 2x ln(x) + 2x

d(Var, log(Var)^2, Var*log(Var)^2 - 2*Var*log(Var) + 2*Var):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 6. SUSTITUCIÓN:  ∫ ln(x)/x dx
% ---------------------------------------------------------------------
% Con u = ln(x) se tiene du = 1/x dx, entonces queda ∫ u du = u^2/2
%
%   ∫ ln(x)/x dx = 1/2 · ln(x)^2

d(Var, log(Var)/Var, 1/2*log(Var)^2):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 7. SUSTITUCIÓN CON x^2:  ∫ x·e^(x^2),  ∫ x·cos(x^2),  ∫ x·sin(x^2)
% ---------------------------------------------------------------------
% Con u = x^2 se tiene du = 2x dx, o sea  x dx = du/2.
% El "x" de afuera es justo lo que hace falta para la sustitución.
%
%   ∫ x e^(x^2) dx   = 1/2 · e^(x^2)
%   ∫ x cos(x^2) dx  = 1/2 · sin(x^2)
%   ∫ x sin(x^2) dx  = -1/2 · cos(x^2)

d(Var, Var*e^(Var^2), 1/2*e^(Var^2)):-
    atom(Var), !.

d(Var, Var*cos(Var^2), 1/2*sin(Var^2)):-
    atom(Var), !.

d(Var, Var*sin(Var^2), -1/2*cos(Var^2)):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 8. SUSTITUCIÓN CON DENOMINADOR:  ∫ x/(x^2 + a) dx
% ---------------------------------------------------------------------
% Con u = x^2 + a, du = 2x dx  ->  ∫ (1/2) du/u = 1/2 ln|u|
%
%   ∫ x/(x^2 + a) dx = 1/2 · ln|x^2 + a|

d(Var, Var/(Var^2+A), 1/2*log(abs(Var^2+A))):-
    atom(Var), number(A), !.

d(Var, Var/(Var^2-A), 1/2*log(abs(Var^2-A))):-
    atom(Var), number(A), !.


% ---------------------------------------------------------------------
% 9. POTENCIAS PARES DE SENO Y COSENO:  ∫ sin(x)^2,  ∫ cos(x)^2
% ---------------------------------------------------------------------
% No se integran directo. Se usan las identidades del ángulo doble:
%
%     sin(x)^2 = (1 - cos(2x)) / 2        cos(x)^2 = (1 + cos(2x)) / 2
%
%   ∫ sin(x)^2 dx = x/2 - sin(2x)/4
%   ∫ cos(x)^2 dx = x/2 + sin(2x)/4

d(Var, sin(Var)^2, 1/2*Var - 1/4*sin(2*Var)):-
    atom(Var), !.

d(Var, cos(Var)^2, 1/2*Var + 1/4*sin(2*Var)):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 10. POTENCIAS IMPARES DE SENO Y COSENO:  ∫ sin(x)^3,  ∫ cos(x)^3
% ---------------------------------------------------------------------
% Se separa un factor:  sin^3 = sin^2 · sin = (1 - cos^2) · sin
% y luego u = cos(x), du = -sin(x) dx:
%
%   ∫ sin(x)^3 dx = -cos(x) + cos(x)^3/3
%   ∫ cos(x)^3 dx =  sin(x) - sin(x)^3/3

d(Var, sin(Var)^3, 1/3*cos(Var)^3 - cos(Var)):-
    atom(Var), !.

d(Var, cos(Var)^3, sin(Var) - 1/3*sin(Var)^3):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 11. PRODUCTO SENO·COSENO:  ∫ sin(x)·cos(x) dx
% ---------------------------------------------------------------------
% Con u = sin(x), du = cos(x) dx  ->  ∫ u du = u^2/2
%
%   ∫ sin(x) cos(x) dx = 1/2 · sin(x)^2

d(Var, sin(Var)*cos(Var), 1/2*sin(Var)^2):-
    atom(Var), !.

d(Var, cos(Var)*sin(Var), R):-               % mismo producto al revés
    atom(Var), d(Var, sin(Var)*cos(Var), R), !.


% ---------------------------------------------------------------------
% 12. TANGENTE AL CUADRADO:  ∫ tan(x)^2 dx
% ---------------------------------------------------------------------
% Identidad: tan(x)^2 = sec(x)^2 - 1, y ∫ sec(x)^2 = tan(x)
%
%   ∫ tan(x)^2 dx = tan(x) - x

d(Var, tan(Var)^2, tan(Var) - Var):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 13. SECANTE:  ∫ sec(x) dx
% ---------------------------------------------------------------------
% Truco clásico: multiplicar y dividir por (sec x + tan x).
% El numerador queda igual a la derivada del denominador:
%
%   ∫ sec(x) dx = ln|sec(x) + tan(x)|
%
% (sec(x) se escribe 1/cos(x) para que SWI-Prolog lo pueda evaluar)

d(Var, sec(Var), log(abs(1/cos(Var) + tan(Var)))):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 14. FUNCIONES INVERSAS:  ∫ arctan(x) dx   y   ∫ arcsin(x) dx
% ---------------------------------------------------------------------
% Por partes con u = arctan(x) (o arcsin(x)) y dv = dx:
%
%   ∫ arctan(x) dx = x arctan(x) - 1/2 ln(1 + x^2)
%   ∫ arcsin(x) dx = x arcsin(x) + sqrt(1 - x^2)

d(Var, atan(Var), Var*atan(Var) - 1/2*log(1+Var^2)):-
    atom(Var), !.

d(Var, asin(Var), Var*asin(Var) + sqrt(1-Var^2)):-
    atom(Var), !.


% ---------------------------------------------------------------------
% 15. ARCOTANGENTE GENERAL:  ∫ 1/(x^2 + a^2) dx
% ---------------------------------------------------------------------
% Se saca a^2 como factor y se usa u = x/a:
%
%   ∫ 1/(x^2 + a^2) dx = (1/a) · arctan(x/a)
%
% En la consulta se escribe el número ya elevado: 1/(x^2+9) -> a = 3

d(Var, 1/(Var^2+A), R):-
    atom(Var), number(A), A > 0, raiz(A, S),
    coef(1, S, C), arg_div(Var, S, U), por(C, atan(U), R), !.

d(Var, 1/(A+Var^2), R):-                     % mismo caso, al revés
    atom(Var), number(A), d(Var, 1/(Var^2+A), R), !.


% ---------------------------------------------------------------------
% 16. FRACCIONES PARCIALES:  ∫ 1/(x^2 - a^2) dx
% ---------------------------------------------------------------------
% Se factoriza  x^2 - a^2 = (x - a)(x + a)  y se separa:
%
%     1/(x^2 - a^2) = 1/(2a) · [ 1/(x - a) - 1/(x + a) ]
%
%   ∫ 1/(x^2 - a^2) dx = 1/(2a) · ln| (x - a)/(x + a) |

d(Var, 1/(Var^2-A), R):-
    atom(Var), number(A), A > 0, raiz(A, S), D is 2*S,
    coef(1, D, C), por(C, log(abs((Var-S)/(Var+S))), R), !.


% ---------------------------------------------------------------------
% 17. FRACCIONES PARCIALES GENERAL:  ∫ 1/((x + a)(x + b)) dx,  a ≠ b
% ---------------------------------------------------------------------
%     1/((x+a)(x+b)) = 1/(b-a) · [ 1/(x+a) - 1/(x+b) ]
%
%   ∫ 1/((x + a)(x + b)) dx = 1/(b-a) · ln| (x + a)/(x + b) |
%
% Ejemplos: 1/(x*(x+1)),  1/((x-2)*(x+3))

d(Var, 1/(U*V), R):-
    atom(Var), desplaz(Var, U, A), desplaz(Var, V, B), A =\= B,
    D is B-A, coef(1, D, C), por(C, log(abs(U/V)), R), !.


% ---------------------------------------------------------------------
% 18. SUSTITUCIÓN TRIGONOMÉTRICA:  ∫ 1/sqrt(a^2 - x^2) dx
% ---------------------------------------------------------------------
% Con x = a·sin(t) la raíz se vuelve a·cos(t) y todo se simplifica:
%
%   ∫ 1/sqrt(a^2 - x^2) dx = arcsin(x/a)

d(Var, 1/sqrt(A-Var^2), asin(U)):-
    atom(Var), number(A), A > 0, raiz(A, S), arg_div(Var, S, U), !.


% ---------------------------------------------------------------------
% 19. SUSTITUCIÓN TRIGONOMÉTRICA (la más pesada):  ∫ sqrt(a^2 - x^2) dx
% ---------------------------------------------------------------------
% Con x = a·sin(t), dx = a·cos(t) dt:
%     ∫ sqrt(a^2 - a^2 sin^2 t) · a cos t dt = a^2 ∫ cos(t)^2 dt
% y ∫ cos^2 se hace con el ángulo doble (como en la regla 9).
% Al volver a la variable x queda:
%
%   ∫ sqrt(a^2 - x^2) dx = x/2 · sqrt(a^2 - x^2) + a^2/2 · arcsin(x/a)
%
% (Es el área bajo una semicircunferencia: de -a a a da pi·a^2/2)

d(Var, sqrt(A-Var^2), 1/2*Var*sqrt(A-Var^2) + B):-
    atom(Var), number(A), A > 0, raiz(A, S), arg_div(Var, S, U),
    coef(A, 2, C), por(C, asin(U), B), !.


% ---------------------------------------------------------------------
% REGLAS GENERALES
% ---------------------------------------------------------------------
% Si no hay una regla difícil, se intenta con las reglas de s/3.

d(Var, F, R):-
    s(Var, F, R), !.

% Si s/3 tampoco puede (porque hay una parte difícil dentro), se separa
% la expresión y se integra cada parte con d/3:

d(Var, K*F, R):-                             % constante por función
    atom(Var), number(K), d(Var, F, RF), por(K, RF, R), !.

d(Var, -F, R):-                              % signo negativo
    atom(Var), d(Var, F, RF), neg(RF, R), !.

d(Var, F+G, R):-                             % suma
    atom(Var), d(Var, F, RF), d(Var, G, RG), sumar(RF, RG, R), !.

d(Var, F-G, R):-                             % resta
    atom(Var), d(Var, F, RF), d(Var, G, RG), restar(RF, RG, R), !.



% ---------------------------------------------------------------------
% INTEGRAL DEFINIDA
% ---------------------------------------------------------------------
% Teorema fundamental del cálculo:  ∫ de A a B de f(x) dx = F(B) - F(A)

definida_d(Var, F, A, B, V):-
    d(Var, F, I), evaluar(Var, I, A, FA), evaluar(Var, I, B, FB),
    V is FB - FA.



% ---------------------------------------------------------------------
% PREDICADOS AUXILIARES
% ---------------------------------------------------------------------

% raiz(A, S): S es la raíz cuadrada de A (entera si es exacta: 9 -> 3).

raiz(A, S):-
    R is sqrt(A), ( R =:= truncate(R) -> S is truncate(R) ; S = R ).


% arg_div(Var, S, U): U es Var/S, o solo Var si S es 1.

arg_div(Var, S, Var):-
    S =:= 1, !.

arg_div(Var, S, Var/S).


% desplaz(Var, U, A): U es de la forma x + A (x sola es A = 0).

desplaz(Var, Var, 0).

desplaz(Var, Var+A, A):-
    number(A).

desplaz(Var, Var-A, B):-
    number(A), B is -A.



% ---------------------------------------------------------------------
% EJEMPLOS:  ?- ejemplos.
% ---------------------------------------------------------------------
% Muestra cada integral, su resultado y cómo se resolvió.

ejemplo(x^3*e^x,         'Por partes repetida (fórmula de reducción).').
ejemplo(x^2*sin(x),      'Por partes dos veces, u = x^2.').
ejemplo(x^2*cos(x),      'Por partes dos veces, u = x^2.').
ejemplo(e^x*sin(x),      'Por partes cíclica: la integral reaparece y se despeja.').
ejemplo(e^x*cos(x),      'Por partes cíclica: la integral reaparece y se despeja.').
ejemplo(x*log(x),        'Por partes con u = ln(x), dv = x dx.').
ejemplo(x^2*log(x),      'Por partes con u = ln(x), dv = x^2 dx.').
ejemplo(log(x)^2,        'Por partes con u = ln(x)^2, dv = dx.').
ejemplo(log(x)/x,        'Sustitución u = ln(x), du = dx/x.').
ejemplo(x*e^(x^2),       'Sustitución u = x^2, du = 2x dx.').
ejemplo(x*cos(x^2),      'Sustitución u = x^2, du = 2x dx.').
ejemplo(x/(x^2+4),       'Sustitución u = x^2 + 4, du = 2x dx.').
ejemplo(sin(x)^2,        'Identidad del ángulo doble: sin^2 = (1 - cos 2x)/2.').
ejemplo(cos(x)^2,        'Identidad del ángulo doble: cos^2 = (1 + cos 2x)/2.').
ejemplo(sin(x)^3,        'Se separa sin^2 = 1 - cos^2 y u = cos(x).').
ejemplo(cos(x)^3,        'Se separa cos^2 = 1 - sin^2 y u = sin(x).').
ejemplo(sin(x)*cos(x),   'Sustitución u = sin(x), du = cos(x) dx.').
ejemplo(tan(x)^2,        'Identidad tan^2 = sec^2 - 1.').
ejemplo(sec(x),          'Multiplicar y dividir por sec(x) + tan(x).').
ejemplo(atan(x),         'Por partes con u = arctan(x), dv = dx.').
ejemplo(asin(x),         'Por partes con u = arcsin(x), dv = dx.').
ejemplo(1/(x^2+9),       'Forma arcotangente con a = 3.').
ejemplo(1/(x^2-4),       'Fracciones parciales: (x - 2)(x + 2).').
ejemplo(1/(x*(x+1)),     'Fracciones parciales: 1/x - 1/(x + 1).').
ejemplo(1/((x-2)*(x+3)), 'Fracciones parciales con a = -2, b = 3.').
ejemplo(1/sqrt(4-x^2),   'Sustitución trigonométrica x = 2 sin(t).').
ejemplo(sqrt(9-x^2),     'Sustitución trigonométrica x = 3 sin(t) (la más pesada).').
ejemplo(x^2*e^x + 3*sin(x)^2 - 1/(x^2+1),
                         'Combinada: se integra cada término por separado.').

ejemplos:-
    forall(ejemplo(F, Texto), mostrar(F, Texto)).

mostrar(F, Texto):-
    ( d(x, F, R) ->
        format("~n  ∫ ~w dx~n    = ~w~n    Método: ~w~n", [F, R, Texto])
    ;   format("~n  ∫ ~w dx~n    (no se pudo integrar)~n", [F])
    ).
