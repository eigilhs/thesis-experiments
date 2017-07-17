#!/usr/bin/env python3

import re
import platform
import subprocess as sp


with open('/proc/cpuinfo') as file:
    s = file.readlines()

s = [line for line in s if line.strip()]
cpuinfo = {k.strip(): v.strip() for k, v in map(lambda line: line.split(':'), s)}
cpuinfo['flags'] = {*cpuinfo['flags'].split()}

with open('/proc/meminfo') as file:
    ram = round(int(file.readline().split()[1]) / 1024**2)

def latex_variable(name, value):
    print(r'\newcommand{\%s}{%s}' % (name, value))

with open('out/include/pg_config.h') as file:
    s = file.read()
m = re.search(r'PG_VERSION_STR "PostgreSQL ([^\s]+)[^)]+\) ([^\s]+)', s)
pg_version, pg_gcc_version = m.groups()

openjdk_version = re.search(r'"([^"]+)',sp.getoutput('java -version')) \
                    .group(1).replace('_', '.')
perf_version = re.search(r'(\d+[^\s]+)', sp.getoutput('perf -v')).group(1)
neo4j_version = re.search(r' (\d+[^\s]+)', sp.getoutput('out/bin/neo4j version')).group(1)

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
latex_variable('pgversion', pg_version)
latex_variable('pggccversion', pg_gcc_version)
latex_variable('openjdkversion', openjdk_version)
latex_variable('perfversion', perf_version)
latex_variable('neojversion', neo4j_version)
