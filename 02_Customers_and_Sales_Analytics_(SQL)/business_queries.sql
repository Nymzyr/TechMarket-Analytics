-- ==========================================================
-- Business Question 1
-- How many orders, customers, sellers and products are stored
-- in the database?
-- ==========================================================

SELECT
    'Orders' AS metric,
    COUNT(*) AS total
FROM orders

UNION ALL

SELECT
    'Customers',
    COUNT(*)
FROM customers

UNION ALL

SELECT
    'Sellers',
    COUNT(*)
FROM sellers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM products;

-- ==========================================================
-- Business Question 2
-- What is the distribution of order statuses?
-- ==========================================================

SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS share_percent
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- ==========================================================
-- Business Question 3
-- How did the number of orders change over time?
-- ==========================================================

SELECT
    strftime('%Y-%m', order_purchase_timestamp) AS purchase_month,
    COUNT(*) AS orders,
    COUNT(*) -
    LAG(COUNT(*))
        OVER(
            ORDER BY strftime('%Y-%m', order_purchase_timestamp)
        ) AS order_change
FROM orders
GROUP BY purchase_month
ORDER BY purchase_month;

-- ==========================================================
-- Business Question 4
-- How did monthly revenue change over time?
-- ==========================================================

SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
    ROUND(SUM(oi.price),2) AS revenue,
    ROUND(
        SUM(oi.price) -
        LAG(SUM(oi.price))
        OVER(
            ORDER BY strftime('%Y-%m', o.order_purchase_timestamp)
        ),
        2
    ) AS revenue_change
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp < '2018-09-01'
GROUP BY purchase_month
ORDER BY purchase_month;


-- ==========================================================
-- Business Question 5
-- Top 10 Sellers by Revenue
-- ==========================================================

SELECT
    oi.seller_id,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;