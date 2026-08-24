# Olist E-commerce BI Analytics

End-to-end Business Intelligence portfolio project built with the Olist Brazilian E-commerce dataset. The project transforms raw marketplace data into a validated PostgreSQL analytical layer and a five-page Power BI dashboard focused on revenue, category performance, customer experience, delivery reliability, and seller management.

## Business objective

Answer the following business question:

> Which categories, regions, sellers, and delivery conditions explain ecommerce revenue, customer satisfaction, and operational risk — and what actions could improve commercial and operational performance?

The project is designed as a BI / Data Analytics case for Data Analyst, BI Analyst, Customer Analytics, and Digital Analytics roles.

## Business questions

- Which categories and regions generate the most revenue?
- Is category performance driven by volume, ticket size, or both?
- How strongly are delivery delays associated with customer satisfaction?
- Where are logistics problems concentrated geographically and over time?
- Which sellers combine commercial value with strong operational performance?
- Which actions should be prioritized to improve revenue, customer experience, and marketplace operations?

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

Raw data files are intentionally not versioned in this repository.

## Tech stack

- PostgreSQL
- DBeaver
- SQL
- Python / pandas for CSV troubleshooting and review-text loading support
- Power BI
- Power Query
- DAX
- Git / GitHub

## End-to-end workflow

```text
Raw CSV files
   ↓
PostgreSQL database
   ↓
Data quality checks
   ↓
SQL analytical views
   ↓
Power BI Import Mode
   ↓
Semantic model + Calendar
   ↓
DAX measures and calculated columns
   ↓
Dashboard QA
   ↓
Business insights and recommendations
```

## Analytical model

Two main SQL views define stable analytical grains.

### `fact_orders`

**Grain:** one row per delivered order.

Used for:

- Total orders and customers
- Order revenue and AOV
- Delivery dates and delivery duration
- Late-delivery analysis
- Review score and review coverage
- Customer geography

### `fact_order_items`

**Grain:** one row per item sold inside a delivered order.

Used for:

- Product and category revenue
- Items sold
- Seller attribution
- Freight value
- Category and seller performance

### Power BI model

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

A direct Calendar relationship to `fact_order_items` was avoided to reduce ambiguous filter paths. Seller measures that require order-level delivery or review data use explicit order-ID context transfer with DAX `TREATAS`.

## Validated baseline KPIs

| KPI | Value |
|---|---:|
| Total orders | 96.48K |
| Total customers | 93.36K |
| Product revenue | 13.22M |
| Average order value | 137.04 |
| Items sold | 110.20K |
| Average delivery days | 12.09 |
| Average review score | 4.15 |
| Review coverage | 78.11% |
| Positive review rate | ~78.9% |
| Late delivery rate | 8.11% |
| Average delay when late | 8.87 days |
| Total sellers | 2.97K |

Revenue was cross-validated between order- and item-grain views. A minimal difference is expected because source price and freight fields were imported as floating-point values.

## Dashboard

The final Power BI report contains five analytical pages.

### 1. Executive Overview

Executive KPIs, monthly revenue trend, leading categories, and geographic revenue concentration.

### 2. Sales & Category Performance

Category revenue, order volume, items sold, category AOV, average item price, freight value, and revenue share.

### 3. Customer Experience

Review coverage, positive/low review rates, review distribution, and the relationship between delivery status and customer satisfaction.

### 4. Delivery & Logistics

Known deliveries, late orders, on-time rate, delay severity, monthly delivery performance, and state-level logistics performance. State rankings use a minimum-volume threshold to avoid over-prioritizing very small markets.

### 5. Seller Performance

Seller revenue, order volume, AOV, delivery reliability, review score, and a seller volume vs. late-delivery scatterplot.

## Executive insights

### 1. Delivery delays are the strongest identified customer-experience risk

Late deliveries have an average review score of **2.56** versus **4.29** for on-time deliveries. Their low-review rate is **54.13%** versus **9.27%** for on-time deliveries — approximately **5.8x higher**.

**Business implication:** reducing late deliveries should be treated as a customer-experience initiative, not only a logistics metric.

### 2. Logistics prioritization should combine rate and absolute affected volume

The overall late-delivery rate is approximately **8.1%**, but performance varies substantially by state. Some markets have high late rates but moderate volume, while large markets can generate many affected customers even with a lower rate.

**Business implication:** prioritize markets using both `Late Delivery Rate` and `Late Orders`, rather than ranking only by percentages.

