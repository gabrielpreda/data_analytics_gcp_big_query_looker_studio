# Looker Studio reporting and data integration

This chapter explains how to turn BigQuery analytical objects into reports and how to combine data sources responsibly.

## Learning objectives

By the end of this chapter, you should be able to:

- Connect Looker Studio to a BigQuery table or view.
- Build a small dashboard with KPIs, charts, and controls.
- Choose between BigQuery preparation and Looker Studio calculations.
- Blend two data sources using a valid join key.
- Recognize duplicate-row and grain problems.
- Explain credentials, freshness, and query-cost implications.

## Existing dashboard exercises

- [Cymbal Pets dashboard](../looker_studio_cymbal_pets)
- [USA Names dashboard](../looker_studio_usa_names)
- [US Census dashboard](../looker_studio_us_census)

Start with Cymbal Pets for the main dashboard exercise because it contains multiple analytical views and business questions.

## Recommended dashboard workflow

1. Prepare or select a stable BigQuery view.
2. Connect the view to Looker Studio.
3. Add scorecards for the main KPIs.
4. Add one trend, one ranking, and one geographic chart.
5. Add filters and controls.
6. Check aggregation and date behavior.
7. Review data credentials and freshness.
8. Share the report only after validating the numbers.

## BigQuery preparation versus Looker Studio calculations

Prefer BigQuery when the logic is:

- Reusable across several reports.
- Computationally expensive.
- Needed for data quality or security.
- Dependent on complex joins.
- Part of the official business definition.

Prefer Looker Studio when the logic is:

- Specific to one chart or report.
- A simple presentation calculation.
- A filter, parameter, or display transformation.
- Useful for quickly testing a reporting idea.

## Data blending

Looker Studio blends combine multiple sources inside a report. A blend can contain up to five data sources and uses equality-based join conditions.

Recommended exercise:

```text
Cymbal Pets revenue by state
+ Census population by state
= revenue per capita by state
```

Before blending, make sure both sources are aggregated to the same grain:

```text
one row per state in source A
one row per state in source B
one row per state after the blend
```

Review these concepts:

- Join keys
- Left outer join
- Inner join
- Full outer join
- Cross join as a special-case operation
- Missing keys
- Null values
- One-to-many relationships
- Duplicate rows
- Pre-blend and post-blend filters

Blending can produce incorrect totals when the sources have different grains. For example, joining customer-level revenue to order-item-level rows can multiply revenue. Aggregate both sides first or perform the join in BigQuery.

## Other connectors

These connectors are optional extensions:

- Google Sheets for targets or manually maintained reference data
- CSV uploads for small files
- Google Analytics for web activity
- Google Ads for campaign data
- Extracted data sources for performance and freshness trade-offs

A good follow-up exercise is:

```text
BigQuery actual sales + Google Sheets sales targets
```

## Dashboard governance

Review:

- Owner's credentials versus Viewer's credentials
- Data freshness
- Report sharing
- BigQuery query costs caused by refreshes
- Consistent KPI definitions
- Reusable BigQuery views

## Further reading

- [Connect Looker Studio to BigQuery](https://cloud.google.com/looker/docs/studio/connect-to-google-bigquery)
- [How blends work in Looker Studio](https://cloud.google.com/looker/docs/studio/how-blends-work-in-looker-studio)
- [Blending tips and advanced concepts](https://cloud.google.com/looker/docs/studio/blending-tips-and-advanced-concepts)
