-- =========================================================
-- 03_business_validation_queries.sql
-- Olist E-commerce BI Analytics
--
-- Purpose:
-- - Validate analytical views before/against Power BI.
-- - Check grain, duplicates, revenue consistency, KPI definitions,
--   delivery/customer-experience logic, and seller attribution.
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
-- Grain: order_id + order_item_id.

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
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score
FROM fact_orders;


-- =========================================================
-- 05. Revenue consistency between views
-- =========================================================
-- A small difference may occur because source price/freight fields
-- were imported as floating-point values.

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

SELECT
    COALESCE(product_category_name_english, product_category_name, 'unknown') AS category,
    ROUND(SUM(price)::numeric, 2) AS revenue,
    COUNT(DISTINCT order_id) AS category_orders,
    COUNT(*) AS items_sold,
    ROUND(
        SUM(price)::numeric / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS category_aov,
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
-- 09. Review coverage and satisfaction KPIs
-- =========================================================
-- Power BI definitions:
-- Positive review: score >= 4
-- Low review: score <= 2
-- Review rates use reviewed orders as denominator.

SELECT
    COUNT(*) AS total_orders,
    COUNT(review_score) AS reviewed_orders,
    ROUND(
        100.0 * COUNT(review_score) / NULLIF(COUNT(*), 0),
        2
    ) AS review_coverage_pct,
    COUNT(*) FILTER (WHERE review_score >= 4) AS positive_review_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE review_score >= 4)
        / NULLIF(COUNT(review_score), 0),
        2
    ) AS positive_review_rate_pct,
    COUNT(*) FILTER (WHERE review_score <= 2) AS low_review_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE review_score <= 2)
        / NULLIF(COUNT(review_score), 0),
        2
    ) AS low_review_rate_pct,
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score
FROM fact_orders;


-- =========================================================
-- 10. Delivery status and KPI validation
-- =========================================================
-- Known delivery requires both actual and estimated delivery dates.

WITH delivery_base AS (
    SELECT
        *,
        CASE
            WHEN delivered_customer_date IS NULL
              OR estimated_delivery_date IS NULL
                THEN 'Unknown'
            WHEN delivered_customer_date > estimated_delivery_date
                THEN 'Late delivery'
            ELSE 'On-time delivery'
        END AS delivery_status,
        CASE
            WHEN delivered_customer_date IS NULL
              OR estimated_delivery_date IS NULL
                THEN NULL
            ELSE GREATEST(
                0,
                delivered_customer_date - estimated_delivery_date
            )
        END AS delay_days
    FROM fact_orders
)
SELECT
    COUNT(*) FILTER (
        WHERE delivery_status IN ('On-time delivery', 'Late delivery')
    ) AS known_delivery_orders,
    COUNT(*) FILTER (
        WHERE delivery_status = 'Late delivery'
    ) AS late_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE delivery_status = 'Late delivery')
        / NULLIF(
            COUNT(*) FILTER (
                WHERE delivery_status IN ('On-time delivery', 'Late delivery')
            ),
            0
        ),
        2
    ) AS late_delivery_rate_pct,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE delivery_status = 'On-time delivery')
        / NULLIF(
            COUNT(*) FILTER (
                WHERE delivery_status IN ('On-time delivery', 'Late delivery')
            ),
            0
        ),
        2
    ) AS on_time_delivery_rate_pct,
    ROUND(
        AVG(delay_days) FILTER (WHERE delivery_status = 'Late delivery')::numeric,
        2
    ) AS avg_delay_days_late
FROM delivery_base;


-- =========================================================
-- 11. Delivery status impact on customer experience
-- =========================================================

