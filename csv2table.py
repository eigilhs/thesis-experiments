#!/usr/bin/env python3
import csv
import sys


data = csv.reader(sys.stdin, delimiter=';')
h = {row[2]: f"{eval(row[0]):,.0f} & {row[3].strip('%')}\% & {row[5]} & {row[6]} {row[7]}" for row in data}
h['branch-misses'] = h['branch-misses'].replace(' of all', '\% of all')

print(r"""\begin{tabular}{|l|r|r|r|l|}
\hline
\textbf{Event Name}   & \textbf{Counter Value} & \textbf{Variance} & \textbf{\% of Time Measured} & \textbf{Note} \\
\hline""")

for name in ('cpu-clock', 'cycles', 'instructions', 'branches',
             'branch-misses', 'syscalls:sys_enter_read',
             'syscalls:sys_enter_write', 'syscalls:sys_enter_fsync',
             'block:block_rq_complete', 'context-switches',
             'cpu-migrations', 'page-faults'):
    print(r'\texttt{'+name.replace('_', r'\_')+'}', '&', h[name], r'\\')

print("""\hline
\end{tabular}""")