### 3. Seller management should combine commercial value and operational quality

Leading sellers reach similar revenue through very different combinations of order volume and AOV. Some high-revenue sellers also show above-average delivery risk, while others combine high value with strong delivery performance.

**Business implication:** seller management should use a scorecard combining revenue, orders, AOV, late-delivery rate, and review score instead of ranking sellers only by revenue.

### 4. Different category economics require different commercial playbooks

The top five categories generate roughly **40%** of product revenue and the top ten approximately **62%**, but their revenue drivers differ:

- `health_beauty`: high volume + healthy ticket
- `watches_gifts`: lower volume + high ticket
- `bed_bath_table`: volume-driven
- `furniture_decor`: relatively more items per category order

**Business implication:** category strategy should vary between availability protection, conversion, basket expansion, bundles, and cross-sell depending on the category economics.

### 5. Low observed purchase frequency creates a CRM opportunity

96.48K orders across 93.36K unique customers implies approximately **1.03 observed orders per customer** in the dataset window.

**Business implication:** customer lifecycle analysis should investigate second-purchase opportunities using recency, frequency, monetary value, category, delivery experience, and review behavior.

### 6. Delivery performance deteriorates during specific periods

The monthly logistics trend contains clear temporary spikes in late-delivery rate, especially around late 2017 and early 2018.

**Business implication:** operational planning should investigate whether demand peaks, seller capacity, or regional logistics constraints explain these periods and build a peak-readiness process.

## Recommended actions

### A. Late Delivery Prevention & Recovery Program

- Identify orders at risk before the estimated delivery date.
- Escalate risk with seller/logistics operations.
- Use proactive customer communication when delay becomes likely.
- Track both frequency (`Late Delivery Rate`) and severity (`Average Delay Days Late`).

A 10% reduction in late orders would correspond to roughly **783 fewer delayed orders**. Using observed low-review rates as a sensitivity scenario, this could represent approximately **350 fewer low-review experiences** if those orders behaved like the current on-time group. This is a scenario, not a causal forecast.

### B. Seller Performance Scorecard

Segment sellers using:

- Commercial value: Revenue, Orders, AOV
- Operational quality: Late Delivery Rate, Average Delay
- Customer experience: Review Score, Low Review Rate
- Scale: Number of affected orders

Suggested management groups:

- High value + good operations → Protect / Grow
- High value + poor operations → Fix urgently
- Lower value + good operations → Develop
- Lower value + poor operations → Monitor / deprioritize

### C. Category & CRM Growth Engine

- Protect inventory and service levels in high-value/high-volume categories.
- Use conversion and premium merchandising for high-ticket categories.
- Test bundles and cross-sell for categories with stronger item-per-order behavior.
- Build customer lifecycle segments and prioritize second-purchase campaigns after positive experiences.
- Use service recovery before commercial win-back for customers affected by late delivery.

## QA and modeling controls

The project includes explicit checks for:

- Correct analytical grain
- Duplicate orders/items
- Revenue consistency across views
- Review coverage and denominator definitions
- Known vs. unknown delivery status
- Minimum-volume controls in geographic rate rankings
- Seller attribution across item- and order-grain tables
- Non-additive distinct counts such as seller/category orders

## Analytical limitations

- Review coverage is approximately 78%, so satisfaction metrics describe reviewed orders rather than every order.
- Review and delivery outcomes are defined at order grain. Orders containing multiple sellers can associate the same order-level experience with more than one seller; seller metrics therefore represent orders associated with each seller, not exclusive causal responsibility.
- `Category AOV` represents category revenue divided by orders containing that category, not necessarily the full basket value of multi-category orders.
- The dashboard is descriptive/diagnostic. Strong relationships such as delivery delay vs. review score should not be interpreted as causal estimates without additional analysis.
- The dataset window limits conclusions about long-term retention and customer lifetime value.

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
    └── README.md
```

## Project status

```text
[✓] Data acquisition and loading
[✓] PostgreSQL database setup
[✓] Data quality validation
[✓] Analytical SQL views
[✓] Business validation queries
[✓] Power BI semantic model
[✓] DAX measures and calculated columns
[✓] Five-page dashboard
[✓] Seller / delivery / customer-experience QA
[✓] Executive insights
[✓] Business recommendations
[✓] Portfolio documentation
```

The Power BI `.pbix` file is kept local by default and excluded through `.gitignore`. Final dashboard screenshots are stored separately in `images/` for portfolio presentation.