WITH delivery_base AS (
    SELECT
        *,
        CASE
            WHEN delivered_customer_date IS NULL
              OR estimated_delivery_date IS NULL
                THEN 'Unknown'
            WHEN delivered_customer_date > estimated_delivery_date
                THEN 'Late delivery'
            ELSE 'On-time delivery'
        END AS delivery_status
    FROM fact_orders
)
SELECT
    delivery_status,
    COUNT(review_score) AS reviewed_orders,
    ROUND(AVG(delivery_days)::numeric, 2) AS avg_delivery_days,
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE review_score <= 2)
        / NULLIF(COUNT(review_score), 0),
        2
    ) AS low_review_rate_pct
FROM delivery_base
WHERE delivery_status IN ('On-time delivery', 'Late delivery')
GROUP BY delivery_status
ORDER BY delivery_status;


-- =========================================================
-- 12. Review score distribution
-- =========================================================

SELECT
    review_score,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_reviewed_orders
FROM fact_orders
WHERE review_score IS NOT NULL
GROUP BY review_score
ORDER BY review_score;


-- =========================================================
-- 13. State delivery performance
-- =========================================================
-- The final Power BI ranking only compares states with >= 500
-- known deliveries to reduce low-volume percentage noise.

WITH state_delivery AS (
    SELECT
        customer_state,
        COUNT(*) FILTER (
            WHERE delivered_customer_date IS NOT NULL
              AND estimated_delivery_date IS NOT NULL
        ) AS known_delivery_orders,
        COUNT(*) FILTER (
            WHERE delivered_customer_date IS NOT NULL
              AND estimated_delivery_date IS NOT NULL
              AND delivered_customer_date > estimated_delivery_date
        ) AS late_orders
    FROM fact_orders
    GROUP BY customer_state
)
SELECT
    customer_state,
    known_delivery_orders,
    late_orders,
    ROUND(
        100.0 * late_orders / NULLIF(known_delivery_orders, 0),
        2
    ) AS late_delivery_rate_pct
FROM state_delivery
WHERE known_delivery_orders >= 500
ORDER BY late_delivery_rate_pct DESC;


-- =========================================================
-- 14. Seller performance validation
-- =========================================================
-- Seller is item-grain while review/delivery are order-grain.
-- First create a distinct seller-order bridge so repeated items from
-- one seller do not duplicate an order-level review or delivery outcome.

WITH seller_orders AS (
    SELECT DISTINCT
        seller_id,
        order_id
    FROM fact_order_items
),

seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS seller_revenue,
        COUNT(*) AS items_sold
    FROM fact_order_items
    GROUP BY seller_id
),

seller_order_metrics AS (
    SELECT
        so.seller_id,
        COUNT(*) AS seller_orders,
        COUNT(*) FILTER (
            WHERE fo.delivered_customer_date IS NOT NULL
              AND fo.estimated_delivery_date IS NOT NULL
        ) AS known_delivery_orders,
        COUNT(*) FILTER (
            WHERE fo.delivered_customer_date IS NOT NULL
              AND fo.estimated_delivery_date IS NOT NULL
              AND fo.delivered_customer_date > fo.estimated_delivery_date
        ) AS late_orders,
        AVG(fo.review_score) AS avg_review_score
    FROM seller_orders so
    INNER JOIN fact_orders fo
        ON so.order_id = fo.order_id
    GROUP BY so.seller_id
)

SELECT
    sr.seller_id,
    ROUND(sr.seller_revenue::numeric, 2) AS revenue,
    som.seller_orders,
    ROUND(
        sr.seller_revenue::numeric / NULLIF(som.seller_orders, 0),
        2
    ) AS seller_aov,
    ROUND(
        100.0 * som.late_orders / NULLIF(som.known_delivery_orders, 0),
        2
    ) AS seller_late_delivery_rate_pct,
    ROUND(som.avg_review_score::numeric, 2) AS seller_avg_review_score,
    sr.items_sold
FROM seller_revenue sr
INNER JOIN seller_order_metrics som
    ON sr.seller_id = som.seller_id
ORDER BY revenue DESC
LIMIT 20;


-- =========================================================
-- 15. Connection check
-- =========================================================

SELECT
    current_database(),
    current_user,
    inet_server_addr(),
    inet_server_port();
