MATCH p = (e2:Event) -[:PRECEDED*]-> (e3:Event),
      (e1:Event) -[:PRECEDED]-> (e2),
      (e3) -[:PRECEDED]-> (e4:Event)
MATCH (eg:Event) -[:PRECEDED]-> (e4:Event)
WHERE e1.team_id = e4.team_id
      AND NONE (ex IN nodes(p) WHERE ex.team_id = e1.team_id)
      AND (eg.sec + eg.min*60) - (e1.sec + e1.min*60) < 10
      AND (eg.x - (100-e1.x)) > 20
      AND (eg.x - (100-e1.x)) /
      ((eg.sec + eg.min*60) - (e1.sec + e1.min*60)+1) > 5
RETURN count(*)
