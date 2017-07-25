#!/usr/bin/env python3
import csv
import sys


data = csv.reader(sys.stdin, delimiter=';')
h = {row[2]: f"{eval(row[0]):,.0f} & {row[3].strip('%')}\% & {row[5]}\% & {row[6]} {row[7]}".replace(' of all', '\% of all') for row in data}

print(r"""\begin{tabular}{|l|c|c|c|c|}
\hline
\textbf{Event Name}   & \textbf{Counter Value} & \textbf{RSD} & \textbf{Measured} & \textbf{Note} \\
\hline""")

for name in h:
    print(r'\texttt{'+name.replace('_', r'\_')+'}', '&', h[name], r'\\')

print("""\hline
\end{tabular}""")
