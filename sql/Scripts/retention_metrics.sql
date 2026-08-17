/*
    CRR, Customer Churn Rate, Early-Stage Churn Rate, Cohort Retention
*/

--CREATE OR REPLACE VIEW customer_retention_rate_vw AS
WITH cus_mnthly AS (
SELECT
    m.mnth,
    COUNT(DISTINCT CASE
        WHEN a.signup_date < m.mnth
        AND (
            a.churn_date IS NULL
            OR a.churn_date > m.mnth
        )
        THEN a.account_id
    END) AS start_mnth,
    COUNT(DISTINCT CASE
        WHEN a.signup_date >= m.mnth
        AND a.signup_date < m.mnth + INTERVAL '1 month'
        THEN a.account_id
    END) AS new_cus,
    COUNT(DISTINCT CASE
        WHEN a.signup_date < m.mnth + INTERVAL '1 month'
        AND (
            a.churn_date IS NULL
            OR a.churn_date >= m.mnth + INTERVAL '1 month'
        )
        THEN a.account_id
    END) AS end_mnth
FROM
    accounts_tbl AS a
CROSS JOIN mnths_list AS m
GROUP BY
    m.mnth
)

SELECT
    m.mnth,
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
ORDER BY
    m.mnth;

--CREATE OR REPLACE VIEW customer_churn_rate_vw AS
WITH churned_mnthly AS (
SELECT
    c.mnth,
    c.start_mnth,
    c.new_cus,
    c.end_mnth,
    ((c.start_mnth + c.new_cus) - c.end_mnth) AS churned_cus
FROM
    customer_retention_rate_vw AS c
)

SELECT
    c.*,
    ROUND(
        100.0 * c.churned_cus
        / NULLIF(c.start_mnth, 0),
        2
    ) AS cus_churn_rate
FROM
    churned_mnthly AS c
ORDER BY
    c.mnth;

--CREATE OR REPLACE VIEW early_churn_rate_vw AS
WITH new_early_churners AS (
SELECT
    m.mnth,
    COUNT(DISTINCT CASE
        WHEN a.signup_date >= m.mnth
        AND a.signup_date < m.mnth + INTERVAL '1 month'
        THEN a.account_id
    END) AS acq_cus,
    COUNT(DISTINCT CASE
        WHEN a.signup_date >= m.mnth
        AND a.signup_date < m.mnth + INTERVAL '1 month'
        AND a.churn_date >= a.signup_date
        AND a.churn_date <= a.signup_date + INTERVAL '30 days'
        THEN a.account_id
    END) AS early_churn_30
FROM
    accounts_tbl AS a
CROSS JOIN mnths_list AS m
GROUP BY
    m.mnth
)

SELECT
    n.*,
    ROUND(
        100.0 * n.early_churn_30
        / NULLIF(n.acq_cus, 0),
        2
    ) AS early_churn_rate
FROM
    new_early_churners AS n
ORDER BY
    n.mnth;

--CREATE OR REPLACE VIEW cohort_retention_vw AS
WITH cohort_data AS (
SELECT
    m.mnth,
    COUNT(DISTINCT CASE
        WHEN a.signup_date >= m.mnth
        AND a.signup_date < m.mnth + INTERVAL '1 month'
        THEN a.account_id
    END) AS monthly_signups,
    COUNT(DISTINCT CASE
        WHEN a.signup_date >= m.mnth
        AND a.signup_date < m.mnth + INTERVAL '1 month'
        AND a.churn_date <= a.signup_date + INTERVAL '30 days'
        THEN a.account_id
    END) AS day_30,
    COUNT(DISTINCT CASE
        WHEN a.signup_date >= m.mnth
        AND a.signup_date < m.mnth + INTERVAL '1 month'
        AND a.churn_date <= a.signup_date + INTERVAL '90 days'
        THEN a.account_id
    END) AS day_90
FROM
    accounts_tbl AS a
CROSS JOIN mnths_list AS m
GROUP BY
    m.mnth
)

SELECT
    c.mnth,
    c.monthly_signups,
    c.day_30,
    ROUND(
        100.0 * (c.monthly_signups - c.day_30)
        / NULLIF(c.monthly_signups, 0),
        2
    ) AS retention_30_pct,
    c.day_90,
    ROUND(
        100.0 * (c.monthly_signups - c.day_90)
        / NULLIF(c.monthly_signups, 0),
        2
    ) AS retention_90_pct
FROM
    cohort_data AS c
ORDER BY
    c.mnth;

/*
    TABLES OF VALUE:
        - Customer Retention Rate: crr_tbl
        - Customer Churn Rate: cus_churn_rate_tbl
        - Early-Stage Churn Rate: early_churner_rate_tbl 
        - Cohort Retention: cohort_retention_tbl
        
    INSIGHTS:
        - Customer retention is decreasing with Dec of 2024 taking the massive hit of 63.18% from prev (Nov, 2024) 83.52%
        - Customer churn rate agrees with CRR as it also saw a massive increase from 16.48% in Nov, 2024 to 36.82% in Dec, 2024
        - Early-Stage churn presents the problem where customers are leaving within 30 days of signup and that rate is highest in
            Dec, 2024 with 55%
        - The retention on 90 days of signup seem to decrease from the starting second-quarter of 2024 reaching as low as 23.08% in Sep, 2024
            with retention rate not being able to cross 60%. Furthermore, the 30 days (early) retention decreases steadily and reaches low as
            58.33% in Nov, 2024. The 90 days retention seem to be always lower than 30 days, but the differences between them is widened during
            the end of 2024
        - All this majorly hints looking into the 2024 year especially into 30 and 90 days period!
*/
