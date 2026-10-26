% s(Var, F, R): R es la integral de F respecto a Var.
% (Se omite la constante de integración C.)
% Nota: en SWI-Prolog el logaritmo natural es log/1 (no ln), así el
% resultado se puede evaluar con is/2.


% Integral de una constante:

s(Var, K, R):-
    atom(Var), number(K), por(K, Var, R), !.


% Integral de una variable respecto a sí misma:

s(Var, Var, 1/2*Var^2):-
    atom(Var), !.


% Integral de una variable elevada a la N (N distinto de -1):

s(Var, Var^N, R):-
    atom(Var), number(N), N =\= -1, is(M, +(N,1)),
    coef(1, M, C), pot(Var, M, P), por(C, P, R), !.


% Integral de una constante por una variable elevada a la N (N distinto de -1):

s(Var, K*Var^N, R):-
    atom(Var), number(K), number(N), N =\= -1, is(M, +(N,1)),
    coef(K, M, C), pot(Var, M, P), por(C, P, R), !.


% INTEGRALES PARA EVALUACION:

% Integral de una variable elevada a la N (N distinto de -1):

s(Var, Var^N, R):-
    var(Var), number(N), N =\= -1, is(M, +(N,1)),
    coef(1, M, C), pot(Var, M, P), por(C, P, R), !.


% Integral de una variable elevada a la -1:

s(Var, Var^N, log(abs(Var))):-
    var(Var), number(N), N =:= -1, !.


% NUEVAS INTEGRALES:

% Integral de una constante por una variable:

s(Var, K*Var, R):-
    atom(Var), number(K), coef(K, 2, C), por(C, Var^2, R), !.


% Integral de 1/x (logaritmo natural):

s(Var, 1/Var, log(abs(Var))):-
    atom(Var), !.


% Integral de K/x:

s(Var, K/Var, R):-
    atom(Var), number(K), por(K, log(abs(Var)), R), !.


% Integral de x^(-1) (equivale a 1/x):

s(Var, Var^N, log(abs(Var))):-
    atom(Var), number(N), N =:= -1, !.


% Integral de una constante por x^(-1):

s(Var, K*Var^N, R):-
    atom(Var), number(K), number(N), N =:= -1, por(K, log(abs(Var)), R), !.


% Integral de e^x:

s(Var, e^Var, e^Var):-
    atom(Var), !.


% Integral del seno:

s(Var, sin(Var), -cos(Var)):-
    atom(Var), !.


% Integral del coseno:

s(Var, cos(Var), sin(Var)):-
    atom(Var), !.


% Integral de la tangente:

s(Var, tan(Var), -log(abs(cos(Var)))):-
    atom(Var), !.


% Integral de la secante al cuadrado:

s(Var, sec(Var)^2, tan(Var)):-
    atom(Var), !.


% Integral de la raíz cuadrada:

s(Var, sqrt(Var), 2/3*Var^(3/2)):-
    atom(Var), !.


% Integral del logaritmo natural:

s(Var, log(Var), Var*log(Var)-Var):-
    atom(Var), !.


% Integral de 1/(1+x^2):

s(Var, 1/(1+Var^2), atan(Var)):-
    atom(Var), !.


% Integral de 1/sqrt(1-x^2):

s(Var, 1/sqrt(1-Var^2), asin(Var)):-
    atom(Var), !.


% Integral de a^x (a constante positiva distinta de 1):

s(Var, K^Var, K^Var/log(K)):-
    atom(Var), number(K), K > 0, K =\= 1, !.


% INTEGRALES POR PARTES:

% Integral de x*e^x:

s(Var, Var*e^Var, e^Var*(Var-1)):-
    atom(Var), !.


% Integral de x*sin(x):

s(Var, Var*sin(Var), sin(Var)-Var*cos(Var)):-
    atom(Var), !.


% Integral de x*cos(x):

s(Var, Var*cos(Var), cos(Var)+Var*sin(Var)):-
    atom(Var), !.


% INTEGRALES CON ARGUMENTO LINEAL U = A*x + B (cambio de variable):

% Integral de e^U:

s(Var, e^U, R):-
    atom(Var), lineal(Var, U, A), coef(1, A, C), por(C, e^U, R), !.


% Integral de exp(U) (exp(U) es lo mismo que e^U):

s(Var, exp(U), R):-
    atom(Var), s(Var, e^U, R), !.


% Integral de sin(U):

s(Var, sin(U), R):-
    atom(Var), lineal(Var, U, A), coef(-1, A, C), por(C, cos(U), R), !.


% Integral de cos(U):

s(Var, cos(U), R):-
    atom(Var), lineal(Var, U, A), coef(1, A, C), por(C, sin(U), R), !.


% Integral de sec(U)^2:

s(Var, sec(U)^2, R):-
    atom(Var), lineal(Var, U, A), coef(1, A, C), por(C, tan(U), R), !.


