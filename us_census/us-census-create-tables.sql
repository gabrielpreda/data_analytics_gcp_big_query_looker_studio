-- Create the working dataset.
CREATE SCHEMA IF NOT EXISTS us_census;

-- Sample the public Census table.
CREATE OR REPLACE TABLE us_census.population_sample AS
SELECT *
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
ORDER BY RAND()
LIMIT 500;

-- Total population per ZIP code.
CREATE OR REPLACE TABLE us_census.population_by_zip AS
SELECT
  zipcode,
  geo_id,
  SUM(population) AS total_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age IS NULL
  AND maximum_age IS NULL
  AND COALESCE(gender, '') = ''
GROUP BY zipcode, geo_id;

-- Top 100 ZIP codes by population.
CREATE OR REPLACE TABLE us_census.top100_zip_population AS
SELECT
  zipcode,
  geo_id,
  total_population,
  RANK() OVER (ORDER BY total_population DESC) AS population_rank
FROM us_census.population_by_zip
ORDER BY population_rank
LIMIT 100;

-- Population by gender per ZIP code.
CREATE OR REPLACE TABLE us_census.population_by_zip_gender AS
SELECT
  zipcode,
  gender,
  SUM(population) AS total_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age IS NULL
  AND maximum_age IS NULL
  AND COALESCE(gender, '') IN ('male', 'female')
GROUP BY zipcode, gender;

-- Population by age group per ZIP code.
CREATE OR REPLACE TABLE us_census.population_by_zip_age_group AS
SELECT
  zipcode,
  CASE
    WHEN minimum_age IS NULL AND maximum_age IS NULL THEN 'Total'
    WHEN minimum_age BETWEEN 0 AND 17 THEN '0-17'
    WHEN minimum_age BETWEEN 18 AND 34 THEN '18-34'
    WHEN minimum_age BETWEEN 35 AND 49 THEN '35-49'
    WHEN minimum_age BETWEEN 50 AND 64 THEN '50-64'
    WHEN minimum_age >= 65 THEN '65+'
    ELSE 'Other'
  END AS age_group,
  SUM(population) AS population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE COALESCE(gender, '') = ''
GROUP BY zipcode, age_group;

-- Dashboard-ready ZIP demographics table.
CREATE OR REPLACE TABLE us_census.zip_demographics_dashboard AS
WITH totals AS (
  SELECT
    zipcode,
    geo_id,
    SUM(population) AS total_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age IS NULL
    AND maximum_age IS NULL
    AND COALESCE(gender, '') = ''
  GROUP BY zipcode, geo_id
),
children AS (
  SELECT
    zipcode,
    SUM(population) AS children_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age BETWEEN 0 AND 17
    AND COALESCE(gender, '') = ''
  GROUP BY zipcode
),
seniors AS (
  SELECT
    zipcode,
    SUM(population) AS senior_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age >= 65
    AND COALESCE(gender, '') = ''
  GROUP BY zipcode
),
gender_totals AS (
  SELECT
    zipcode,
    SUM(CASE WHEN gender = 'male' THEN population ELSE 0 END) AS male_population,
    SUM(CASE WHEN gender = 'female' THEN population ELSE 0 END) AS female_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age IS NULL
    AND maximum_age IS NULL
    AND COALESCE(gender, '') IN ('male', 'female')
  GROUP BY zipcode
)
SELECT
  t.zipcode,
  t.geo_id,
  t.total_population,
  c.children_population,
  s.senior_population,
  g.male_population,
  g.female_population,
  SAFE_DIVIDE(c.children_population, t.total_population) AS children_share,
  SAFE_DIVIDE(s.senior_population, t.total_population) AS senior_share,
  SAFE_DIVIDE(g.male_population, g.male_population + g.female_population) AS male_share,
  SAFE_DIVIDE(g.female_population, g.male_population + g.female_population) AS female_share
FROM totals t
LEFT JOIN children c USING (zipcode)
LEFT JOIN seniors s USING (zipcode)
LEFT JOIN gender_totals g USING (zipcode);

-- Create dashboard-ready views for Looker Studio.
CREATE OR REPLACE VIEW us_census.v_zip_population AS
SELECT *
FROM us_census.population_by_zip;

CREATE OR REPLACE VIEW us_census.v_zip_demographics_dashboard AS
SELECT *
FROM us_census.zip_demographics_dashboard;
