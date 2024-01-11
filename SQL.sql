/*creating the database*/

CREATE SCHEMA esports_data;

DROP TABLE IF EXISTS generalesportsdata;
CREATE TABLE generalesportsdata (
  game_title VARCHAR(255) CHARACTER SET utf8mb4  PRIMARY KEY,
  release_year YEAR,
  genre VARCHAR(255),
  total_earnings DECIMAL(12,2),
  offline_earnings DECIMAL(12,2)
);

LOAD DATA INFILE 'GeneralEsportData.csv'
INTO TABLE generalesportsdata
FIELDS TERMINATED BY ';'
IGNORE 1 LINES;

DROP TABLE IF EXISTS historicalesportsdata;
CREATE TABLE historicalesportsdata (
  tournament_date DATE DEFAULT NULL,
  game_title VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  Earnings DECIMAL(15,2) DEFAULT NULL,
  no_players INT DEFAULT NULL,
  no_tournaments INT DEFAULT NULL,
  FOREIGN KEY (game_title) REFERENCES generalesportsdata (game_title)
);

LOAD DATA INFILE 'HistoricalEsportData1.csv'
INTO TABLE historicalesportsdata
FIELDS TERMINATED BY ';'
IGNORE 1 LINES;


/*Creating an output to have a general grasp of the data*/

SELECT 
    g.game_title,
    g.genre,
    g.release_year,
    SUM(h.no_tournaments) AS total_tournaments,
    SUM(h.no_players) AS total_players,
    SUM(h.Earnings) AS total_earnings,
    g.total_earnings AS global_total_earnings
FROM
    generalesportsdata g
        JOIN
    historicalesportsdata h ON g.game_title = h.game_title
GROUP BY g.game_title
HAVING total_earnings IS NOT NULL
    AND total_tournaments IS NOT NULL
    AND total_players != 0
ORDER BY g.release_year , g.game_title;
    
/*esports Industry analysis - tournaments and earnings*/

SELECT 
    DATE_FORMAT(tournament_date, '%Y') AS tournament_year,
    SUM(no_tournaments) AS tournaments_p_year,
    SUM(earnings) AS earnings_p_year,
    SUM(earnings) / SUM(no_tournaments) AS avg_tournamentprize
FROM
    historicalesportsdata
GROUP BY DATE_FORMAT(tournament_date, '%Y');

/*p/month - analyzing seazonality */ 

SELECT 
    DATE_FORMAT(tournament_date, '%Y-%m') AS tournament_year_month,
    SUM(no_tournaments) AS tournaments_p_year_month,
    SUM(earnings) AS earnings_p_year_month,
    SUM(earnings) / SUM(no_tournaments) AS avg_tournament_prize
FROM
    historicalesportsdata
GROUP BY DATE_FORMAT(tournament_date, '%Y-%m');

/*Top 10 games in the market*/

SELECT 
    game_title,
    SUM(Earnings) AS total_earnings,
    SUM(no_players) AS total_players,
    SUM(no_tournaments) AS total_tournaments,
    SUM(no_players) / SUM(no_tournaments) AS avg_players_per_tournament
FROM
    HistoricalEsportsData
GROUP BY game_title
ORDER BY total_earnings DESC
LIMIT 10;

/* top games p/no_players*/

SELECT 
    game_title,
    SUM(Earnings) AS total_earnings,
    SUM(no_players) AS total_players,
    SUM(no_tournaments) AS total_tournaments,
    SUM(no_players) / SUM(no_tournaments) AS avg_players_per_tournament
FROM
    HistoricalEsportsData
GROUP BY game_title
ORDER BY total_players DESC
LIMIT 10;

/* top games p/tournaments*/

SELECT 
    game_title,
    SUM(Earnings) AS total_earnings,
    SUM(no_players) AS total_players,
    SUM(no_tournaments) AS total_tournaments,
    SUM(no_players) / SUM(no_tournaments) AS avg_players_per_tournament
FROM
    HistoricalEsportsData
GROUP BY game_title
ORDER BY total_tournaments DESC
LIMIT 10;

/*Playerbase analysis in order to understand any relationship with player earnings vs. tournaments */

SELECT 
    DATE_FORMAT(tournament_date, '%Y') AS tournament_year,
    SUM(no_players) AS total_players,
    SUM(earnings) / SUM(no_players) AS avg_earning_p_player
FROM
    HistoricalEsportsData
GROUP BY tournament_year
ORDER BY tournament_year ASC;

/*Releases p/ year analysis an possible correlation with tournaments*/

SELECT 
    release_year, COUNT(game_title) AS releases_year
FROM
    generalesportsdata
GROUP BY release_year
ORDER BY release_year ASC;
/*genre analysis */
SELECT 
    genre, COUNT(*) AS genre_count
FROM
    generalesportsdata
GROUP BY genre
ORDER BY genre_count DESC;

/*Genre-wise Earnings and Tournaments*/

SELECT 
    g.genre,
    SUM(h.no_tournaments) AS total_tournaments,
    SUM(h.Earnings) AS total_earnings,
    SUM(no_players) AS total_players,
    SUM(h.Earnings) / SUM(h.no_players) AS avg_earnings_per_player
FROM
    generalesportsdata g
        JOIN
    historicalesportsdata h ON g.game_title = h.game_title
GROUP BY g.genre
ORDER BY total_earnings DESC , total_tournaments DESC;
    
/* Genre-wise Player Engagement */

SELECT 
    g.genre,
    SUM(h.no_players) AS total_players,
    SUM(h.no_tournaments) AS total_tournaments
FROM
    generalesportsdata g
        JOIN
    historicalesportsdata h ON g.game_title = h.game_title
GROUP BY g.genre
ORDER BY total_players DESC , total_tournaments DESC;

/*releases*/

SELECT 
    release_year,
    COUNT(*) as total_releases_per_year,
    genre
FROM
    generalesportsdata
GROUP BY 
    release_year,
    genre
ORDER BY 
    release_year ASC, 
    genre;
