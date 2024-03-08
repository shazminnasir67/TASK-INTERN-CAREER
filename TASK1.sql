Create database spotifyDB;
Create table spotify (
	id VARCHAR(255) PRIMARY KEY ,
    name VARCHAR(255),
    artists VARCHAR(255),
    duration_ms INT,
    release_date VARCHAR(10),
    year_of_release INT,
    acousticness float,
    danceability float,
    energy float,
    intstrumentless float,
    liveness float ,
    loudness float signed,
    speechiness float,
    tempo float,
    valence float,
    mode int,
    key_value int,
    popularity int,
    explicit int
    );
    

    
LOAD DATA INFILE 'C:\\Users\\HOME\\Documents\\Spotify.csv' 
INTO TABLE spotify
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;  

show warnings;

Use spotifydb;
show tables;

describe Spotify;

SELECT * FROM Spotify;

-- What are the total number of rows in the dataset?
SElECT count(id) as total_no_rows From spotify ;

-- How many columns are there?
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'spotifydb' AND table_name = 'spotify';

-- What are the data types of each column?
describe spotify;

-- Are there any duplicate rows in the dataset?
Select distinct count(id) from spotify;

-- What are the basic descriptive statistics (mean, median, min, max) for numerical columns?
SELECT  AVG(duration_ms) as average_duration, MIN(duration_ms) as minimun_duration , MAX(duration_ms) as maximum_duration FROM spotify;
SELECT  AVG(duration_ms) as average_loudness, MIN(loudness) as minimun_loudness , MAX(loudness) as maximum_loudness FROM spotify;

-- How much the value differ from the mean value ?
SELECT stddev(duration_ms) as std_dev_duration_ms From spotify;


-- What is the average duration of songs released in each year?
SELECT  year_of_release ,avg(duration_ms) as average FROM spotify group by year_of_release;


-- How many explicit and non-explicit songs are there in the dataset?
SELECT explicit ,count(explicit) as songs_explicit from spotify group by explicit ;


-- Which songs are in the top 10 in terms of popularity?
select name as most_popular ,count(popularity) as total from spotify group by popularity LIMIT 10;

-- What is the average danceability and energy for songs released before and after 2000?
SELECT 
	CASE
		WHEN year_of_release < 2000 THEN 'Before 2000'
		WHEN year_of_release >= 2000 THEN 'After 2000'
	END AS release_period, AVG(danceability) AS avg_danceability, AVG(energy) AS avg_energy
From spotify group by release_period;
    

-- What is the average loudness and tempo for songs with low and high acousticness levels?
Select 
	CASE 
		when acousticness > avg_acousticness THEN 'High Acousticness level'
        when acousticness <= avg_acousticness THEN 'Low Acousticness level'
	END AS Acousticness_level, AVG(loudness) as avg_loudness,
        AVG(tempo) as avg_tempo 
FROM spotify ,( SELECT AVG(acousticness) AS avg_acousticness FROM spotify) as average
GROUP BY Acousticness_level;


-- Which key has the highest average valence?
SELECT key_value
from (SELECT key_value, avg(valence) as avg_valence from spotify group by key_value ORDER BY avg_valence DESC
    LIMIT 1
) as key_table ;


-- Find the total number of songs for each mode (major or minor).
SELECT mode ,count(ID) as total_songs from spotify group by mode;
DELETE FROM spotify where mode=7;

-- Retrieve the most recent songs based on release date.
 select name from spotify order by release_date LIMIT 10;

-- What is the average popularity of songs for each year?
select year_of_release, avg(popularity) as avg_popularity from spotify group by year_of_release;

-- Identify songs with high danceability and energy but low acousticness.
select name 
from spotify
where 
	danceability > (SELECT AVG(danceability) FROM spotify)
    AND energy > (SELECT AVG(energy) FROM spotify)
    AND acousticness < (SELECT AVG(acousticness) FROM spotify);

-- Which artist has the highest average loudness in their songs?
select artists from spotify where loudness = (SELECT max(loudness) from spotify );

-- Find the songs with the lowest and highest instrumentalness.
SELECT
    MAX(CASE 
		WHEN intstrumentless > (SELECT AVG(intstrumentless) FROM spotify) THEN name END) AS highest_instrumentalness,
    MAX(CASE 
		WHEN intstrumentless < (SELECT AVG(intstrumentless) FROM spotify) THEN name END) AS lowest_instrumentalness
FROM spotify;


-- What is the average speechiness for songs in different keys?
select key_value ,avg(speechiness) as avg_speechiness from spotify group by key_value;

-- Retrieve songs with explicit lyrics and a popularity score above a certain threshold.
select count(name) from spotify where explicit =1 AND popularity > 80;

-- Identify the most common tempo among songs.
select count(id) as common_tempo ,tempo from spotify group by tempo order by common_tempo DESC limit 3;


-- convert the 'duration_ms' column, representing the duration of songs in milliseconds, to minutes?
SELECT  duration_ms/60000 as duration_min from spotify;
 
-- Write a query to handle NULL values in the 'release_date' column by replacing them with a default date.
SELECT release_date from spotify where release_date is NULL;
-- Extract the first 10 characters from the 'artists' column to obtain a concise representation.
SELECT SUBSTRING(artists,1,10) as extractedstring from spotify;

-- lets trim the "['" from artists column 
SELECT TRIM("']" from TRIM("['" from artists)) as trimmedstring from spotify;

-- Calculate the total duration of all songs in minutes.
SELECT SUM(duration_ms)/60000 as Total_duration from spotify;

-- Determine the average energy level across all songs in the dataset.
select avg (energy) as avg_energy from spotify ;

