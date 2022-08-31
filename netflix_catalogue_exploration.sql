/*
This data set was created to list all shows available on Netflix streaming, 
and analyze the data to find interesting facts. 
This data was acquired in July 2022 containing data available in the 
United States Netflix Catalogue.
Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Updating database
*/

--Number of movies and shows available on US Netflix
SELECT type, COUNT(TYPE)
FROM titles
GROUP BY type
;

SELECT COUNT(*)
FROM titles;

--Number of movies and shows classified by age certification
SELECT  age_certification, COUNT(*) AS total
FROM titles
GROUP BY age_certification
;
	--confirmation
SELECT SUM(total)
FROM (
	SELECT  age_certification, COUNT(*) AS total
	FROM titles
	GROUP BY age_certification
	) AS tb1
;

--Movies ordered by duration
SELECT id, title, type, release_year, runtime, production_countries, imdb_score
FROM titles
WHERE type = 'MOVIE' -- AND production_countries NOT LIKE '%IN%'
ORDER BY runtime DESC
;
	-- note: there are a lot of Indian productions, if you want to filter these productions, 
	-- you can add the "and" clause that I commented on in the code. 

-- Movies and shows ordered by year and score
SELECT id, title, type, release_year, genres, imdb_score, tmdb_score, production_countries
FROM titles
WHERE type = 'MOVIE' AND imdb_score IS NOT NULL
ORDER BY release_year DESC, imdb_score DESC
;

SELECT id, title, type, release_year, genres, imdb_score, tmdb_score, production_countries
FROM titles
WHERE type = 'SHOW' AND imdb_score IS NOT NULL
ORDER BY release_year DESC, imdb_score DESC
;
	--note: there were some movies/shows without a score, I filtered that so the result looks clearer

--Number of movies per release_year
SELECT release_year, COUNT(*) AS total_movies
FROM titles
GROUP BY release_year
ORDER BY release_year DESC
;

--Average number of movies per year from 2010 onwards
SELECT AVG(total_movies)
FROM (
	SELECT release_year, COUNT(*) AS total_movies
	FROM titles
	GROUP BY release_year
	ORDER BY release_year DESC
) AS movies_per_year
WHERE release_year >= 2010
;

-- Same query but using a Common Table Expresion (CTE)
WITH movies_per_year (release_year, num_movies)
AS
(
	SELECT release_year, COUNT(*) AS total_movies
	FROM titles
	GROUP BY release_year
	ORDER BY release_year DESC
)
SELECT AVG(num_movies)
FROM movies_per_year
WHERE release_year > 2009
;

-- Most voted movies vs most rated movies ¿are the results similar?
SELECT  title,
		type,
		genres,
		imdb_score,
		imdb_votes
FROM titles
WHERE imdb_score IS NOT NULL AND type = 'MOVIE'
ORDER BY imdb_score DESC;

SELECT  title,
		type,
		genres,
		imdb_score,
		imdb_votes
FROM titles
WHERE imdb_votes IS NOT NULL AND type = 'MOVIE'
ORDER BY imdb_votes DESC;
-- They are not that similar, we remind you that only the netflix catalog is taken into account

--Updating some incorrect scores on the database
UPDATE titles SET imdb_score = 7.4
WHERE title = 'Chhota Bheem & Krishna vs Zimbara'
;

UPDATE titles SET imdb_score = 8.3
WHERE title = 'Major'
;

UPDATE titles SET imdb_score = 7.7
WHERE title = 'Chhota Bheem & Krishna in Mayanagari'
;

-- Most voted shows vs most rated shows ¿are the results similar?
SELECT  title,
		type,
		genres,
		imdb_score,
		imdb_votes
FROM titles
WHERE imdb_score IS NOT NULL AND type = 'SHOW'
ORDER BY imdb_score DESC;

SELECT  title,
		type,
		genres,
		imdb_score,
		imdb_votes
