SELECT count(*)
FROM (SELECT DISTINCT *, lead(x) OVER () AS lx,
                         lead(min) OVER () AS lmin,
                         lead(sec) OVER () AS lsec
      FROM (SELECT *
            FROM (SELECT *, lead(team_id) OVER w AS lti
                  FROM events
                  WINDOW w AS (PARTITION BY match_id, period_id
                               ORDER BY min, sec, timestamp)
                  ) A
            WHERE team_id != lti
            ) B
     ) C
WHERE lsec + lmin*60 - (sec + min*60) BETWEEN 3 AND 10
  AND lx - (100-x) > 20
  AND (lx - (100-x)) / (lsec + lmin*60 - (sec + min*60)) > 6;
