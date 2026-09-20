# Build a USA Names Dashboard with Looker Studio

This exercise demonstrates how to build an interactive Looker Studio dashboard using the BigQuery public dataset **USA Names**.

Dataset:

```text
bigquery-public-data.usa_names.usa_1910_current
```

The dataset contains baby names registered in the United States since 1910, including:

- Name
- Gender
- State
- Year
- Number of births

This dashboard visualizes name popularity, gender distribution, state-level trends, and rising names over time.

---

## Learning Objectives

During this exercise you will learn how to:

- Connect Looker Studio to BigQuery
- Use BigQuery views as dashboard data sources
- Visualize aggregations and trends
- Filter dashboards by year, state, gender and name
- Compare name popularity over time
- Present SQL analytics results visually

---

## Recommended BigQuery Views

Before building the dashboard, create several views in BigQuery that prepare the data for Looker Studio.

---

### View 1: Name Popularity by Year

```sql
CREATE OR REPLACE VIEW `<PROJECT_ID>.usa_names.name_popularity_by_year_vw` AS
SELECT
  name,
  gender,
  state,
  year,
  SUM(number) AS total_births
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY name, gender, state, year;
```

Use this view for:

- Time series charts
- Name trend analysis
- State and gender filters

---

### View 2: Most Popular Names

```sql
CREATE OR REPLACE VIEW `<PROJECT_ID>.usa_names.most_popular_names_vw` AS
SELECT
  name,
  SUM(number) AS total_births
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY name;
```

Use this view for:

- Top names bar charts
- Name ranking tables

---

### View 3: Male vs Female Name Popularity

```sql
CREATE OR REPLACE VIEW `<PROJECT_ID>.usa_names.gender_name_comparison_vw` AS
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
  COALESCE(m.name, f.name) AS name,
  IFNULL(m.male_births, 0) AS male_births,
  IFNULL(f.female_births, 0) AS female_births,
  IFNULL(m.male_births, 0) + IFNULL(f.female_births, 0) AS total_births
FROM male_names m
FULL OUTER JOIN female_names f
ON m.name = f.name;
```

Use this view for:

- Gender comparison charts
- Unisex name analysis
- Male vs female popularity tables

---

### View 4: Rising Names After 2010

```sql
CREATE OR REPLACE VIEW `<PROJECT_ID>.usa_names.rising_names_after_2010_vw` AS
SELECT
  name,
  SUM(CASE WHEN year BETWEEN 2000 AND 2009 THEN number ELSE 0 END) AS births_2000_2009,
  SUM(CASE WHEN year >= 2010 THEN number ELSE 0 END) AS births_2010_present,
  SUM(CASE WHEN year >= 2010 THEN number ELSE 0 END)
    - SUM(CASE WHEN year BETWEEN 2000 AND 2009 THEN number ELSE 0 END) AS growth
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY name
HAVING births_2000_2009 > 0
   AND births_2010_present > 0;
```

Use this view for:

- Rising names analysis
- Before vs after comparison
- Business-style trend reporting

---

## Step 1: Open Looker Studio

Navigate to:

```text
https://lookerstudio.google.com
```

Click:

```text
Create → Report
```

---

## Step 2: Connect to BigQuery

1. Select **BigQuery**
2. Choose your project
3. Select the dataset:

```text
usa_names
```

4. Select the main view:

```text
name_popularity_by_year_vw
```

5. Click **Add**
6. Click **Add to Report**

---

## Dashboard KPIs

Create scorecards for:

### Total Births

Metric:

```text
SUM(total_births)
```

### Unique Names

Metric:

```text
COUNT_DISTINCT(name)
```

### Number of States

Metric:

```text
COUNT_DISTINCT(state)
```

### Latest Year

Metric:

```text
MAX(year)
```

---

## Visualizations

### Births Over Time

Chart type:

```text
Time Series
```

Dimension:

```text
year
```

Metric:

```text
SUM(total_births)
```

Purpose:

```text
Shows how the number of registered names changes over time.
```

---

### Most Popular Names

Chart type:

```text
Bar Chart
```

Data source:

```text
most_popular_names_vw
```

Dimension:

```text
name
```

Metric:

```text
total_births
```

Sort:

```text
total_births DESC
```

Limit:

```text
10
```

---

### Popularity of a Selected Name Over Time

Chart type:

```text
Line Chart
```

Dimension:

```text
year
```

Metric:

```text
SUM(total_births)
```

Filter:

```text
name
```

Example:

```text
Emma
```

Purpose:

```text
Shows how a specific name changes in popularity over time.
```

---

### Male vs Female Popularity

Chart type:

```text
Stacked Bar Chart
```

Data source:

```text
gender_name_comparison_vw
```

Dimension:

```text
name
```

Metrics:

```text
male_births
female_births
```

Sort:

```text
total_births DESC
```

Limit:

```text
20
```

---

### Top States by Births

Chart type:

```text
Geo Chart or Bar Chart
```

Dimension:

```text
state
```

Metric:

```text
SUM(total_births)
```

---

### Rising Names After 2010

Chart type:

```text
Table or Bar Chart
```

Data source:

```text
rising_names_after_2010_vw
```

Dimensions:

```text
name
```

Metrics:

```text
births_2000_2009
births_2010_present
growth
```

Sort:

```text
growth DESC
```

Limit:

```text
20
```

---

## Filters

Add controls for:

- Year
- State
- Gender
- Name

Recommended filters:

```text
Year Range Control
State Drop-down
Gender Drop-down
Name Search Box
```

---

## Suggested Dashboard Layout

### Row 1 — KPI Scorecards

- Total Births
- Unique Names
- States
- Latest Year

### Row 2 — Trends

- Births Over Time
- Popularity of Selected Name Over Time

### Row 3 — Rankings

- Most Popular Names
- Top States by Births

### Row 4 — Comparisons

- Male vs Female Popularity
- Rising Names After 2010

---

## Example Questions

The dashboard should help answer:

- What were the most popular baby names overall?
- What were the most popular names in a specific year?
- How did the popularity of Emma change over time?
- Which names are popular for both boys and girls?
- Which names became more popular after 2010?
- Which states registered the highest number of births?

---

## Possible Extensions

- Top names by decade
- Top names by state
- Name ranking over time
- Female vs male naming trends
- AI-generated dashboard summaries using Gemini