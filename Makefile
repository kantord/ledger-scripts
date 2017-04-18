all: reports/ graphs/

reports/: reports/daily_totals.txt reports/daily_change.txt \
	 reports/weekly_totals.txt reports/weekly_change.txt \
	 reports/monthly_totals.txt reports/monthly_change.txt \
	 reports/daily_totals_moving.txt reports/daily_change_moving.txt \
	 reports/daily_spending.txt

graphs/: graphs/daily_totals.png graphs/daily_totals_moving.png \
	graphs/daily_change_moving.png graphs/daily_spending.png \
	graphs/daily_spending_moving.png graphs/weekly_change_moving.png \
	graphs/daily_totals_comparison.png graphs/daily_change_comparison.png \
	graphs/bkv.png graphs/food_vs_drinks.png

reports/daily_totals.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Assets -n -J --sort d > $@

reports/daily_change.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Assets -n -j --sort d > $@

reports/daily_spending.txt: ./ledge.txt
	ledger -f ledge.txt reg -D Expenses -n -j --sort d -X Ft > $@

reports/weekly_totals.txt: ./ledge.txt
	ledger -f ledge.txt reg -W Assets -n -J --sort d > $@

reports/weekly_change.txt: ./ledge.txt
	ledger -f ledge.txt reg -W Assets -n -j --sort d > $@

reports/monthly_totals.txt: ./ledge.txt
	ledger -f ledge.txt reg -M Assets -n -J --sort d > $@

reports/monthly_change.txt: ./ledge.txt
	ledger -f ledge.txt reg -M Assets -n -j --sort d > $@

reports/bkv.txt: ./ledge.txt
	ledger -f ledge.txt reg -M "Transport:BKV" -n -j --sort d > $@

reports/food.txt: ./ledge.txt
	ledger -f ledge.txt reg -D "Expenses:Food" -n -j --sort d > $@

reports/drinks.txt: ./ledge.txt
	ledger -f ledge.txt reg -D "Expenses:Drinks" -n -j --sort d > $@

reports/daily_totals_moving.txt: ./reports/daily_totals.txt ./movingsum
	bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/daily_change_moving.txt: ./reports/daily_change.txt ./movingsum
	bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/daily_spending_moving.txt: ./reports/daily_spending.txt ./movingsum
	bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/food_moving.txt: ./reports/food.txt ./movingsum
	bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

reports/drinks_moving.txt: ./reports/drinks.txt ./movingsum
	bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum 30)" > $@

#reports/weekly_change_moving.txt: ./reports/weekly_change.txt ./movingsum7
	#bash -c "paste -d' ' <(cat '$<' | cut -f1 -d' ') <(cat '$<' | cut -f2 -d' ' | ./movingsum7)" > $@

graphs/daily_totals.png: reports/daily_totals.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_totals_moving.png: reports/daily_totals_moving.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_change_moving.png: reports/daily_change_moving.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_spending.png: reports/daily_spending.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_spending_moving.png: reports/daily_spending_moving.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/weekly_change_moving.png: reports/weekly_change_moving.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/bkv.png: reports/bkv.txt ./plot.sh
	./plot.sh "$<" "$@"

graphs/daily_totals_comparison.png: reports/daily_totals_moving.txt reports/daily_totals.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

graphs/daily_change_comparison.png: reports/daily_change_moving.txt reports/daily_change.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

graphs/food_vs_drinks.png: reports/food_moving.txt reports/drinks.txt ./plot2.sh
	./plot2.sh "$<" "$(word 2,$^)" "$@"

./movingsum: ./movingsum.hs
	ghc $< -o $@

#./movingsum7: ./movingsum7.hs
	#ghc $< -o $@
