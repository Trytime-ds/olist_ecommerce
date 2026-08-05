# Power BI

This folder documents the Power BI layer of the Olist E-commerce BI Analytics project.

## Connection

Power BI connects to PostgreSQL using import mode.

Imported analytical views:

- `fact_orders`
- `fact_order_items`

## Model

Recommended model:

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

## Calendar table

DAX table:

```DAX
Calendar =
CALENDAR(
    MIN(fact_orders[purchase_date]),
    MAX(fact_orders[purchase_date])
)
```

Recommended columns:

```DAX
Year = YEAR('Calendar'[Date])
Month Number = MONTH('Calendar'[Date])
Month Name = FORMAT('Calendar'[Date], "MMM")
Year Month = FORMAT('Calendar'[Date], "YYYY-MM")
Quarter = "Q" & FORMAT('Calendar'[Date], "Q")
```

## Core DAX measures

```DAX
Revenue =
SUM(fact_order_items[price])

Freight Revenue =
SUM(fact_order_items[freight_value])

Total Revenue Incl Freight =
SUM(fact_order_items[total_item_value])

Total Orders =
DISTINCTCOUNT(fact_orders[order_id])

Total Customers =
DISTINCTCOUNT(fact_orders[customer_unique_id])

Average Order Value =
DIVIDE([Revenue], [Total Orders])

Items Sold =
COUNTROWS(fact_order_items)

Average Review Score =
AVERAGE(fact_orders[review_score])

Low Review Orders =
CALCULATE(
    [Total Orders],
    fact_orders[review_score] <= 2
)

Low Review Rate =
DIVIDE([Low Review Orders], [Total Orders])

Average Delivery Days =
AVERAGE(fact_orders[delivery_days])

Late Orders =
CALCULATE(
    [Total Orders],
    fact_orders[is_late_delivery] = 1
)

Late Delivery Rate =
DIVIDE([Late Orders], [Total Orders])

On-Time Orders =
CALCULATE(
    [Total Orders],
    fact_orders[is_late_delivery] = 0
)
```

## Planned dashboard pages

1. Executive Overview
2. Sales & Category Performance
3. Customer Experience
4. Delivery & Logistics
5. Seller Performance

## Notes

The `.pbix` file is not versioned by default because Power BI files can become large. Screenshots can be added to the `images/` folder for portfolio presentation.
