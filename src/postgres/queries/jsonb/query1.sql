SELECT
    name,
    avg(outcome::int) AS rate,
    count(*) AS total
FROM events
JOIN players
  ON player_id = players.id
JOIN matches
  ON match_id = matches.id
 AND competition_id = 90
 AND season_id = 2016
WHERE type_id = 1 AND qualifiers ? '1'
GROUP BY player_id, name
HAVING count(outcome) > 100
ORDER BY rate DESC
NULLS LAST
LIMIT 10;
