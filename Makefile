VPATH = src
P = out
PGDIR = build/postgres

.PHONY: all clean distclean neo4j-version

all: $P/bin/postgres $P/bin/neo4j

$P $(PGDIR):
	mkdir -p $@

$(PGDIR)/Makefile: postgresql/configure | $(PGDIR)
	cd $| && $(CURDIR)/$< --prefix=$(CURDIR)/$P

$P/bin/postgres: $(PGDIR)/Makefile | $P
	$(MAKE) -C $(<D) install

neo4j-version::
	if [ ! -f .$@ ]; then touch .$@; fi
	if [ `cd neo4j; git rev-parse HEAD` != "`cat .$@`" ]; \
		then cd neo4j; \
		git rev-parse HEAD > ../.$@; \
	fi

$P/bin/neo4j: .neo4j-version | $P
	cd neo4j && mvn clean install -DminimalBuild -DskipTests
	tar xf neo4j/packaging/standalone/target/neo4j-community-*-unix.tar.gz --strip 1 -C $|

clean:
	$(RM) -r build
	cd neo4j && mvn clean

distclean: clean
	$(RM) -r $P
	$(RM) .neo4j-version
