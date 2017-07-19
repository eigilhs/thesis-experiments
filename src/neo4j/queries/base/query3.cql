MATCH (e1:Event) -[:PRECEDED]-> (e2:Event)
WHERE e1.team_id <> e2.team_id
MATCH p = (e2:Event) -[:PRECEDED*0..]-> (e3:Event),
      (e3:Event) -[:PRECEDED]-> (e4:Event {team_id: e1.team_id})
MATCH (eg:Event) -[:PRECEDED]-> (e4:Event)
WHERE ((eg.sec + eg.min*60) - (e1.sec + e1.min*60)) IN RANGE(3, 10)
      AND (eg.x - (100-e1.x)) > 20
      AND (eg.x - (100-e1.x)) /
      ((eg.sec + eg.min*60) - (e1.sec + e1.min*60)) > 6
      AND NONE (ex IN nodes(p) WHERE ex.team_id = e1.team_id)
RETURN count(*)
