-- DuckDB notebook: Billboard Hot 100
-- Created:  2026-06-07 03:23:51
-- Exported: 2026-06-17 22:39:50

-- ================================================================================
-- Cell 1
create table bb100 as
select * from
read_csv("D:\opendata\BillboardHot100\Billboard_Hot_100.csv");

-- ================================================================================
-- Cell 2
SELECT * FROM bb100 ORDER BY date DESC, rank LIMIT 5;

-- ================================================================================
-- Cell 3
-- Any complete row duplicates?
SELECT *
FROM bb100
GROUP BY ALL 
HAVING COUNT(*) > 1;

-- ================================================================================
-- Cell 4
-- Is date and rank unique?  It seems like it should be
SELECT date, rank, COUNT(*) AS N
FROM bb100
GROUP BY ALL 
HAVING COUNT(*) > 1
ORDER BY date DESC;
