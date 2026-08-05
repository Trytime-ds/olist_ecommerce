# Project Workflow

This document summarizes the workflow followed in the Olist E-commerce BI Analytics project.

## 1. Data acquisition

The project uses the Olist Brazilian E-commerce Public Dataset. The original CSV files were downloaded from Kaggle and imported into a local PostgreSQL database.

## 2. Database setup

A local PostgreSQL database was created and managed with DBeaver. CSV files were imported into raw tables.

Main raw entities:

- orders
- order_items
- customers
- products
- sellers
- order_payments
- order_reviews
- category_translation

## 3. Loading issues and fixes

The `order_reviews` file presented text-related loading issues because review comments contained long strings, special characters, quotes, and encoding inconsistencies.

The solution was to create the `order_reviews` table manually using safer types:

- `TEXT` for IDs and comments
- `INT` for review score
- `TIMESTAMP` for review dates

The free-text review comments presented encoding artifacts. The first version of the BI dashboard focuses on structured fields such as `review_score`, order dates, delivery flags, and revenue.

## 4. Data quality checks

Before creating analytical views, several checks were performed:

- Row counts by table
- Order status distribution
- Purchase date range
- Null checks in important dates
- Review score distribution
- Data type review through `information_schema.columns`

## 5. Analytical modeling in SQL

Two analytical views were created.

### `fact_orders`

One row per delivered order. Built by summarizing `order_items` at `order_id` level and summarizing `order_reviews` at `order_id` level before joining with orders and customers.

This avoided duplicate orders caused by multiple reviews for the same order.

### `fact_order_items`

One row per item sold inside a delivered order. Built by joining order items with orders, customers, products, category translation, and sellers.

## 6. Business validation

The analytical views were validated through:

- Row counts
- Duplicate checks
- Revenue comparison between `fact_orders` and `fact_order_items`
- Executive KPIs
- Top categories by revenue
- Top states by revenue
- Delivery delay impact on review score

## 7. Power BI model

Power BI was connected to PostgreSQL using import mode.

Current recommended model:

```text
Calendar
   ↓
fact_orders
   ↓
fact_order_items
```

Active relationships:

- `Calendar[Date]` 1:* `fact_orders[purchase_date]`
- `fact_orders[order_id]` 1:* `fact_order_items[order_id]`

This avoids ambiguous filter paths between Calendar and both fact tables.

## 8. DAX measures

The model includes measures such as:

- Revenue
- Freight Revenue
- Total Revenue Incl Freight
- Total Orders
- Total Customers
- Average Order Value
- Items Sold
- Average Review Score
- Low Review Orders
- Low Review Rate
- Average Delivery Days
- Late Orders
- Late Delivery Rate
- On-Time Orders

## 9. Dashboard design

Planned pages:

1. Executive Overview
2. Sales & Category Performance
3. Customer Experience
4. Delivery & Logistics
5. Seller Performance
