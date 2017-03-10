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
	neo4j benchmark pgpopulate neopopulate pgstart pgstop

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

pgstart:
	$P/bin/pg_ctl start
pgstop:
	$P/bin/pg_ctl stop

$P/pgstat%: src/query%.sql
	paste -s -d ' ' $< | perf stat -r 10 -ddd -o $@ $P/bin/postgres --single opta
$P/pgtime%: src/query%.sql
	paste -s -d ' ' $< | $(GTIME) -v $P/bin/postgres --single opta 2> $@

pgpopulate: | optadata postgres
	$P/bin/initdb
	$P/bin/pg_ctl start
	sleep 3
	$P/bin/createdb opta
	$(PY) optaload/pgload.py # Populate Postgres
	$P/bin/pg_ctl stop

tmp/csvgraph: | optadata
	$(PY) optaload/read_files.py $(DATADIR)
neopopulate: tmp/csvgraph $(NEOTARGET)
	NEO4J_DIR=$P optaload/import_csv.sh	# Populate Neo4j

benchmark: $(addprefix $P/,pgstat1 pgstat2 pgtime1 pgtime2)

clean:
	$(RM) -r build
	cd neo4j && mvn clean

distclean: clean
	$(RM) -r $P
	$(RM) .neo4j-version
