
WITH monthly_data AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        COUNT(*) AS orders_count,
        SUM(order_items.unit_price * order_items.quantity) AS revenue
    FROM orders
    JOIN order_items
        ON orders.order_id = order_items.order_id
    WHERE orders.status = 'completed'
    GROUP BY 1
    ORDER BY 1
)
SELECT *
FROM monthly_data;


WITH monthly_data AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        COUNT(*) AS orders_count,
        SUM(order_items.unit_price * order_items.quantity) AS revenue
    FROM orders
    JOIN order_items
        ON orders.order_id = order_items.order_id
    WHERE orders.status = 'completed'
    GROUP BY 1
),
growth AS (
    SELECT
        month,
        orders_count,
        revenue,
        LAG(orders_count) OVER (ORDER BY month) AS prev_orders,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM monthly_data
)
SELECT
    month,
    orders_count,
    revenue,
    ROUND( (revenue - prev_revenue) / prev_revenue * 100, 2) AS revenue_growth_pct,
    ROUND( (orders_count - prev_orders) / prev_orders * 100, 2) AS orders_growth_pct
FROM growth
ORDER BY month;


WITH monthly_data AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        COUNT(*) AS orders_count,
        SUM(order_items.unit_price * order_items.quantity) AS revenue
    FROM orders
    JOIN order_items
        ON orders.order_id = order_items.order_id
    WHERE orders.status = 'completed'
    GROUP BY 1
),


quarterly_data AS (
    SELECT
        DATE_TRUNC('quarter', month) AS quarter,
        SUM(orders_count) AS orders_count,
        SUM(revenue) AS revenue
    FROM monthly_data
    GROUP BY 1
    ORDER BY 1
),


quarterly_growth AS (
    SELECT
        quarter,
        orders_count,
        revenue,
        LAG(orders_count) OVER (ORDER BY quarter) AS prev_orders,
        LAG(revenue) OVER (ORDER BY quarter) AS prev_revenue
    FROM quarterly_data
)


SELECT
    quarter,
    orders_count,
    revenue,
    ROUND( (revenue - prev_revenue) / prev_revenue * 100, 2) AS revenue_growth_pct,
    ROUND( (orders_count - prev_orders) / prev_orders * 100, 2) AS orders_growth_pct
FROM quarterly_growth
ORDER BY quarter;