WITH ca_starts AS (SELECT * FROM
     (SELECT *, lead(x) OVER () AS lx,
                lead(min) OVER () AS lmin,
                lead(sec) OVER () AS lsec,
                lead(period_id) OVER () AS lep
      FROM (SELECT *
            FROM (SELECT *,
                  lead(period_id) OVER w AS lpi,
                  lead(team_id) OVER w AS lti
                  FROM events
                  WINDOW w AS (ORDER BY match_id, period_id, min, sec, timestamp)
                  ) A
            WHERE team_id != lti AND lti is not null AND period_id = lpi
            ) B
     ) C
     WHERE period_id = lep
       AND lsec + lmin*60 - (sec + min*60) < 10
       AND lx - (100-x) > 20
       AND (lx - (100-x)) / (lsec + lmin*60 - (sec + min*60) + 1) > 5
)
SELECT (SELECT array_agg(type_id)
          FROM events
         WHERE match_id = c.match_id
           AND period_id = c.period_id
           AND min * 60 + sec BETWEEN c.min * 60 + c.sec AND c.lmin * 60 + c.lsec)
FROM ca_starts c;
