/*
ARPU, LTV
*/

--CREATE OR REPLACE VIEW arpu_ltv_vw AS
WITH info_tbl AS (
SELECT
    s.account_id,
    s.mrr_amount,
    s.start_date,
    s.end_date,
    s.end_date_status,
    a.churn_date
FROM
    subscription_tbl AS s
LEFT JOIN accounts_tbl AS a
    ON
    s.account_id = a.account_id
),
setup_tbl AS (
SELECT
    m.mnth,
    SUM(CASE
        WHEN i.start_date <= m.mnth
        AND (
            i.end_date_status = 'Ongoing'
            OR i.end_date >= m.mnth + INTERVAL '1 month'
        )
        AND (
            i.churn_date IS NULL
            OR i.churn_date >= m.mnth + INTERVAL '1 month'
        )
        THEN i.mrr_amount
        ELSE 0
    END) AS total_mrr,
    COUNT(DISTINCT CASE
        WHEN i.start_date <= m.mnth
        AND (
            i.end_date_status = 'Ongoing'
            OR i.end_date >= m.mnth + INTERVAL '1 month'
        )
        AND (
            i.churn_date IS NULL
            OR i.churn_date >= m.mnth + INTERVAL '1 month'
        )
        THEN i.account_id
    END) AS active_cus
FROM
    info_tbl AS i
CROSS JOIN mnths_list AS m
GROUP BY
    m.mnth
),
arpu_tbl AS (
SELECT
    s.*,
    ROUND(
        s.total_mrr
        / NULLIF(s.active_cus, 0),
        2
    ) AS arpu
FROM
    setup_tbl AS s
)

SELECT
    a.*,
    ROUND(
        a.arpu
        / NULLIF(c.cus_churn_rate / 100.0, 0),
        2
    ) AS ltv,
    c.cus_churn_rate
FROM
    arpu_tbl AS a
LEFT JOIN customer_churn_rate_vw AS c
    ON
    a.mnth = c.mnth
ORDER BY
    a.mnth;

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
