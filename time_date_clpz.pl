:- use_module(library(clpz)).
:- use_module(library(reif)).
:- use_module(library(time)).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

--------------------------DESCRIPTION------------------------------------------
-------------------------------------------------------------------------------

The core of this system is timestamp_dt/7, a predicate based on CLP(Z). It lets you compute dates from seconds and seconds
from dates—the classic Unix timestamp. The timeline handled by this predicate ranges from `0000-01-01 00:00:00` up to the limits of the integer type.

Several predicates are derived from timestamp_dt/7 for everyday use:

- date_calc_time_between/16 – computes the time between two dates
- date_calc_time_plus/16 – adds a duration to a date
- date_calc_time_minus/16 – subtracts a duration from a date
- date_calc_days_plus/13 – adds days to a date and time
- date_calc_days_minus/13 – subtracts days from a date and time
- date_calc_hours_plus/13 – adds hours to a date and time
- date_calc_hours_minus/13 – subtracts hours from a date and time
- date_calc_minutes_plus/13 – adds minutes to a date and time
- date_calc_minutes_minus/13 – subtracts minutes from a date and time
- date_calc_seconds_plus/13 – adds seconds to a date and time
- date_calc_seconds_minus/13 – subtracts seconds from a date and time
- date_calc_days_plus/7 – adds days to a date
- date_calc_days_minus/7 – subtracts days from a date
- date_calc_hours_plus/7 – adds hours to a date
- date_calc_hours_minus/7 – subtracts hours from a date
- date_calc_minutes_plus/7 – adds minutes to a date
- date_calc_minutes_minus/7 – subtracts minutes from a date
- date_calc_seconds_plus/7 – adds seconds to a date
- date_calc_seconds_minus/7 – subtracts seconds from a date
- timestamp_milliseconds_dt/8 – converts between milliseconds and a date/time
- timestamp_milliseconds_dt_float/7 – converts between milliseconds and a date/time with fractional seconds 

In the section "HELPFUL PREDICATES" (below) you can see the definition of the listed predicates, they are not described in detail, because i believe it is faster to read
the definition, than a description.(I hope it is intuitive to use them)

Detailed description of timestamp_dt/7:
You can find the implementation below "HELPFUL PREDICATES"
timestamp_dt(?Seconds:integer, ?Y:integer, ?M:integer, ?D:integer, ?HH:integer, ?MM:integer, ?SS:integer) is semidet.

   True if Seconds represents the POSIX timestamp (seconds since epoch)
   corresponding to the date and time components (Y,M,D, HH:MM:SS).

   This predicate is bidirectional:
   - If Seconds is given, it decomposes the timestamp into date/time components.
   - If the date/time components are given, it calculates the corresponding Seconds.
   @param Secs  The total number of seconds since 1970-01-01.
   @param Y     Year (e.g., 2024).
   @param M     Month (1-12).
   @param D     Day (1-31).
   @param HH    Hours (0-23).
   @param MM    Minutes (0-59).
   @param SS    Seconds (0-59).

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

%Some test queries
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
?-timestamp_dt(0,Year,Month,Day,Hour,Minute,Second).
%@    Year = 1970, Month = 1, Day = 1, Hour = 0, Minute = 0, Second = 0.

%?-date_calc_time_minus(1,1,1,1,2000,1,1,10,10,10,Year,Month,Day,Hour,Min,Sec).
%@    Year = 1999, Month = 12, Day = 31, Hour = 9, Min = 9, Sec = 9
%@ ;  false.

%?-date_calc_days_plus(2,1,1,1,Year,Month,Day).
%@    Y = 1, M = 1, D = 3
%@ ;  false.

%?-date_calc_days_minus(2,1,1,1,Year,Month,Day).
%@    Year = 0, Month = 12, Day = 30
%@ ;  false.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */




/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HELPFUL PREDICATES
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%Calculate time between dates
date_calc_time_between(Days,Hours,Minutes,Seconds,StartY,StartM,StartD,StartH,StartMin,StartS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs,StartY,StartM,StartD,StartH,StartMin,StartS),
    timestamp_dt(Secs_1,Y,M,D,H,Min,Sec),
    Hours in 0..23,
    Minutes in 0..59,
    Seconds in 0..59,
    Sec_Delta #= Days*86400 + Hours*3600 + Minutes*60 + Seconds,
    Sec_Delta #= Secs_1-Secs.

