/*
Total Revenue, Revenue Growth Rate, 
Expansion Revenue, Contraction Revenue
*/

WITH subscription_tbl AS (
SELECT
    s.* EXCLUDE (is_trial,
    upgrade_flag,
    downgrade_flag,
    churn_flag,
    auto_renew_flag,
    end_date,
    start_date),
    STRFTIME(
        s.start_date, 
        '%Y-%m-%d'
        ) AS start_date,
    CASE
        WHEN s.end_date NOT IN ('Ongoing', 'Unknown')
            THEN STRFTIME(
                TRY_STRPTIME(s.end_date, '%d-%m-%Y'),
                '%Y-%m-%d'
                )
        WHEN s.end_date = 'Ongoing' THEN 'Ongoing'
        ELSE 'Unknown'
    END AS end_date,
    CASE 
        WHEN s.is_trial = 'TRUE' THEN 'T'
        WHEN s.is_trial = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS is_trial,
       CASE 
        WHEN s.upgrade_flag = 'TRUE' THEN 'T'
        WHEN s.upgrade_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS upgrade_flag,
       CASE 
        WHEN s.downgrade_flag = 'TRUE' THEN 'T'
        WHEN s.downgrade_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS downgrade_flag,
       CASE 
        WHEN s.churn_flag = 'TRUE' THEN 'T'
        WHEN s.churn_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS churn_flag,
       CASE 
        WHEN s.auto_renew_flag = 'TRUE' THEN 'T'
        WHEN s.auto_renew_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS auto_renew_flag,
FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\subscriptions_cleaned.csv' AS s
),
-- find total revenue
total_revenue_tbl AS (
SELECT 
    SUM(s.arr_amount) AS total_revenue
FROM
    subscription_tbl AS s
),
-- create total mrr per month
total_mrr_per_mnth AS (
SELECT
    STRFTIME(m.mnth, '%Y-%m') AS mnth,
    SUM(CASE
        WHEN s.end_date = 'Unknown' THEN 0
        WHEN ((s.end_date = 'Ongoing' OR CAST(s.end_date AS DATE) >= m.mnth + INTERVAL '1 month')
        AND CAST(s.start_date AS DATE) <= m.mnth)
        THEN s.mrr_amount
    END) AS total_mrr
FROM
    subscription_tbl AS s
CROSS JOIN mnths_list AS m
GROUP BY
    m.mnth
ORDER BY
    m.mnth
),
-- create curr and prev total mrr per mnth
curr_prev_total_mrr AS (
SELECT
    t.mnth,
    t.total_mrr AS curr_total_mrr,
    LAG(t.total_mrr) OVER(ORDER BY t.mnth) AS prev_total_mrr
FROM
    total_mrr_per_mnth AS t
),
-- create revenue growth rate
revenue_growth_rate_tbl AS (
SELECT
    c.*,
    ROUND(
        ((c.curr_total_mrr - c.prev_total_mrr)
        / NULLIF(c.prev_total_mrr, 0))
        * 100.0,
        2
    ) AS revenue_growth_rate
FROM
    curr_prev_total_mrr AS c
)

SELECT
    r.*
FROM
    revenue_growth_rate_tbl AS r;

/*
    TABLES OF VALUE:
        - Total Revenue: total_revenue_tbl
        - Revenue Growth Rate: revenue_growth_rate_tbl
        
    INSIGHTS:
        - 
*/
