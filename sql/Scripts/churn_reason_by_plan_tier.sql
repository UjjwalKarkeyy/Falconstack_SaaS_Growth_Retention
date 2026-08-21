--CREATE OR REPLACE VIEW churn_reason_per_tier AS 
WITH info_table AS (
SELECT
        c.account_id,
        c.reason_code,
        s.plan_tier
FROM
        'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\churn_events_cleaned.csv' AS c
LEFT JOIN
        'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\subscriptions_cleaned.csv' AS s
        ON
    c.account_id = s.account_id
),
-- create reason count for each tier and reasons
reason_count AS (
SELECT
        plan_tier,
        reason_code,
        COUNT(*) AS reason_count
FROM
    info_table
GROUP BY
        plan_tier,
        reason_code
)
-- final reason count ratio as final output
SELECT
    plan_tier,
    reason_code,
    reason_count,

    ROUND(
        1.0 * reason_count /
        SUM(reason_count) OVER (PARTITION BY plan_tier),
        4
    ) AS reason_count_ratio
FROM
    reason_count
ORDER BY
    plan_tier,
    reason_code;