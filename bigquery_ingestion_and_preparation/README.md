# BigQuery ingestion and data preparation

This chapter explains how data arrives in BigQuery and how raw data becomes trustworthy, reusable analytical data. The Cymbal Pets example is the main exercise.

## Learning objectives

By the end of this chapter, you should be able to:

- Choose an ingestion method for a simple analytics workload.
- Describe the difference between native and external tables.
- Recognize common BigQuery input formats.
- Explain batch versus streaming ingestion.
- Describe where Dataflow fits in an ingestion architecture.
- Separate raw, staging, and analytical data.
- Validate data before exposing it to a dashboard.

## Ingestion choices

### Direct BigQuery load

Use a BigQuery load job for a controlled batch file. This is the simplest option for CSV, JSON, Avro, and Parquet files in Cloud Storage.

Typical workflow:

```text
source file → Cloud Storage → BigQuery load job → native BigQuery table
```

Review:

- Explicit schema versus schema autodetection
- Append versus overwrite
- Compression
- Bad records
- File naming and source tracking

### Direct CSV load with an explicit schema

The following example loads a local CSV file into a native BigQuery table. Replace the placeholders with your project, bucket, and file names.

Create a CSV file named `customers.csv` with a header row:

```csv
customer_id,first_name,last_name,email,gender,address_city,address_state,loyalty_member
1001,Ana,Popescu,ana@example.com,F,Bucharest,B,true
1002,John,Smith,john@example.com,M,Seattle,WA,false
1003,Maria,Ionescu,maria@example.com,F,Cluj,CJ,true
```

Then create `customers_schema.json`:

```json
[
  {"name": "customer_id", "type": "STRING", "mode": "REQUIRED"},
  {"name": "first_name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "last_name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "email", "type": "STRING", "mode": "NULLABLE"},
  {"name": "gender", "type": "STRING", "mode": "NULLABLE"},
  {"name": "address_city", "type": "STRING", "mode": "NULLABLE"},
  {"name": "address_state", "type": "STRING", "mode": "NULLABLE"},
  {"name": "loyalty_member", "type": "BOOL", "mode": "NULLABLE"}
]
```

Upload the files to Cloud Storage and load the CSV into BigQuery:

```bash
export PROJECT_ID="PROJECT_ID"
export REGION="US"
export BUCKET="${PROJECT_ID}-ingestion"
export DATASET="ingestion_demo"
export TABLE="customers_raw"

gcloud config set project "${PROJECT_ID}"
gcloud storage buckets create "gs://${BUCKET}" --location="${REGION}"
gcloud storage cp customers.csv customers_schema.json "gs://${BUCKET}/customers/"

bq --location="${REGION}" mk --dataset "${PROJECT_ID}:${DATASET}"
bq --location="${REGION}" load \
  --replace \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --schema=customers_schema.json \
  "${PROJECT_ID}:${DATASET}.${TABLE}" \
  "gs://${BUCKET}/customers/customers.csv"
```

Check the loaded table:

```sql
SELECT *
FROM `<PROJECT_ID>.ingestion_demo.customers_raw`
ORDER BY customer_id;
```

The explicit schema prevents BigQuery from guessing field types. It also makes the load reproducible and documents the expected structure of the file.

### Direct load from a Cloud Storage file

For the Cymbal Pets Avro files, the repository uses a BigQuery load query:

```sql
LOAD DATA OVERWRITE `<PROJECT_ID>.cymbal_pets.products`
FROM FILES(
  format = 'AVRO',
  uris = ['gs://sample-data-and-media/cymbal-pets/tables/products/*.avro']
);
```

Use `LOAD DATA OVERWRITE` when the destination should be rebuilt from the source files. Use an append or incremental process when existing rows must be preserved.


### External tables

An external table keeps the data in its original location and exposes it through a BigQuery table definition. BigQuery reads the source file when you query the external table; the rows are not copied into native BigQuery storage.

External tables are useful for exploration or when data should remain in Cloud Storage. Native BigQuery tables are usually better for repeated, performance-sensitive analytics.

