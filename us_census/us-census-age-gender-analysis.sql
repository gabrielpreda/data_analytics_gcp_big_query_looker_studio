-- Most populated age ranges across the US.
SELECT
  minimum_age,
  maximum_age,
  SUM(population) AS total_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age IS NOT NULL
  AND COALESCE(gender, '') = ''
GROUP BY minimum_age, maximum_age
ORDER BY minimum_age;

-- Total population by broad age group.
WITH age_groups AS (
  SELECT
    CASE
      WHEN minimum_age BETWEEN 0 AND 17 THEN '0-17'
      WHEN minimum_age BETWEEN 18 AND 34 THEN '18-34'
      WHEN minimum_age BETWEEN 35 AND 49 THEN '35-49'
      WHEN minimum_age BETWEEN 50 AND 64 THEN '50-64'
      WHEN minimum_age >= 65 THEN '65+'
      ELSE 'Other'
    END AS age_group,
    population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age IS NOT NULL
    AND COALESCE(gender, '') = ''
)
SELECT
  age_group,
  SUM(population) AS total_population
FROM age_groups
GROUP BY age_group
ORDER BY total_population DESC;

-- ZIP codes with the highest estimated child population.
SELECT
  zipcode,
  SUM(population) AS children_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age BETWEEN 0 AND 17
  AND COALESCE(gender, '') = ''
GROUP BY zipcode
ORDER BY children_population DESC
LIMIT 50;

-- ZIP codes with the highest estimated senior population.
SELECT
  zipcode,
  SUM(population) AS senior_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age >= 65
  AND COALESCE(gender, '') = ''
GROUP BY zipcode
ORDER BY senior_population DESC
LIMIT 50;

-- Compare male and female population by ZIP code.
SELECT
  zipcode,
  SUM(CASE WHEN gender = 'male' THEN population ELSE 0 END) AS male_population,
  SUM(CASE WHEN gender = 'female' THEN population ELSE 0 END) AS female_population,
  SUM(population) AS gender_population_total,
  SAFE_DIVIDE(SUM(CASE WHEN gender = 'male' THEN population ELSE 0 END), SUM(population)) AS male_share,
  SAFE_DIVIDE(SUM(CASE WHEN gender = 'female' THEN population ELSE 0 END), SUM(population)) AS female_share
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age IS NULL
  AND maximum_age IS NULL
  AND COALESCE(gender, '') IN ('male', 'female')
GROUP BY zipcode
HAVING gender_population_total >= 10000
ORDER BY ABS(male_share - female_share) DESC
LIMIT 50;

-- Dashboard table: age group distribution by ZIP.
CREATE OR REPLACE TABLE us_census.zip_age_group_dashboard AS
WITH zip_age_groups AS (
  SELECT
    zipcode,
    CASE
      WHEN minimum_age BETWEEN 0 AND 17 THEN '0-17'
      WHEN minimum_age BETWEEN 18 AND 34 THEN '18-34'
      WHEN minimum_age BETWEEN 35 AND 49 THEN '35-49'
      WHEN minimum_age BETWEEN 50 AND 64 THEN '50-64'
      WHEN minimum_age >= 65 THEN '65+'
      ELSE 'Other'
    END AS age_group,
    SUM(population) AS population
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
  WHERE minimum_age IS NOT NULL
    AND COALESCE(gender, '') = ''
  GROUP BY zipcode, age_group
),
zip_totals AS (
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
  z.zipcode,
  z.age_group,
  z.population,
  t.total_population,
  SAFE_DIVIDE(z.population, t.total_population) AS population_share
FROM zip_age_groups z
JOIN zip_totals t
USING (zipcode);
