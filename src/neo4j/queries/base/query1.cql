MATCH (p:Player)
      -[:WAS_INVOLVED_IN]-> (e:Event {type_id: 1})
      -[:HAPPENED_IN]-> (g:Game)
      -[:IS_A_GAME_IN]-> (s:Season {season_id: '201690'}),
      (q:Qualifier {qualifier_id: 1}) -[:IS_PART_OF]-> (e)
WITH p, avg(e.outcome) as a, count(e) AS c
WHERE c > 100
RETURN p.name, a, c
ORDER BY a DESC
LIMIT 10
