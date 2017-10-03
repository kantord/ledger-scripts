#!/usr/bin/gnuplot

reset

set datafile separator " "
set terminal wxt size 410,250 enhanced font 'Verdana,9' persist
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12

set style line 1 lc rgb '#8b1a0e' pt 1 ps 1 lt 1 lw 2 # --- red
set style line 2 lc rgb '#5e9c36' pt 6 ps 1 lt 1 lw 2 # --- green

set key bottom right

set xdata time
set timefmt "%Y-%m-%d"

set format y "%.0f EUR"
set ytics 100

set output "./graphs/income_expense_comparison.png"

plot './reports/income_expense_comparison.txt' u 1:2 t 'Incomes' w lp ls 1, \
     ''                  u 1:3 t 'Expenses' w lp ls 2
