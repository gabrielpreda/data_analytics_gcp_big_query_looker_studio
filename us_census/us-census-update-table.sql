-- Create a small editable sample table from the public Census dataset.
CREATE OR REPLACE TABLE us_census.population_sample_editable AS
SELECT
  geo_id,
  zipcode,
  population,
  minimum_age,
  maximum_age,
  gender
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE minimum_age IS NULL
  AND maximum_age IS NULL
  AND COALESCE(gender, '') = ''
ORDER BY RAND()
LIMIT 100;

-- Simulate an update for a small percentage of rows.
UPDATE us_census.population_sample_editable
SET population = CAST(population * (0.95 + RAND() * 0.10) AS INT64)
WHERE RAND() < 0.10;

-- Check updated sample table.
SELECT
  COUNT(*) AS row_count,
  SUM(population) AS total_sample_population,
  AVG(population) AS avg_zip_population,
  MIN(population) AS min_zip_population,
  MAX(population) AS max_zip_population
FROM us_census.population_sample_editable;

-- Find the largest ZIPs in the editable sample.
SELECT
  zipcode,
  population
FROM us_census.population_sample_editable
ORDER BY population DESC
LIMIT 20;

-- Add a derived population segment column.
ALTER TABLE us_census.population_sample_editable
ADD COLUMN IF NOT EXISTS population_segment STRING;

-- Populate the derived segment column.
UPDATE us_census.population_sample_editable
SET population_segment = CASE
  WHEN population >= 50000 THEN 'Large ZIP area'
  WHEN population >= 20000 THEN 'Medium ZIP area'
  WHEN population >= 5000 THEN 'Small ZIP area'
  ELSE 'Very small ZIP area'
END
WHERE population_segment IS NULL;

-- Validate the segment distribution.
SELECT
  population_segment,
  COUNT(*) AS zip_count,
  SUM(population) AS segment_population
FROM us_census.population_sample_editable
GROUP BY population_segment
ORDER BY segment_population DESC;
