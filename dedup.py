import csv
import sys
import re

with open(sys.argv[1]) as rules_file:
    rules_reader = csv.reader(rules_file)
    rules = sorted(rules_reader, key=lambda row: -len(row[0]))

for row in sys.stdin:
    if row.startswith("    Expenses:"):
        for original, new in rules:
            if original in row and new not in row:
                row = row.replace(original, new + "\t")
                break
        print(row.replace("\n", ""))
    else:
        print(row.replace("\n", ""))
