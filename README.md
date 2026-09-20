# Objectives

- 📊 Analyze and process large-scale data with BigQuery
- 🛠️ Build AI-assisted BigQuery workflows and agents
- 🧩 Design multi-agent systems
- 📈 Create interactive analytics dashboards with BigQuery and Looker Studio

# Project setup: BigQuery and Looker Studio

The steps below create a Google Cloud project, connect it to billing, enable the APIs used by this repository, and grant the permissions needed to query and prepare data for Looker Studio.

> **Cost warning:** BigQuery and Looker Studio can generate billable query costs. Looker Studio refreshes can run BigQuery queries automatically. Set a budget alert and avoid selecting `SELECT *` on large tables while experimenting. A budget alert does not stop usage by itself.

## 1. Create a Google Cloud project

1. Sign in to the [Google Cloud Console](https://console.cloud.google.com/).
2. Open **IAM & Admin → Manage resources** and click **Create project**.
3. Enter a project name, for example `da_bq_la`.
4. Choose the organization or folder if your account belongs to one. For a personal account, select **No organization** when that option is available.
5. Click **Create**.
6. Open **Billing → My projects**, find the new project, and copy its **Project ID**. Use the Project ID—not the display name—in commands and BigQuery table references.

Project IDs are globally unique. The project is the container for the APIs, BigQuery datasets, query jobs, permissions, and costs used by this repository. See Google's [project creation documentation](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

## 2. Create or select a Cloud Billing account

1. Open **Billing → Manage billing accounts**.
2. If you do not already have an active billing account, click **Create account** and complete the payments-profile and payment-method steps. If you already have one, select it.
3. Open **Billing → My projects**.
4. Find the project, open its **Actions** menu, choose **Change billing**, select the billing account, and click **Set account**.
5. Confirm that the project shows an active billing account.

An active billing account is required even when using public BigQuery datasets; the billing project pays for query processing. The account used for the project must be in a billable state. See [link a project to a billing account](https://cloud.google.com/billing/docs/how-to/modify-project) and [create a Cloud Billing account](https://cloud.google.com/billing/docs/how-to/create-billing-account).

If you cannot create or attach billing, an administrator must grant you **Billing Account User** (`roles/billing.user`) on the billing account and **Project Billing Manager** (`roles/billing.projectManager`) on the project, or perform the linking for you.

## 3. Select the project and enable the required APIs

Select the new project in the Google Cloud Console. Then enable the BigQuery API from **APIs & Services → Library**, or use one of the command-line options in the next section. The BigQuery API is normally enabled automatically the first time you open BigQuery Studio, but enabling it explicitly makes the setup reproducible.

The BigQuery API is the only API required by the SQL, data-preparation, and Looker Studio exercises in this repository. The `mcp_bigquery` exercise additionally uses the BigQuery MCP endpoint.

## 4. Choose a working environment

Choose either Cloud Shell or a local computer. Both options use the same Google Cloud project and IAM permissions.

### Option A: Cloud Shell

Cloud Shell runs in a browser and includes the Google Cloud CLI (`gcloud`), `bq`, Git, and Python. It is already connected to the Google account used to open it.

1. Click **Activate Cloud Shell** in the Google Cloud Console.
2. Select the project in the Console before opening Cloud Shell, or set it explicitly:

```bash
export PROJECT_ID="PROJECT_ID"
gcloud config set project "${PROJECT_ID}"
gcloud services enable bigquery.googleapis.com --project="${PROJECT_ID}"
```

3. Clone this repository or upload it to the Cloud Shell home directory.
4. Run the SQL and `bq` commands from the relevant module README.
5. If Cloud Shell asks for authorization the first time a command accesses Google Cloud, click **Authorize**.

Cloud Shell is temporary unless files are saved in its persistent home directory. It is convenient for training because participants do not need to install the Google Cloud CLI locally. See Google's [Cloud Shell documentation](https://cloud.google.com/shell/docs).

### Option B: Local computer

On a local computer, install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install), Git, and Python 3. Then run:

```bash
export PROJECT_ID="PROJECT_ID"

gcloud auth login
gcloud config set project "${PROJECT_ID}"
gcloud services enable bigquery.googleapis.com --project="${PROJECT_ID}"
```

The `gcloud auth login` command authenticates the CLI. For Python code or the BigQuery MCP agent, also create local Application Default Credentials:

```bash
gcloud auth application-default login
```

Cloud Shell normally does not require this extra ADC command because its environment is already configured for Google Cloud client libraries. See Google's [ADC documentation](https://cloud.google.com/docs/authentication/provide-credentials-adc).

For the `mcp_bigquery` module, install its Python dependencies from the repository root:

```bash
cd mcp_bigquery
python -m pip install -r requirements.txt
```

Set the project variables before running module commands:

```bash
export GOOGLE_CLOUD_PROJECT="${PROJECT_ID}"
export BIGQUERY_PROJECT="${PROJECT_ID}"
export GOOGLE_CLOUD_LOCATION="europe-west1"  # or another supported region
```

## 5. Grant the required IAM permissions

For a personal learning project, the account that created the project commonly has broad project permissions. For a shared or production project, use the narrower roles below instead of granting `Owner` or `Editor`.

### Permissions for the person running this repository

Grant these roles to your Google account at the **project** level:

| Task | IAM role | Where to grant it |
| --- | --- | --- |
| Run query and load jobs | **BigQuery Job User** (`roles/bigquery.jobUser`) | Billing/query project |
| Enable APIs | **Service Usage Admin** (`roles/serviceusage.serviceUsageAdmin`) | Project; usually only needed during setup |
| Read tables, views, and public datasets | **BigQuery Data Viewer** (`roles/bigquery.dataViewer`) | Each dataset, table, or view that you do not own |
| Create or modify the datasets, tables, and views used by this repo | **BigQuery Data Editor** (`roles/bigquery.dataEditor`) | Your project or the specific working datasets |

For a single-user sandbox, **BigQuery Admin** (`roles/bigquery.admin`) at the project level is simpler and covers BigQuery administration, but it is broader than necessary. Google recommends granting the least-privileged roles needed for the task; see the [BigQuery IAM roles reference](https://cloud.google.com/bigquery/docs/access-control).

To grant a role in the Console:

1. Open **IAM & Admin → IAM** and make sure the new project is selected.
2. Click **Grant access**.
3. Enter the user's Google account email under **New principals**.
4. Select the role under **Assign roles** and click **Save**.
5. Repeat for each role and dataset scope as appropriate.

Alternatively, a project administrator can run:

```bash
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="user:YOUR_EMAIL@example.com" \
  --role="roles/bigquery.jobUser"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="user:YOUR_EMAIL@example.com" \
  --role="roles/bigquery.dataEditor"
```

Do not grant **BigQuery Data Editor** on Google's public datasets. The public dataset owner controls that access. You only need **BigQuery Job User** on your billing project to query them, and you reference them with fully qualified names such as `bigquery-public-data.usa_names.usa_1910_current`.

Keep datasets and queries in compatible locations. For example, a dataset created in `US` should be queried by jobs that can run in `US`; do not mix `US` and `EU` resources accidentally.

## 6. Connect BigQuery to Looker Studio

1. Open [Looker Studio](https://lookerstudio.google.com/) and click **Create → Report**.
2. In **Add data to report**, select the **BigQuery** connector.
3. Choose **My projects** and select the project used for billing and data, or enter its Project ID manually.
4. Select the dataset and table/view, or choose **Custom Query** and use Standard SQL.
5. Click **Add** to attach the data source to the report.
6. When prompted, authorize Looker Studio to use your Google account's BigQuery credentials.

The BigQuery connector can use a table, view, or custom query. For public datasets, select your own project as the **Billing project** and reference the public table in the SQL. Looker Studio queries can incur normal BigQuery charges, including scheduled or automatic data refreshes. See Google's [BigQuery connector documentation](https://cloud.google.com/looker/docs/studio/connect-to-google-bigquery).

By default, a data source can use **Owner's credentials** or **Viewer's credentials**:

- **Owner's credentials**: viewers can use the report without having direct BigQuery access; queries use the data-source owner's authorization. Share the report only with people who should see the returned data.
- **Viewer's credentials**: every viewer must have permission to query the underlying BigQuery data and must authorize the connector.

Use the credential option deliberately, especially if the report contains sensitive data. Granting report access is not automatically the same as granting direct BigQuery access.

## 7. Verify the setup

Run a small test query in **BigQuery Studio**:

```sql
SELECT name, gender, SUM(number) AS total_births
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year >= 2000
GROUP BY name, gender
ORDER BY total_births DESC
LIMIT 10;
```

Then create a Looker Studio report from the same public table or from one of this repository's datasets. If you see `bigquery.jobs.create`, `bigquery.tables.getData`, or billing errors, check respectively:

1. **BigQuery Job User** on the project selected as the billing project.
2. **BigQuery Data Viewer** on the dataset/table, unless it is a public dataset.
3. The project has an active Cloud Billing account and the correct billing project is selected.

## 8. BigQuery MCP agent

The `mcp_bigquery` example also requires **MCP Tool User** (`roles/mcp.toolUser`) in addition to **BigQuery Job User** and **BigQuery Data Viewer**. Enable the remote BigQuery MCP endpoint when using that example:

```bash
gcloud beta services mcp enable bigquery.googleapis.com --project="${PROJECT_ID}"
```

See Google's [BigQuery MCP setup documentation](https://cloud.google.com/bigquery/docs/use-bigquery-mcp).

# Applications

The applications are organized as a short learning path. The chapter READMEs explain the core concepts, hands-on examples, and optional extensions.

## 1. BigQuery basics

| Resource | Description |
|---------|----------|
| [BigQuery basics](bigquery_basics) | Storage and compute, query costs, performance, partitioning, clustering, monitoring, and quotas |

## 2. BigQuery SQL and public data

| Resource | Description |
|---------|----------|
| [USA Names](usa_names) | Learn GoogleSQL, aggregation, window functions, DML, and time-series analysis with `bigquery-public-data.usa_names` |
| [US Census](us_census) | Analyze demographic and ZIP-code data from `bigquery-public-data.census_bureau_usa.population_by_zip_2010` |

## 3. BigQuery ingestion and data preparation

| Resource | Description |
|---------|----------|
| [Ingestion and preparation](bigquery_ingestion_and_preparation) | Batch ingestion, external tables, file formats, streaming concepts, Dataflow, data quality, and analytical layers |
| [Cymbal Pets](cymbal_pets) | Load Avro source files, validate source tables, create analytical views, and run business queries |

## 4. BigQuery notebooks and data analytics

| Resource | Description |
|---------|----------|
| [Notebook analytics](bigquery_notebooks) | SQL and Python notebooks, BigQuery DataFrames, exploratory analysis, and notebook visualizations using the existing datasets |

## 5. Looker Studio

| Resource | Description |
|---------|----------|
| [Looker Studio chapter](looker_studio) | Connectors, dashboard design, credentials, freshness, calculated fields, and data blending |
| [Dashboard - Cymbal Pets](looker_studio_cymbal_pets) | Build a business dashboard from Cymbal Pets analytical views |
| [Dashboard - USA Names](looker_studio_usa_names) | Build a dashboard from USA Names analytical views |
| [Dashboard - US Census](looker_studio_us_census) | Build a demographic and geographic dashboard from Census analytical views |

## 6. Gemini and BigQuery MCP

| Resource | Description |
|---------|----------|
| [Gemini SQL for BigQuery](gemini_bigquery) | Generate, explain, review, optimize, and validate SQL with Gemini in BigQuery |
| [BigQuery MCP agent](mcp_bigquery) | Ask an AI agent to inspect and query BigQuery through the Google BigQuery MCP Server |
