MATCH (:Qualifier {qualifier_id: 6})
      -[:IS_PART_OF]-> (e1:Event {type_id: 1})
      -[:PRECEDED*1..3]-> (e2:Event {type_id: 12, outcome: 1})
      <-[:IS_PART_OF]- (:Qualifier {qualifier_id: 15})
WHERE (e1) -[:PRECEDED]-> (:Event {type_id: 44})
      -[:PRECEDED]-> (:Event {type_id: 44})
      -[:PRECEDED]-> (e2)
      OR (e1) -[:PRECEDED]-> (e2)
RETURN count(*);
