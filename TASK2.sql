-- Create the Spotify_N database
Create database Spotify_N;
use spotify_N;


-- NORMALIZING DATABASE into 2 theme tables songs,artists and 1 breakdown of many-to-many relationship table (songsartists)
CREATE TABLE `Songs` (
  `id` varchar(255) PRIMARY KEY,
  `name` varchar(255),
  `duration_ms` int,
  `release_date` varchar(255),
  `year_of_release` int,
  `acousticness` float,
  `danceability` float,
  `energy` float,
  `intstrumentless` float,
  `liveness` float,
  `loudness` float,
  `speechiness` float,
  `tempo` float,
  `valence` float,
  `mode` int,
  `key_value` int,
  `popularity` int,
  `explicit` int
);

CREATE TABLE `songsartists` (
  `song_id` varchar(255),
  `artistsid` varchar(255)
);

CREATE TABLE `artists` (
  `artistsid` varchar(255) PRIMARY KEY,
  `artists_name` varchar(255)
);


-- Referencing Tables to relationship table 
ALTER TABLE `songsartists` ADD FOREIGN KEY (`song_id`) REFERENCES `Songs` (`id`);

ALTER TABLE `songsartists` ADD FOREIGN KEY (`artistsid`) REFERENCES `artists` (`artistsid`);


-- Loading data from csv to individual tables

LOAD DATA INFILE 'C:\\Users\\HOME\\Documents\\Spotify2.csv' 
INTO TABLE songs
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;  
show warnings;


LOAD DATA INFILE 'C:\\Users\\HOME\\Documents\\relationship.csv' 
INTO TABLE songsartists
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

LOAD DATA INFILE 'C:\\Users\\HOME\\Documents\\artists.csv' 
INTO TABLE artists
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Indexes for efficient query performance
CREATE INDEX idx_artist_id ON artists(artistsid);
CREATE INDEX idx_songs_name ON songs (name);
CREATE INDEX idx_artists_artists_name ON artists (artists_name);
CREATE INDEX idx_songsartists_song_id ON songsartists (song_id);



-- Sample queries for analysis and optimization

-- Query to find records in songsartists without corresponding songs
-- (Useful for maintaining referential integrity)
SELECT sa.*
FROM songsartists sa
LEFT JOIN songs s ON sa.song_id = s.id
WHERE s.id IS NULL;

-- SQL query to retrieve the names of all songs and their corresponding artists from the songs and artists tables.
SELECT s.name , a.artists_name
FROM songs s
JOIN songsartists sa ON s.id = sa.song_id
JOIN artists a ON sa.artistsid = a.artistsid;

-- Analyzing Query perfomance plan
EXPLAIN SELECT songs.name, artists.artists_name
FROM songs
JOIN songsartists ON songs.id = songsartists.song_id
JOIN artists ON songsartists.artistsid = artists.artistsid;


-- Additional queries for analysis and optimization
SELECT * FROM songs WHERE popularity >60;

EXPLAIN SELECT * FROM songs JOIN songsartists ON songs.id = songsartists.song_id;

SELECT *
FROM songs
WHERE duration_ms = (SELECT MAX(duration_ms) FROM songs WHERE popularity = 84);

SELECT artists.artists_name, COUNT(songsartists.song_id) AS song_count
FROM artists
JOIN songsartists ON artists.artistsid = songsartists.artistsid
GROUP BY artists.artists_name
ORDER BY song_count DESC
LIMIT 10;

SELECT explicit, AVG(duration_ms) AS avg_duration
FROM songs
GROUP BY explicit;
-- Show the CREATE TABLE statements for reference
SHOW CREATE TABLE `spotify_n`.`artists`;
SHOW CREATE TABLE `spotify_n`.`songsartists`;

-- Display InnoDB status for further analysis
SHOW ENGINE InnoDB STATUS;


