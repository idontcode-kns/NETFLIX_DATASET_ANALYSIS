DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

--1. Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

--3.List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = 2020;

--3.Find the Top 5 Countries with the Most Content on Netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--4.Identify the Longest Movie
select * from netflix
where duration=(select max(duration) from netflix)

--5.Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select * from netflix
where director='Rajiv Chilaka'

--6.Count the Number of Content Items in Each Genre
select listed_in,count(*) from netflix
group by listed_in

--7.List All TV Shows with More Than 5 Seasons
select * from netflix
where type='TV Show' and duration>'5 Seasons'

--8.Find each year and the average numbers of content release in India on netflix
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC

--9.List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

--10.Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

--11.Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--12.Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
select unnest(string_to_array(casts,',')) as actor,count(*)
from netflix
group by actor
order by count(*) desc
limit 10;

--13.Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
select category,count(*) as content_count
from(select case
                when description ilike '%Kills%' or description ilike '%Violence%' then 'Rated A'
				else 'Family_Movies'
end as category 
from netflix)
as categorized_content
group by category

--14.Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

  