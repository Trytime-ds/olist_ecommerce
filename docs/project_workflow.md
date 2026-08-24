# Project Workflow

This document summarizes the final workflow followed in the Olist E-commerce BI Analytics project, from raw CSV ingestion to business recommendations.

## 1. Data acquisition

The project uses the Olist Brazilian E-commerce Public Dataset. Original CSV files were downloaded locally and loaded into PostgreSQL.

## 2. Database setup

A local PostgreSQL database was created and managed with DBeaver.

Main raw entities:

- `orders`
- `order_items`
- `customers`
- `products`
- `sellers`
- `order_payments`
- `order_reviews`
- `category_translation`

## 3. Loading issues and fixes

The `order_reviews` file presented loading problems because free-text comments contained long strings, quotes, special characters, multiline text, and encoding inconsistencies.

The table was created manually with safer types:

- `TEXT` for IDs/comments
- `INT` for review score
- `TIMESTAMP` for review dates

Review comments still contained encoding artifacts in some records. Because the BI scope uses structured review fields rather than NLP, this issue was documented and treated as non-blocking.

## 4. Data quality checks

Before modeling, the project checked:

- Row counts
- Order-status distribution
- Date ranges
- NULL values in critical dates
- Review-score distribution
- Column data types
- Duplicate keys
- Revenue consistency

## 5. Analytical modeling in SQL

Two views were created with explicit grains.

### `fact_orders`

**Grain:** one row per delivered order.

`order_items` and `order_reviews` are aggregated to `order_id` before joining, preventing order duplication caused by multiple items or multiple reviews.

Used for:

- Order/customer KPIs
- Order revenue
- Reviews
- Delivery dates
- Delivery duration
- Customer geography

### `fact_order_items`

**Grain:** one row per item sold inside a delivered order.

Built from order items joined with order, customer, product, category translation, and seller information.

Used for:

- Category analysis
- Seller analysis
- Item-level revenue
- Freight
- Items sold

## 6. SQL business validation

The analytical layer was validated before Power BI using:

- View row counts
- Duplicate checks
- Revenue comparison across grains
- Executive KPI checks
- Monthly revenue
- Category revenue
- Geographic revenue
- Review distribution
- Delivery/review comparison
- Seller-level validation using distinct seller-order pairs

The main purpose of this stage was to confirm that each KPI respected the correct analytical grain.

## 7. Power BI connection

Power BI connects to PostgreSQL using **Import Mode**.

Imported views:

- `fact_orders`
- `fact_order_items`

The PBIX therefore stores an imported analytical snapshot while PostgreSQL remains the upstream analytical source.

## 8. Semantic model

Final model:

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

Single-direction filtering was maintained to avoid ambiguous filter paths.

The report uses a Year slicer across the final pages. Category dimensions are kept on item-grain visuals rather than used as a global filter for order-grain customer/logistics measures.

## 9. Power BI calculated columns

Important semantic columns include:

### `Delivery Status`

Classifies orders as:

- `On-time delivery`
- `Late delivery`
- `Unknown`

Orders missing actual or estimated delivery dates are classified as `Unknown` before evaluating the late-delivery flag.

### `Delay Days`

Calculates days beyond the estimated delivery date, returning 0 for on-time/early deliveries and blank when required dates are unavailable.

These columns support denominator-safe delivery KPIs.

## 10. DAX metric design

Measures were organized in a dedicated `_Measures` table.

Main measure groups:

### Executive / sales

- Revenue
- Total Freight
- Total Orders
- Total Customers
- Average Order Value
- Items Sold
- Category Orders
- Category AOV
- Average Item Price
- Revenue Share

### Customer experience

- Reviewed Orders
- Review Coverage
- Positive Review Orders
- Positive Review Rate
- Average Review Score
- Low Review Orders
- Low Review Rate

### Delivery / logistics

- Known Delivery Orders
- Late Orders
- Late Delivery Rate
- On-Time Orders
- On-Time Delivery Rate
- Average Delivery Days
- Average Delay Days Late

### Seller performance

- Total Sellers
- Seller Orders
- Seller AOV
- Seller Late Orders
- Seller Known Delivery Orders
- Seller Late Delivery Rate
- Seller Average Review Score
- Average Revenue per Seller

## 11. Cross-grain seller measures

Seller attributes live in `fact_order_items`, while review and delivery fields live in `fact_orders`.

To avoid bidirectional model relationships, seller order IDs are transferred explicitly to the order-grain table with DAX `TREATAS`.

Pattern:

```DAX
VAR SellerOrderIDs =
    VALUES(fact_order_items[order_id])
RETURN
    CALCULATE(
        [Order Grain Measure],
        TREATAS(
            SellerOrderIDs,
            fact_orders[order_id]
        )
    )
```

`VALUES(order_id)` ensures that multiple items from the same seller inside one order do not duplicate the order-level review or delivery outcome.

## 12. Dashboard pages

The completed report contains five portfolio pages:

1. **Executive Overview** — revenue, orders, customers, AOV, review score, delivery rate, category and state concentration.
2. **Sales & Category Performance** — category revenue, order volume, items, ticket, price, freight, and revenue share.
3. **Customer Experience** — review coverage, review distribution, positive/low-review rates, and delivery-status comparison.
4. **Delivery & Logistics** — known deliveries, late/on-time rates, delay severity, monthly trend, and state-level delivery performance.
5. **Seller Performance** — seller revenue, volume, AOV, reviews, delivery performance, and seller risk/value comparison.

A separate validation page was used during development and is hidden from the portfolio report.

## 13. Final QA

The report was reviewed for:

- Correct DAX denominators
- Correct category and seller context
- Order/item grain consistency
- Seller `TREATAS` logic
- Review coverage handling
- Known vs. unknown delivery dates
- Rate formatting
- Year filter behavior
- Naming consistency
- Low-volume bias in state-level delay rankings

For geographic late-delivery rankings, a minimum threshold of **500 known deliveries** is applied so that very small markets do not dominate the ranking purely through unstable percentages.

## 14. Business interpretation

The final analysis was consolidated into six executive insights:

1. Delivery delay is the strongest identified customer-experience risk.
2. Logistics prioritization should combine rate and absolute affected volume.
3. Seller management should combine commercial value and operational quality.
4. Different category economics require different commercial playbooks.
5. Low observed purchase frequency creates a CRM/retention opportunity.
6. Temporary delivery deterioration supports proactive peak-capacity planning.

See `docs/insights.md` for evidence, recommended actions, KPIs, sensitivity scenarios, and analytical limitations.

## 15. Final output

The project ends with:

- Validated SQL analytical views
- Reproducible SQL QA queries
- Power BI semantic model
- Five-page Power BI dashboard
- Final executive insights
- Actionable business recommendations
- GitHub portfolio documentation
