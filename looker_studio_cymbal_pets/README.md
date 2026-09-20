# Build a Cymbal Pets Dashboard with Looker Studio

This guide walks you through creating an interactive dashboard in Looker Studio using data stored in BigQuery for the Cymbal Pets dataset.

---

## Prerequisites

Before starting, ensure that:

- You have access to Google Cloud Platform (GCP)
- The Cymbal Pets dataset is available in BigQuery
- The following tables exist:

```text
customers
orders
order_items
products
```

- The following views have been created:

```text
customer_analytics_vw
product_analytics_vw
```

---

## Dashboard Objectives

The dashboard will answer questions such as:

- How many customers do we have?
- Who are the top customers?
- Which products generate the most revenue?
- Which products sell the most units?
- Which states generate the most revenue?
- Which products may face inventory shortages?

---

## Step 1: Open Looker Studio

Navigate to:

https://lookerstudio.google.com

Click:

```text
Create → Report
```

---

## Step 2: Connect to BigQuery

1. Select **BigQuery**
2. Choose your project
3. Select dataset:

```text
cymbal_pets
```

4. Select view:

```text
customer_analytics_vw
```

5. Click **Add**
6. Click **Add to Report**

---

## Step 3: Add Customer KPI Scorecards

Add four scorecards.

### Total Customers

Metric:

```text
COUNT_DISTINCT(customer_id)
```

### Total Revenue

Metric:

```text
SUM(total_revenue)
```

### Total Orders

Metric:

```text
SUM(total_orders)
```

### Average Order Value

Metric:

```text
AVG(avg_order_value)
```

---

## Step 4: Revenue by State

Insert a Geo Chart.

Dimension:

```text
address_state
```

Metric:

```text
SUM(total_revenue)
```

Title:

```text
Revenue by State
```

---

## Step 5: Top Customers Table

Insert a Table.

Dimensions:

```text
customer_name
address_state
loyalty_member
```

Metrics:

```text
total_orders
total_revenue
avg_order_value
```

Sort by:

```text
total_revenue DESC
```

Limit:

```text
10
```

---

## Step 6: Add Product Analytics Data Source

Navigate to:

```text
Resource → Manage Added Data Sources
```

Add:

```text
product_analytics_vw
```

---

## Step 7: Top Revenue Products

Insert a Bar Chart.

Dimension:

```text
product_name
```

Metric:

```text
total_revenue
```

Sort:

```text
total_revenue DESC
```

Limit:

```text
10
```

---

## Step 8: Most Sold Products

Insert a Horizontal Bar Chart.

Dimension:

```text
product_name
```

Metric:

```text
units_sold
```

Sort:

```text
units_sold DESC
```

Limit:

```text
10
```

---

## Step 9: Revenue by Category

Insert a Pie Chart.

Dimension:

```text
category
```

Metric:

```text
SUM(total_revenue)
```

---

## Step 10: Inventory Risk Analysis

Insert a Table.

Dimensions:

```text
product_name
brand
category
```

Metrics:

```text
inventory_level
units_sold
total_revenue
```

Filter:

```text
inventory_level < 50
```

Sort:

```text
units_sold DESC
```

---

## Step 11: Add Dashboard Filters

### Customer State Filter

Dimension:

```text
address_state
```

### Product Category Filter

Dimension:

```text
category
```

### Loyalty Member Filter

Dimension:

```text
loyalty_member
```

---

## Step 12: Add Date Range Control

Insert:

```text
Date Range Control
```

Date field:

```text
order_date
```

---

## Suggested Dashboard Layout

### Row 1 — KPIs

- Total Customers
- Total Revenue
- Total Orders
- Average Order Value

### Row 2

- Revenue by State
- Revenue by Category

### Row 3

- Top Customers
- Top Revenue Products

### Row 4

- Most Sold Products
- Low Inventory Products

### Top Filters

- Date Range
- State
- Category
- Loyalty Member

---

## Example Business Questions

### Top Customers

```sql
SELECT *
FROM customer_analytics_vw
ORDER BY total_revenue DESC
LIMIT 10;
```

### Top Products

```sql
SELECT *
FROM product_analytics_vw
ORDER BY total_revenue DESC
LIMIT 10;
```

### Revenue by State

```sql
SELECT
    address_state,
    SUM(total_revenue) AS revenue
FROM customer_analytics_vw
GROUP BY address_state
ORDER BY revenue DESC;
```

### Inventory Risk

```sql
SELECT
    product_name,
    inventory_level,
    units_sold
FROM product_analytics_vw
WHERE inventory_level < 50
ORDER BY units_sold DESC;
```

---

## Next Steps

Possible enhancements:

- Customer Lifetime Value (CLV)
- Monthly Revenue Trends
- Product Recommendation Analytics
- Customer Segmentation
- Inventory Forecasting
- AI-powered insights using BigQuery and Gemini