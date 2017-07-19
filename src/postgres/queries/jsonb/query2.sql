WITH RECURSIVE ordered_events AS (
     SELECT id, type_id, next_id
     FROM (SELECT *, lead(id) OVER w AS next_id FROM events
           WINDOW w AS (PARTITION BY match_id, period_id
                        ORDER BY min, sec, timestamp)) e
     WHERE type_id = 44
        OR (type_id = 1  AND qualifiers ? '6')
        OR (type_id = 12 AND qualifiers ? '15' AND outcome)
),
rec AS (
     SELECT * FROM ordered_events
     WHERE type_id = 1
   UNION
     SELECT e.* FROM (SELECT * FROM ordered_events
                      WHERE type_id IN (44, 12)) e, rec r
     WHERE e.id = r.next_id
)
SELECT count(*) FROM rec
WHERE type_id = 12;
