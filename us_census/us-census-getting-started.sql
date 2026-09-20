-- Standard SQL
-- What information is available in the US Census ZIP population table?
SELECT
  geo_id,
  zipcode,
  population,
  minimum_age,
  maximum_age,
  gender
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
LIMIT 20;

-- Filtering and aggregation
-- What are the most populated ZIP Code Tabulation Areas?
SELECT
  zipcode,
  SUM(population) AS total_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age IS NULL
  AND maximum_age IS NULL
  AND COALESCE(gender, '') = ''
GROUP BY zipcode
ORDER BY total_population DESC
LIMIT 20;

-- Filtering by age range
-- Which ZIP codes have the largest population of children aged 0-9?
SELECT
  zipcode,
  SUM(population) AS children_0_9_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age >= 0
  AND maximum_age <= 9
  AND COALESCE(gender, '') = ''
GROUP BY zipcode
ORDER BY children_0_9_population DESC
LIMIT 20;

-- Gender aggregation
-- What is the total male and female population across the dataset?
SELECT
  gender,
  SUM(population) AS total_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age IS NULL
  AND maximum_age IS NULL
  AND COALESCE(gender, '') IN ('male', 'female')
GROUP BY gender
ORDER BY total_population DESC;

-- Joins
-- Compare male and female population in the same ZIP code.
WITH male_population AS (
  SELECT
    zipcode,
    SUM(population) AS male_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age IS NULL
    AND maximum_age IS NULL
    AND gender = 'male'
  GROUP BY zipcode
),
female_population AS (
  SELECT
    zipcode,
    SUM(population) AS female_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age IS NULL
    AND maximum_age IS NULL
    AND gender = 'female'
  GROUP BY zipcode
)
SELECT
  m.zipcode,
  m.male_population,
  f.female_population,
  m.male_population + f.female_population AS total_population,
  SAFE_DIVIDE(m.male_population, m.male_population + f.female_population) AS male_share,
  SAFE_DIVIDE(f.female_population, m.male_population + f.female_population) AS female_share
FROM male_population m
JOIN female_population f
USING (zipcode)
ORDER BY total_population DESC
LIMIT 50;

-- Window functions
-- Rank ZIP codes by total population.
SELECT
  zipcode,
  population AS total_population,
  RANK() OVER (ORDER BY population DESC) AS population_rank,
  PERCENT_RANK() OVER (ORDER BY population) AS population_percent_rank
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age IS NULL
  AND maximum_age IS NULL
  AND COALESCE(gender, '') = ''
ORDER BY population_rank
LIMIT 50;

-- CTEs
-- Which ZIP codes have a high share of seniors aged 65+?
WITH total_population AS (
  SELECT
    zipcode,
    SUM(population) AS total_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age IS NULL
    AND maximum_age IS NULL
    AND COALESCE(gender, '') = ''
  GROUP BY zipcode
),
senior_population AS (
  SELECT
    zipcode,
    SUM(population) AS senior_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age >= 65
    AND COALESCE(gender, '') = ''
  GROUP BY zipcode
)
SELECT
  t.zipcode,
  t.total_population,
  s.senior_population,
  SAFE_DIVIDE(s.senior_population, t.total_population) AS senior_share
FROM total_population t
JOIN senior_population s
USING (zipcode)
WHERE t.total_population >= 10000
ORDER BY senior_share DESC
LIMIT 50;

-- Business analytics query
-- Segment ZIP codes by population size for dashboarding.
WITH zip_totals AS (
  SELECT
    zipcode,
    SUM(population) AS total_population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age IS NULL
    AND maximum_age IS NULL
    AND COALESCE(gender, '') = ''
  GROUP BY zipcode
)
SELECT
  CASE
    WHEN total_population >= 50000 THEN 'Large ZIP area'
    WHEN total_population >= 20000 THEN 'Medium ZIP area'
    WHEN total_population >= 5000 THEN 'Small ZIP area'
    ELSE 'Very small ZIP area'
  END AS population_segment,
  COUNT(*) AS zip_count,
  SUM(total_population) AS segment_population,
  AVG(total_population) AS avg_zip_population
FROM zip_totals
GROUP BY population_segment
ORDER BY segment_population DESC;
