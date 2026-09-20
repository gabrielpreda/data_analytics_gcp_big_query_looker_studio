-- Standard SQL
-- What information is available about baby names in the United States?
SELECT
  name,
  gender,
  state,
  year,
  number
FROM `bigquery-public-data.usa_names.usa_1910_current`
LIMIT 10;

-- Filtering and aggregation
-- What were the most popular baby names in 2020?
SELECT
  name,
  SUM(number) AS total_births
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020
GROUP BY name
ORDER BY total_births DESC
LIMIT 10;

-- Joins
-- Compare male and female popularity for the same name.
WITH male_names AS (
  SELECT
      name,
      SUM(number) AS male_births
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE gender = 'M'
  GROUP BY name
),

female_names AS (
  SELECT
      name,
      SUM(number) AS female_births
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE gender = 'F'
  GROUP BY name
)

SELECT
    m.name,
    m.male_births,
    f.female_births
FROM male_names m
JOIN female_names f
ON m.name = f.name
ORDER BY (m.male_births + f.female_births) DESC
LIMIT 50;

-- Window functions
-- How has the popularity of the name Emma changed over time in CA?
SELECT
    year,
    number,
    SUM(number) OVER (
        ORDER BY year
    ) AS cumulative_births
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE name = 'Emma' and state = 'CA'
  AND gender = 'F'
ORDER BY year;


-- CTEs
-- Which names became popular after the year 2000?
WITH recent_names AS (
  SELECT
      name,
      SUM(number) AS births
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE year >= 2000
  GROUP BY name
)

SELECT *
FROM recent_names
WHERE births > 50000
ORDER BY births DESC;

-- Business analytics queries
-- Before vs. After 2010: Rising Baby Names
SELECT
    name,
    SUM(CASE WHEN year BETWEEN 2000 AND 2009 THEN number ELSE 0 END) AS births_2000_2009,
    SUM(CASE WHEN year >= 2010 THEN number ELSE 0 END) AS births_2010_present,
    SUM(CASE WHEN year >= 2010 THEN number ELSE 0 END)
      - SUM(CASE WHEN year BETWEEN 2000 AND 2009 THEN number ELSE 0 END) AS growth
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY name
HAVING births_2000_2009 > 0
   AND births_2010_present > 0
ORDER BY growth DESC
LIMIT 20;
