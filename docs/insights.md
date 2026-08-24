# Business Insights and Recommendations

This document consolidates the final analytical findings from the Olist E-commerce BI Analytics project. The goal is not only to describe dashboard results, but to translate them into business actions for commercial growth, customer experience, logistics, and marketplace seller management.

## Validated baseline metrics

| Metric | Value |
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

---

## 1. Delivery delays are the strongest identified customer-experience risk

### Evidence

Among reviewed orders:

| Delivery status | Avg review score | Low review rate | Avg delivery days |
|---|---:|---:|---:|
| On-time delivery | 4.29 | 9.27% | 10.40 |
| Late delivery | 2.56 | 54.13% | 30.94 |

Late deliveries therefore show:

- A **1.73-point drop** in average review score.
- A low-review rate approximately **5.8x higher** than on-time deliveries.
- Much longer total delivery duration.
- An average delay of **8.87 days beyond the estimated date** when late.

### Business interpretation

Late delivery is not a marginal operational issue. It identifies a materially different customer experience and is the strongest diagnostic relationship found in the project.

### Recommended action: Late Delivery Prevention & Recovery Program

1. Detect orders at risk before the estimated delivery date.
2. Create an operational queue for seller/logistics escalation.
3. Communicate proactively when a delay becomes likely.
4. Trigger service recovery before sending further commercial campaigns.
5. Track both delay frequency and delay severity.

### Sensitivity scenario

Approximately 7.83K orders are late. A 10% reduction corresponds to roughly **783 fewer delayed orders**. If those orders had the same observed low-review rate as the on-time group, the difference in rates implies roughly **350 fewer low-review experiences**.

This is a sensitivity scenario based on observed group differences, not a causal forecast.

### KPIs to monitor

- Late Delivery Rate
- Late Orders
- Orders at Risk
- Average Delay Days Late
- Low Review Rate by Delivery Status
- Recovery Rate

---

## 2. Logistics prioritization should combine rate and absolute affected volume

### Evidence

The overall late-delivery rate is approximately **8.1%**, but state-level performance varies substantially.

Markets such as MA, CE, BA, RJ, and PA show rates above the global benchmark after applying a minimum-volume threshold. However, a state with the highest percentage does not necessarily create the greatest number of delayed customers.

For example:

- Smaller markets can show very high late rates with moderate absolute volume.
- Large markets such as RJ or SP can generate a large number of delayed orders even with lower rates.

### Business interpretation

Using only percentage rankings can misallocate operational resources. Logistics prioritization should distinguish **severity** from **business impact**.

### Recommended action: State Logistics Priority Matrix

Use two dimensions:

1. `Late Delivery Rate` — relative severity.
2. `Late Orders` / delivery volume — absolute impact.

Suggested prioritization:

| Profile | Action |
|---|---|
| High rate + high/relevant volume | Immediate operational intervention |
| Very high rate + moderate volume | Root-cause investigation |
| Lower rate + very high volume | Incremental optimization at scale |
| High rate + very low volume | Monitor before major intervention |

The dashboard already applies a minimum of 500 known deliveries to the state-rate ranking to reduce low-volume noise.

### KPIs to monitor

- Late Delivery Rate by State
- Late Orders by State
- Known Delivery Orders
- Average Delay Days Late
- Affected Revenue / Revenue at Risk

---

## 3. Seller management should combine commercial value and operational quality

### Evidence

The marketplace contains approximately **2.97K sellers**, while the top 20 generate roughly one-fifth of total product revenue.

Leading sellers can reach similar revenue through very different commercial models:

- Some depend on high order volume and lower AOV.
- Others generate similar revenue with much lower volume and very high AOV.
- Some high-revenue sellers also have above-average late-delivery rates.

Examples visible in the final dashboard include:

- `53243585`: high revenue, very high AOV, low late-delivery rate, strong review score.
- `4a3ca931`: high order volume, lower AOV, above-average late rate, weaker review score.
- `4869f7a5`: top revenue with a late rate above the marketplace average.

### Business interpretation

Revenue alone is insufficient for seller management. A commercially important seller can simultaneously create operational risk.

### Recommended action: Seller Performance Scorecard

Build seller management around four dimensions:

**Commercial value**
- Revenue
- Seller Orders
- Seller AOV

**Operational quality**
- Seller Late Delivery Rate
- Average Delay

**Customer experience**
- Seller Average Review Score
- Low Review Rate

**Scale / risk**
- Orders affected
- Revenue exposed

Suggested management segments:

| Segment | Action |
|---|---|
| High value + good operations | Protect / Grow |
| High value + poor operations | Fix urgently |
| Lower value + good operations | Develop |
| Lower value + poor operations | Monitor / deprioritize |

Potential interventions include seller SLA reviews, targeted corrective plans, operational alerts, and growth support for high-quality sellers.

### Modeling limitation

Review score and delivery status are order-level outcomes. If an order contains multiple sellers, the same order-level experience can be associated with each participating seller. Seller metrics therefore represent the experience of orders associated with a seller, not exclusive causal responsibility.

---

## 4. Different category economics require different commercial playbooks

