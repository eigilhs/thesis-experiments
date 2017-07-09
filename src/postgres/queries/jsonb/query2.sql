SELECT count(*)
FROM (
    SELECT
        match_id,
        nth_value(events.id,       1) OVER w AS id1,
        nth_value(events.type_id,  1) OVER w AS etype1,
        nth_value(events.type_id,  2) OVER w AS etype2,
        nth_value(events.type_id,  3) OVER w AS etype3,
        nth_value(events.type_id,  4) OVER w AS etype4,
        nth_value(events.qualifiers ? '6',  1) OVER w AS q1,
        nth_value(events.qualifiers ? '15', 2) OVER w AS q2,
        nth_value(events.qualifiers ? '15', 4) OVER w AS q4,
        nth_value(events.outcome, 2) OVER w AS oc2,
        nth_value(events.outcome, 4) OVER w AS oc4
    FROM events
    WINDOW w AS (
        PARTITION BY match_id, period_id
        ORDER BY min, sec, timestamp
        ROWS 3 PRECEDING
    )
) AS situations
WHERE situations.etype1 = 1
AND   situations.q1
AND   ((situations.etype2 = 12 AND situations.q2 AND situations.oc2)
        OR (    situations.etype2 = 44
            AND situations.etype3 = 44
            AND situations.etype4 = 12
            AND situations.q4
            AND situations.oc4)
);
