/*
Top-Customers Revenue Share, 
Revenue Concentration Risk
*/

--CREATE OR REPLACE VIEW total_arr_per_account_vw AS
SELECT
    s.account_id,
    COALESCE(
        SUM(CASE
            WHEN s.churn_flag = 'F'
            AND s.end_date_status = 'Ongoing'
            THEN s.arr_amount
            ELSE 0
        END),
        0
    ) AS total_arr
FROM
    subscription_tbl AS s
GROUP BY
    s.account_id;

--CREATE OR REPLACE VIEW top_5_revenue_share_vw AS
WITH all_total_arr AS (
SELECT
    SUM(t.total_arr) AS total
FROM
    total_arr_per_account_vw AS t
)

SELECT
    t.account_id,
    t.total_arr,
    ROUND(
        (t.total_arr / NULLIF(a.total, 0))
        * 100.0,
        2
    ) AS revenue_share
FROM
    total_arr_per_account_vw AS t
CROSS JOIN all_total_arr AS a
ORDER BY
    t.total_arr DESC
LIMIT 5;

--CREATE OR REPLACE VIEW revenue_concentration_vw AS
SELECT
    SUM(t.revenue_share) AS total_conc
FROM
    top_5_revenue_share_vw AS t;

/*
    TABLES OF VALUE:
        - Top Customers Revenue Share: top_5_revenue_share
        - Revenue Concentration Risk: total_conc_share
    INSIGHTS:
        - The top 5 customers account for only 5.07% of total active ARR,
          indicating low revenue concentration and limited dependency
          on a small number of customers.
*/