#### CSV external table with an explicit schema

The CSV file from the direct-load example is already stored at:

```text
gs://${BUCKET}/customers/customers.csv
```

Create an external table by declaring the column types in the table definition:

```sql
CREATE OR REPLACE EXTERNAL TABLE `<PROJECT_ID>.ingestion_demo.customers_csv_external` (
  customer_id STRING,
  first_name STRING,
  last_name STRING,
  email STRING,
  gender STRING,
  address_city STRING,
  address_state STRING,
  loyalty_member BOOL
)
OPTIONS(
  format = 'CSV',
  uris = ['gs://<BUCKET>/customers/customers.csv'],
  skip_leading_rows = 1
);
```

Query the external table like a native table:

```sql
SELECT
  address_state,
  COUNT(*) AS customer_count,
  COUNTIF(loyalty_member) AS loyalty_customer_count
FROM `<PROJECT_ID>.ingestion_demo.customers_csv_external`
GROUP BY address_state
ORDER BY customer_count DESC;
```

The external table uses the schema in the SQL definition. It does not use the local `customers_schema.json` file from the `bq load` example, so keep the two schemas consistent when both objects refer to the same CSV file.

#### Avro external table for Cymbal Pets

Avro files contain their schema, so BigQuery can infer the external table schema from the files:

```sql
CREATE OR REPLACE EXTERNAL TABLE `<PROJECT_ID>.cymbal_pets.products_avro_external`
OPTIONS(
  format = 'AVRO',
  uris = ['gs://sample-data-and-media/cymbal-pets/tables/products/*.avro']
);
```

Inspect the inferred schema and query the external table:

```sql
SELECT *
FROM `<PROJECT_ID>.cymbal_pets.products_avro_external`
LIMIT 20;
```

To compare the external and native versions of the Cymbal Pets products data:

```sql
SELECT 'external' AS source, COUNT(*) AS row_count
FROM `<PROJECT_ID>.cymbal_pets.products_avro_external`

UNION ALL

SELECT 'native' AS source, COUNT(*) AS row_count
FROM `<PROJECT_ID>.cymbal_pets.products`;
```

The external and native tables can return the same data, but they have different storage and performance characteristics. Use the external table for exploration and the native table for repeated transformations, joins, dashboards, and workloads that need predictable performance.

Compare an external table with a loaded table using the same source file. Check the schema, query results, bytes processed, freshness, and operational ownership.

### Multiple file formats

Compare these formats:

| Format | Main consideration |
| --- | --- |
| CSV | Familiar, but schema and escaping can be ambiguous |
| JSON | Semi-structured fields and nested data |
| Avro | Explicit schema and the format used by Cymbal Pets |
| Parquet | Columnar storage and efficient analytical reads |

## Cymbal Pets: the hands-on ingestion example

The existing [Cymbal Pets module](../cymbal_pets) loads Avro files from Cloud Storage and creates four source tables:

- `customers`
- `orders`
- `order_items`
- `products`

Complete the following sequence:

1. Create the `cymbal_pets` dataset.
2. Load the Avro files.
3. Inspect schemas and row counts.
4. Run the data-quality queries.
5. Check for orphan orders, orphan order items, and missing customer data.
6. Create customer and product analytical views.
7. Run business questions against the views.

## Raw, staging, and analytics layers

Use the CSV load above to create a small three-layer pipeline. Each layer has a different purpose:

| Layer | Object | Purpose |
| --- | --- | --- |
| Raw | `ingestion_demo.customers_raw` | Preserve the loaded CSV values and source schema |
| Staging | `ingestion_demo.customers_staging` | Clean strings, normalize codes, and cast types |
| Analytics | `ingestion_demo.customer_summary_vw` | Expose business-ready metrics for analysis and dashboards |

### Create the datasets

```sql
CREATE SCHEMA IF NOT EXISTS `<PROJECT_ID>.ingestion_demo`
OPTIONS(location = 'US');
```

### Raw layer

The raw table is created by the CSV load command. Keep the raw values unchanged so that the original ingestion can be inspected or reprocessed.

