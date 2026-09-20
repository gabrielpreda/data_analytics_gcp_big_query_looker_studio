# BigQuery notebooks

This folder contains Jupyter notebooks that query BigQuery, load results into pandas DataFrames, and create visualizations with matplotlib.

The notebooks combine:

- GoogleSQL for querying data
- Python for analysis and calculations
- pandas for local tabular analysis
- matplotlib for charts
- BigQuery tables and views for reusable results

## Notebooks

### USA Names

[usa_names_analysis.ipynb](usa_names_analysis.ipynb) uses the public table:

```text
bigquery-public-data.usa_names.usa_1910_current
```

The notebook:

- Inspects the table schema and row count
- Calculates total births and unique names by year
- Finds the most popular names
- Plots selected name trends over time
- Compares births and unique names by state
- Optionally writes the yearly result to a BigQuery table

This notebook can be run without creating a source dataset because the USA Names table is public. Query jobs still use your Google Cloud project as the billing project.

### Cymbal Pets

[cymbal_pets_analysis.ipynb](cymbal_pets_analysis.ipynb) uses the tables created by the [Cymbal Pets module](../cymbal_pets/README.md):

```text
cymbal_pets.customers
cymbal_pets.orders
cymbal_pets.order_items
cymbal_pets.products
```

The notebook:

- Checks that the source tables exist
- Creates or replaces customer and product analytical views
- Calculates customer metrics
- Analyzes revenue by state
- Analyzes revenue and units sold by product category
- Identifies products with low inventory and recorded sales
- Optionally writes customer segments to BigQuery

Complete the Cymbal Pets loading instructions before opening this notebook.

## Requirements

You need:

- A Google Cloud project with billing enabled
- The BigQuery API enabled
- Permission to create query jobs in the project
- Permission to read the source tables
- Permission to create views and tables in the destination dataset when using the Cymbal Pets notebook
- A Python notebook environment such as BigQuery Studio, Jupyter, or Colab

The notebooks install these Python packages in their first cell:

```text
google-cloud-bigquery
db-dtypes
pandas
matplotlib
```

## Authentication and project configuration

The notebooks create a BigQuery client using one of these environment variables:

```text
GOOGLE_CLOUD_PROJECT
BIGQUERY_PROJECT
```

Set one of them before running the notebook if the environment does not already provide the active project.

For local development, authenticate with Application Default Credentials:

```bash
gcloud auth application-default login
```

In Cloud Shell, the Google Cloud environment is normally already authenticated. Authorize Cloud Shell if prompted.

## Running a notebook

1. Open the notebook in BigQuery Studio, Jupyter, or Colab.
2. Select a Python kernel or runtime.
3. Set the project environment variable if necessary.
4. Run the package-installation cell.
5. Run the remaining cells from top to bottom.
6. Review the query results and charts.

The Cymbal Pets notebook creates these views as part of its normal workflow:

```text
cymbal_pets.customer_analytics_vw
cymbal_pets.product_analytics_vw
```

## Writing results to BigQuery

The final write cells are disabled by default. Each notebook defines:

```python
WRITE_RESULTS = False
```

Change it to `True` only when you want to create or replace the destination table. The destination table names are:

```text
usa_names.births_by_year_notebook
cymbal_pets.customer_segments_notebook
```

Make sure the destination dataset exists and that your account has permission to create or replace tables before enabling result writing.

## SQL and Python responsibilities

The notebooks use BigQuery for filtering, joining, aggregating, and reading the source data. They use pandas for smaller result sets and Python-based calculations or visualizations.

Keep large source data in BigQuery. Download only the result needed for local analysis, and check the query size before running expensive queries.

Reusable transformations should remain in BigQuery views or tables. Notebook-specific exploration and charts can remain in Python cells.

## Notebook analysis and Looker Studio

Use the notebooks to explore data and test analytical ideas. Use the corresponding Looker Studio examples to share recurring dashboards:

- [USA Names dashboard](../looker_studio_usa_names/README.md)
- [Cymbal Pets dashboard](../looker_studio_cymbal_pets/README.md)

The notebooks can create or inspect the same analytical views used by the dashboards.

## Next steps

- Add filters for state, gender, category, or date.
- Create a monthly revenue analysis for Cymbal Pets.
- Save a notebook result and connect it to Looker Studio.
- Add BigQuery DataFrames as an alternative Python interface.
- Use Gemini in BigQuery to generate one of the SQL queries, then validate it against the notebook result.

## Further reading

- [Introduction to BigQuery notebooks](https://cloud.google.com/bigquery/docs/notebooks-introduction)
- [BigQuery Python client libraries](https://cloud.google.com/bigquery/docs/reference/libraries)
- [Application Default Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc)
