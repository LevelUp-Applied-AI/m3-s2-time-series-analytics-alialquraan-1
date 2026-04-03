WITH first_purchase AS (
    SELECT
        customer_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS rn
    FROM orders
    WHERE status = 'completed'
),
cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', order_date) AS cohort_month,
        order_date AS first_order_date
    FROM first_purchase
    WHERE rn = 1
),
all_orders AS (
    SELECT
        o.customer_id,
        o.order_date,
        c.cohort_month,
        c.first_order_date
    FROM orders o
    JOIN cohorts c
        ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
),
retention_flags AS (
    SELECT
        customer_id,
        cohort_month,
        MAX(CASE WHEN order_date > first_order_date
                 AND order_date <= first_order_date + INTERVAL '30 days'
            THEN 1 ELSE 0 END) AS retained_30
    FROM all_orders
    GROUP BY customer_id, cohort_month
),
cohort_summary AS (
    SELECT
        cohort_month,
        COUNT(*) AS total_customers,
        ROUND(AVG(retained_30)*100,2) AS retention_30
    FROM retention_flags
    GROUP BY cohort_month
)
SELECT
    cohort_month,
    total_customers,
    retention_30,
    ROUND(retention_30 - LAG(retention_30) OVER (ORDER BY cohort_month),2) AS mom_retention_change
FROM cohort_summary
ORDER BY cohort_month;


-- Example 2: Monthly revenue by category with moving average and growth
WITH monthly_category AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        p.category,
        SUM(oi.unit_price * oi.quantity) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.status = 'completed'
    GROUP BY 1,2
),
category_trend AS (
    SELECT
        month,
        category,
        revenue,
        AVG(revenue) OVER (
            PARTITION BY category
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS revenue_3m_ma,
        LAG(revenue) OVER (PARTITION BY category ORDER BY month) AS prev_revenue
    FROM monthly_category
)
SELECT
    month,
    category,
    revenue,
    revenue_3m_ma,
    ROUND((revenue - prev_revenue)/prev_revenue*100,2) AS mom_growth_pct
FROM category_trend
ORDER BY category, month;