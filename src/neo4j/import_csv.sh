#!/bin/bash

$NEO4J_DIR/bin/neo4j-import --stacktrace true --multiline-fields true \
  --into $NEO4J_DIR/data/databases/base.db \
  --id-type string \
  --skip-duplicate-nodes true \
  --bad-tolerance 100000 \
  --nodes:Player /tmp/csvgraph/Player.csv \
  --nodes:Team /tmp/csvgraph/Team.csv \
  --nodes:Competition /tmp/csvgraph/Competition.csv \
  --nodes:Event /tmp/csvgraph/Event.csv \
  --nodes:Game /tmp/csvgraph/Game.csv \
  --nodes:Qualifier /tmp/csvgraph/Qualifier.csv \
  --nodes:Season /tmp/csvgraph/Season.csv \
  --nodes:Sport /tmp/csvgraph/Sport.csv \
  --relationships:HAPPENED_IN /tmp/csvgraph/HAPPENED_IN.csv \
  --relationships:PRECEDED /tmp/csvgraph/PRECEDED.csv \
  --relationships:IS_A_GAME_IN /tmp/csvgraph/IS_A_GAME_IN.csv \
  --relationships:IS_A_LEAGUE_IN /tmp/csvgraph/IS_A_LEAGUE_IN.csv \
  --relationships:IS_A_SEASON_OF /tmp/csvgraph/IS_A_SEASON_OF.csv \
  --relationships:IS_PART_OF /tmp/csvgraph/IS_PART_OF.csv \
  --relationships:PLAYED_IN /tmp/csvgraph/PLAYED_IN.csv \
  --relationships:PLAYS_FOR /tmp/csvgraph/PLAYS_FOR.csv \
  --relationships:PLAYS_IN /tmp/csvgraph/PLAYS_IN.csv \
  --relationships:WAS_INVOLVED_IN /tmp/csvgraph/WAS_INVOLVED_IN.csv


sed -Ei 's/active_database=\w+.db/active_database=base.db/' $NEO4J_DIR/conf/neo4j.conf
$NEO4J_DIR/bin/neo4j restart && sleep 3
$NEO4J_DIR/bin/cypher-shell <<EOF && sleep 10
CREATE INDEX ON :Event(type_id);
CREATE INDEX ON :Qualifier(qualifier_id);
EOF
