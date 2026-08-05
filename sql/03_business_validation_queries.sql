-- =========================================================
-- 03_business_validation_queries.sql
-- Olist E-commerce BI Analytics
--
-- Purpose:
-- - Validate analytical views before using them in Power BI.
-- - Check grain, duplicates, revenue consistency, and initial business KPIs.
-- =========================================================


-- =========================================================
-- 01. View row counts
-- =========================================================

SELECT 'fact_orders' AS view_name, COUNT(*) AS total_rows
FROM fact_orders
UNION ALL
SELECT 'fact_order_items', COUNT(*)
FROM fact_order_items;


-- =========================================================
-- 02. Duplicate check: fact_orders
-- =========================================================
-- Expected result: 0 rows.
-- fact_orders should have one row per order_id.

SELECT
    order_id,
    COUNT(*) AS rows_per_order
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY rows_per_order DESC;


-- =========================================================
-- 03. Duplicate check: fact_order_items
-- =========================================================
-- Expected result: 0 rows.
-- The logical grain is order_id + order_item_id.

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS rows_per_item
FROM fact_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
ORDER BY rows_per_item DESC;


-- =========================================================
-- 04. Executive KPIs
-- =========================================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(SUM(order_revenue)::numeric, 2) AS total_revenue,
    ROUND(AVG(order_revenue)::numeric, 2) AS avg_order_value,
    ROUND(AVG(order_freight)::numeric, 2) AS avg_freight_value,
    ROUND(AVG(order_total_value)::numeric, 2) AS avg_total_order_value,
    ROUND(AVG(delivery_days)::numeric, 2) AS avg_delivery_days,
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score,
    ROUND(
        100.0 * SUM(is_late_delivery)::numeric / COUNT(*),
        2
    ) AS late_delivery_rate_pct
FROM fact_orders;


-- =========================================================
-- 05. Revenue consistency between views
-- =========================================================
-- Revenue from fact_orders and fact_order_items should be aligned.
-- A small difference can occur because price/freight were imported as real.

SELECT
    'fact_orders' AS source,
    ROUND(SUM(order_revenue)::numeric, 2) AS revenue
FROM fact_orders

UNION ALL

SELECT
    'fact_order_items' AS source,
    ROUND(SUM(price)::numeric, 2) AS revenue
FROM fact_order_items;


-- =========================================================
-- 06. Monthly revenue
-- =========================================================

SELECT
    DATE_TRUNC('month', purchase_date)::date AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_revenue)::numeric, 2) AS revenue,
    ROUND(AVG(order_revenue)::numeric, 2) AS avg_order_value
FROM fact_orders
GROUP BY DATE_TRUNC('month', purchase_date)
ORDER BY month;


-- =========================================================
-- 07. Top categories by revenue
-- =========================================================
-- Uses fact_order_items because category lives at product/item level.

SELECT
    COALESCE(product_category_name_english, product_category_name, 'unknown') AS category,
    ROUND(SUM(price)::numeric, 2) AS revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(AVG(price)::numeric, 2) AS avg_item_price
FROM fact_order_items
GROUP BY COALESCE(product_category_name_english, product_category_name, 'unknown')
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 08. Top customer states by revenue
-- =========================================================

SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(SUM(order_revenue)::numeric, 2) AS revenue,
    ROUND(AVG(order_revenue)::numeric, 2) AS avg_order_value
FROM fact_orders
GROUP BY customer_state
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 09. Delivery delay impact on review score
-- =========================================================

SELECT
    CASE
        WHEN is_late_delivery = 1 THEN 'Late delivery'
        ELSE 'On-time delivery'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score,
    ROUND(AVG(delivery_days)::numeric, 2) AS avg_delivery_days,
    ROUND(AVG(order_revenue)::numeric, 2) AS avg_order_revenue
FROM fact_orders
WHERE review_score IS NOT NULL
GROUP BY is_late_delivery
ORDER BY is_late_delivery;


-- =========================================================
-- 10. Review score distribution
-- =========================================================

SELECT
    review_score,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_orders
FROM fact_orders
WHERE review_score IS NOT NULL
GROUP BY review_score
ORDER BY review_score;


-- =========================================================
-- 11. Top sellers by revenue
-- =========================================================

SELECT
    seller_id,
    seller_state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price)::numeric, 2) AS revenue,
    ROUND(AVG(freight_value)::numeric, 2) AS avg_freight
FROM fact_order_items
GROUP BY seller_id, seller_state
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 12. Connection check
-- =========================================================

SELECT
    current_database(),
    current_user,
    inet_server_addr(),
    inet_server_port();
