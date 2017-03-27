#!/bin/bash

$NEO4J_DIR/bin/neo4j-import --stacktrace true --multiline-fields true \
  --into $NEO4J_DIR/data/databases/graph.db \
  --id-type string \
  --skip-duplicate-nodes true \
  --bad-tolerance 100000 \
  --nodes:Player /tmp/csvgraph/Player.csv \
  --nodes:Team /tmp/csvgraph/Team.csv \
  --nodes:TeamOfficial /tmp/csvgraph/TeamOfficial.csv \
  --nodes:Competition /tmp/csvgraph/Competition.csv \
  --nodes:Event /tmp/csvgraph/Event.csv \
  --nodes:Game /tmp/csvgraph/Game.csv \
  --nodes:Qualifier /tmp/csvgraph/Qualifier.csv \
  --nodes:Season /tmp/csvgraph/Season.csv \
  --nodes:Sport /tmp/csvgraph/Sport.csv \
  --nodes:Stadium /tmp/csvgraph/Stadium.csv \
  --relationships:HAPPENED_IN /tmp/csvgraph/HAPPENED_IN.csv \
  --relationships:IS_A_GAME_IN /tmp/csvgraph/IS_A_GAME_IN.csv \
  --relationships:IS_A_LEAGUE_IN /tmp/csvgraph/IS_A_LEAGUE_IN.csv \
  --relationships:IS_A_SEASON_OF /tmp/csvgraph/IS_A_SEASON_OF.csv \
  --relationships:IS_PART_OF /tmp/csvgraph/IS_PART_OF.csv \
  --relationships:IS_THE_STADIUM_OF /tmp/csvgraph/IS_THE_STADIUM_OF.csv \
  --relationships:MANAGES /tmp/csvgraph/MANAGES.csv \
  --relationships:PLAYED_IN /tmp/csvgraph/PLAYED_IN.csv \
  --relationships:PLAYS_FOR /tmp/csvgraph/PLAYS_FOR.csv \
  --relationships:PLAYS_IN /tmp/csvgraph/PLAYS_IN.csv \
  --relationships:WAS_INVOLVED_IN /tmp/csvgraph/WAS_INVOLVED_IN.csv
