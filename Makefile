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
	clearcache

all: pgpopulate neopopulate

$P $(PGDIR):
	mkdir -p $@

$(PGDIR)/GNUMakefile: postgresql/configure | $(PGDIR)
	cd $| && $(CURDIR)/$< --prefix=$(CURDIR)/$P

postgres: $(PGDIR)/GNUMakefile | $P
	$(MAKE) -C $(<D) install

# Use git HEAD to determine if we should build Neo4j
.neo4j-version: neo4j-version
neo4j-version:
	if [ ! -f .$@ ]; then touch .$@; fi
	if [ `cd neo4j; git rev-parse HEAD` != "`cat .$@`" ]; then \
		cd neo4j && git rev-parse HEAD > ../.$@; \
	fi

$(NEOTARGET): .neo4j-version | $P
	cd neo4j && mvn clean install -U -DminimalBuild -DskipTests
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

EVENTS := cpu-clock,context-switches,cpu-migrations,page-faults,cycles,instructions,branches,branch-misses,syscalls:sys_enter_read,syscalls:sys_enter_write,syscalls:sys_enter_fsync,block:block_rq_complete

$P/pgstat_base.%: src/postgres/queries/base/query%.sql
	$P/bin/psql opta -c "ALTER DATABASE opta SET search_path TO base;"
	sudo -E perf stat -e $(EVENTS) -a -o $@ -ddd -r 5 -- \
	sh -c "sudo -E -u $(USER) $P/bin/psql opta -f $<"
$P/pgstat_jsonb.%: src/postgres/queries/jsonb/query%.sql
	$P/bin/psql opta -c "ALTER DATABASE opta SET search_path TO jsonb;"
	sudo -E perf stat -e $(EVENTS) -a -o $@ -ddd -r 5 -- \
	sh -c "sudo -E -u $(USER) $P/bin/psql opta -f $<"

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

benchmark: $(addprefix $P/,pgstat_base.1 pgstat_base.2 pgstat_jsonb.1 pgstat_jsonb.2) $P/specs.tex

clearcache:
	-find src -name "__pycache__" | xargs $(RM) -r

clean: clearcache
	$(RM) -r build
	cd neo4j && mvn clean

distclean: clean
	$(RM) -r $P
	$(RM) .neo4j-version
	$(RM) -r $(DATADIR)
