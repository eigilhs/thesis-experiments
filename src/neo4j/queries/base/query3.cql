MATCH (e1:Event) -[:PRECEDED]-> (e2:Event)
WHERE e1.team_id <> e2.team_id
WITH e1, e2
MATCH p = (e2:Event) -[:PRECEDED*0..]-> (e3:Event)
WHERE ((e3.sec + e3.min*60) - (e1.sec + e1.min*60)) >= 3
      AND (e3.x - (100-e1.x)) > 20
      AND (e3.x - (100-e1.x)) /
      ((e3.sec + e3.min*60) - (e1.sec + e1.min*60)) > 6
      AND NONE (ex IN nodes(p) WHERE ex.team_id = e1.team_id)
RETURN count(DISTINCT e1);
