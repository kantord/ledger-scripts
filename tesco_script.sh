#!/usr/bin/bash

xclip -selection c -o > /tmp/__selection.txt
date +"%Y/%m/%d Tesco"
cat /tmp/__selection.txt | cut -f'1,3' -d"	" | sed 's/  Ft$/ Ft/;s/^/    Expenses:Food:/;s/ \([0-9]\+\) Ft$/\1 Ft/' | python dedup.py dedup_rules.csv
