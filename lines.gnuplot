#!/usr/bin/gnuplot

reset

set datafile separator " "
set terminal pngcairo size 910,250 enhanced font 'Verdana,9'
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12


set key top right

set xdata time
set timefmt "%Y-%m-%d"

set format y "%.0f EUR"
set ytics 100

set style line 1 lc rgb '#8b1a0e' lt 1 lw 2 pt 7 pi -1 ps 1
set style line 2 lc rgb '#5e9c36' lt 1 lw 2 pt 7 pi -1 ps 1
set pointintervalbox 2.5

set output output_file

set offset graph 0.05, graph 0.05, graph 0.05, graph 0.05

plot input_file u 1:2 t line1_name w lp ls 1, \
     ''                  u 1:3 t line2_name w lp ls 2
