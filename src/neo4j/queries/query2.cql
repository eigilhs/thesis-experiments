MATCH (e1:Event {type_id: 1}) -[:BEFORE*1..3]-> (e2:Event {type_id: 2})

MATCH (p1:Possession) -[:EVENT*0..2]-> (p2:Possession)
