/*
NRR, GRR
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
-- table for start, expansion, contraction, and churned MRR
mrr_tbl AS (
SELECT
    -- STARTING MRR
    SUM(
        CASE
            WHEN s.start_date <= '2024-10-01'
             AND (
                 s.end_date = 'Ongoing'
                 OR s.end_date >= '2024-10-01'
             )
            THEN s.mrr_amount
            ELSE 0
        END
    ) AS oct_start_mrr,
    SUM(
        CASE
            WHEN s.start_date <= '2024-11-01'
             AND (
                 s.end_date = 'Ongoing'
                 OR s.end_date >= '2024-11-01'
             )
            THEN s.mrr_amount
            ELSE 0
        END
    ) AS nov_start_mrr,
    -- EXPANSION MRR
    SUM(
        CASE
            WHEN s.upgrade_flag = 'T'
             AND s.start_date >= '2024-10-01'
             AND s.start_date < '2024-11-01'
            THEN s.mrr_amount
            ELSE 0
        END
    ) AS oct_expansion_mrr,
    SUM(
        CASE
            WHEN s.upgrade_flag = 'T'
             AND s.start_date >= '2024-11-01'
             AND s.start_date < '2024-12-01'
            THEN s.mrr_amount
            ELSE 0
        END
    ) AS nov_expansion_mrr,
    -- CONTRACTION MRR
    SUM(
        CASE
            WHEN s.downgrade_flag = 'T'
             AND s.start_date >= '2024-10-01'
             AND s.start_date < '2024-11-01'
            THEN s.mrr_amount
            ELSE 0
        END
    ) AS oct_contraction_mrr,
    SUM(
        CASE
            WHEN s.downgrade_flag = 'T'
             AND s.start_date >= '2024-11-01'
             AND s.start_date < '2024-12-01'
            THEN s.mrr_amount
            ELSE 0
        END
    ) AS nov_contraction_mrr,
    -- CHURNED MRR
    SUM(
        CASE
            WHEN s.churn_flag = 'T'
             AND s.end_date >= '2024-10-01'
             AND s.end_date < '2024-11-01'
            THEN s.mrr_amount
            ELSE 0
        END
    ) AS oct_churned_mrr,
    SUM(
        CASE
            WHEN s.churn_flag = 'T'
             AND s.end_date >= '2024-11-01'
             AND s.end_date < '2024-12-01'
            THEN s.mrr_amount
            ELSE 0
        END
    ) AS nov_churned_mrr
FROM
    subscription_tbl AS s
),
nrr_grr_tbl AS (
SELECT
        ROUND((
            (m.oct_start_mrr + m.oct_expansion_mrr - m.oct_contraction_mrr - m.oct_churned_mrr)
            / NULLIF(m.oct_start_mrr, 0))
            * 100.0,
            2
        ) AS oct_nrr,
        ROUND((
            (m.nov_start_mrr + m.nov_expansion_mrr - m.nov_contraction_mrr - m.nov_churned_mrr)
            / NULLIF(m.nov_start_mrr, 0))
            * 100.0,
            2
        ) AS nov_nrr,
        ROUND((
            (m.oct_start_mrr - m.oct_churned_mrr - m.oct_contraction_mrr)
            / NULLIF(m.oct_start_mrr, 0))
            * 100.0,
            2
        ) AS oct_grr,
        ROUND((
            (m.nov_start_mrr - m.nov_churned_mrr - m.nov_contraction_mrr )
            / NULLIF(m.nov_start_mrr, 0))
            * 100.0,
            2
        ) AS nov_grr
FROM
    mrr_tbl AS m
)

SELECT
    *
FROM
    nrr_grr_tbl;

/*
    TABLES OF VALUE:
        - NRR: nrr_grr_tbl
        - GRR: nrr_grr_tbl
        
    INSIGHTS:
    - Both NRR and GRR decreased slightly from October to November 2024.
    - NRR decreased from 99.46% in October to 98.77% in November, a decline of 0.69 percentage points.
    - GRR remained relatively stable, decreasing only slightly from 97.18% to 97.14%, a decline of 0.04 percentage points.
    - NRR remained below 100% in both months, indicating that expansion MRR was not sufficient to fully offset MRR lost through contraction and churn.
    - The larger decline in NRR compared with GRR suggests that the change was driven more by weaker expansion performance than by 
        increased contraction or churn.
*/
