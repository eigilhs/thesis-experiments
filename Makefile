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

all: pgpopulate $P/bin/cypher-shell neopopulate

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
	sed -i '/auth_enabled/s/^#//' $P/conf/neo4j.conf

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

EVENTS := cycles,instructions,cpu-clock,context-switches,cpu-migrations,branches,branch-misses,page-faults,cache-misses,bus-cycles,mem-loads,mem-stores,cache-references

test:
	bash -c "cat csv2table.py{,}"

.SECONDARY: out/pgstat_base.1 out/pgstat_base.2 out/pgstat_base.3 out/pgstat_jsonb.1 out/pgstat_jsonb.2 out/pgstat_jsonb.3 out/neostat_base.1 out/neostat_base.2 out/neostat_base.3

$P/pgstat_base.%: src/postgres/queries/base/query%.sql 
	$P/bin/psql opta -c "ALTER DATABASE opta SET search_path TO base;"
	sudo -E perf stat -p `head -1 out/data/postgres/postmaster.pid` \
	-e $(EVENTS) -x';' -d -r 5 -- \
	sh -c "sudo -E -u $(USER) $P/bin/psql opta -f $<" 2> $@
$P/pgstat_jsonb.%: src/postgres/queries/jsonb/query%.sql
	$P/bin/psql opta -c "ALTER DATABASE opta SET search_path TO jsonb;"
	sudo -E perf stat -p `head -1 out/data/postgres/postmaster.pid` \
	-e $(EVENTS) -x';' -d -r 5 -- \
	sh -c "sudo -E -u $(USER) $P/bin/psql opta -f $<" 2> $@
$P/neostat_base.%: src/neo4j/queries/base/query%.cql
	sed -Ei 's/active_database=\w+.db/active_database=base.db/' $P/conf/neo4j.conf
	$P/bin/neo4j restart && sleep 10
	@echo Warm-up ...
	sudo -E -u $(USER) cat $< | $P/bin/cypher-shell
	sleep 10
	sudo -E perf stat -p `cat out/run/neo4j.pid` -e $(EVENTS) -x';' -d -r 5 -- \
	sh -c "sudo -E -u $(USER) cat $< | $P/bin/cypher-shell" 2> $@
$P/pgstat_base.%.tex: $P/pgstat_base.% csv2table.py
	cat $< | ./csv2table.py > $@
$P/pgstat_jsonb.%.tex: $P/pgstat_jsonb.% csv2table.py
	cat $< | ./csv2table.py > $@
$P/neostat_base.%.tex: $P/neostat_base.% csv2table.py
	cat $< | ./csv2table.py > $@

charts: $(addprefix $P/,pgstat_1_cycles.pdf pgstat_2_cycles.pdf pgstat_3_cycles.pdf compstat_1_cycles.pdf compstat_2_cycles.pdf compstat_3_cycles.pdf)

COMMA := ,
SPACE :=
SPACE +=

$P/pgstat_%_cycles.pdf: $P/pgstat_base.% $P/pgstat_jsonb.%
	for m in $(subst $(COMMA),$(SPACE),$(EVENTS)); do \
		./generate_plots.py -o $(@D)/pgstat_$*_$$m.pdf -m $$m -l Base,JSONB $^ ; \
	done
$P/compstat_%_cycles.pdf: $P/pgstat_jsonb.% $P/neostat_base.%
	for m in $(subst $(COMMA),$(SPACE),$(EVENTS)); do \
		./generate_plots.py -o $(@D)/compstat_$*_$$m.pdf -m $$m -l PostgreSQL,Neo4j $^ ; \
	done

pgpopulate: | $(DATADIR) postgres
	$P/bin/pg_ctl stop
	$(RM) -r $(PGDATA)
	$P/bin/initdb
	sed -i -r '/^#?work_mem/{s/^#//;s/=\s?\w+/= 512MB/}' $(PGDATA)/postgresql.conf
	$P/bin/pg_ctl start
	sleep 3
	$P/bin/createdb opta
	$(PY) src/postgres/pgload.py # Populate Postgres

tmp/csvgraph: | $(DATADIR)
	$(PY) src/neo4j/schemas/base/read_files.py $(DATADIR)
neopopulate: tmp/csvgraph $(NEOTARGET)
	$(RM) -r $P/data/databases/*
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
