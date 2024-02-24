WITH all_apps AS                
(
	(select 
		name, rating, review_count::numeric, price::numeric
	from app_store_apps  
	where primary_genre = 'Games'
	)
	UNION ALL		

	(select 
	 	name, rating, review_count::numeric, REPLACE(price, '$', '')::numeric
	from play_store_apps
	where category IN ('GAME', 'FAMILY')
	 )
)

SELECT
	name, 
	COUNT(name),
	ROUND(AVG(rating), 2) as avg_rating,
	MAX(review_count) as review_count
FROM all_apps
WHERE price::numeric <= '1'
	and review_count >= 1000000 
	and rating >= '4.5'
GROUP BY name
HAVING SUM(review_count) >= 10000000
ORDER BY review_count desc