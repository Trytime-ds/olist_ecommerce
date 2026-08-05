# Olist E-commerce BI Analytics

End-to-end Business Intelligence project using the Olist Brazilian E-commerce dataset. The goal is to transform raw ecommerce data into a validated analytical model and an interactive Power BI dashboard focused on sales performance, customer experience, and delivery performance.

## Business objective

Answer the following business question:

> Which categories, regions, sellers, and delivery conditions explain ecommerce revenue, customer satisfaction, and operational issues?

The project is designed as a BI/Analytics portfolio case for Data Analyst, BI Analyst, Customer Analytics, and Digital Analytics roles.

## Dataset

Source: Olist Brazilian E-commerce Public Dataset.

Main entities used:

- Orders
- Order items
- Customers
- Products
- Sellers
- Payments
- Reviews
- Product category translation

Raw data files are not versioned in this repository. Download the original dataset from Kaggle and load it locally into PostgreSQL.

## Tools

- PostgreSQL
- DBeaver
- SQL
- Python / pandas for CSV troubleshooting and review-text loading support
- Power BI
- DAX
- GitHub documentation

## Workflow

```text
Raw CSV files
   ↓
PostgreSQL database
   ↓
Data quality checks
   ↓
SQL analytical views
   ↓
Power BI data model
   ↓
DAX measures
   ↓
Dashboard pages
   ↓
Business insights
```

## Analytical layer

Two main SQL views were created:

### `fact_orders`

Grain: one row per order.

Used for:

- Total orders
- Total customers
- Revenue at order level
- Average order value
- Delivery days
- Late delivery flag
- Review score
- Customer state analysis

### `fact_order_items`

Grain: one row per item sold inside an order.

Used for:

- Revenue by product category
- Revenue by seller
- Items sold
- Freight value by item
- Category performance
- Seller performance

## Validated KPIs

After correcting duplicated orders caused by multiple reviews per order, the validated baseline metrics were:

| KPI | Value |
|---|---:|
| Total orders | 96,478 |
| Total customers | 93,358 |
| Total revenue | 13,224,700 |
| Average order value | 137.04 |
| Average freight value | 22.79 |
| Average total order value | 159.83 |
| Average delivery days | 12.09 |
| Average review score | 4.15 |
| Late delivery rate | 8.11% |

Revenue was also cross-validated between `fact_orders` and `fact_order_items`, with only a minimal difference likely caused by floating-point precision in imported `real` fields.

## Initial business findings

- The highest-revenue categories include `health_beauty`, `watches_gifts`, `bed_bath_table`, `sports_leisure`, and `computers_accessories`.
- Revenue is strongly concentrated in the state of `SP`, followed by `RJ` and `MG`.
- Late deliveries have a much lower average review score than on-time deliveries:
  - On-time delivery: average review score 4.29, average delivery days 10.40
  - Late delivery: average review score 2.56, average delivery days 30.94

## Power BI model

Current model:

```text
Calendar
   ↓
fact_orders
   ↓
fact_order_items
```

Recommended active relationships:

- `Calendar[Date]` 1:* `fact_orders[purchase_date]`
- `fact_orders[order_id]` 1:* `fact_order_items[order_id]`

A direct `Calendar` relationship to `fact_order_items` was avoided in the first version to reduce ambiguous filter paths.

## Planned dashboard pages

1. Executive Overview
2. Sales & Category Performance
3. Customer Experience
4. Delivery & Logistics
5. Seller Performance

## Repository structure

```text
.
├── README.md
├── .gitignore
├── sql/
│   ├── 01_setup_and_data_quality.sql
│   ├── 02_create_views.sql
│   └── 03_business_validation_queries.sql
├── docs/
│   ├── data_dictionary.md
│   ├── project_workflow.md
│   └── insights.md
├── powerbi/
│   └── README.md
├── notebooks/
│   └── README.md
└── images/
    └── .gitkeep
```

## Status

```text
[✓] Download dataset
[✓] Create PostgreSQL database
[✓] Import main tables
[✓] Resolve loading issues
[✓] Rename tables
[✓] Review data types
[✓] Create fact_orders
[✓] Create fact_order_items
[✓] Validate base metrics
[✓] Connect Power BI
[✓] Create calendar table
[✓] Create DAX measures
[✓] Validate Power BI measures
[ ] Design dashboard
[ ] Document insights
```
