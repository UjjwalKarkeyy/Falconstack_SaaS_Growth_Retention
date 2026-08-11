/*
CRR, Customer Churn Rate, Early-Stage Churn Rate, Cohort Retention
*/

WITH accounts_table AS (
SELECT
        a.* EXCLUDE (
            churn_flag,
            is_trial,
            signup_date
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
mnths_group AS (
SELECT
    DISTINCT
        DATE_TRUNC('month', signup_date) AS mnth
FROM
    accounts_table
),
-- create start mnth cus count
cus_mnthly AS (
SELECT 
    c.mnth,
    COUNT(DISTINCT CASE
        WHEN (a.signup_date < c.mnth) 
        AND (a.churn_date IS NULL OR a.churn_date > c.mnth) 
        THEN a.account_id
    END
    ) AS start_mnth,
    COUNT(DISTINCT CASE
        WHEN (a.signup_date >= c.mnth AND a.signup_date < c.mnth + INTERVAL '1 month')
        THEN a.account_id
    END
    ) AS new_cus,
    COUNT(DISTINCT CASE
        WHEN (a.signup_date < c.mnth + INTERVAL '1 month')
        AND (a.churn_date IS NULL OR a.churn_date >= c.mnth + INTERVAL '1 month')
        THEN a.account_id
    END
    ) AS end_mnth
FROM
    accounts_table AS a
CROSS JOIN mnths_group AS c
GROUP BY
    c.mnth
ORDER BY
    c.mnth
),
-- calculate customer retention rate (crr)
crr_tbl AS (
SELECT
    STRFTIME(m.mnth, '%Y-%m') AS mnth,
    m.start_mnth,
    m.new_cus,
    m.end_mnth,
    ROUND(
        100.0 * (m.end_mnth - m.new_cus)
        / NULLIF(m.start_mnth, 0),
        2
    ) AS crr
FROM
    cus_mnthly AS m
),
-- create churned counts per mnth
churned_mnthly AS (
SELECT
    c.mnth,
    c.start_mnth,
    c.new_cus,
    c.end_mnth,
    ((c.start_mnth + c.new_cus) - c.end_mnth) AS churned_cus
FROM
    crr_tbl AS c
),
cus_churn_rate_tbl AS (
SELECT
    c.*,
    ROUND(
        100.0 * (c.churned_cus)
        / NULLIF(c.start_mnth, 0),
        2
    ) AS cus_churn_rate
FROM
    churned_mnthly AS c
),
-- create new cus and early churners table
new_early_churners AS (
SELECT
    m.mnth,
    COUNT(DISTINCT CASE
        WHEN a.signup_date >= m.mnth
         AND a.signup_date < m.mnth + INTERVAL '1 month'
        THEN a.account_id
    END) AS acq_cus,
    COUNT(DISTINCT CASE
        WHEN (a.signup_date >= m.mnth AND a.signup_date < m.mnth + INTERVAL '1 month') 
        AND (a.churn_date >= a.signup_date AND a.churn_date <= (a.signup_date + INTERVAL '30 days'))
        THEN a.account_id
    END
    ) AS early_churn_30
FROM
    accounts_table AS a
CROSS JOIN mnths_group AS m
GROUP BY
    m.mnth
ORDER BY
    m.mnth
),
-- create early_churner_rate table
early_churner_rate_tbl AS (
SELECT
    n.*,
    ROUND(
        (100.0 * n.early_churn_30)
        / NULLIF(n.acq_cus, 0),
        2
    ) AS early_churn_rate
FROM
    new_early_churners AS n
)

SELECT
    *
FROM
    early_churner_rate_tbl AS e;

/*
    TABLES OF VALUE:
        - Customer Retention Rate: crr_tbl
        - Customer Churn Rate: cus_churn_rate_tbl
        - Early-Stage Churn Rate: early_churner_rate_tbl 
        
    INSIGHTS:
*/
