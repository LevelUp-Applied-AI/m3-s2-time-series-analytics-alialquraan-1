

WITH daily_revenue AS (
    SELECT
        DATE(order_date) AS day,
        SUM(order_items.unit_price * order_items.quantity) AS revenue,
        COUNT(DISTINCT orders.order_id) AS orders_count
    FROM orders
    JOIN order_items
        ON orders.order_id = order_items.order_id
    WHERE orders.status = 'completed'
    GROUP BY 1
)
SELECT
    day,
    revenue,
    orders_count,
    ROUND(AVG(revenue) OVER (
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS revenue_7d_ma,
    ROUND(AVG(revenue) OVER (
        ORDER BY day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2) AS revenue_30d_ma,
    ROUND(AVG(orders_count) OVER (
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS orders_7d_ma
FROM daily_revenue
ORDER BY day;