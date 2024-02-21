SELECT *
FROM play_store_apps 
WHERE genres ILIKE '%Game%' 
ORDER BY rating DESC
LIMIT 10

SELECT DISTINCT genres
FROM play_store_apps

SELECT  primary_genre
FROM app_store_apps 
GROUP BY primary_genre
ORDER BY COUNT(*) DESC

SELECT *
FROM app_store_apps
WHERE primary_genre = 'Games' AND rating = 5.0 AND price BETWEEN 0 AND 1
--ORDER BY rating DESC
-- LIMIT 30

SELECT *
FROM app_store_apps
WHERE primary_genre = 'Education' AND rating = 5.0 AND price BETWEEN 0 AND 1

SELECT DISTINCT currency
FROM app_store_apps

--Apple query

SELECT name, review_count::numeric, content_rating
FROM app_store_apps
WHERE primary_genre = 'Games' 
	AND rating = 5.0 
	AND price BETWEEN 0 AND 1
ORDER BY review_count DESC

--Play query

SELECT name, review_count::numeric, content_rating, rating
FROM play_store_apps
WHERE category = 'GAME' --there are a lot listed under FAMILY but not all in family are games...
-- 	(category = 'GAME'
-- 	OR genres ILIKE '%Game%') --go in later and see what other words tag games
	AND rating = 5.0 --necessary to lower to 4.5 since there aren't any 5.0 games, but more may show up after fixing game filter
	AND REPLACE(price, '$', '')::numeric BETWEEN 0 AND 1
ORDER BY review_count DESC

SELECT *
FROM play_store_apps
WHERE category = 'FAMILY'
--WHERE name ILIKE '%candy%crush%'

SELECT category
FROM play_store_apps
GROUP BY category
ORDER BY COUNT(*)

--Unioned query:
--next need to find only apps with count of 2 - but what about spelling inconsitencies?
--and round the ratings to nearest .5
--add new columns for income and expenses

WITH apps AS
(SELECT name, content_rating, review_count::numeric, price
FROM app_store_apps
WHERE primary_genre = 'Games' 
	AND rating >= 4.8
	AND price BETWEEN 0 AND 1
ORDER BY review_count DESC
)
UNION ALL

(SELECT name, content_rating, review_count::numeric, REPLACE(price, '$', '')::numeric
FROM play_store_apps
WHERE category IN ('GAME', 'FAMILY')
	AND rating >= 4.8
	AND REPLACE(price, '$', '')::numeric BETWEEN 0 AND 1
ORDER BY review_count DESC
 )
SELECT name,
	AVG(rating) AS avg_rating,
	SUM(review_count) AS review_count,
	MAX(price) AS price
FROM apps