% Integral de U^N (N distinto de -1):

s(Var, U^N, R):-
    atom(Var), number(N), N =\= -1, lineal(Var, U, A), is(M, +(N,1)),
    D is A*M, coef(1, D, C), pot(U, M, P), por(C, P, R), !.


% Integral de U^(-1):

s(Var, U^N, R):-
    atom(Var), number(N), N =:= -1, lineal(Var, U, A),
    coef(1, A, C), por(C, log(abs(U)), R), !.


% Integral de K/U:

s(Var, K/U, R):-
    atom(Var), number(K), lineal(Var, U, A),
    coef(K, A, C), por(C, log(abs(U)), R), !.


% REGLAS GENERALES:

% Integral de una constante por cualquier función (K*sin(x), K*e^x, K*(x+1), ...):

s(Var, K*F, R):-
    atom(Var), number(K), s(Var, F, RF), por(K, RF, R), !.


% Integral de una función con signo negativo (-F):

s(Var, -F, R):-
    atom(Var), s(Var, F, RF), neg(RF, R), !.


% Integral de una suma (se integra cada término):

s(Var, F+G, R):-
    atom(Var), s(Var, F, RF), s(Var, G, RG), sumar(RF, RG, R), !.


% Integral de una resta (se integra cada término):

s(Var, F-G, R):-
    atom(Var), s(Var, F, RF), s(Var, G, RG), restar(RF, RG, R), !.



% INTEGRAL DEFINIDA Y EVALUACION:

% definida(Var, F, A, B, V): V es la integral de F respecto a Var entre A y B,
% calculada como F(B) - F(A).

definida(Var, F, A, B, V):-
    s(Var, F, I), evaluar(Var, I, A, FA), evaluar(Var, I, B, FB),
    V is FB - FA.


% evaluar(Var, I, X0, V): V es el valor de la expresión I cuando Var vale X0.

evaluar(Var, I, X0, V):-
    X is float(X0), sust(Var, X, I, E), V is E.


% sust(Var, Val, T, R): R es T con cada aparición de Var cambiada por Val.

sust(Var, Val, T, Val):-
    T == Var, !.

sust(_, _, T, T):-
    atomic(T), !.

sust(Var, Val, T, R):-
    T =.. [F|Args], maplist(sust(Var, Val), Args, NArgs), R =.. [F|NArgs].



% PREDICADOS AUXILIARES:

% lineal(Var, U, A): U es de la forma A*Var + B (B puede no estar).

lineal(Var, Var, 1).

lineal(Var, A*Var, A):-
    number(A), A =\= 0.

lineal(Var, U+B, A):-
    number(B), lineal(Var, U, A).

lineal(Var, U-B, A):-
    number(B), lineal(Var, U, A).

lineal(Var, B+U, A):-
    number(B), lineal(Var, U, A).


% coef(K, M, C): C es la fracción K/M simplificada (2/4 -> 1/2, 6/3 -> 2).

coef(K, M, C):-
    integer(K), integer(M), !,
    G is gcd(K, M), A0 is K // G, B0 is M // G,
    ( B0 < 0 -> A is -A0, B is -B0 ; A = A0, B = B0 ),
    ( B =:= 1 -> C = A ; C = A/B ).

coef(K, M, C):-
    C is K / M.


% pot(Var, M, P): P es Var^M, escribiendo Var^1 como Var.

pot(Var, M, Var):-
    M =:= 1, !.

pot(Var, M, Var^M).


% por(C, T, R): R es C*T, quitando el coeficiente 1 y pasando el signo de T a C
% (3 * -cos(x) -> -3*cos(x)).

por(C, -T, R):-
    number(C), !, C2 is -C, por(C2, T, R).

por(A/B, -T, R):-
    number(A), !, A2 is -A, por(A2/B, T, R).

por(C, T, T):-
    C == 1, !.

por(C, T, R):-
    C == -1, !, neg(T, R).

por(C, T, C*T).


% neg(T, R): R es -T, evitando dobles negativos (-(-T) -> T, -(3*x) -> -3*x).

neg(-T, T):- !.

neg(C*T, R):-
    number(C), !, C2 is -C, por(C2, T, R).

neg(A/B*T, R):-
    number(A), number(B), !, A2 is -A, por(A2/B, T, R).

neg(T, -T).


% sumar(A, B, R): R es A+B, escribiendo A + -B como A-B.

sumar(A, -B, A-B):- !.

sumar(A, C*T, A-R):-
    number(C), C < 0, !, C2 is -C, por(C2, T, R).

sumar(A, B, A+B).


% restar(A, B, R): R es A-B, escribiendo A - -B como A+B.

restar(A, -B, A+B):- !.

restar(A, C*T, A+R):-
    number(C), C < 0, !, C2 is -C, por(C2, T, R).

restar(A, B, A-B).
