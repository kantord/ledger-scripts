all: reports/ graphs/

reports/: reports/daily_totals.txt reports/daily_change.txt \
	 reports/monthly_totals.txt reports/monthly_change.txt \
	 reports/daily_totals_moving.txt reports/daily_change_moving.txt \
	 reports/daily_spending.txt reports/expenses.txt reports/savings.txt \
	 reports/pie.txt reports/bar.txt reports/food.txt reports/drinks.txt \
	 reports/_payees.txt reports/payees.txt

graphs/: graphs/daily_totals.png graphs/daily_totals_moving.png \
	graphs/daily_change_moving.png graphs/daily_spending.png \
	graphs/daily_spending_moving.png \
	graphs/daily_totals_comparison.png graphs/daily_change_comparison.png \
	graphs/daily_totals_comparison_90.png \
	graphs/bkv.png graphs/food_vs_drinks.png graphs/expenses.png  graphs/pie.png \
	graphs/bar.png graphs/food.png graphs/drinks.png graphs/payees.png \
	graphs/daily_savings_comparison.png graphs/stacked.png

reports/daily_totals.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Assets -n -J --sort d -X Ft | python ./fill_date_gaps.py > $@

reports/daily_savings.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Savings -n -J --sort d  -X Ft | python ./fill_date_gaps.py> $@

reports/daily_change.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Assets -n -j --sort d -X Ft > $@

reports/daily_spending.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Expenses -n -j --sort d -X Ft > $@
reports/monthly_totals.txt: ./ledge.txt
	ledger -f ledge.txt reg -M Assets -n -J --sort d  -X Ft> $@

reports/monthly_change.txt: ./ledge.txt
	ledger -f ledge.txt reg -M Assets -n -j --sort d  -X Ft> $@

reports/bkv.txt: ./ledge.txt
	ledger -f ledge.txt reg -M "Transport:BKV" -n -j --sort d  -X Ft> $@


reports/daily_totals_moving.txt: ./reports/daily_totals.txt ./movingsum
	bash -c "paste -d' ' <(tac '$<' | cut -f1 -d' ') <(tac '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/daily_savings_moving.txt: ./reports/daily_savings.txt ./movingsum
	bash -c "paste -d' ' <(tac '$<' | cut -f1 -d' ') <(tac '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/daily_totals_moving_90.txt: ./reports/daily_totals.txt ./movingsum
	bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum 90)" > $@

reports/daily_change_moving.txt: ./reports/daily_change.txt ./movingsum
	bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/daily_spending_moving.txt: ./reports/daily_spending.txt ./movingsum
	bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

graphs/daily_totals.png: reports/daily_totals.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_totals_moving.png: reports/daily_totals_moving.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_totals_moving.png: reports/daily_totals_moving.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_change_moving.png: reports/daily_change_moving.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_spending.png: reports/daily_spending.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_spending_moving.png: reports/daily_spending_moving.txt ./plot.sh
	./plot.sh "$<" "$@"


graphs/bkv.png: reports/bkv.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_totals_comparison.png: reports/daily_totals_moving.txt reports/daily_totals.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

graphs/daily_savings_comparison.png: reports/daily_savings_moving.txt reports/daily_savings.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

graphs/daily_totals_comparison_90.png: reports/daily_totals_moving_90.txt reports/daily_totals.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

graphs/daily_change_comparison.png: reports/daily_change_moving.txt reports/daily_change.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

./movingsum: ./movingsum.hs
	ghc $< -o $@

./aggrhead: ./aggrhead.hs
	ghc $< -o $@

reports/expenses.txt: ./ledge.txt
	ledger -f $< bal "Expenses" --depth 2 -B --no-total -X Ft| tail -n +2 | sed "s/^ *//" | sed "s/ Ft  /,/" | sed "s/Expenses\://" | sed "s/Expenses\://" | sed "s/, \+/,/" > $@ 

reports/food.txt: ./ledge.txt
	ledger -f $< bal "Expenses:Food" --depth 3 -B --no-total -X Ft| tail -n +2 | sed "s/^ *//" | sed "s/ Ft  /,/" | sed "s/Expenses\://" | sed "s/Expenses\://" | sed "s/, \+/,/" | sort --key 1 -t',' --numeric -r | sed "s/,/ /" | tail -n +2 | ./aggrhead 50 > $@ 

reports/drinks.txt: ./ledge.txt
	ledger -f $< bal "Expenses:Drinks" --depth 3 -B --no-total -X Ft| tail -n +2 | sed "s/^ *//" | sed "s/ Ft  /,/" | sed "s/Expenses\://" | sed "s/Expenses\://" | sed "s/, \+/,/" > $@ 

reports/savings.txt: ./ledge.txt
	ledger -f $< bal "Assets:Savings" -n -B -X Ft| sed "s/^ *//" | sed "s/ Ft  /,/" | sed "s/Expenses\://" | sed "s/Expenses\://" | sed "s/, \+/,/" | sed "s/Assets/Savings/" > $@ 

reports/pie.txt: reports/savings.txt reports/expenses.txt
	cat $^ > $@

reports/_payees.txt: ./ledge.txt ./aggrhead
	ledger -f ledge.txt bal  -n --group-by payee Assets -X Ft | grep -v -e "^$$" > $@

reports/payees.txt: reports/_payees.txt
	bash -c "paste -d' ' <(cat $< |  sed -n 'n;p' | sed \"s/^ *//;s/ *Assets//;s/-//;s/ Ft//\") <(cat $<| sed -n 'p;n') |  sort -k1 -t' ' --numeric --reverse | ./aggrhead 25" > $@

graphs/expenses.png: reports/expenses.txt pie.py
	python pie.py $< $@

graphs/pie.png: reports/pie.txt pie.py
	python pie.py $< $@

graphs/drinks.png: reports/drinks.txt pie.py
	python pie.py $< $@

reports/bar.txt: reports/pie.txt ./aggrhead
	cat $< | sort --key 1 -t',' --numeric -r | sed "s/,/ /" | ./aggrhead 25 > $@

graphs/bar.png: reports/bar.txt ./bar.sh
	./bar.sh "$<" "$@"

graphs/food.png: reports/food.txt ./bar.sh
	./bar.sh "$<" "$@"

graphs/payees.png: reports/payees.txt ./bar.sh
	./bar.sh "$<" "$@"


graphs/stacked.png: ledge.txt stacked.py
	ledger -f $< reg -M Expenses Taxes Income --sort d -X Ft  --no-rounding -F '%D,,,%A,,,%t\n' | sed "s/ Ft$$//" | python stacked.py $@
