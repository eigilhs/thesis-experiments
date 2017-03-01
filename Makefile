VPATH = src
P = out
PGDIR = build/postgres
PGDATA = out/data
PGPORT = 40576
DATADIR = optadata
PY = python3

# Where the tarballs are
NEOTARDIR = neo4j/packaging/standalone/target
# Some arbitrary file that changes when neo is built
NEOTARGET = $P/lib/neo4j-common-*.jar

.PHONY: all clean distclean neo4j-version postgres \
	neo4j benchmark pgpopulate neopopulate

all: pgpopulate neopopulate #postgres $(NEOTARGET)

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

pgpopulate: | optadata postgres
	$P/bin/initdb
	$P/bin/pg_ctl start
	$P/bin/createdb opta
	$(PY) optaload/pgload.py # Populate Postgres
	$P/bin/pg_ctl stop

tmp/csvgraph: | optadata
	$(PY) optaload/read_files.py $(DATADIR)
neopopulate: tmp/csvgraph $(NEOTARGET)
	NEO4J_DIR=$P optaload/import_csv.sh	# Populate Neo4j

benchmark:
	#TODO

clean:
	$(RM) -r build
	cd neo4j && mvn clean

distclean: clean
	$(RM) -r $P
	$(RM) .neo4j-version
