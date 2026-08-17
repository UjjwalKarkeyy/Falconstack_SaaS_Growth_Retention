/*
NRR, GRR
*/

--CREATE OR REPLACE VIEW mrr_components_vw AS
SELECT
    SUM(CASE
        WHEN s.start_date <= DATE '2024-10-01'
        AND (
            s.end_date_status = 'Ongoing'
            OR s.end_date >= DATE '2024-10-01'
        )
        THEN s.mrr_amount
        ELSE 0
    END) AS oct_start_mrr,
    SUM(CASE
        WHEN s.start_date <= DATE '2024-11-01'
        AND (
            s.end_date_status = 'Ongoing'
            OR s.end_date >= DATE '2024-11-01'
        )
        THEN s.mrr_amount
        ELSE 0
    END) AS nov_start_mrr,
    SUM(CASE
        WHEN s.upgrade_flag = 'T'
        AND s.start_date >= DATE '2024-10-01'
        AND s.start_date < DATE '2024-11-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS oct_expansion_mrr,
    SUM(CASE
        WHEN s.upgrade_flag = 'T'
        AND s.start_date >= DATE '2024-11-01'
        AND s.start_date < DATE '2024-12-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS nov_expansion_mrr,
    SUM(CASE
        WHEN s.downgrade_flag = 'T'
        AND s.start_date >= DATE '2024-10-01'
        AND s.start_date < DATE '2024-11-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS oct_contraction_mrr,
    SUM(CASE
        WHEN s.downgrade_flag = 'T'
        AND s.start_date >= DATE '2024-11-01'
        AND s.start_date < DATE '2024-12-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS nov_contraction_mrr,
    SUM(CASE
        WHEN s.churn_flag = 'T'
        AND s.end_date >= DATE '2024-10-01'
        AND s.end_date < DATE '2024-11-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS oct_churned_mrr,
    SUM(CASE
        WHEN s.churn_flag = 'T'
        AND s.end_date >= DATE '2024-11-01'
        AND s.end_date < DATE '2024-12-01'
        THEN s.mrr_amount
        ELSE 0
    END) AS nov_churned_mrr
FROM
    subscription_tbl AS s;

--CREATE OR REPLACE VIEW nrr_grr_vw AS
SELECT
    ROUND(
        ((m.oct_start_mrr + m.oct_expansion_mrr - m.oct_contraction_mrr - m.oct_churned_mrr)
        / NULLIF(m.oct_start_mrr, 0))
        * 100.0,
        2
    ) AS oct_nrr,
    ROUND(
        ((m.nov_start_mrr + m.nov_expansion_mrr - m.nov_contraction_mrr - m.nov_churned_mrr)
        / NULLIF(m.nov_start_mrr, 0))
        * 100.0,
        2
    ) AS nov_nrr,
    ROUND(
        ((m.oct_start_mrr - m.oct_churned_mrr - m.oct_contraction_mrr)
        / NULLIF(m.oct_start_mrr, 0))
        * 100.0,
        2
    ) AS oct_grr,
    ROUND(
        ((m.nov_start_mrr - m.nov_churned_mrr - m.nov_contraction_mrr)
        / NULLIF(m.nov_start_mrr, 0))
        * 100.0,
        2
    ) AS nov_grr
FROM
    mrr_components_vw AS m;

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