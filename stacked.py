import numpy as np
import pandas as pd
import pylab as plt
import matplotlib
import collections
import sys
import csv


matplotlib.style.use('ggplot')


def get_group(name):
    return name.split(":")[1]

sums_per_month = collections.defaultdict(lambda: collections.defaultdict(float))
sums_per_group = collections.defaultdict(float)
labels = set()
index = []
last_month = None
for row in sys.stdin:
    row = row.split(",,,")
    group_ = get_group(row[1])
    labels.add(group_)
    last_month = row[0]
    sums_per_month[row[0]][group_] += float(row[2])
    sums_per_group[group_] += float(row[2])

labels = sorted(labels, key=lambda l: -sum(sums_per_month[x][l] for x in sums_per_month.keys()))
labels = tuple(labels[:5]) + ("Other", )

simplified_sums_per_month = collections.defaultdict(
    lambda: collections.defaultdict(float))

for month, sums in sums_per_month.items():
    if month == last_month:
        continue
    index += ["'" + month[2:7]]
    for label, value in sums.items():
        label = label if label in labels else "Other"
        simplified_sums_per_month[month][label] += value


simplified_sums_per_group = collections.defaultdict(list)
for month, sums in simplified_sums_per_month.items():
    for group_, value in sums.items():
        simplified_sums_per_group[group_].append(value)


stds = {
    group_:np.std(values)/sum(values) for group_, values in simplified_sums_per_group.items()
}


labels = sorted(labels, key=lambda l: stds[l])


df = pd.DataFrame([
    [sums[label] for label in labels]
    for month, sums in simplified_sums_per_month.items()
], columns=labels, index=index)



tableau20 = [(31, 119, 180), (174, 199, 232), 
        (255, 127, 14), (255, 187, 120), (44, 160, 44), 
        (152, 223, 138), (214, 39, 40), (255, 152, 150), 
        (148, 103, 189), (197, 176, 213), (140, 86, 75), 
        (196, 156, 148), (227, 119, 194), (247, 182, 210), 
        (127, 127, 127), (199, 199, 199), (188, 189, 34), 
        (219, 219, 141), (23, 190, 207), (158, 218, 229)]

for i in range(len(tableau20)): 
    r, g, b = tableau20[i] 
    tableau20[i] = (r / 255., g / 255., b / 255.)




ax = df.plot(kind='area', color = tableau20, alpha=.7, title="Title Goes Here");


ax.set_xlabel("x axis units")
ax.set_ylabel("y axis units")

plt.savefig(sys.argv[1])
