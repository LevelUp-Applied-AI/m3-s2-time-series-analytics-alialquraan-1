WITH first_purchase AS (
    SELECT
        o.customer_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS rn
    FROM orders o
    WHERE o.status = 'completed'
)
SELECT *
FROM first_purchase
WHERE rn = 1;


WITH first_purchase AS (
    SELECT
        o.customer_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS rn
    FROM orders o
    WHERE o.status = 'completed'
),
cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', order_date) AS cohort_month,
        order_date AS first_order_date
    FROM first_purchase
    WHERE rn = 1
)
SELECT *
FROM cohorts;


WITH first_purchase AS (
    SELECT
        o.customer_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS rn
    FROM orders o
    WHERE o.status = 'completed'
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
)
SELECT *
FROM all_orders;

WITH first_purchase AS (
    SELECT
        o.customer_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS rn
    FROM orders o
    WHERE o.status = 'completed'
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

        MAX(CASE 
            WHEN order_date > first_order_date
             AND order_date <= first_order_date + INTERVAL '30 days'
            THEN 1 ELSE 0 END) AS retained_30,

        MAX(CASE 
            WHEN order_date > first_order_date
             AND order_date <= first_order_date + INTERVAL '60 days'
            THEN 1 ELSE 0 END) AS retained_60,

        MAX(CASE 
            WHEN order_date > first_order_date
             AND order_date <= first_order_date + INTERVAL '90 days'
            THEN 1 ELSE 0 END) AS retained_90

    FROM all_orders
    GROUP BY customer_id, cohort_month
)
SELECT *
FROM retention_flags;


WITH first_purchase AS (
    SELECT
        o.customer_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS rn
    FROM orders o
    WHERE o.status = 'completed'
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

        MAX(CASE 
            WHEN order_date > first_order_date
             AND order_date <= first_order_date + INTERVAL '30 days'
            THEN 1 ELSE 0 END) AS retained_30,

        MAX(CASE 
            WHEN order_date > first_order_date
             AND order_date <= first_order_date + INTERVAL '60 days'
            THEN 1 ELSE 0 END) AS retained_60,

        MAX(CASE 
            WHEN order_date > first_order_date
             AND order_date <= first_order_date + INTERVAL '90 days'
            THEN 1 ELSE 0 END) AS retained_90

    FROM all_orders
    GROUP BY customer_id, cohort_month
)

SELECT
    cohort_month,
    COUNT(*) AS total_customers,

    ROUND(AVG(retained_30) * 100, 2) AS retention_30_days,
    ROUND(AVG(retained_60) * 100, 2) AS retention_60_days,
    ROUND(AVG(retained_90) * 100, 2) AS retention_90_days

FROM retention_flags
GROUP BY cohort_month
ORDER BY cohort_month;

