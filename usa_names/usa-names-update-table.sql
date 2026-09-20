-- update the table data
UPDATE `usa_names.usa_sample`
SET number = CAST(1 + RAND()*200 AS INT64)
WHERE RAND() < 0.05;

-- check Texas
SELECT SUM(number)
FROM  `usa_names.usa_sample`
WHERE state = 'TX';