FROM titles
WHERE imdb_votes IS NOT NULL AND type = 'SHOW'
ORDER BY imdb_votes DESC;
 -- They are a little bit more similar than in the movies querys

-- Most voted movie per year
SELECT t1.title, t1.release_year, t1.imdb_score, t1.imdb_votes
FROM titles AS t1
JOIN 	(SELECT release_year, MAX(imdb_votes) AS imdb_votes
		FROM titles
		WHERE type = 'MOVIE'
		GROUP BY release_year
		ORDER BY release_year DESC) AS t2
ON t1.release_year = t2.release_year AND t1.imdb_votes = t2.imdb_votes
ORDER BY release_year DESC
;

--Number of movies and series whose genre is drama
SELECT COUNT(*)
FROM titles
WHERE genres LIKE '%drama%'
; --note: you can change the genre in the WHERE clause to whatever genre you want


-- Shows with the most seasons and an 8.5+ score
SELECT id, title, release_year, seasons, imdb_score
FROM titles
WHERE type = 'SHOW' AND imdb_score >= 8.5
ORDER BY seasons DESC
;

-- Person with more appearances in the netflix catalogue and his movie titles
SELECT DISTINCT(name) AS name, role, COUNT(*) AS appearances
FROM credits
JOIN titles ON titles.id = credits.movie_id
--WHERE production_countries NOT LIKE '%IN%' AND production_countries NOT LIKE '%JP%'
GROUP BY name, role
ORDER BY appearances DESC
;

SELECT name, role, title, imdb_score
FROM credits
JOIN titles ON titles.id = credits.movie_id
WHERE name = 'Boman Irani'
ORDER BY imdb_score DESC
;

-- Number of actors and directors on the database
SELECT role, COUNT(*) AS total
FROM credits
GROUP BY role
;

-- Number of productions per director using window_functions
SELECT  ROW_NUMBER() OVER() AS row_line,
		person_id, 
		name, 
		role, 
		COUNT(*) AS total_productions, 
		DENSE_RANK() OVER(ORDER BY COUNT(*) DESC)
FROM credits
WHERE role = 'DIRECTOR'
GROUP BY person_id, name, role
ORDER BY total_productions DESC
;

-- Director with more appearances in the Netflix catalog and his movies score
SELECT DISTINCT(name) AS name, role, COUNT(*) AS appearances
FROM credits
WHERE role = 'DIRECTOR'
GROUP BY name, role
ORDER BY appearances DESC
LIMIT 1
;

SELECT name, role, title, genres, imdb_score
FROM credits
JOIN titles ON titles.id = credits.movie_id
WHERE name = 'Raúl Campos'
ORDER BY imdb_score DESC
;

-- Creating a materialized view of top rated movies
CREATE MATERIALIZED VIEW public.top_rated_movies_mview
AS
SELECT  title,
		type,
		genres,
		imdb_score,
		imdb_votes
FROM titles
WHERE imdb_score IS NOT NULL AND type = 'MOVIE'
ORDER BY imdb_score DESC
WITH DATA;

--Inserting a random row
INSERT INTO titles (id, 
					title, 
					type, 
					description, 
					release_year, 
					age_certification, 
					runtime, 
					genres, 
					production_countries,
				    seasons,
					imdb_id,
				    imdb_score,
				    imdb_votes,
				    tmdb_popularity,
				    tmdb_score)
VALUES ('tbm12345',
		'The Best Movie 12345',
		'MOVIE',
		'Best movie of 2023',
		2023,
		'R',
		120,
		'drama',
		'MX',
		NULL,
		'tttbm12345',
		9.9,
		3000000,
		NULL,
		NULL
		)
;


-- Creating a view
CREATE VIEW public.top_rated_movies_view
 AS
SELECT  title,
		type,
		genres,
		imdb_score,
		imdb_votes
FROM titles
WHERE imdb_score IS NOT NULL AND type = 'MOVIE'
ORDER BY imdb_score DESC;