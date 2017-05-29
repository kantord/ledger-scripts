import matplotlib.pyplot as plt
import csv
import sys

with open(sys.argv[1]) as inp:
    csvf = list(csv.reader(inp))

max_n = 10
csvf = sorted(csvf, key=lambda r: -float(r[0]))
csvf = tuple(csvf)[:(max_n - 1)] + ((sum(float(r[0]) for r in tuple(csvf)[(max_n - 1):]), "Other"), )
labels=[row[1] for row in csvf]
values=[float(row[0]) for row in csvf]

plt.figure(figsize=(11, 7))
patches, texts, _ = plt.pie(values, labels=None, startangle=90, autopct='%1.1f%%', labeldistance=1.05, pctdistance=1.1)
plt.axis('equal')
plt.legend(patches, labels, loc="best")
# plt.tight_layout()

plt.savefig(sys.argv[2])
