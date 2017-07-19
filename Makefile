VPATH = src
P = out
PGDIR = build/postgres
export PGDATA = out/data/postgres
export PGPORT = 40576
DATADIR = optadata
PY = python3
GTIME := /usr/bin/time

# Where the tarballs are
NEOTARDIR = neo4j/packaging/standalone/target
# Some arbitrary file that changes when neo is built
NEOTARGET = $P/lib/neo4j-common-*.jar

.PHONY: all clean distclean neo4j-version postgres \
	neo4j benchmark pgpopulate neopopulate pgstart pgstop \
	clearcache charts neostart neostop

all: pgpopulate neopopulate $P/bin/cypher-shell

$P $(PGDIR):
	mkdir -p $@

$(PGDIR)/GNUMakefile: postgresql/configure | $(PGDIR)
	cd $| && $(CURDIR)/$< --prefix=$(CURDIR)/$P

postgres: $(PGDIR)/GNUMakefile | $P
	$(MAKE) -C $(<D) install

$P/bin/cypher-shell:
	$(MAKE) -C $(@F) build
	cp $(@F)/$(@F)/build/install/$(@F)/$(@F)* $P/bin/

# Use git HEAD to determine if we should build Neo4j
.neo4j-version: neo4j-version
neo4j-version:
	if [ ! -f .$@ ]; then touch .$@; fi
	if [ `cd neo4j; git rev-parse HEAD` != "`cat .$@`" ]; then \
		cd neo4j && git rev-parse HEAD > ../.$@; \
	fi

$(NEOTARGET): .neo4j-version | $P
	cd neo4j && mvn clean install -U -DskipTests -Dlicense.skip=true
	tar xf $(NEOTARDIR)/neo4j-community-*-unix.tar.gz --strip 1 -C $|

neo4j: $(NEOTARGET)

$(DATADIR):
	rsync -rP toppfotball@ssh.domeneshop.no:www/Opta/ $@

$P/specs.tex: getspecs.py
	./$< > $@

pgstart:
	$P/bin/pg_ctl start
pgstop:
	$P/bin/pg_ctl stop
neostart:
	$P/bin/neo4j start
neostop:
	$P/bin/neo4j stop

EVENTS := cpu-clock,context-switches,cpu-migrations,page-faults,cycles,instructions,branches,branch-misses,syscalls:sys_enter_read,syscalls:sys_enter_write,syscalls:sys_enter_fsync,block:block_rq_complete

$P/pgstat_base.%: src/postgres/queries/base/query%.sql 
	$P/bin/psql opta -c "ALTER DATABASE opta SET search_path TO base;"
	sudo -E perf stat -e $(EVENTS) -x';' -a -d -r 5 -- \
	sh -c "sudo -E -u $(USER) $P/bin/psql opta -f $<" 2> $@
$P/pgstat_jsonb.%: src/postgres/queries/jsonb/query%.sql
	$P/bin/psql opta -c "ALTER DATABASE opta SET search_path TO jsonb;"
	sudo -E perf stat -e $(EVENTS) -x';' -a -d -r 5 -- \
	sh -c "sudo -E -u $(USER) $P/bin/psql opta -f $<" 2> $@
$P/neostat_base.%: src/neo4j/queries/base/query%.cql
	# TODO: change database
	sudo -E perf stat -e $(EVENTS) -x';' -a -d -r 5 -- \
	sh -c "sudo -E -u $(USER) cat $< | out/bin/cypher-shell" 2> $@
$P/pgstat_base.%.tex: $P/pgstat_base.%
	cat $< | ./csv2table.py > $@
$P/pgstat_jsonb.%.tex: $P/pgstat_jsonb.%
	cat $< | ./csv2table.py > $@
$P/neostat_base.%.tex: $P/neostat_base.%
	cat $< | ./csv2table.py > $@

charts: $(addprefix $P/,pgstat_1_cycles.pdf pgstat_2_cycles.pdf pgstat_3_cycles.pdf pgstat_1_syscalls.pdf pgstat_2_syscalls.pdf pgstat_3_syscalls.pdf compstat_1_cycles.pdf compstat_2_cycles.pdf  compstat_3_cycles.pdf compstat_1_syscalls.pdf compstat_2_syscalls.pdf compstat_3_syscalls.pdf)

$P/pgstat_%_cycles.pdf: $P/pgstat_base.% $P/pgstat_jsonb.%
	./generate_plots.py -o $@ -m cycles,instructions,branches -l Base,JSONB $^
$P/pgstat_%_syscalls.pdf: $P/pgstat_base.% $P/pgstat_jsonb.%
	./generate_plots.py -o $@ -l Base,JSONB \
	-m 'syscalls:sys_enter_read,syscalls:sys_enter_write,page-faults' $^
$P/compstat_%_cycles.pdf: $P/pgstat_jsonb.% $P/neostat_base.%
	./generate_plots.py -o $@ -m cycles,instructions,branches \
	-l 'PostgreSQL with JSONB',Neo4j $^
$P/compstat_%_syscalls.pdf: $P/pgstat_jsonb.% $P/neostat_base.%
	./generate_plots.py -o $@ -l 'PostgreSQL with JSONB',Neo4j \
	-m 'syscalls:sys_enter_read,syscalls:sys_enter_write,page-faults' $^

pgpopulate: | optadata postgres
	$P/bin/initdb
	$P/bin/pg_ctl start
	sleep 3
	$P/bin/createdb opta
	$(PY) src/postgres/pgload.py # Populate Postgres
	$P/bin/pg_ctl stop

tmp/csvgraph: | optadata
	$(PY) src/neo4j/schemas/base/read_files.py $(DATADIR)
neopopulate: tmp/csvgraph $(NEOTARGET)
	NEO4J_DIR=$P src/neo4j/import_csv.sh	# Populate Neo4j

benchmark: $(addprefix $P/,pgstat_base.1.tex pgstat_base.2.tex pgstat_base.3.tex pgstat_jsonb.1.tex pgstat_jsonb.2.tex pgstat_jsonb.3.tex neostat_base.1.tex neostat_base.2.tex neostat_base.3.tex) $P/specs.tex

clearcache:
	-find src -name "__pycache__" | xargs $(RM) -r

clean: clearcache
	$(RM) -r build
	cd neo4j && mvn clean

distclean: clean
	$(RM) -r $P
	$(RM) .neo4j-version
	$(RM) -r $(DATADIR)
