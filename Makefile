all: reports/ graphs/
reports/: reports/daily_totals.txt
graphs/: graphs/daily_totals_comparison.png graphs/daily_savings_comparison.png graphs/stacked.png

reports/daily_totals.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Assets -n -J --sort d -X Ft | python ./fill_date_gaps.py > $@

reports/daily_savings.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Savings -n -J --sort d  -X Ft | python ./fill_date_gaps.py> $@

reports/expenses_hierarchy.txt: ./ledge.txt

reports/daily_totals_moving.txt: ./reports/daily_totals.txt ./movingsum
	bash -c "paste -d' ' <(tac '$<' | cut -f1 -d' ') <(tac '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/daily_savings_moving.txt: ./reports/daily_savings.txt ./movingsum
	bash -c "paste -d' ' <(tac '$<' | cut -f1 -d' ') <(tac '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

graphs/daily_totals_comparison.png: reports/daily_totals_moving.txt reports/daily_totals.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

graphs/daily_savings_comparison.png: reports/daily_savings_moving.txt reports/daily_savings.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

./movingsum: ./movingsum.hs
	ghc $< -o $@

./aggrhead: ./aggrhead.hs
	ghc $< -o $@

graphs/stacked.png: ledge.txt stacked.py
	ledger -f $< reg -M Expenses Taxes Income --sort d -X Ft  --no-rounding -F '%D,,,%A,,,%t\n' | sed "s/ Ft$$//" | python stacked.py $@
