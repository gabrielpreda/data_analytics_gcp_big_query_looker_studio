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

### External tables

An external table keeps the data in its original location and exposes it through a BigQuery table definition. It is useful for exploration or when data should remain in Cloud Storage, but native BigQuery tables are usually better for repeated, performance-sensitive analytics.

Compare an external table with a loaded table using the same source file. Record the differences in performance, schema management, freshness, and operational ownership.

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

The Cymbal Pets workflow demonstrates a simple layered architecture:

```text
raw source tables
      ↓
staging tables with standardized fields
      ↓
analytics tables and views
      ↓
Looker Studio and notebooks
```

Not every small project needs three physical datasets. The layers represent different responsibilities:

- Raw data preserves what arrived.
- Staging data cleans names, types, and identifiers.
- Analytics data exposes stable business concepts.

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
- [Pub/Sub to BigQuery Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/pubsub-to-bigquery)
- [Cloud Storage CSV to BigQuery Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/cloud-storage-csv-to-bigquery)
