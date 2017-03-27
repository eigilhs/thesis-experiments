SELECT
    players.name,
    teams.name AS team,
    CAST(sum(accurate_pass) AS FLOAT) / sum(total_pass) AS rate,
    sum(total_pass) AS total
FROM player_results
JOIN players ON player_results.player_id = players.id
JOIN teams ON player_results.team_id = teams.id
WHERE season_id = 2016
  AND competition_id = 90
GROUP BY players.id, teams.id, season_id
HAVING sum(total_pass) > 400
ORDER BY rate DESC
NULLS LAST
LIMIT 10;
