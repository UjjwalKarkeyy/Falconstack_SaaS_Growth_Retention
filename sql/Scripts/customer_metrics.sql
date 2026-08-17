/*
Total Customers by month, Customer Growth Rate
*/

--CREATE OR REPLACE VIEW customer_growth_vw AS
WITH customers_by_month AS (
SELECT
    m.mnth,
    COUNT(DISTINCT CASE
        WHEN a.signup_date < m.mnth + INTERVAL '1 month'
        AND (
            a.churn_date IS NULL
            OR a.churn_date >= m.mnth + INTERVAL '1 month'
        )
        THEN a.account_id
    END) AS total_cus
FROM
    mnths_list AS m
CROSS JOIN accounts_tbl AS a
GROUP BY
    m.mnth
),
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
    mnth,
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