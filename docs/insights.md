# Insights

This document will collect business findings from the Olist E-commerce BI Analytics dashboard.

## Validated baseline metrics

| Metric | Value |
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

## Sales and category performance

Initial SQL validation showed that the top revenue categories are:

1. health_beauty
2. watches_gifts
3. bed_bath_table
4. sports_leisure
5. computers_accessories

These categories should be highlighted in the Sales & Category Performance dashboard page.

## Geographic performance

The highest-revenue customer states are:

1. SP
2. RJ
3. MG
4. RS
5. PR

The state of SP strongly concentrates order volume and revenue.

## Delivery and customer experience

Delivery performance has a strong relationship with review score:

| Delivery status | Total orders | Avg review score | Avg delivery days | Avg order revenue |
|---|---:|---:|---:|---:|
| On-time delivery | 69,383 | 4.29 | 10.40 | 136.42 |
| Late delivery | 5,976 | 2.56 | 30.94 | 146.91 |

Initial interpretation:

> Late deliveries are associated with substantially lower customer satisfaction.

This should be one of the central insights in the final dashboard.
