# Power BI Layer

This folder documents the final Power BI semantic model and dashboard for the Olist E-commerce BI Analytics project.

## Connection and model

Power BI connects to PostgreSQL using Import Mode and imports:

- `fact_orders`
- `fact_order_items`

Final relationship model:

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

Relationships remain single-direction to avoid ambiguous filter paths. The final dashboard uses Year as the shared slicer.

## Calendar

```DAX
Calendar =
CALENDAR(
    MIN(fact_orders[purchase_date]),
    MAX(fact_orders[purchase_date])
)
```

Supporting columns include Year, Month Number, Month Name, Year Month, Quarter, and Year Month Sort.

## Calculated columns

### Delivery Status

```DAX
Delivery Status =
SWITCH(
    TRUE(),
    ISBLANK(fact_orders[delivered_customer_date])
        || ISBLANK(fact_orders[estimated_delivery_date]), "Unknown",
    fact_orders[is_late_delivery] = 1, "Late delivery",
    "On-time delivery"
)
```

### Delay Days

```DAX
Delay Days =
VAR DeliveredDate = fact_orders[delivered_customer_date]
VAR EstimatedDate = fact_orders[estimated_delivery_date]
RETURN
    IF(
        ISBLANK(DeliveredDate) || ISBLANK(EstimatedDate),
        BLANK(),
        MAX(0, DATEDIFF(EstimatedDate, DeliveredDate, DAY))
    )
```

## Sales and category measures

```DAX
Revenue = SUM(fact_order_items[price])

Total Freight = SUM(fact_order_items[freight_value])

Total Orders = DISTINCTCOUNT(fact_orders[order_id])

Total Customers = DISTINCTCOUNT(fact_orders[customer_unique_id])

Average Order Value = DIVIDE([Revenue], [Total Orders])

Items Sold = COUNTROWS(fact_order_items)

Category Orders = DISTINCTCOUNT(fact_order_items[order_id])

Category AOV = DIVIDE([Revenue], [Category Orders])

Average Item Price = AVERAGE(fact_order_items[price])

Revenue Share =
DIVIDE(
    [Revenue],
    CALCULATE(
        [Revenue],
        ALL(fact_order_items[product_category_name_english])
    )
)
```

`Category AOV` means category revenue per order containing that category. It is not necessarily the complete basket AOV for multi-category orders.

## Customer-experience measures

```DAX
Reviewed Orders = COUNT(fact_orders[review_score])

Review Coverage = DIVIDE([Reviewed Orders], [Total Orders])

Positive Review Orders =
CALCULATE(
    [Reviewed Orders],
    KEEPFILTERS(fact_orders[review_score] >= 4)
)

Positive Review Rate = DIVIDE([Positive Review Orders], [Reviewed Orders])

Average Review Score = AVERAGE(fact_orders[review_score])

Low Review Orders =
CALCULATE(
    [Reviewed Orders],
    KEEPFILTERS(fact_orders[review_score] <= 2)
)

Low Review Rate = DIVIDE([Low Review Orders], [Reviewed Orders])
```

Review definitions:

- 1–2: low review
- 3: neutral
- 4–5: positive review

Orders without a review are excluded from satisfaction-rate denominators.

## Delivery measures

```DAX
Known Delivery Orders =
CALCULATE(
    [Total Orders],
    fact_orders[Delivery Status] IN {"On-time delivery", "Late delivery"}
)

Late Orders =
CALCULATE(
    [Total Orders],
    fact_orders[Delivery Status] = "Late delivery"
)

Late Delivery Rate = DIVIDE([Late Orders], [Known Delivery Orders])

On-Time Orders =
CALCULATE(
    [Total Orders],
    fact_orders[Delivery Status] = "On-time delivery"
)

On-Time Delivery Rate = DIVIDE([On-Time Orders], [Known Delivery Orders])

Average Delivery Days = AVERAGE(fact_orders[delivery_days])

Average Delay Days Late =
CALCULATE(
    AVERAGE(fact_orders[Delay Days]),
    fact_orders[Delivery Status] = "Late delivery"
)
```

The state-level late-delivery ranking applies a minimum threshold of 500 known deliveries before comparing rates.

## Seller measures and cross-grain filtering

```DAX
Total Sellers = DISTINCTCOUNT(fact_order_items[seller_id])

Seller Orders = DISTINCTCOUNT(fact_order_items[order_id])

Seller AOV = DIVIDE([Revenue], [Seller Orders])

Average Revenue per Seller = DIVIDE([Revenue], [Total Sellers])
```

Seller attributes are item-grain while review and delivery outcomes are order-grain. Instead of enabling bidirectional relationships, seller measures transfer the distinct order IDs to `fact_orders` using `TREATAS`.

```DAX
Seller Average Review Score =
VAR SellerOrderIDs = VALUES(fact_order_items[order_id])
RETURN
    CALCULATE(
        [Average Review Score],
        TREATAS(SellerOrderIDs, fact_orders[order_id])
    )
```

```DAX
Seller Late Orders =
VAR SellerOrderIDs = VALUES(fact_order_items[order_id])
RETURN
    CALCULATE(
        [Late Orders],
        TREATAS(SellerOrderIDs, fact_orders[order_id])
    )
```

```DAX
Seller Known Delivery Orders =
VAR SellerOrderIDs = VALUES(fact_order_items[order_id])
RETURN
    CALCULATE(
        [Known Delivery Orders],
        TREATAS(SellerOrderIDs, fact_orders[order_id])
    )
```

```DAX
Seller Late Delivery Rate =
DIVIDE([Seller Late Orders], [Seller Known Delivery Orders])
```

Using `VALUES(order_id)` prevents multiple item rows from duplicating the weight of one order-level review or delivery outcome.

## Final dashboard pages

1. Executive Overview
2. Sales & Category Performance
3. Customer Experience
4. Delivery & Logistics
5. Seller Performance

A development validation page is kept hidden from the portfolio-facing report.

## Final QA

The final QA checked:

- Revenue and order consistency
- Category AOV filter context
- Review coverage and review-rate denominators
- Known-delivery denominators
- Seller `TREATAS` measures
- Low-volume bias in state rankings
- Year slicer behavior
- KPI naming, percentages, and visible K/M formatting

## Portfolio note

The `.pbix` file remains excluded through `.gitignore`. Dashboard screenshots are intended to be stored in `images/` so the final report can be reviewed without Power BI Desktop.
