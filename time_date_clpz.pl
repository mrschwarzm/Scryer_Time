:- use_module(library(clpz)).
:- use_module(library(reif)).
:- use_module(library(time)).


%?-timestamp_dt(X,-1,1,1,0,0,1).

print_query(Query) :-
    Query,
    write(Query), nl,
    fail.
print_query(_).



% Bidirektional: seconds <-> date (Y-M-D) and time (HH:MM:SS)
% timestamp_dt(Secs, Y,M,D, HH,MM,SS)


timestamp_dt(Secs, Y,M,D, HH,MM,SS) :-
    % Time-Constraints
    HH in 0..23, MM in 0..59, SS in 0..59,
    Rem   in 0..86399,
    HH_MM_SS #= HH*3600 + MM*60 + SS,
    Rem #= HH_MM_SS,
    Secs #= Days*86400 + Rem,
    (   ground(Secs) ->
        days_remainder_from_seconds(Secs, Days, Rem),
        ymd_from_days_det(Days, Y,M,D)
    ;
        month_lengths(Y, ML),
        M in 1..12,
        nth1_clp(M, ML, LM),
        D in 1..LM,
        days_since_epoch_rel(Y,M,D, Days)
    ).

%Euclid deconstruction - Sec/Days
days_remainder_from_seconds(Secs, Days, Rem) :-
    Rem in 0..86399,
    Secs #= Days*86400 + Rem.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Date - Days relational
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
days_since_epoch_rel(Y,M,D, Days) :-
    month_lengths(Y, ML),
    M in 1..12,
    nth1_clp(M, ML, LM),
    D in 1..LM,
    M1 #= M - 1,
    sum_first_n(ML, M1, DaysBefore),
    DOY #= DaysBefore + D,
    days_upto_year(Y, DaysUpToY),
    const_days_upto_1970(C1970),
    Days #= (DaysUpToY - C1970) + (DOY - 1).

%Days to year
days_upto_year(Y, Total) :-
    N1 #= Y - 1,
    A  #= N1 div 4,
    B  #= N1 div 100,
    C  #= N1 div 400,
    Leaps #= A - B + C,
    Total #= 365*Y + Leaps.

% Days  0000-01-01 till 1970-01-01
const_days_upto_1970(719527).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Hinnat to calulate Dates.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

ymd_from_days_det(Days, Y,M,D) :-
    % Ref. 0000-03-01
    Z #= Days + 719468,
    (Z #>= 0 -> E #= Z ; E #= Z - 146096),
    Era #= E div 146097,
    Doe #= Z - Era*146097,
    Yoe #= (Doe - Doe div 1460 + Doe div 36524 - Doe div 146096) div 365,
    Y0  #= Yoe + Era*400,
    DoY #= Doe - (365*Yoe + Yoe div 4 - Yoe div 100 + Yoe div 400),
    Mp  #= (5*DoY + 2) div 153,
    D0  #= DoY - (153*Mp + 2) div 5 + 1,
    M0  #= Mp + 3,
    (   Mp #< 10 ->
        Y #= Y0,     M #= M0
    ;   Y #= Y0 + 1, M #= Mp - 9
    ),
    D #= D0.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Monts and leap years
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
month_lengths(Y, [31, Feb,31,30,31,30,31,31,30,31,30,31]) :-
    feb_length(Y, Feb).

feb_length(Y, Feb) :-
    is_leap_b(Y, B),
    Feb #= 28 + B.

is_leap_b(Y, B) :-
    B in 0..1,
    B400 in 0..1, B4 in 0..1, NotB100 in 0..1,
    B400 #<==> (Y mod 400 #= 0),
    B4   #<==> (Y mod 4   #= 0),
    NotB100 #<==> (Y mod 100 #\= 0),
    B #<==> (B400 #\/ (B4 #/\ NotB100)).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Helper Functions!
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

%Sum of the elements
sum_first_n(_, N, Sum) :-
    N #= 0, Sum #= 0.
sum_first_n([H|T], N, Sum) :-
    N #> 0,
    N1 #= N - 1,
    sum_first_n(T, N1, Rest),
    Sum #= H + Rest.

%Finder of the "right" element in the list
nth1_clp(N, [X|_], X) :-
    N #= 1.
nth1_clp(N, [_|Xs], X) :-
    N #> 1,
    N1 #= N - 1,
    nth1_clp(N1, Xs, X).