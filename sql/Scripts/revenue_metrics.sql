/*
Total Monthly Recurring Revenue, Revenue Growth Rate, 
Expansion Revenue, Contraction Revenue
*/

--CREATE OR REPLACE VIEW total_arr_vw AS
SELECT
    SUM(s.arr_amount) AS total_arr
FROM
    subscription_tbl AS s;

--CREATE OR REPLACE VIEW revenue_growth_rate_vw AS
WITH total_mrr_per_mnth AS (
SELECT
    m.mnth,
    SUM(CASE
        WHEN s.end_date_status = 'Ongoing'
        AND s.start_date <= m.mnth
        THEN s.mrr_amount
        WHEN s.end_date IS NOT NULL
        AND s.end_date >= m.mnth + INTERVAL '1 month'
        AND s.start_date <= m.mnth
        THEN s.mrr_amount
        ELSE 0
    END) AS total_mrr
FROM
    subscription_tbl AS s
CROSS JOIN mnths_list AS m
GROUP BY
    m.mnth
),
curr_prev_total_mrr AS (
SELECT
    t.mnth,
    t.total_mrr AS curr_total_mrr,
    LAG(t.total_mrr) OVER (
        ORDER BY
            t.mnth
    ) AS prev_total_mrr
FROM
    total_mrr_per_mnth AS t
)

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
ORDER BY
    c.mnth;

--CREATE OR REPLACE VIEW expansion_revenue_rate_vw AS
WITH oct_nov_exp_revenue AS (
SELECT
    SUM(CASE
        WHEN s.upgrade_flag = 'T'
        AND s.start_date >= DATE '2024-10-01'
        AND s.start_date < DATE '2024-11-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS oct_expansion_mrr_24,
    SUM(CASE
        WHEN s.upgrade_flag = 'T'
        AND s.start_date >= DATE '2024-11-01'
        AND s.start_date < DATE '2024-12-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS nov_expansion_mrr_24
FROM
    subscription_tbl AS s
)

SELECT
    ROUND(
        ((o.nov_expansion_mrr_24 - o.oct_expansion_mrr_24)
        / NULLIF(o.oct_expansion_mrr_24, 0))
        * 100.0,
        2
    ) AS exp_revenue_rate
FROM
    oct_nov_exp_revenue AS o;

--CREATE OR REPLACE VIEW contraction_revenue_rate_vw AS
WITH oct_nov_contract_revenue AS (
SELECT
    SUM(CASE
        WHEN s.downgrade_flag = 'T'
        AND s.start_date >= DATE '2024-10-01'
        AND s.start_date < DATE '2024-11-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS oct_contract_mrr_24,
    SUM(CASE
        WHEN s.downgrade_flag = 'T'
        AND s.start_date >= DATE '2024-11-01'
        AND s.start_date < DATE '2024-12-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS nov_contract_mrr_24
FROM
    subscription_tbl AS s
)

SELECT
    ROUND(
        ((o.nov_contract_mrr_24 - o.oct_contract_mrr_24)
        / NULLIF(o.oct_contract_mrr_24, 0))
        * 100.0,
        2
    ) AS contract_revenue_rate
FROM
    oct_nov_contract_revenue AS o;

/*
    TABLES OF VALUE:
        - Total Monthly Recurring Revenue: total_mrr_tbl
        - Revenue Growth Rate: revenue_growth_rate_tbl
        - Expansion Revenue Rate: expansion_rev_tbl
        - Contraction Revenue Rate: contraction_rev_tbl
    
    INSIGHTS:
    - Total revenue cannot be calculated because the dataset does not contain actual recognized/billed revenue. Therefore, 
        Total MRR is used as the available recurring-revenue metric.
    
    - MRR growth rate is estimated to show a declining trend beginning in Q3 2024.
    
    - Expansion MRR decreased by approximately 16.01% from October 2024 to November 2024, indicating less additional recurring revenue 
        generated through upgrades.
    
    - Contraction MRR also decreased by approximately 54.58% from October 2024 to November 2024, indicating a substantial reduction in 
        recurring revenue lost through downgrades.
*/