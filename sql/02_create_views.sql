-- =========================================================
-- 02_create_views.sql
-- Olist E-commerce BI Analytics
--
-- Purpose:
-- - Create analytical SQL views for Power BI.
-- - Define stable grains:
--   1. fact_orders: one row per order.
--   2. fact_order_items: one row per item sold inside an order.
-- =========================================================


-- =========================================================
-- 01. fact_orders
-- =========================================================
-- Grain: one row per delivered order.
--
-- Important modeling note:
-- order_reviews can contain more than one review per order.
-- To avoid duplicating orders, reviews are summarized first at order_id level.
--
-- order_items is also summarized at order_id level before joining to orders.
-- This keeps fact_orders at the correct order grain.

DROP VIEW IF EXISTS fact_orders;

CREATE VIEW fact_orders AS
WITH order_totals AS (
    SELECT
        order_id,
        SUM(price) AS order_revenue,
        SUM(freight_value) AS order_freight,
        SUM(price + freight_value) AS order_total_value,
        COUNT(order_item_id) AS total_items
    FROM order_items
    GROUP BY order_id
),

review_summary AS (
    SELECT
        order_id,
        ROUND(AVG(review_score)::numeric, 2) AS review_score,
        COUNT(*) AS total_reviews
    FROM order_reviews
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,

    NULLIF(o.order_purchase_timestamp, '')::timestamp::date AS purchase_date,
    NULLIF(o.order_approved_at, '')::timestamp::date AS approved_date,
    NULLIF(o.order_delivered_carrier_date, '')::timestamp::date AS delivered_carrier_date,
    NULLIF(o.order_delivered_customer_date, '')::timestamp::date AS delivered_customer_date,
    NULLIF(o.order_estimated_delivery_date, '')::timestamp::date AS estimated_delivery_date,

    EXTRACT(
        DAY FROM (
            NULLIF(o.order_delivered_customer_date, '')::timestamp 
            - NULLIF(o.order_purchase_timestamp, '')::timestamp
        )
    ) AS delivery_days,

    CASE
        WHEN NULLIF(o.order_delivered_customer_date, '')::timestamp 
             > NULLIF(o.order_estimated_delivery_date, '')::timestamp
        THEN 1
        ELSE 0
    END AS is_late_delivery,

    rs.review_score,
    rs.total_reviews,

    ot.order_revenue,
    ot.order_freight,
    ot.order_total_value,
    ot.total_items

FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_totals ot
    ON o.order_id = ot.order_id
LEFT JOIN review_summary rs
    ON o.order_id = rs.order_id
WHERE o.order_status = 'delivered';


-- Validate fact_orders

SELECT *
FROM fact_orders
LIMIT 10;

SELECT COUNT(*)
FROM fact_orders;


-- =========================================================
-- 02. fact_order_items
-- =========================================================
-- Grain: one row per item sold inside a delivered order.
--
-- This view is used for product, category, seller, item revenue,
-- freight, and regional item-level analysis.

DROP VIEW IF EXISTS fact_order_items;

CREATE VIEW fact_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,

    p.product_category_name,
    ct.product_category_name_english,

    oi.seller_id,
    s.seller_city,
    s.seller_state,

    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS total_item_value,

    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    o.order_status,
    NULLIF(o.order_purchase_timestamp, '')::timestamp::date AS purchase_date

FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered';


-- Validate fact_order_items

SELECT *
FROM fact_order_items
LIMIT 10;

SELECT COUNT(*)
FROM fact_order_items;
