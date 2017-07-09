SELECT count(*)
FROM (
    SELECT
        match_id,
        nth_value(events.id,       1) OVER w AS id1,
        nth_value(events.type_id,  1) OVER w AS etype1,
        nth_value(qs.qualifier_id, 1) OVER w AS qtype1,
        nth_value(qs.qualifier_id, 2) OVER w AS qtype2,
        nth_value(events.type_id,  2) OVER w AS etype2,
        nth_value(events.type_id,  3) OVER w AS etype3,
        nth_value(events.type_id,  4) OVER w AS etype4,
        nth_value(qs.qualifier_id, 4) OVER w AS qtype4,
        nth_value(events.outcome, 2) OVER w AS oc2,
        nth_value(events.outcome, 4) OVER w AS oc4
    FROM events
    LEFT JOIN (
         SELECT event_id, qualifier_id
         FROM   qualifiers
         WHERE  qualifiers.qualifier_id = 6
         OR     qualifiers.qualifier_id = 15
    ) AS qs ON qs.event_id = events.id
    WINDOW w AS (
        PARTITION BY match_id, period_id
        ORDER BY min, sec, timestamp
        ROWS 3 PRECEDING
    )
) AS situations
WHERE situations.etype1 = 1
AND   situations.qtype1 = 6
AND   ((situations.etype2 = 12 AND situations.qtype2 = 15 AND situations.oc2)
        OR (    situations.etype2 = 44
            AND situations.etype3 = 44
            AND situations.etype4 = 12
            AND situations.qtype4 = 15
            AND situations.oc4)
);
