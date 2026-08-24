# Data Dictionary

This document describes the main analytical objects used in the Olist E-commerce BI Analytics project.

## Source tables

| Table | Description |
|---|---|
| `orders` | Order-level information, order status, and key dates. |
| `order_items` | Item-level order detail, product, seller, price, and freight. |
| `customers` | Customer identifiers and customer location. |
| `products` | Product metadata and product category. |
| `sellers` | Seller identifiers and seller location. |
| `order_payments` | Payment type, installments, and payment value. |
| `order_reviews` | Review score, review comments, and review timestamps. |
| `category_translation` | Portuguese-to-English product category translation. |

## Analytical views

### `fact_orders`

**Grain:** one row per delivered order.

| Column | Description |
|---|---|
| `order_id` | Unique order identifier. |
| `customer_id` | Customer identifier associated with the order. |
| `customer_unique_id` | Unique customer identifier. |
| `customer_city` | Customer city. |
| `customer_state` | Customer state. |
| `order_status` | Order status. The analytical view keeps delivered orders only. |
| `purchase_date` | Order purchase date. |
| `approved_date` | Order approval date. |
| `delivered_carrier_date` | Date when the order was delivered to the carrier. |
| `delivered_customer_date` | Date when the order was delivered to the customer. |
| `estimated_delivery_date` | Estimated customer delivery date. |
| `delivery_days` | Days between purchase and actual customer delivery. |
| `is_late_delivery` | SQL flag: 1 if actual delivery was after estimated delivery date, else 0. |
| `review_score` | Average review score per order. Multiple reviews are summarized first at order grain. |
| `total_reviews` | Number of reviews associated with the order. |
| `order_revenue` | Sum of item prices per order. |
| `order_freight` | Sum of freight value per order. |
| `order_total_value` | Item price plus freight per order. |
| `total_items` | Number of order-item rows in the order. |

### `fact_order_items`

**Grain:** one row per item sold inside a delivered order.

| Column | Description |
|---|---|
| `order_id` | Order identifier. |
| `order_item_id` | Item sequence inside the order. |
| `product_id` | Product identifier. |
| `product_category_name` | Original product category name in Portuguese. |
| `product_category_name_english` | Product category name translated to English. |
| `seller_id` | Seller identifier. |
| `seller_city` | Seller city. |
| `seller_state` | Seller state. |
| `price` | Item price. |
| `freight_value` | Freight charged for the item. |
| `total_item_value` | Item price plus freight value. |
| `customer_id` | Customer identifier. |
| `customer_unique_id` | Unique customer identifier. |
| `customer_city` | Customer city. |
| `customer_state` | Customer state. |
| `order_status` | Order status. The analytical view keeps delivered orders only. |
| `purchase_date` | Order purchase date. |

## Power BI semantic layer

### Calculated columns in `fact_orders`

| Column | Description |
|---|---|
| `Delivery Status` | Classifies an order as `On-time delivery`, `Late delivery`, or `Unknown`. Missing actual/estimated dates are treated as `Unknown`. |
| `Delay Days` | Number of days actual delivery exceeded the estimated date. Returns 0 for on-time/early orders and blank when required dates are unavailable. |

### Calendar

| Field | Description |
|---|---|
| `Date` | Continuous date key spanning the analytical order period. |
| `Year` | Calendar year. |
| `Month Number` | Numeric month used for sorting. |
| `Month Name` | Month label. |
| `Year Month` | Reporting month label. |
| `Quarter` | Calendar quarter. |
| `Year Month Sort` | Numeric YYYYMM sort key. |

## Main measures

### Executive / sales

| Measure | Definition / interpretation |
|---|---|
| `Revenue` | Sum of `fact_order_items[price]`. |
| `Total Freight` | Sum of item-level freight values. |
| `Total Orders` | Distinct delivered orders. |
| `Total Customers` | Distinct `customer_unique_id`. |
| `Average Order Value` | Revenue / Total Orders. |
| `Items Sold` | Count of rows in `fact_order_items`. |
| `Category Orders` | Distinct orders within the current item/category filter context. |
| `Category AOV` | Category revenue / Category Orders. This is category revenue per order containing the category, not full basket AOV. |
| `Average Item Price` | Average item price in the current context. |
| `Revenue Share` | Category revenue divided by revenue with the category filter removed. |

### Customer experience

| Measure | Definition / interpretation |
|---|---|
| `Reviewed Orders` | Orders with nonblank review score. |
| `Review Coverage` | Reviewed Orders / Total Orders. |
| `Positive Review Orders` | Reviewed orders with score 4–5. |
| `Positive Review Rate` | Positive Review Orders / Reviewed Orders. |
| `Average Review Score` | Mean review score across reviewed orders. |
| `Low Review Orders` | Reviewed orders with score 1–2. |
| `Low Review Rate` | Low Review Orders / Reviewed Orders. |

### Delivery / logistics

| Measure | Definition / interpretation |
|---|---|
| `Known Delivery Orders` | Orders classified as either on-time or late. Unknown delivery status is excluded. |
| `Late Orders` | Orders classified as late delivery. |
| `Late Delivery Rate` | Late Orders / Known Delivery Orders. |
| `On-Time Orders` | Orders classified as on-time. |
| `On-Time Delivery Rate` | On-Time Orders / Known Delivery Orders. |
| `Average Delivery Days` | Average purchase-to-delivery duration. |
| `Average Delay Days Late` | Average positive days beyond estimated delivery date among late orders only. |

### Seller performance

| Measure | Definition / interpretation |
|---|---|
| `Total Sellers` | Distinct sellers in the current item context. |
| `Seller Orders` | Distinct order IDs associated with each seller. |
| `Seller AOV` | Revenue / Seller Orders. |
| `Average Revenue per Seller` | Revenue / Total Sellers in the current context. |
| `Seller Average Review Score` | Order-level review score transferred from seller order IDs to `fact_orders` using `TREATAS`. |
| `Seller Late Orders` | Late order count for the unique order IDs associated with a seller. |
| `Seller Known Delivery Orders` | Known-delivery order count for the unique order IDs associated with a seller. |
| `Seller Late Delivery Rate` | Seller Late Orders / Seller Known Delivery Orders. |

## Modeling notes

- `fact_orders` is used for order-level KPIs such as reviews, delivery performance, customers, and order counts.
- `fact_order_items` is used for item/product/category/seller analysis.
- The two views have different grains and should not be merged without careful aggregation.
- Distinct counts such as Category Orders and Seller Orders are non-additive across categories/sellers.
- Seller review and delivery measures use distinct seller-order IDs with DAX `TREATAS` to preserve order grain without enabling bidirectional model relationships.
- Review coverage is incomplete, so customer-satisfaction rates are explicitly calculated over reviewed orders.
