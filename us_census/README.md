# US Census Analytics with BigQuery

This module extends the SQL exercises using the **US Census** public datasets available in BigQuery.

Example dataset:

```text
bigquery-public-data.census_bureau_usa.population_by_zip_2010
```

The dataset contains demographic information such as:

- ZIP Code
- State
- Population
- Gender
- Age Groups

Unlike the USA Names dataset, the Census data is well suited for building dashboards and performing demographic analysis.

---

## Contents

### 1. us-census-getting-started.sql

Explore the Census dataset.

Topics:

- Browse the data
- Inspect schemas
- Basic SELECT queries
- Filtering
- Sorting

Learning objectives:

- Understand the Census dataset
- Explore demographic information
- Practice basic SQL

---

### 2. us-census-create-tables.sql

Create reusable analytical datasets.

Topics:

- Create datasets
- Create tables
- Copy public data
- Create analytical views
- Create dashboard-ready tables

Learning objectives:

- Prepare data for analytics
- Build reusable BigQuery objects
- Create views for reporting

---

### 3. us-census-analysis.sql

Perform demographic analysis.

Topics:

- Population by State
- Population by ZIP Code
- Age distributions
- Gender distributions
- Ranking
- Window functions
- Summary statistics

Learning objectives:

- Analyze demographic data
- Practice analytical SQL
- Prepare datasets for visualization

---

### 4. us-census-update-table.sql

Work with user-managed Census tables.

Topics:

- INSERT
- UPDATE
- DELETE
- MERGE
- Refresh analytical tables

Learning objectives:

- Maintain analytical datasets
- Practice DML operations
- Prepare production-ready tables

---

## Suggested Looker Studio Dashboards

The analytical views created in this module can be connected directly to Looker Studio.

Example dashboards include:

- Population by State
- Population by ZIP Code
- Age Distribution
- Gender Distribution
- Top 20 Largest ZIP Codes
- Geographic Population Maps

---

## Skills Covered

- BigQuery SQL
- Aggregations
- Views
- Window Functions
- Demographic Analytics
- Dashboard Preparation
- Looker Studio Integration

This module complements the USA Names exercises and provides richer analytical scenarios for reporting and visualization.