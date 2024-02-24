-- Android Table
SELECT *
FROM play_store_apps

-- Apple Table
SELECT *
FROM app_store_apps

-- Android Top Rated
SELECT *
FROM play_store_apps
WHERE rating IS NOT null
ORDER BY rating DESC

-- Android Top Reviewed

SELECT name, category, ROUND(AVG(rating),1) AS avg_rating, SUM(review_count) AS total_reviews, install_count
FROM play_store_apps
WHERE rating IS NOT null
GROUP BY name, category, install_count
ORDER BY total_reviews DESC

-- Android Top Category
SELECT category, COUNT(category)
FROM play_store_apps
GROUP BY category
ORDER BY count DESC

-- Apple Top Category
SELECT primary_genre AS category, COUNT(primary_genre)
FROM app_store_apps
GROUP BY category
ORDER BY count DESC

-- Apple Top Rated
SELECT *
FROM app_store_apps
WHERE rating IS NOT null
ORDER BY rating DESC

-- Apple Top Reviewed

SELECT name, primary_genre, ROUND(AVG(rating),1) AS avg_rating, SUM(review_count::numeric) AS total_reviews
FROM app_store_apps
WHERE rating IS NOT null
GROUP BY name, primary_genre
ORDER BY total_reviews DESC

--  TOP AVERAGE RATING E10+
SELECT name, ROUND(AVG(rating),1) AS avg_rating, SUM(review_count) AS total_reviews
FROM play_store_apps
WHERE category = 'GAME'
AND content_rating = 'Everyone 10+'
GROUP BY name
ORDER BY total_reviews DESC

-- Apple Top Reviewed Games

SELECT name, primary_genre, ROUND(AVG(rating),1) AS avg_rating, SUM(review_count::numeric) AS total_reviews
FROM app_store_apps
WHERE rating IS NOT null
AND primary_genre = 'Games'
GROUP BY name, primary_genre
ORDER BY total_reviews DESC

-- Android Top Reviewed Games

SELECT name, category, ROUND(AVG(rating),1) AS avg_rating, SUM(review_count::numeric) AS total_reviews
FROM play_store_apps
WHERE rating IS NOT null
AND category = 'GAME'
GROUP BY name, category
ORDER BY total_reviews DESC

--UNION

(SELECT name, COUNT(name), play_store_apps.category, rating::numeric, SUM(review_count) AS total_review_count, MAX(price::money) AS max_price,
 CASE
WHEN price::money < '$1.00' THEN '10000'
WHEN price::money = '$2.00' THEN '20000'
ELSE 'blank' END AS purchase_price
FROM play_store_apps
	WHERE play_store_apps.category = 'GAME''FAMILY'
	AND rating IS NOT NULL
  	--AND name IN (SELECT name FROM app_store_apps) 
GROUP BY play_store_apps.name, category, rating, price


UNION

SELECT name, COUNT(name), app_store_apps.primary_genre AS category, rating, SUM(review_count::numeric) AS total_review_count, MAX(price::money) AS max_price,
CASE
WHEN price::money < '$1.00' THEN '10000'
WHEN price::money = '$2.00' THEN '20000'
ELSE 'blank' END AS purchase_price
FROM app_store_apps
	WHERE app_store_apps.primary_genre = 'Games'
	AND rating IS NOT NULL
 --AND name IN (SELECT name FROM play_store_apps) 	
GROUP BY name, category, rating, price)

--GROUP BY name, category, rating, max_price	
ORDER BY total_review_count DESC, rating DESC
LIMIT 10;
 

--FINAL
--CTE with UNION
WITH all_apps AS
(
(SELECT name, rating, review_count::numeric, price
FROM app_store_apps
WHERE primary_genre = 'Games'
AND rating IS NOT NULL
)
UNION ALL
(
SELECT name, rating, review_count::numeric, REPLACE(price, '$', '')::numeric
FROM play_store_apps
WHERE category IN ('GAME','FAMILY')
AND rating IS NOT NULL)
)

SELECT
	name,
	ROUND(ROUND(AVG(rating)*2, 0) / 2, 1) AS avg_rating_rounded,
	SUM(review_count) AS total_review_count,
	MAX(price) AS in_store_price,
	CASE WHEN MAX(price) <= 1 THEN 10000
		ELSE MAX(price)*10000 END
		AS purchase_cost,

	(CASE WHEN name IN (SELECT name FROM app_store_apps)
		THEN 5000 ELSE 0 END +
		CASE WHEN name IN (SELECT name FROM play_store_apps)
		THEN 5000 ELSE 0 END) *12
		AS annual_income,	

	CASE WHEN ROUND(AVG(rating)*2, 0)/2=5.0 THEN 11
		WHEN ROUND(AVG(rating)*2, 0)/2=4.5 THEN 10
		WHEN ROUND(AVG(rating)*2, 0)/2=4.0 THEN 9
		END
		AS est_lifespan_yrs,

	ROUND(
		(((CASE WHEN name IN (SELECT name FROM app_store_apps)
			THEN 5000 ELSE 0 END +
			CASE WHEN name IN (SELECT name FROM play_store_apps)
			THEN 5000 ELSE 0 END)*12)
		*
		(CASE WHEN ROUND(AVG(rating)*2, 0)/2=5.0 THEN 11
			WHEN ROUND(AVG(rating)*2, 0)/2=4.5 THEN 10
			WHEN ROUND(AVG(rating)*2, 0)/2=4.0 THEN 9 END))
		-
		((CASE WHEN ROUND(AVG(rating)*2, 0)/2=5.0 THEN 11
			WHEN ROUND(AVG(rating)*2, 0)/2=4.5 THEN 10
			WHEN ROUND(AVG(rating)*2, 0)/2=4.0 THEN 9 END)
		* 1000)
		-
		(CASE WHEN MAX(price) <=1 THEN 10000 ELSE MAX(price)*10000 END)
		, 0) AS est_net_profit

FROM all_apps
GROUP BY name
HAVING ROUND(ROUND(AVG(rating)*2, 0)/2, 1) >=4.0
	AND SUM(review_count) >= 1000000 
	AND (CASE WHEN name IN (SELECT name FROM app_store_apps)
		THEN 5000 ELSE 0 END +
		CASE WHEN name IN (SELECT name FROM play_store_apps)
		THEN 5000 ELSE 0 END) *12= '120000'
ORDER BY annual_income DESC, total_review_count DESC, avg_rating_rounded DESC
LIMIT 20;
