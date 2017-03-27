#!/usr/bin/env python3

import platform


with open('/proc/cpuinfo') as file:
    s = file.readlines()

s = [line for line in s if line.strip()]
cpuinfo = {k.strip(): v.strip() for k, v in map(lambda line: line.split(':'), s)}
cpuinfo['flags'] = {*cpuinfo['flags'].split()}

with open('/proc/meminfo') as file:
    ram = round(int(file.readline().split()[1]) / 1024**2)

def latex_variable(name, value):
    print(r'\newcommand{\%s}{%s}' % (name, value))

latex_variable('plfram', ram)
latex_variable('plfcpuname', cpuinfo['model name'].replace('@', 'running at'))
latex_variable('plfcpucores', cpuinfo['cpu cores'])
latex_variable('plfcputhreads', cpuinfo['siblings'])
latex_variable('plfsystem', platform.system())
latex_variable('plfdist', platform.dist()[0].title())
latex_variable('plfdistversion', platform.dist()[1])
latex_variable('plfkernelversion', platform.release())
latex_variable('plfarchitecture', platform.architecture()[0].replace('bit', '-bit'))
latex_variable('plfmachine', platform.machine().replace('_', r'\_'))
