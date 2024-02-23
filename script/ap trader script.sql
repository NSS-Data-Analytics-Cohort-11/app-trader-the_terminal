SELECT *
FROM app_store_apps;

SELECT*
FROM play_store_apps;

SELECT MAX(rating) AS max_rating, name, price, content_rating, primary_genre, review_count
FROM app_store_apps
WHERE price <=1.00
AND rating =5
AND primary_genre = 'Games'
GROUP BY app_store_apps.rating, app_store_apps.name, app_store_apps.price, app_store_apps.content_rating, app_store_apps.primary_genre, app_store_apps.review_count
ORDER BY app_store_apps.review_count::numeric DESC;

SELECT MAX(rating) AS max_ratings, name, price, content_rating, category, review_count
FROM play_store_apps
WHERE play_store_apps.type = 'Free'
AND category = 'GAME'
GROUP BY play_store_apps.rating, play_store_apps.name, play_store_apps.price, play_store_apps.content_rating, play_store_apps.category, play_store_apps.review_count
ORDER BY play_store_apps.review_count DESC;

WITH apps AS
(
	(SELECT name, rating, review_count::numeric, price
	FROM app_store_apps
	WHERE primary_genre = 'Games'
	)
	UNION ALL
	(
	SELECT name, rating, review_count::numeric, REPLACE(price,'$','')::numeric
		FROM play_store_apps
		WHERE category IN ('GAME', 'FAMILY'))
	)
SELECT 
	name,
	ROUND(ROUND(AVG(rating)*2,0)/2,1) AS avg_rating_rounded,
	ROUND(SUM(review_count)/10000000,2) AS review_count_millions,
	MAX(price) AS price,
	CASE WHEN MAX(price) <= 1  THEN 10000
		ELSE MAX (price)*10000 END
		AS yearly_income,
	CASE WHEN ROUND(AVG(rating)*2,0)/2 = 5.0 THEN 11
		WHEN ROUND(AVG(rating)*2,0)/2 = 4.5 THEN 10
		WHEN ROUND(AVG(rating)*2,0)/2 = 4.0 THEN 9
		END 
		AS lifespan,
	ROUND(
	((CASE WHEN name IN(SELECT name FROM app_store_apps) THEN 5000 ELSE 0 END *
	  	CASE WHEN name IN (SELECT name FROM play_store_apps) THEN 5000 ELSE 0 END)*12)
		*
		(CASE WHEN ROUND(AVG(rating)*2,0)/2 = 5.0 THEN 11
		 	WHEN ROUND(AVG(rating)*2,0)/2 = 4.5 THEN 10
		 	WHEN ROUND(AVG(rating)*2,0)/2 = 4.0 THEN 9 END))
		-
		((CASE WHEN ROUND(AVG(rating)*2,0)/2 = 5.0 THEN 11
		 	WHEN ROUND(AVG(rating)*2,0)/2 = 4.5 THEN 10
		 	WHEN ROUND(AVG(rating)*2,0)/2 = 4.0 THEN 9 END)
		 * 1000)
		 =
		 (CASE 
		  	WHEN MAX(price) <= 1 THEN 10000 
		  	ELSE MAX(price)*10000 END
		  , 0)
		  AS net_profit
FROM apps
GROUP BY name
HAVING ROUND(ROUND(AVG(rating)*2, 0)/2,1) >= 4.0
ORDER BY net_profit DESC, review_count_millions DESC;