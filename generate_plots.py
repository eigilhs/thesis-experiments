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

metrics = args.metric.split(',')
labels = args.label.split(',')
outfilename = args.output
colors = 'r', 'y', 'g', 'b', 'c', 'm'
hatches = ' ', '//', '..', '++', '\\\\', 'xx', '/', '\\', 'x', '+'

data = []
for fname in args.input:
    means, errs = [], []
    with open(fname) as file:
        h = {row[2]: (eval(row[0]), 0.01 * float(row[3].strip('%')))
             for row in csv.reader(file, delimiter=';')}
    for metric in metrics:
        means.append(h[metric][0])
        errs.append(h[metric][1] * means[-1])
    data.append((means, errs))


ind = np.arange(len(metrics))
width = 0.35

fig, ax = plt.subplots()

if color:
    leg = [ax.bar(ind + width*i, means, width, color=color, yerr=errs)[0]
           for i, ((means, errs), color) in enumerate(zip(data, colors))]
else:
    leg = [ax.bar(ind + width*i, means, width, color='w', edgecolor='k',
                  hatch=hatch, yerr=errs)[0]
           for i, ((means, errs), hatch) in enumerate(zip(data, hatches))]

ax.set_xticks(ind + width / 2)
ax.set_xticklabels(metrics)
ax.legend(leg, labels)

plt.savefig(outfilename, bbox_inches='tight')
