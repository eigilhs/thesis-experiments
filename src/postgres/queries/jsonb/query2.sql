WITH RECURSIVE pertinent_events AS (
     SELECT id, type_id, prev_id
     FROM (SELECT *, lag(id) OVER () AS prev_id
           FROM events) e
     WHERE type_id = 44
        OR (type_id = 1  AND qualifiers ? '6')
        OR (type_id = 12 AND qualifiers ? '15' AND outcome)
), cleared_corners AS (
     SELECT * FROM pertinent_events
     WHERE type_id = 12
   UNION
     SELECT e.* FROM cleared_corners c,
                     (SELECT * FROM pertinent_events
                      WHERE type_id IN (1, 44)) e
     WHERE e.id = c.prev_id
)
SELECT count(*)
FROM cleared_corners
WHERE type_id = 1;
