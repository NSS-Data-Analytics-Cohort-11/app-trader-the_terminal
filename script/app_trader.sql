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

-- select *
-- from play_Store_apps


-- select
-- 	category,
-- 	max(review_count)
-- from play_store_apps
-- group by category
-- order by max desc;

-- select *
-- from play_store_apps

-- select *
-- from app_store_apps

select genres
from play_store_apps

select category
from app_store_apps


-- apps that are in both stores
select 
	distinct name,
	primary_genre,
	max(rating) as max_rating,
	price::MONEY,
	content_rating,
	CAST(review_count as integer)
from app_store_apps
where name is not null
	and rating is not null
group by name, primary_genre, price, content_rating, review_count

UNION

select 
	distinct name,
	category,
	max(rating) as max_rating,
	price::MONEY,
	content_rating, 
	CAST(review_count as integer)
from play_Store_apps
where name is not null
	and rating is not null
group by name, category, price, content_rating, review_count

order by price, max_rating desc, review_count desc;