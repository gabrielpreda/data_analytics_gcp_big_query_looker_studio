-- sample the initial table
CREATE OR REPLACE TABLE usa_names.usa_sample AS 
SELECT *
FROM `bigquery-public-data.usa_names.usa_1910_current`as usn
ORDER BY RAND()
LIMIT 50;

-- number of names per state
CREATE OR REPLACE TABLE usa_names.names_per_state AS 
SELECT usn.state as state, count(*) as count_names
FROM `bigquery-public-data.usa_names.usa_1910_current`as usn
GROUP BY usn.state;


-- most frequent names per state
CREATE OR REPLACE TABLE `usa_names.state_top_names` AS
WITH ranked AS (
  SELECT
    usn.state,
    usn.name,
    SUM(usn.number) AS total_count,
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY SUM(usn.number) DESC) AS rn
  FROM `bigquery-public-data.usa_names.usa_1910_current` as usn
  GROUP BY state, name
)
SELECT state, name, total_count
FROM ranked
WHERE rn = 1;

-- most frequent names per gender
CREATE OR REPLACE TABLE `usa_names.gender_top_names` AS
WITH ranked AS (
  SELECT
    usn.gender,
    usn.name,
    SUM(usn.number) AS total_count,
    ROW_NUMBER() OVER (PARTITION BY gender ORDER BY SUM(usn.number) DESC) AS rn
  FROM `bigquery-public-data.usa_names.usa_1910_current` as usn
  GROUP BY gender, name
)
SELECT gender, name, total_count
FROM ranked
WHERE rn = 1;


-- US top 10 names
CREATE OR REPLACE TABLE `usa_names.us_top10_names` AS
SELECT
  name,
  SUM(number) AS total_count
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY name
ORDER BY total_count DESC
LIMIT 10;

-- US top 20 names grouped by gender
CREATE OR REPLACE TABLE `usa_names.us_top20_names_by_gender` AS
SELECT
  name, gender,
  SUM(number) AS total_count
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY name, gender
ORDER BY total_count DESC
LIMIT 20;

-- US top 10 names per year
CREATE OR REPLACE TABLE `usa_names.us_top10_names_by_year` AS
WITH ranked AS (
  SELECT
    year,
    name,
    SUM(number) AS total_count,
    ROW_NUMBER() OVER (PARTITION BY year ORDER BY SUM(number) DESC) AS rn
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  GROUP BY year, name
)
SELECT year, name, total_count
FROM ranked
WHERE rn <= 10
ORDER BY year, total_count DESC;


-- US total names per state per year
CREATE OR REPLACE TABLE `usa_names.births_per_state_year` AS
SELECT
  state,
  year,
  SUM(number) AS total_births
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY state, year
ORDER BY year, state;

-- US total names per state per year per gender
CREATE OR REPLACE TABLE `usa_names.births_per_state_year_gender` AS
SELECT
  state,
  year,
  gender,
  SUM(number) AS total_births
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY state, year, gender
ORDER BY year, state, gender;



--name analytics
CREATE OR REPLACE TABLE `usa_names.names_analytics` AS
WITH base AS (
  SELECT
    state,
    year,
    name,
    SUM(number) AS name_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  GROUP BY state, year, name
),
state_year_totals AS (
  SELECT
    state,
    year,
    SUM(name_count) AS state_year_total
  FROM base
  GROUP BY state, year
),
us_year_totals AS (
  SELECT
    year,
    SUM(name_count) AS us_year_total
  FROM base
  GROUP BY year
)
SELECT
  b.state,
  b.year,
  b.name,
  b.name_count,
  s.state_year_total,
  u.us_year_total,
  SAFE_DIVIDE(b.name_count, s.state_year_total) AS pct_of_state_year,  -- share within that state/year
  SAFE_DIVIDE(b.name_count, u.us_year_total)   AS pct_of_us_year        -- share within US that year
FROM base b
JOIN state_year_totals s
  USING (state, year)
JOIN us_year_totals u
  USING (year);
