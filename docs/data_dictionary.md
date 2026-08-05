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

## `fact_orders`

Grain: one row per delivered order.

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
| `is_late_delivery` | Flag: 1 if actual delivery was after estimated delivery date, else 0. |
| `review_score` | Average review score per order. Used because some orders can have more than one review. |
| `total_reviews` | Number of reviews associated with the order. |
| `order_revenue` | Sum of item prices per order. |
| `order_freight` | Sum of freight value per order. |
| `order_total_value` | Item price plus freight per order. |
| `total_items` | Number of items in the order. |

## `fact_order_items`

Grain: one row per item sold inside a delivered order.

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

## Modeling notes

- `fact_orders` is used for order-level KPIs such as total orders, customers, review score, delivery days, and late delivery rate.
- `fact_order_items` is used for item-level and product-level analysis such as revenue by category, seller performance, and item-level freight.
- The two views have different grains and should not be merged without careful aggregation.
