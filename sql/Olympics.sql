-- DuckDB notebook: Olympics
-- Created:  2026-06-17 13:58:49
-- Exported: 2026-06-19 14:33:31

-- ================================================================================
-- Cell 1
-- http://www.olympanalyt.com/
DROP TABLE IF EXISTS sports;
CREATE TABLE sports AS
SELECT * FROM
read_csv("D:\Codex\Python-OlympicsData\csv\sports*.csv");

-- ================================================================================
-- Cell 2
-- http://www.olympanalyt.com/
DROP TABLE IF exists medals;
CREATE table medals AS
SELECT * FROM
read_csv("D:\Codex\Python-OlympicsData\csv\all_olympic_med*.csv");

-- ================================================================================
-- Cell 3
-- http://www.olympanalyt.com/
DROP TABLE IF EXISTS games;
CREATE TABLE games AS SELECT * FROM
read_csv("D:\Codex\Python-OlympicsData\csv\games*.csv");

-- ================================================================================
-- Cell 4
-- Medals by year/season
SELECT
    M.year
  , M.season
  , M.games
  , G.host_country
  , COUNT(*) FILTER (WHERE medal = 'Gold') AS gold
  , COUNT(*) FILTER (WHERE medal = 'Silver') AS silver
  , COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze
  , COUNT(*) AS total_medals
FROM medals AS M
LEFT OUTER JOIN games AS G ON G.games = M.games
GROUP BY ALL
ORDER BY year DESC, season;

-- ================================================================================
-- Cell 5
-- Medals by year/season + country
SELECT
    M.year
  , M.season
  , M.games
  --, G.host_country
  , M.country_code
  , M.country
  , COUNT(*) FILTER (WHERE medal = 'Gold') AS gold
  , COUNT(*) FILTER (WHERE medal = 'Silver') AS silver
  , COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze
  , COUNT(*) AS total_medals
FROM medals AS M
LEFT OUTER JOIN games AS G ON G.games = M.games
GROUP BY ALL
ORDER BY year DESC, season, gold DESC, silver DESC, bronze DESC;

-- ================================================================================
-- Cell 6
WITH foo AS (
-- Medals by year/season + country
SELECT
    M.year
  , M.season
  , M.games
  --, G.host_country
  , M.country_code
  , M.country
  , COUNT(*) FILTER (WHERE medal = 'Gold') AS gold
  , COUNT(*) FILTER (WHERE medal = 'Silver') AS silver
  , COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze
  , COUNT(*) AS total_medals
FROM medals AS M
LEFT OUTER JOIN games AS G ON G.games = M.games
GROUP BY ALL
)
SELECT country_code, country
  , sum(gold) as gold, sum(silver) as silver, sum(bronze) as bronze, sum(total_medals) as totalmedals
  , COUNT(*) AS num_of_games
  , ROUND(sum(gold) / COUNT(*), 1) as avg_gold
  , ROUND(sum(silver) / COUNT(*), 1) as avg_silver
  , ROUND(sum(bronze) / COUNT(*), 1) as avg_bronze
  , ROUND(sum(total_medals) / COUNT(*), 1) as avg_totalmedals
  
  , string_agg(year, ', ' ORDER BY year) as years
FROM foo
GROUP BY ALL
ORDER BY gold DESC, silver DESC, bronze DESC;

-- ================================================================================
-- Cell 7
SELECT DISTINCT year, sport, event_gender, event_name, count(*) AS N 
FROM medals
WHERE season = 'Winter'
GROUP BY ALL
ORDER BY year DESC, sport, event_gender, event_name;

SELECT DISTINCT year FROM medals where season = 'Winter' ORDER BY year;

-- ================================================================================
-- Cell 8
-- Winter Events over years
PIVOT (
    SELECT DISTINCT year
         , sport
         , event_gender
         , event_name
         , COUNT(*) AS N 
    FROM medals
    WHERE season = 'Winter'
    GROUP BY ALL
)
ON year
USING COALESCE(SUM(N)::text, '')
GROUP BY sport
       , event_gender
       , event_name
ORDER BY sport
       , event_name
       , event_gender;

-- ================================================================================
-- Cell 9
-- Summer Events over years
PIVOT (
    SELECT DISTINCT year
         , sport
         , event_gender
         , CONCAT('''', event_name) AS event_name
         , COUNT(*) AS N 
    FROM medals
    WHERE season = 'Summer'
    GROUP BY ALL
)
ON year
USING COALESCE(SUM(N)::text, '')
GROUP BY sport
       , event_gender
       , event_name
ORDER BY sport
       , event_name
       , event_gender;

-- ================================================================================
-- Cell 10
SELECT athletes, COUNT(*) AS total_medals
FROM medals
GROUP BY ALL
ORDER BY COUNT(*) DESC;

-- ================================================================================
-- Cell 11
create table medals2 AS
SELECT * FROM read_csv("D:\Codex\Python-OlympicsData\csv\all_athlete_games.csv");

-- ================================================================================
-- Cell 12
select year, count(*) AS N from medals2 group by all order by year desc;

-- ================================================================================
-- Cell 13
select * from medals2
--WHERE year IN (1996, 2000, 2004)
WHERE year IN (2018)
and Medal IS NOT NULL
ORDER BY sport, event, medal;

-- ================================================================================
-- Cell 14
SELECT * FROm medals2
where 1=1
--and event = 'Basketball Men''s Basketball'
and sport ILIKE '%Swimming%'
--and event ilike '%%'
and year = 2004
and medal is not null
ORDER BY sport, event, medal;

-- ================================================================================
-- Cell 15
select * --year, count(*) 
from medals2
--where name ilike 'Michael Fred Phelps, II'
where name ilike '%biles%'
and medal is not null
--order by year, event;

-- ================================================================================
-- Cell 16
SELECT * FROM medals where athletes ILIKE '%phelps%' and country_code = 'USA' and year >= 2000;
--SELECT year, count(*) FROM medals where athletes ILIKE '%phelps%' and country_code = 'USA' and year >= 2000 GROUP BY ALL;

-- ================================================================================
-- Cell 17
DROP VIEW IF EXISTS vw_medals;
CREATE VIEW vw_medals
AS
  SELECT DISTINCT year, season, CONCAT(year, ' ', season) year_season, city, sport, event, medal, NOC, team
  , CASE WHEN medal = 'Gold' THEN 1 WHEN medal = 'Silver' THEN 2 WHEN medal = 'Bronze' THEN 3 ELSE NULL END AS medal_order
  , count(*) AS team_count
  , string_agg(name, ', ') as athletes
  FROM medals2
  WHERE medal is not null
  GROUP BY ALL;

-- ================================================================================
-- Cell 18
SELECT sport, event, COUNT(*) AS N, string_agg(year, ', ' ORDER BY year) as games
FROM (
SELECT DISTINCT year, sport, event 
FROM vw_medals
)
--where event ilike '%Figure Sk%'
--where year = 2018
GROUP BY ALL
ORDER BY N DESC, sport, event;

-- ================================================================================
-- Cell 19
SELECT year_season, sport, event, COUNT(*) AS event_count 
FROM vw_medals
--WHERE year = 2000
GROUP BY ALL
order by event_count DESC
--ORDER BY year desc, team_count DESC, sport, event, medal_order;