### Evidence

The top five categories account for roughly **40% of product revenue**, while the top ten account for approximately **62%**.

However, category revenue is produced through different combinations of volume and ticket:

### `health_beauty`

- Revenue: ~1.23M
- Category orders: ~8.65K
- Category AOV: ~142.61

**Profile:** high volume + healthy ticket.

### `watches_gifts`

- Revenue: ~1.17M
- Category orders: ~5.50K
- Category AOV: ~212.23

**Profile:** lower volume + high ticket.

### `bed_bath_table`

- Revenue: ~1.02M
- Category orders: ~9.27K
- Category AOV: ~110.38

**Profile:** strongly volume-driven.

### `furniture_decor`

- Category orders: ~6.31K
- Items sold: ~8.16K

**Profile:** higher items-per-category-order signal than several other leading categories.

### Business interpretation

A single category strategy would ignore the underlying economics. Revenue growth can come from very different levers depending on whether a category is volume-driven, ticket-driven, or has stronger multi-item behavior.

### Recommended action: Category Playbooks

| Category profile | Commercial action |
|---|---|
| High volume + high value | Protect availability and service level; scale selectively |
| High ticket + lower volume | Increase qualified conversion and protect premium experience |
| High volume + lower ticket | Increase basket size, attach rate, and promotional efficiency |
| Higher items/order behavior | Test bundles, recommendations, and cross-sell |

A 1% revenue uplift applied only to the current top-five category revenue base (~5.25M) represents roughly **52.5K** in incremental revenue as a sensitivity scenario; 2% represents roughly **105K**. These values illustrate business leverage rather than forecast performance.

### Modeling note

`Category AOV` is category revenue divided by orders containing that category. It does not represent the complete basket value when an order includes multiple categories.

---

## 5. Low observed purchase frequency creates a CRM and retention opportunity

### Evidence

The dataset contains approximately:

- 96.48K delivered orders
- 93.36K unique customers

This corresponds to roughly **1.03 observed orders per customer** during the available period.

### Business interpretation

The dataset does not support a formal churn conclusion because the observation window is limited. However, the low observed purchase frequency is sufficient to justify deeper customer-lifecycle analysis.

### Recommended action: Customer Lifecycle / CRM Analytics

Segment customers using:

- Recency
- Frequency
- Monetary value
- Category purchased
- Delivery experience
- Review behavior

Suggested CRM logic:

**Positive experience**

On-time delivery + positive review → second-purchase, category cross-sell, or loyalty campaign.

**Negative experience**

Late delivery / low review → service recovery first, commercial win-back second.

### Sensitivity scenario

If just 1% of the 93.36K observed customers generated one incremental purchase at the current average order value of 137.04, the incremental revenue would be approximately **128K**. A 5% scenario would represent approximately **640K**.

These are illustrative scenarios, not retention forecasts.

### KPIs to add in a future CRM layer

- Repeat Purchase Rate
- Orders per Customer
- Time to Second Purchase
- RFM segments
- Revenue from Repeat Customers
- Win-back Conversion Rate

---

## 6. Temporary delivery deterioration supports proactive peak-capacity planning

### Evidence

The monthly dashboard shows periods where late-delivery rate rises materially above its normal range, especially around late 2017 and early 2018. The revenue trend also shows strong expansion through 2017.

### Business interpretation

The descriptive data does not prove that higher demand caused the delivery spikes, but the pattern creates a valuable operational hypothesis: seller or logistics capacity may not scale smoothly during specific demand periods.

### Recommended action: Peak Readiness Framework

Before expected high-volume periods:

1. Forecast orders by state, category, and seller.
2. Compare expected volume against fulfillment capacity.
3. Identify sellers and markets with deteriorating SLA performance.
4. Create threshold-based operational alerts.
5. Review backlog and at-risk orders daily during peak periods.

### KPIs to monitor

- Forecast vs. Actual Orders
- Backlog
- Orders at Risk
- Late Delivery Rate
- Average Delay Days Late
- Seller SLA Compliance

---

# Executive priorities

If management could prioritize only three initiatives from this analysis:

## Priority 1 — Delivery Risk Program

Reduce delayed orders because delay is associated with the largest identified deterioration in customer satisfaction.

## Priority 2 — Seller Performance Management

Manage strategic sellers using commercial value + operational quality rather than revenue alone.

## Priority 3 — Customer & Category Growth Engine

Use category-specific commercial playbooks and customer lifecycle analytics to increase basket value and repeat purchase potential without depending exclusively on acquisition.

---

# Analytical limitations

- Review coverage is approximately 78%, so customer-satisfaction metrics apply to reviewed orders.
- Seller review and delivery metrics use order-level outcomes associated with each seller, not exclusive seller causality.
- Category AOV is category revenue per order containing the category, not complete basket AOV for multi-category orders.
- Geographic rate comparisons require sufficient volume; the final dashboard applies a minimum known-delivery threshold to the state ranking.
- Relationships identified in the dashboard are descriptive/diagnostic and should not be interpreted as causal estimates without additional analysis.
- The dataset observation window limits long-term retention and customer lifetime value conclusions.
