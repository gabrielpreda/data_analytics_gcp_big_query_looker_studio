# Build a US Census Dashboard with Looker Studio

This exercise demonstrates how to build an interactive demographic dashboard using the **US Census** public datasets available in BigQuery.

Example dataset:

```text
bigquery-public-data.census_bureau_usa.population_by_zip_2010
```

The dashboard combines demographic data with geographic information to produce state and county level analytics.

---

## Learning Objectives

During this exercise you will learn how to:

- Connect Looker Studio to BigQuery
- Build analytical views
- Join multiple datasets
- Prepare dashboard-ready data
- Create geographic dashboards
- Analyze demographic trends

---

# Data Preparation

Rather than connecting Looker Studio directly to the raw Census table, create analytical views that simplify reporting.

---

## View 1 — Population by ZIP Code

```sql
CREATE OR REPLACE VIEW `<PROJECT_ID>.us_census.population_zip_vw` AS

SELECT
    zipcode,
    state_code,
    gender,
    minimum_age,
    maximum_age,
    population
FROM
`bigquery-public-data.census_bureau_usa.population_by_zip_2010`;
```

Purpose

- Base analytical view
- Source for all other views

---

## View 2 — Population by State

```sql
CREATE OR REPLACE VIEW `<PROJECT_ID>.us_census.population_state_vw` AS

SELECT
    state_code,
    SUM(population) AS total_population
FROM
`bigquery-public-data.census_bureau_usa.population_by_zip_2010`
GROUP BY state_code;
```

Purpose

- State rankings
- Geo maps
- KPI calculations

---

## View 3 — Population by Age Group

```sql
CREATE OR REPLACE VIEW `<PROJECT_ID>.us_census.population_age_vw` AS

SELECT
    CONCAT(minimum_age,'-',maximum_age) AS age_group,
    gender,
    SUM(population) population
FROM
`bigquery-public-data.census_bureau_usa.population_by_zip_2010`
GROUP BY
age_group,
gender;
```

Purpose

- Population pyramid
- Age analysis
- Gender comparisons

---

## View 4 — ZIP Geography

Create a lookup table (or use another public dataset) that maps ZIP Codes to:

```text
ZIP Code

↓

County

↓

State
```

Example

```sql
SELECT
    zipcode,
    county_name,
    state_name
FROM
zip_lookup;
```

Join this table with the population view to create:

```text
population_dashboard_vw
```

Fields:

- ZIP Code
- County
- State
- Population
- Gender
- Age Group

This becomes the primary Looker Studio data source.

---

# Open Looker Studio

Navigate to

```text
https://lookerstudio.google.com
```

Create

```text
Create → Report
```

---

# Connect BigQuery

Select

```text
BigQuery
```

Dataset

```text
us_census
```

View

```text
population_dashboard_vw
```

---

# Dashboard KPIs

Create scorecards

### Total Population

```text
SUM(population)
```

### Number of States

```text
COUNT_DISTINCT(state_name)
```

### Number of Counties

```text
COUNT_DISTINCT(county_name)
```

### Number of ZIP Codes

```text
COUNT_DISTINCT(zipcode)
```

---

# Visualizations

## Population by State

Chart

```text
Geo Map
```

Dimension

```text
state_name
```

Metric

```text
SUM(population)
```

---

## Population by County

Chart

```text
Horizontal Bar Chart
```

Dimension

```text
county_name
```

Metric

```text
SUM(population)
```

Sort

```text
SUM(population) DESC
```

---

## Largest ZIP Codes

Chart

```text
Table
```

Dimensions

```text
zipcode

county_name

state_name
```

Metric

```text
population
```

Sort

```text
population DESC
```

---

## Population by Age Group

Chart

```text
Stacked Bar Chart
```

Dimension

```text
age_group
```

Breakdown

```text
gender
```

Metric

```text
SUM(population)
```

---

## Gender Distribution

Chart

```text
Pie Chart
```

Dimension

```text
gender
```

Metric

```text
SUM(population)
```

---

## Top States

Chart

```text
Bar Chart
```

Dimension

```text
state_name
```

Metric

```text
SUM(population)
```

Limit

```text
10
```

---

# Dashboard Filters

Add:

- State
- County
- ZIP Code
- Gender
- Age Group

---

# Suggested Dashboard Layout

## Row 1

- Total Population
- States
- Counties
- ZIP Codes

## Row 2

- Population by State
- Gender Distribution

## Row 3

- Population by County
- Population by Age Group

## Row 4

- Largest ZIP Codes
- Geographic Map

---

# Example Business Questions

The dashboard should answer questions such as:

- Which states have the largest population?
- Which counties are the most populated?
- Which ZIP Codes contain the largest populations?
- How is the population distributed by age?
- How does the gender distribution vary by state?
- Which counties have the highest concentration of children?
- Which states have the largest senior population?

---

# Possible Extensions

- Population density by county
- Interactive county drill-down
- Choropleth maps
- Population growth analysis
- AI-generated demographic summaries using Gemini