%Add time or remove time to a date (exact time)
date_calc_time_plus(Days,Hours,Minutes,Seconds,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs+86400*Days+3600*Hours+60*Minutes+Seconds,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

date_calc_time_minus(Days,Hours,Minutes,Seconds,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs-(86400*Days+3600*Hours+60*Minutes+Seconds),
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

%Standard calculations to add or remove time(days, hours, minutes, seconds) on a date with exact time
date_calc_days_plus(Days,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs+86400*Days,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

date_calc_days_minus(Days,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs-86400*Days,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

date_calc_hours_plus(Hours,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs+3600*Hours,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

date_calc_hours_minus(Hours,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs-3600*Hours,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

date_calc_minutes_plus(Minutes,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs+60*Minutes,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

date_calc_minutes_minus(Minutes,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs-60*Minutes,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

date_calc_seconds_plus(Seconds,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs+Seconds,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

date_calc_seconds_minus(Seconds,OY,OM,OD,OH,OMin,OS,Y,M,D,H,Min,Sec):-
    timestamp_dt(Secs, OY,OM,OD,OH,OMin,OS),
    Secs_1 #= Secs-Seconds,
    timestamp_dt(Secs_1, Y,M,D,H,Min,Sec).

%Standard calculations to add or remove time(days, hours, minutes, seconds) on a date without time
date_calc_days_plus(Days,OY,OM,OD,Y,M,D):-
    timestamp_dt(Secs, OY,OM,OD, 0,0,0),
    Secs_1 #= Secs+86400*Days,
    timestamp_dt(Secs_1, Y,M,D,_,_,_).

date_calc_days_minus(Days,OY,OM,OD,Y,M,D):-
    timestamp_dt(Secs, OY,OM,OD, 0,0,0),
    Secs_1 #= Secs-86400*Days,
    timestamp_dt(Secs_1, Y,M,D,_,_,_).

date_calc_hours_plus(Hours,OY,OM,OD,Y,M,D):-
    timestamp_dt(Secs, OY,OM,OD, 0,0,0),
    Secs_1 #= Secs+3600*Hours,
    timestamp_dt(Secs_1, Y,M,D,_,_,_).

date_calc_hours_minus(Hours,OY,OM,OD,Y,M,D):-
    timestamp_dt(Secs, OY,OM,OD, 0,0,0),
    Secs_1 #= Secs-3600*Hours,
    timestamp_dt(Secs_1, Y,M,D,_,_,_).

date_calc_minutes_plus(Minutes,OY,OM,OD,Y,M,D):-
    timestamp_dt(Secs, OY,OM,OD, 0,0,0),
    Secs_1 #= Secs+60*Minutes,
    timestamp_dt(Secs_1, Y,M,D,_,_,_).

date_calc_minutes_minus(Minutes,OY,OM,OD,Y,M,D):-
    timestamp_dt(Secs, OY,OM,OD, 0,0,0),
    Secs_1 #= Secs-60*Minutes,
    timestamp_dt(Secs_1, Y,M,D,_,_,_).

date_calc_seconds_plus(Seconds,OY,OM,OD,Y,M,D):-
    timestamp_dt(Secs, OY,OM,OD, 0,0,0),
    Secs_1 #= Secs+Seconds,
    timestamp_dt(Secs_1, Y,M,D,_,_,_).

date_calc_seconds_minus(Seconds,OY,OM,OD,Y,M,D):-
    timestamp_dt(Secs, OY,OM,OD, 0,0,0),
    Secs_1 #= Secs-Seconds,
    timestamp_dt(Secs_1, Y,M,D,_,_,_).

%Milliseconds into date (bidirectional)
timestamp_milliseconds_dt(MS, Y, M, D, HH, MM, SS, MSec) :-
    MS #= 1000*Secs + MSec,
    0  #=< MSec,
    MSec in 0..999,
    timestamp_dt(Secs, Y, M, D, HH, MM, SS).

%Milliseconds into a date (seconds have a . comma)
timestamp_milliseconds_dt_float(MS, Y, M, D, HH, MM, SSF) :-
    timestamp_milliseconds_dt(MS, Y, M, D, HH, MM, SS, MSec),
    SSF #= SS + MSec/1000.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
END SIMPLE PREDICATES
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


% Bidirectional: seconds <-> date (Y-M-D) and time (HH:MM:SS)
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
Hinnat algorithm to calculate Dates.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

ymd_from_days_det(Days, Y,M,D) :-
    % Reference: 0000-03-01
    Z #= Days + 719468,

    zcompare(CZ, Z, 0),
    e_from_z(CZ, Z, E),

    Era #= E div 146097,
    Doe #= Z - Era*146097,

    Yoe #= (Doe - Doe div 1460 + Doe div 36524 - Doe div 146096) div 365,
    Y0  #= Yoe + Era*400,

    DoY #= Doe - (365*Yoe + Yoe div 4 - Yoe div 100 + Yoe div 400),
    Mp  #= (5*DoY + 2) div 153,
    D0  #= DoY - (153*Mp + 2) div 5 + 1,
    M0  #= Mp + 3,
    zcompare(CM, Mp, 10),
    ym_from_mp(CM, Y0, M0, Mp, Y, M),

    D #= D0.
e_from_z(>, Z, E) :- E #= Z.
e_from_z(=, Z, E) :- E #= Z.
e_from_z(<, Z, E) :- E #= Z - 146096.

ym_from_mp(<, Y0, M0, _Mp, Y, M) :- Y #= Y0,     M #= M0.
ym_from_mp(=, Y0, _M0,  Mp, Y, M) :- Y #= Y0 + 1, M #= Mp - 9.
ym_from_mp(>, Y0, _M0,  Mp, Y, M) :- Y #= Y0 + 1, M #= Mp - 9.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Months and leap years
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
Helper predicates!
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

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Only for testing with python
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
print_query(Query) :-
    Query,
    write(Query), nl,
    false.
print_query(_).
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
only to support some calculations
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
modulo(A, B, R) :-
    R #= A - (A // B) * B.
