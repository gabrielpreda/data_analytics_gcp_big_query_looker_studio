# Build an AI-ready analytics dataset

## Prerequisites

### 1. Configuration and environment

User roles:

* roles/bigquery.user (for running queries)
* roles/bigquery.dataViewer (for accessing data)
* roles/serviceusage.serviceUsageAdmin (for enabling apis)
* roles/iam.oauthClientViewer (oAuth)
* roles/iam.serviceAccountViewer (oAuth)
* roles/oauthconfig.editor (oAuth)

### 2. Project & auth config

Open GCP Console. In the Console, run the following commands.
```bash
BIGQUERY_PROJECT=PROJECT_ID
​
gcloud config set project ${BIGQUERY_PROJECT}
gcloud auth application-default login
```


### 3. User roles and APIs

In the console, run the following commands.

```bash
gcloud services enable bigquery.googleapis.com --project=${BIGQUERY_PROJECT}
```

### 4. Load sample dataset

In the console, run the following command.

```bash
# Create the dataset if it doesn't exist (pick a location of your choice)
# You can add --default_table_expiration to auto expire tables.
bq --project_id=${BIGQUERY_PROJECT} mk -f --dataset --location=US cymbal_pets

# Load the data
for table in products customers orders order_items; do 
bq --project_id=${BIGQUERY_PROJECT} query --nouse_legacy_sql \
    "LOAD DATA OVERWRITE cymbal_pets.${table} FROM FILES(
        format = 'avro',
        uris = [ 'gs://sample-data-and-media/cymbal-pets/tables/${table}/*.avro']);"
done
```

### 4. Explore the source tables

Select BigQuery | Studio in the hamburger menu.  
check that there is the database `cymbal_pets` available.
Inspect the tables in the dataset. Verify that the tables:  
- customers
- order_items
- orders
- products 

are available.


### 5. Create views

* Create a customer analytics view: [customer-analytics-view.sql](customer-analytics-view.sql) 
* Create a product sales view: [product-analytics-view.sql](product-analytics-view.sql)


### 6. Validate data quality

Here are some queries to validate data quality: [data-quality.sql](data-quality.sql)  


### 7. Test business queries

Here are some basic business queries: [business-queries.sql](business-queries.sql)



