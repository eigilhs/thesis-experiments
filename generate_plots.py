#!/usr/bin/env python3
import csv
import argparse

import numpy as np
import matplotlib.pyplot as plt


color = False
parser = argparse.ArgumentParser()
parser.add_argument('-m', '--metric', required=True,
                    help='Comma separated list of metrics')
parser.add_argument('-o', '--output', required=True,
                    help='Output image file')
parser.add_argument('input', metavar='FILE', nargs='+',
                    help='Input files')
parser.add_argument('-l', '--label', required=True,
                    help='Comma separated list of x-axis labels')
args = parser.parse_args()

metric = args.metric
labels = args.label.split(',')
outfilename = args.output
colors = 'r', 'y', 'g', 'b', 'c', 'm'
hatches = ' ', '//', '..', '++', '\\\\', 'xx', '/', '\\', 'x', '+'

data = []
for fname in args.input:
    with open(fname) as file:
        h = {row[2]: (eval(row[0]), 0.01 * float(row[3].strip('%')), row[-2])
             for row in csv.reader(file, delimiter=';')}
    if metric == 'elapsed':
        mean = h['task-clock'][0] / float(h['task-clock'][2])
        errrate = h['task-clock'][1]
        err = errrate * mean
    else:
        mean = h[metric][0]
        err = h[metric][1] * mean
        errrate = h[metric][1]
    data.append((mean, err, errrate))

ind = 1
width = 0.35

fig, ax = plt.subplots(figsize=(3, 3))
leg = []
rects = []

if color:
    for i, ((means, errs, _), color) in enumerate(zip(data, colors)):
        r = ax.bar(ind + width*i, means, width, color=color, yerr=errs)
        rects.append(r)
        leg.append(r[0])
else:
    for i, ((means, errs, _), hatch) in enumerate(zip(data, hatches)):
        r = ax.bar(ind + width*i, means, width, color='w', edgecolor='k',
                   hatch=hatch, yerr=errs)
        rects.append(r)
        leg.append(r[0])

# ax.set_xticks(ind + width / 2)
# ax.set_xticklabels(metrics)
ax.set_xticks([])
ax.set_xticklabels([])
# ax.legend(leg, labels)
ax.yaxis.get_major_formatter().set_powerlimits((0, 3))
# ax.set_yticks([])
# ax.set_ylim(0, max(m+e for ms, es, _ in data for m, e in zip(ms, es))*1.2)

# for r, d in zip(rects, data):
#     for rect, err in zip(r, d[2]):
#         height = rect.get_height()
#         ax.text(rect.get_x() + rect.get_width()/2., 1.05 * height * (1 + err),
#                 '%g' % int(height),
#                 ha='center', va='bottom')

plt.savefig(outfilename, bbox_inches='tight')
