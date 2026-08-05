-- =========================================================
-- 01_setup_and_data_quality.sql
-- Olist E-commerce BI Analytics
--
-- Purpose:
-- - Validate raw imported tables.
-- - Rename imported CSV tables into cleaner analytical names.
-- - Review basic data quality before creating analytical views.
-- =========================================================

-- =========================================================
-- 01. Validate raw imported tables
-- =========================================================

SELECT 'olist_customers_dataset' AS table_name, COUNT(*) AS total_rows FROM olist_customers_dataset
UNION ALL
SELECT 'olist_order_items_dataset', COUNT(*) FROM olist_order_items_dataset
UNION ALL
SELECT 'olist_order_payments_dataset', COUNT(*) FROM olist_order_payments_dataset
UNION ALL
SELECT 'olist_orders_dataset', COUNT(*) FROM olist_orders_dataset
UNION ALL
SELECT 'olist_products_dataset', COUNT(*) FROM olist_products_dataset
UNION ALL
SELECT 'olist_sellers_dataset', COUNT(*) FROM olist_sellers_dataset
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'product_category_name_translation', COUNT(*) FROM product_category_name_translation;


-- =========================================================
-- 02. Rename raw tables
-- =========================================================
-- Run only once after importing the original CSV files.

ALTER TABLE olist_orders_dataset RENAME TO orders;
ALTER TABLE olist_order_items_dataset RENAME TO order_items;
ALTER TABLE olist_customers_dataset RENAME TO customers;
ALTER TABLE olist_products_dataset RENAME TO products;
ALTER TABLE olist_sellers_dataset RENAME TO sellers;
ALTER TABLE olist_order_payments_dataset RENAME TO order_payments;
ALTER TABLE product_category_name_translation RENAME TO category_translation;


-- =========================================================
-- 03. Validate renamed tables
-- =========================================================

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;


-- =========================================================
-- 04. Review columns and data types
-- =========================================================

SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;


-- =========================================================
-- 05. Business exploration checks
-- =========================================================

-- 05.1 Order status distribution

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 05.2 Purchase date range
-- Note: In this import, order date columns were loaded as character varying.
-- They are converted to timestamp later when analytical views are created.

SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;


-- 05.3 Null checks in important order dates

SELECT
    COUNT(*) AS total_orders,
    COUNT(order_purchase_timestamp) AS purchase_date_not_null,
    COUNT(order_approved_at) AS approved_date_not_null,
    COUNT(order_delivered_carrier_date) AS carrier_date_not_null,
    COUNT(order_delivered_customer_date) AS customer_delivery_date_not_null,
    COUNT(order_estimated_delivery_date) AS estimated_delivery_date_not_null
FROM orders;


-- 05.4 Review score distribution

SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- 05.5 Focused type check for key tables

SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('orders', 'order_items', 'order_reviews')
ORDER BY table_name, ordinal_position;
