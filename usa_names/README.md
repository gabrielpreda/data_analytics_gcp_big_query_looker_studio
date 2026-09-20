# USA Names Analytics with BigQuery

This module introduces BigQuery SQL using the **USA Names** public dataset.

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

It is an excellent dataset for learning SQL because it is easy to understand while still containing millions of records.

---

## Contents

### 1. usa-names-getting-started.sql

Introduces the dataset and demonstrates basic SQL operations.

Topics:

- Explore the dataset
- Inspect table structure
- Simple SELECT statements
- Filtering with WHERE
- Sorting results
- Limiting output

Learning objectives:

- Become familiar with BigQuery SQL
- Explore a public dataset
- Understand the available columns

---

### 2. usa-names-create-tables.sql

Creates your own datasets and tables based on the public dataset.

Topics:

- Create datasets
- Create tables
- Copy data from public datasets
- Create filtered datasets
- Create views

Learning objectives:

- Work with your own BigQuery objects
- Understand datasets and tables
- Create reusable analytical assets

---

### 3. Analytical queries

The analytical queries are included in `usa-names-getting-started.sql`. The focused ranking example is in [usa-names-most-frequent-name-per-state.sql](usa-names-most-frequent-name-per-state.sql).

Topics:

- Aggregations
- GROUP BY
- HAVING
- Window functions
- Ranking
- Most popular names
- Trends over time
- State analysis

Learning objectives:

- Build analytical queries
- Generate business insights
- Use advanced SQL features

---

### 4. usa-names-update-table.sql

Introduces data manipulation operations.

Topics:

- INSERT
- UPDATE
- DELETE
- MERGE
- CREATE OR REPLACE

Learning objectives:

- Modify BigQuery tables
- Understand DML operations
- Maintain analytical datasets

---

## Skills Covered

- Standard SQL
- Filtering
- Aggregations
- Window Functions
- Views
- DML
- BigQuery Best Practices

This module provides the SQL foundation used throughout the rest of the course.
