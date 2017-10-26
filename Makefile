all: reports/ graphs/ price.db
reports/: reports/daily_totals.txt
graphs/: graphs/daily_totals_comparison.png graphs/daily_savings_comparison.png graphs/stacked.png graphs/income_expense_comparison.png

reports/daily_totals.txt: ./ledge.txt price.db
	ledger -f ledge.txt reg -D Assets -n -J --sort d -X Ft | python ./fill_date_gaps.py > $@

reports/daily_savings.txt: ./ledge.txt price.db
	ledger -f ledge.txt reg -D Savings -n -J --sort d  -X Ft | python ./fill_date_gaps.py> $@

reports/daily_totals_moving.txt: ./reports/daily_totals.txt ./movingsum price.db
	bash -c "paste -d' ' <(tac '$<' | cut -f1 -d' ') <(tac '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/daily_savings_moving.txt: ./reports/daily_savings.txt ./movingsum price.db
	bash -c "paste -d' ' <(tac '$<' | cut -f1 -d' ') <(tac '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/income_expense_comparison.txt: ./ledge.txt price.db
	bash -c "join <(ledger -f $< reg Income -n -M -X EUR --no-rounding -j | sed 's/ -/ /') <(ledger -f $< reg Expenses Taxes -n -M -X EUR --no-rounding -j )" > $@


graphs/daily_totals_comparison.png: reports/daily_totals_moving.txt reports/daily_totals.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

graphs/daily_savings_comparison.png: reports/daily_savings_moving.txt reports/daily_savings.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

./movingsum: ./movingsum.hs
	ghc $< -o $@

./aggrhead: ./aggrhead.hs
	ghc $< -o $@

graphs/stacked.png: ledge.txt stacked.py price.db
	ledger -f $< reg -M Expenses Taxes Income --sort d -X Ft  --no-rounding -F '%D,,,%A,,,%t\n' | sed "s/ Ft$$//" | python stacked.py $@

graphs/income_expense_comparison.png: reports/income_expense_comparison.txt lines.gnuplot
	gnuplot -e "input_file='$<'" \
			-e "line1_name='Incomes'" \
			-e "line2_name='Expenses and taxes'" \
			-e "output_file='$@'" \
	lines.gnuplot

graphs/food_vs_drinks.png: reports/food_vs_drinks.txt lines.gnuplot
	gnuplot -e "input_file='$<'" \
			-e "line1_name='Food'" \
			-e "line2_name='Drinks'" \
			-e "output_file='$@'" \
	lines.gnuplot

days.txt: ledge.txt
	ledger -f $< reg -j | cut -f1 -d' ' | sort | uniq > $@

pricedb/%:
	curl http://api.fixer.io/$*\?base\=EUR | jq '.base as $$base | .date as $$date | .rates | to_entries | map(["P", $$date, .key, ((1 / .value) | tostring), $$base] | join (" ")) | .[]' -r | sed 's USD $$ ; s HUF Ft ; s - / g' > $@

price.db: days.txt
	for day in $$(cat days.txt); do make pricedb/$$day; done
	cat pricedb/* | sed 's/\(P [0-9/]\+\)/\1 00:00:00/' > $@