```sql
SELECT *
FROM `<PROJECT_ID>.ingestion_demo.customers_raw`;
```

### Staging layer

Create a cleaned table from the raw table. This example trims text, normalizes email and state values, and converts the customer identifier to an integer.

```sql
CREATE OR REPLACE TABLE `<PROJECT_ID>.ingestion_demo.customers_staging` AS
SELECT
  SAFE_CAST(NULLIF(TRIM(customer_id), '') AS INT64) AS customer_id,
  NULLIF(TRIM(first_name), '') AS first_name,
  NULLIF(TRIM(last_name), '') AS last_name,
  LOWER(NULLIF(TRIM(email), '')) AS email,
  UPPER(NULLIF(TRIM(gender), '')) AS gender,
  INITCAP(NULLIF(TRIM(address_city), '')) AS address_city,
  UPPER(NULLIF(TRIM(address_state), '')) AS address_state,
  loyalty_member
FROM `<PROJECT_ID>.ingestion_demo.customers_raw`;
```

Validate the staging table:

```sql
SELECT
  COUNT(*) AS row_count,
  COUNTIF(customer_id IS NULL) AS missing_customer_ids,
  COUNTIF(email IS NULL) AS missing_emails,
  COUNTIF(address_state IS NULL) AS missing_states
FROM `<PROJECT_ID>.ingestion_demo.customers_staging`;
```

### Analytics layer

Create a view that exposes metrics at one row per state:

```sql
CREATE OR REPLACE VIEW `<PROJECT_ID>.ingestion_demo.customer_summary_vw` AS
SELECT
  address_state,
  COUNT(*) AS customer_count,
  COUNTIF(loyalty_member) AS loyalty_customer_count,
  COUNT(DISTINCT gender) AS gender_count
FROM `<PROJECT_ID>.ingestion_demo.customers_staging`
GROUP BY address_state;
```

Query the analytics view:

```sql
SELECT *
FROM `<PROJECT_ID>.ingestion_demo.customer_summary_vw`
ORDER BY customer_count DESC;
```

The same pattern applies to the Cymbal Pets tables:

```text
raw customers, orders, order_items, products
        ↓
cleaned staging tables
        ↓
customer and product analytical views
        ↓
notebooks and Looker Studio
```

Keep reusable business logic in the analytics layer. Keep exploratory calculations in notebooks and presentation-specific calculations in Looker Studio.


## Incremental preparation

Use `MERGE` to implement incremental processing:

- Insert new records.
- Update changed records.
- Avoid rebuilding a large table unnecessarily.
- Add an ingestion timestamp.
- Track the source file or source system.

The existing USA Names and Census update scripts demonstrate DML. For production-style incremental processing, also review keys, duplicates, late-arriving records, and idempotency.

## Streaming ingestion and Dataflow

Streaming can be represented with this architecture without implementing a full custom pipeline:

```text
event producer → Pub/Sub → Dataflow → BigQuery events table
```

Dataflow is useful when data needs transformation, validation, routing, windowing, or scalable processing before it reaches BigQuery.

Try this demonstration:

- Generate JSON web or IoT events.
- Publish them to Pub/Sub.
- Use a Google-provided Pub/Sub-to-BigQuery template.
- Send malformed records to a dead-letter table.
- Create a simple dashboard over the resulting table.

## Additional exercises

- Load the same data as CSV and Parquet.
- Create an external table over a Cloud Storage file.
- Add an ingestion timestamp and source-file column.
- Create a staging table with standardized field names.
- Convert a full-refresh query into an incremental `MERGE`.
- Sketch a Dataflow pipeline without implementing custom Beam code.

## Further reading

- [BigQuery load data](https://cloud.google.com/bigquery/docs/loading-data)
- [External tables](https://cloud.google.com/bigquery/docs/external-tables)
- [Create Cloud Storage external tables](https://cloud.google.com/bigquery/docs/external-data-cloud-storage)
- [Pub/Sub to BigQuery Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/pubsub-to-bigquery)
- [Cloud Storage CSV to BigQuery Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/cloud-storage-csv-to-bigquery)
