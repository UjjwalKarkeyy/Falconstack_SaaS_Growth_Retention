/*
Top-Customers Revenue Share, 
Revenue Concentration Risk
*/

WITH subscription_tbl AS (
SELECT
    s.* EXCLUDE (s.churn_flag),
    CASE
        WHEN s.churn_flag = 'TRUE' THEN 'T'
        WHEN s.churn_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS churn_flag
FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\subscriptions_cleaned.csv' AS s
),
-- create total arr for each account
total_arr_per_acc AS (
SELECT
    s.account_id,
    COALESCE(
        SUM(CASE
            WHEN s.churn_flag = 'F' THEN s.arr_amount
            END
            ), 0
    ) AS total_arr
FROM
    subscription_tbl AS s
GROUP BY
    s.account_id
),
-- find total arr
all_total_arr AS(
SELECT
    SUM(t.total_arr) AS total
FROM
    total_arr_per_acc AS t
),
-- create top 5 account's revenue share
top_5_revenue_share AS (
SELECT
    t.account_id,
    t.total_arr,
    ROUND(
        (t.total_arr / NULLIF(a.total, 0))
        * 100.0
        , 2
    ) AS revenue_share
FROM
    total_arr_per_acc AS t
CROSS JOIN all_total_arr AS a
ORDER BY
    t.total_arr DESC
LIMIT 5
),
-- create total concentration share
total_conc_share AS (
SELECT
    SUM(t.revenue_share) AS total_conc
FROM
    top_5_revenue_share AS t
)

SELECT
    *
FROM
    total_conc_share;

/*
    TABLES OF VALUE:
        - Top Customers Revenue Share: top_5_revenue_share
        - Revenue Concentration Risk: total_conc_share
    INSIGHTS:
        - The top 5 customers account for only 5.07% of total active ARR,
          indicating low revenue concentration and limited dependency
          on a small number of customers.
*/

