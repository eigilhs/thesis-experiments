MATCH p = (e2:Event {type_id: 12, outcome: 1})
      <-[:PRECEDED*0..3]- (e1:Event {type_id: 1})
WHERE EXISTS((:Qualifier {qualifier_id: 15})
             -[:IS_PART_OF]-> (e2))
      AND EXISTS((e1) <-[:IS_PART_OF]-
                 (:Qualifier {qualifier_id: 6}))
      AND (EXISTS((e1) -[:PRECEDED]-> (e2))
           OR NONE (ex IN nodes(p)[1..-1]
                    WHERE ex.type_id <> 44))
RETURN count(*);
