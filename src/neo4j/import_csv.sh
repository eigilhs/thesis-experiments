#!/bin/bash

$NEO4J_DIR/bin/neo4j-import --stacktrace true --multiline-fields true \
  --into $NEO4J_DIR/data/databases/base.db \
  --id-type string \
  --skip-duplicate-nodes true \
  --bad-tolerance 100000 \
  --nodes:Player /tmp/basecsv/Player.csv \
  --nodes:Team /tmp/basecsv/Team.csv \
  --nodes:Competition /tmp/basecsv/Competition.csv \
  --nodes:Event /tmp/basecsv/Event.csv \
  --nodes:Game /tmp/basecsv/Game.csv \
  --nodes:Qualifier /tmp/basecsv/Qualifier.csv \
  --nodes:Season /tmp/basecsv/Season.csv \
  --nodes:Sport /tmp/basecsv/Sport.csv \
  --relationships:HAPPENED_IN /tmp/basecsv/HAPPENED_IN.csv \
  --relationships:IS_A_GAME_IN /tmp/basecsv/IS_A_GAME_IN.csv \
  --relationships:IS_A_LEAGUE_IN /tmp/basecsv/IS_A_LEAGUE_IN.csv \
  --relationships:IS_A_SEASON_OF /tmp/basecsv/IS_A_SEASON_OF.csv \
  --relationships:IS_PART_OF /tmp/basecsv/IS_PART_OF.csv \
  --relationships:PLAYED_IN /tmp/basecsv/PLAYED_IN.csv \
  --relationships:PLAYS_FOR /tmp/basecsv/PLAYS_FOR.csv \
  --relationships:PLAYS_IN /tmp/basecsv/PLAYS_IN.csv \
  --relationships:WAS_INVOLVED_IN /tmp/basecsv/WAS_INVOLVED_IN.csv
