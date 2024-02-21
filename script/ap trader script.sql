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