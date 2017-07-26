SELECT $$(SELECT id, team_id, min, sec, x,
                 lead(team_id) OVER () AS next_team,
                 lead(id) OVER () AS next_id
          FROM events)$$ events_1 \gset
WITH RECURSIVE possessions AS (
    SELECT id attack_id, *
      FROM :events_1 e
     WHERE team_id != next_team
  UNION
    SELECT p.attack_id, e.*
      FROM :events_1 e, possessions p
     WHERE e.id = p.next_id
       AND (e.team_id = p.team_id OR p.id = p.attack_id)
)
SELECT count(DISTINCT p.attack_id)
  FROM :events_1 e, possessions p
 WHERE e.id = p.attack_id
   AND (p.sec - e.sec + (p.min - e.min)*60 >= 3
        AND p.x - (100-e.x) > 20
        AND (p.x - (100-e.x)) /
            (p.sec - e.sec + (p.min - e.min)*60) > 6);
