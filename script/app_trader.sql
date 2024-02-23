-- select *
-- from app_store_apps

-- select
-- 	name,
-- 	max(rating), 
-- 	category
-- from play_Store_apps
-- where rating is not null
-- group by name, rating, category
-- order by rating desc;

-- select distinct category, max(rating)
-- from play_Store_apps
-- group by category
-- order by max(rating) desc;

-- select 
-- from play_Store_apps


-- select
-- 	category,
-- 	max(review_count)
-- from play_store_apps
-- group by category
-- order by max desc;

select *
from play_store_apps

select *
from app_store_apps

-- select distinct category
-- from play_store_apps

select distinct primary_genre
from app_store_apps

select
	DISTINCT name,
	SUM(review_count) as review_count,
	category
from play_store_apps
where category IN ('GAME', 'FAMILY')
group by name, category
order by review_count desc

-- select distinct rating
-- from app_store_apps
-- order by rating desc

-- apps that are in both stores
select 
	distinct name,						-- running this query returns 1348 games
	primary_genre,
	rating,
	--max(rating) as max_rating,
	price::MONEY,
	content_rating,
	SUM((CAST(review_count as integer))) AS total_review_count
from app_store_apps
where name is not null
	and primary_genre ILIKE '%Games%'
	and rating is not null
	and rating >= '4.5'
	and price::MONEY <= '$1'
	--and CAST(review_count as integer) >= 10000000
	
--order by review_count desc
group by name, primary_genre, rating, price, content_rating, review_count
 
UNION ALL								-- running the UNION ALL returns 264 games

select 
	distinct name,						-- running this query returns 30 games from the Play Store
	category,
	rating,
	--max(rating) as max_rating,
	price::MONEY,
	content_rating,
	SUM((CAST(review_count as integer))) AS total_review_count
--	install_count
from play_Store_apps
where name is not null
	and category IN ('GAME', 'FAMILY')
	and rating is not null
	and rating <= '4.5'
	and price::MONEY <= '$1'
	and review_count >= 10000000
--order by install_count DESC
group by name, category, price, rating, content_rating, review_count
order by total_review_count DESC;



order by price, rating desc, review_count desc;

-----------------------
select
	name,
	COUNT(name),
	SUM(review_count) as review_count,
	category,
	price::MONEY
from play_store_apps
where category IN ('GAME', 'FAMILY')
	and price::MONEY <= '$1'
	and review_count >= 10000000
group by name, category, price, review_count
--order by review_count desc
--limit 10

UNION

select 
	distinct name,
	COUNT(name),
	SUM(CAST(review_count as integer)) as review_count,
	primary_genre,
	price::MONEY
from app_store_apps
where primary_genre = 'Games'
	and price::MONEY <= '$1'
	and CAST(review_count as integer) >= 1000000
group by name, primary_genre, price

order by review_count desc
limit 10


******************************************************************************************************

WITH app_store AS
	(
	select 
		name,
		CAST(review_count as integer) as review_count,
		price::MONEY,
		primary_genre,
		rating
	from app_store_apps
	where primary_genre = 'Games')
	--group by name, price, primary_genre, rating),
	--order by review_count desc

play_store AS
	(
	select
		name, 
		CAST(review_count as integer) as review_count,
		price::MONEY,
		category,
		rating
	from play_store_apps
	where category IN ('GAME', 'FAMILY')
	--group by name, price, category, rating)
	--order by review_count desc
	)
	
SELECT
	a.name as app_name, 
	--primary_genre,
	SUM(CAST(a.review_count as integer)) as review_count,
	a.price::MONEY,
	a.rating
FROM app_store as a
FULL OUTER JOIN play_store as p
ON a.name = p.name
	WHERE category IN ('GAME', 'FAMILY')
	and a.price::MONEY <= '$1'
	and a.review_count >= 1000000
	and a.rating >= '4.5'
group by a.name, a.price, a.review_count, a.rating