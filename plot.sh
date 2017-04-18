#!/usr/bin/env bash

gnuplot <<- EOF
    set datafile sep ' '
    set xdata time
    set timefmt "%Y-%m-%d"
    set output "$2"
    set term png
    plot "$1" using 1:2 with lines
EOF
