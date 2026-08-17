/*
ARPU, LTV
*/
-- using view 'subscription_tbl' and left join on view 'accounts_tbl'
WITH info_tbl AS (
SELECT 
    s.account_id,
    s.mrr_amount,
    s.start_date,
    s.end_date,
    a.churn_date
FROM
    subscription_tbl AS s
LEFT JOIN accounts_tbl AS a
    ON
    s.account_id = a.account_id
),
-- setup table for arpu calculation
setup_tbl AS (
SELECT
    STRFTIME(m.mnth, '%Y-%m') AS mnth,

    SUM(
        CASE
            WHEN CAST(i.start_date AS DATE) <= m.mnth
            AND (
                i.end_date IN ('Ongoing', 'Unknown')
                OR TRY_CAST(i.end_date AS DATE) >= m.mnth + INTERVAL '1 month'
            )
            AND (
                i.churn_date IS NULL
                OR TRY_CAST(i.churn_date AS DATE) >= m.mnth + INTERVAL '1 month'
            )
            THEN i.mrr_amount
            ELSE 0
        END
    ) AS total_mrr,

    COUNT(
        DISTINCT CASE
            WHEN CAST(i.start_date AS DATE) <= m.mnth
            AND (
                i.end_date IN ('Ongoing', 'Unknown')
                OR TRY_CAST(i.end_date AS DATE) >= m.mnth + INTERVAL '1 month'
            )
            AND (
                i.churn_date IS NULL
                OR TRY_CAST(i.churn_date AS DATE) >= m.mnth + INTERVAL '1 month'
            )
            THEN i.account_id
        END
    ) AS active_cus
FROM
    info_tbl AS i
CROSS JOIN mnths_list AS m
GROUP BY
    m.mnth
ORDER BY
    m.mnth
),
-- create arpu table
arpu_tbl AS (
SELECT
    s.*,
    ROUND(
        s.total_mrr
        / NULLIF(s.active_cus, 0)
        , 2
    ) AS arpu
FROM
    setup_tbl AS s
),
-- using view 'cus_churn_rate_tbl' for ltv
ltv_arpu_tbl AS (
SELECT
    a.*,
    ROUND(
        a.arpu
        / NULLIF(c.cus_churn_rate / 100.0, 0)
        , 2
    ) AS ltv,
    c.cus_churn_rate
FROM
    arpu_tbl AS a
LEFT JOIN cus_churn_rate_tbl AS c
    ON
    a.mnth = c.mnth
)

SELECT
    l.*
FROM
    ltv_arpu_tbl AS l;

/*
    TABLES OF VALUE:
        - ARPU: ltv_arpu_tbl
        - LTV: ltv_arpu_tbl
        
    INSIGHTS:
        - MRR grew strongly until around Sep 2024, then started declining
        - Active customers peaked at 227 in Aug 2024, then fell sharply to 142 by Dec
        - ARPU kept increasing, meaning remaining customers were worth more on average
        - Churn rose significantly, reaching 36.82% in Dec 2024
        - As churn increased, LTV dropped heavily despite higher ARPU
        - Growth was strong, but worsening churn became the key problem in late 2024
*/