-- What is the highest popularity value among the songs?
select max(popularity) as maximum from spotify;
-- Find the count of explicit songs in the dataset.
select count(id) as no_of_exp_songs from spotify where explicit=1;

-- Calculate the sum of 'loudness' for songs released between 2000 to 2015 year.
select sum(loudness) from spotify where year_of_release BETWEEN 2000 and 2015;

-- Calculate the total acousticness for songs with a popularity greater than 50.
select sum(acousticness)as total_acousticness from spotify where popularity> 50;

-- Determine the average danceability for songs released before the year 2000.
select avg(danceability) as avg_danceability from spotify where year_of_release < 2000;

-- Find the song with the highest instrumentalness value.
select max(intstrumentless) as maximum  from spotify ;

-- Count the number of unique 'key_value' entries in the dataset.
select count(key_value) from spotify;

-- Calculate the sum of 'tempo' for explicit songs.
select sum(tempo) from spotify where explicit= 1;

-- TREND ANALYSIS

SELECT 
	YEAR(release_date) as release_year,
    MONTH(release_date) as release_month,
    COUNT(id) as songs_count
from spotify
GROUP BY   
	YEAR(release_date),
    MONTH(release_date)
ORDER BY release_year, release_month ;

SELECT 
	release_year , release_month ,songs_count , LAG(songs_count) OVER (ORDER BY release_year, release_month) AS prev_month_count,
    (songs_count - LAG(songs_count) OVER (ORDER BY release_year, release_month)) / LAG(songs_count) OVER (ORDER BY release_year, release_month) * 100 AS percentage_change
from (SELECT 
	YEAR(release_date) as release_year,
    MONTH(release_date) as release_month,
    COUNT(id) as songs_count
	from spotify
	GROUP BY   
		YEAR(release_date),
		MONTH(release_date)
	ORDER BY release_year, release_month ) AS monthly_songs
ORDER BY release_year , release_month;
    
-- FINDING OUTLIER AND ANOMILIES
select 
	duration_ms ,ntile(3) over (order by duration_ms) AS duration_quartile
from spotify;
    

SELECT 
	duration_quartile,
    max(duration_ms) as quartile_break
FROM ( 
		select 
	duration_ms ,ntile(3) over (order by duration_ms) AS duration_quartile
	from spotify) as quartiles
WHERE duration_quartile IN(1,3)
GROUP BY duration_quartile;

create VIEW Spotify2 AS select name , duration_ms FROM spotify;


WITH OrderedData AS (
  SELECT
    name,
    duration_ms,
    ROW_NUMBER() OVER (ORDER BY duration_ms) AS row_n,
    COUNT(*) OVER () AS total_rows
  FROM
    Spotify2
),
QuartileBreaks AS (
  SELECT
    name,
    duration_ms,
    MAX(CASE WHEN row_n = FLOOR(total_rows * 0.75) THEN duration_ms END) OVER () AS q_three_upper,
    MAX(CASE WHEN row_n = FLOOR(total_rows * 0.75) + 1 THEN duration_ms END) OVER () AS q_three_lower,
    MAX(CASE WHEN row_n = FLOOR(total_rows * 0.25) THEN duration_ms END) OVER () AS q_one_upper,
    MAX(CASE WHEN row_n = FLOOR(total_rows * 0.25) + 1 THEN duration_ms END) OVER () AS q_one_lower
  FROM
    OrderedData
),
IQR AS (
  SELECT
    name,
    duration_ms,
    (q_three_upper + q_three_lower) / 2 AS q_three,
    (q_one_upper + q_one_lower) / 2 AS q_one,
    1.5 * (q_three_upper - q_one_upper) AS outlier_range
  FROM
    QuartileBreaks
)
SELECT
  name,
  duration_ms,
  CASE
    WHEN duration_ms >= (q_three + outlier_range) OR duration_ms <= (q_one - outlier_range) THEN TRUE
    ELSE FALSE
  END AS is_outlier
FROM
  IQR LIMIT 1000;


-- where duration_ms >=((SELECT MAX(q3) FROM IQR)+(SELECT MAX(outlier_range) from IQR )) or duration_ms <= (SELECT MAX(q1) FROM IQR)-(SELECT MAX(outlier_range) from IQR );

-- Metric calculate
SELECT artists , avg(duration_ms) 
FROM spotify 
GROUP BY artists;

-- find songs with a popularity higher than the average popularity for each artist.

With ArtistPopularity AS (
  SELECT artists, AVG(popularity) AS avg_popularity
  FROM spotify
  GROUP BY artists)
SELECT s.name, s.artists, s.popularity
FROM spotify as  s
JOIN
  ArtistPopularity ap ON s.artists = ap.artists
WHERE s.popularity > ap.avg_popularity;

-- compare the average popularity of explicit and non-explicit songs.
SELECT case
	WHEN explicit = 0 THEN 'non-explicit'
    WHEN explicit = 1 THEN 'explicit'
    END as explicity ,
		AVG(popularity) as avg_popularity
FROM spotify
GROUP BY explicity;
    
-- find the correlation between acousticness and popularity for songs released in the last three years.

with last_three_year AS (
	SELECT acousticness, popularity
    from spotify
    where Year_of_release IN( SELECT DISTINCT year_of_release
		FROM (SELECT year_of_release
			FROM spotify ORDER BY year_of_release DESC
			LIMIT 3 ) AS recent_years ))
SELECT (count(*) * sum(acousticness * popularity) - sum(acousticness) * sum(popularity)) / 
        (sqrt(count(*) * sum(acousticness * acousticness) - sum(acousticness) * sum(acousticness)) * sqrt(count(*) * sum(popularity * popularity) - sum(popularity) * sum(popularity))) 
        AS correlation_coefficient_sample From last_three_year  ;
        