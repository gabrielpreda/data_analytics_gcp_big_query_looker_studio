# BigQuery basics

This chapter covers the BigQuery concepts needed for the hands-on examples in this repository.

## Learning objectives

By the end of this chapter, you should be able to:

- Explain the difference between BigQuery storage and compute.
- Identify projects, datasets, tables, views, and query jobs.
- Estimate query cost before running a query.
- Read basic query execution information.
- Explain why partitioning and clustering improve performance.
- Find quota and monitoring information.

## BigQuery architecture

BigQuery stores data separately from the compute resources used to query it. You do not create database servers or virtual machines for normal SQL workloads. You create datasets and tables, submit query jobs, and BigQuery allocates the required execution resources.

Important concepts:

- A **project** organizes APIs, billing, permissions, and jobs.
- A **dataset** groups tables and views in one location.
- A **table** stores structured or semi-structured data.
- A **view** stores SQL logic rather than a separate copy of the result.
- A **query job** executes SQL and produces a result.
- A **slot** is a virtual compute unit used by BigQuery to execute work.

## Storage and compute exercise

Use the USA Names or US Census example to compare:

```sql
SELECT *
FROM `bigquery-public-data.usa_names.usa_1910_current`;
```

with a query that selects only the required columns and filters the data:

```sql
SELECT name, gender, year, number
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year >= 2000
LIMIT 1000;
```

Before executing either query, inspect the estimated bytes processed. Observe how selecting fewer columns and filtering earlier can reduce cost and improve performance.

## Query cost and optimization

Use these controls and habits:

- Review the bytes-processed estimate before execution.
- Use a dry run when working from the command line or a client library.
- Set a maximum bytes billed limit for experiments.
- Avoid `SELECT *` in reusable queries.
- Filter partition columns when a table is partitioned.
- Aggregate before joining when the business question does not require row-level detail.
- Check the query execution graph when a query is slow or unexpectedly expensive.
- Use query history to compare cost and runtime.

## Partitioning and clustering

Partitioning divides a table into segments, commonly by a date or timestamp column. A query that filters the partitioning column can scan fewer partitions.

Clustering organizes data within a table or partition according to selected columns. It is useful when queries frequently filter or group by those columns.

Create a small demonstration table rather than running a long performance benchmark:

```sql
CREATE OR REPLACE TABLE `<PROJECT_ID>.usa_names.names_by_year`
PARTITION BY year_date
CLUSTER BY state, gender AS
SELECT
  name, gender, state, year, number,
  DATE(year, 1, 1) AS year_date
FROM `bigquery-public-data.usa_names.usa_1910_current`;
```

Compare a query filtered by `year` with one that scans all years. Choose partitioning and clustering columns according to the columns used most often for filtering and grouping.

## Monitoring and quotas

Review these monitoring and quota concepts without configuring production reservations:

- Query history
- Job details
- Bytes processed
- Slot usage
- Reservations
- Concurrent jobs
- Load and streaming limits
- API quotas
- Dataset and table limits

Use the Google Cloud Console to locate quota information and identify the difference between a quota error and a query-cost problem. Detailed reservation design is optional material.

## Exercises

1. Run one query against USA Names and one against US Census.
2. Estimate the cost before running each query.
3. Create one partitioned and clustered table.
4. Compare the query plan and bytes processed.
5. Record one example of a query that could be made cheaper.

## Further reading

- [BigQuery analytics overview](https://cloud.google.com/bigquery/docs/query-overview)
- [Understand BigQuery slots](https://cloud.google.com/bigquery/docs/slots)
- [BigQuery quotas and limits](https://cloud.google.com/bigquery/quotas)
