/*
Total Customers by month, Customer Growth Rate
*/

WITH accounts_table AS (
SELECT
        a.* EXCLUDE (
            churn_flag,
            is_trial
        ),

        CASE
            WHEN a.churn_flag = 'TRUE' THEN 'T'
        WHEN a.churn_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS churn_flag,

        CASE
            WHEN a.is_trial = 'TRUE' THEN 'T'
        WHEN a.is_trial = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS is_trial,

        CAST(a.signup_date AS DATE) AS signup_date,

        CASE
            WHEN c.churn_date IS NOT NULL
            THEN CAST(c.churn_date AS DATE)
        ELSE NULL
    END AS churn_date
FROM
        'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\accounts_cleaned.csv' AS a
LEFT JOIN
        'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\churn_events_cleaned.csv' AS c
        ON
    a.account_id = c.account_id
),
-- create list of reporting months
cus_months AS (
SELECT
    DISTINCT
        DATE_TRUNC('month', signup_date) AS mnth
FROM
    accounts_table
),
-- calculate total active customers at the end of each month
customers_by_month AS (
SELECT
        m.mnth,

        COUNT(
            DISTINCT CASE
                WHEN a.signup_date < m.mnth + INTERVAL '1 month'
                AND (
                    a.churn_date IS NULL
                    OR a.churn_date >= m.mnth + INTERVAL '1 month'
                )
                THEN a.account_id
            END
        ) AS total_cus
FROM
    cus_months AS m
CROSS JOIN accounts_table AS a
GROUP BY
        m.mnth
),
-- get previous month's total
customer_growth AS (
SELECT
        mnth,
        total_cus,

        LAG(total_cus) OVER (
ORDER BY
    mnth
        ) AS prev_mnth_total
FROM
    customers_by_month
)

SELECT
    STRFTIME(mnth, '%Y-%m') AS mnth,
    total_cus,
    prev_mnth_total,

    ROUND(
        (
            (total_cus - prev_mnth_total) * 100.0
            / NULLIF(prev_mnth_total, 0)
        ),
        2
    ) AS customer_growth_rate
FROM
    customer_growth
ORDER BY
    mnth;
    
/*
    INSIGHT: Customer Growth Rate has been decreasing since 2024-08 (Aug)
*/
