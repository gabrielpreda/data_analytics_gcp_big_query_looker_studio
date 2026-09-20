# BigQuery notebooks and data analytics

This chapter covers notebooks as an exploratory analytics environment. Notebooks complement SQL scripts and Looker Studio rather than replacing them.

## Learning objectives

By the end of this chapter, you should be able to:

- Combine SQL, Python, narrative text, and visualizations.
- Explore a BigQuery table with BigQuery DataFrames.
- Decide when to use SQL and when to use Python.
- Create a small analytical visualization.
- Save a derived result back to BigQuery.

## Notebook workflow

```text
question → SQL exploration → Python analysis → visualization → validated result
```

Start with one notebook. The USA Names dataset is the simplest starting point; Cymbal Pets is the best business example.

## Suggested USA Names notebook

Tasks:

1. Query the public USA Names table.
2. Inspect row counts, year range, and missing values.
3. Calculate total births by year and state.
4. Identify the most popular names.
5. Plot a time series for selected names.
6. Compare two states or genders.

Keep the notebook focused on exploration. The final reusable SQL should still become a view or table in BigQuery.

## Suggested Cymbal Pets notebook

Tasks:

1. Query `customer_analytics_vw` and `product_analytics_vw`.
2. Inspect revenue and order distributions.
3. Identify high-value customers.
4. Compare categories and states.
5. Create one chart with Python.
6. Write a small customer-segment result back to BigQuery.

## SQL and Python together

Use this division of responsibilities:

- Use SQL for filtering, joining, aggregating, and reusable transformations.
- Use Python for exploratory calculations, statistical analysis, and custom visualizations.
- Keep large data in BigQuery instead of downloading it unnecessarily.
- Push final business logic back into views or tables when it must be reused.

## BigQuery DataFrames

BigQuery DataFrames provides a pandas-like interface that executes work against BigQuery. It is useful when you know Python but are not ready to write every transformation in GoogleSQL.

Try these operations:

- Reading a BigQuery table.
- Selecting and filtering columns.
- Grouping and aggregating.
- Plotting a result.
- Writing a result to a BigQuery table.

DataFrames do not remove the need to understand SQL, data grain, query cost, or permissions.

## Notebook visualization versus Looker Studio

| Use a notebook when | Use Looker Studio when |
| --- | --- |
| Exploring an unfamiliar dataset | Sharing a dashboard with others |
| Testing an analytical idea | Providing filters and recurring reports |
| Performing statistical analysis | Presenting governed KPIs |
| Building a one-time visualization | Supporting business users |

## Optional extensions

These topics are optional extensions:

- BigQuery ML
- Forecasting
- Model evaluation
- Geospatial Python libraries
- Automated notebook execution
- Production notebook orchestration

## Further reading

- [Introduction to BigQuery notebooks](https://cloud.google.com/bigquery/docs/notebooks-introduction)
- [BigQuery DataFrames](https://cloud.google.com/bigquery/docs/dataframes-introduction)
