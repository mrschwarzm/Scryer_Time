## Time Calculation System (CLP(Z)-based)

A small Prolog library for date/time arithmetic built on CLP(Z) 
for Scryer Prolog, an ISO-standard Prolog implementation. It provides conversion 
between POSIX seconds (Unix) and calendar date-time components, calculation of time 
differences between dates and times, and convenient predicates for adding and subtracting times. Its core predicate __timestamp_dt/7__ is fully bidirectional, allowing values to be calculated in either direction.

Convenience predicates for adding/removing days, hours, minutes, seconds:

    Core predicate: timestamp_dt/7
    Derived utilities:
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
        


## Date and Time Subtraction

The following example subtracts one year, one month, one day, one hour, one minute, and one second from 2000-01-01 10:10:10.
```
?- date_calc_time_minus(
       1, 1, 1, 1,
       2000, 1, 1, 10, 10, 10,
       Year, Month, Day, Hour, Min, Sec
   ).
Year  = 1999,
Month = 12,
Day   = 31,
Hour  = 9,
Min   = 9,
Sec   = 9.
```
## Adding/Subtracting Days

Two days are added to 0001-01-01:
```
?- date_calc_days_plus(2, 1, 1, 1, Year, Month, Day).
Year  = 1,
Month = 1,
Day   = 3.
```
Two days are subtracted from 0001-01-01:
```
?- date_calc_days_minus(2, 1, 1, 1, Year, Month, Day).
Year  = 0,
Month = 12,
Day   = 30.
```
Timeline coverage: from 0000-01-01 00:00:00 up to 5000+ years ;)

For more info: Please take a look into time_date_clpz.pl

P.S.: The library has been tested with millions of test cases, and there should be no errors. It is very unlikely but, if you find an error (e.g., an incorrect calculation), __please open an issue immediately__!
