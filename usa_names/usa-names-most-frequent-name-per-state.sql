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