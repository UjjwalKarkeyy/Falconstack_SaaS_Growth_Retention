--CREATE OR REPLACE VIEW segment_info_tbl AS 
WITH info_tbl AS (
SELECT
    a.account_id,
    s.subscription_id,
    a.industry,
    CASE 
        WHEN a.is_trial = TRUE 
        THEN 'T'
        WHEN a.is_trial = FALSE
        THEN 'F'
        ELSE 'U'
    END AS is_trial,
    CASE 
        WHEN a.churn_flag = TRUE 
        THEN 'T'
        WHEN a.churn_flag = FALSE
        THEN 'F'
        ELSE 'U'
    END AS churn_flag
FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\accounts_cleaned.csv' AS a
LEFT JOIN 'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\subscriptions_cleaned.csv' AS s
    ON
    a.account_id = s.account_id
),
new_tbl AS (
SELECT
    i.*,
    f.usage_count,
    f.usage_duration_secs
FROM
    info_tbl AS i
LEFT JOIN 'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\feature_usage_cleaned.csv' AS f
    ON
    i.subscription_id = f.subscription_id
),
-- create subscription id ticket count
sub_ticket AS (
SELECT
    r.subscription_id,
    COUNT(s.account_id) AS support_ticket_count
FROM
    subscription_tbl AS r
LEFT JOIN 'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\support_tickets_cleaned.csv' AS s
    ON
    r.account_id = s.account_id
GROUP BY
    r.subscription_id
)

SELECT
    n.subscription_id,
    n.industry,
    n.is_trial,
    n.churn_flag,
    n.usage_count,
    n.usage_duration_secs,
    s.support_ticket_count
FROM
    new_tbl AS n
LEFT JOIN sub_ticket AS s
    ON
    n.subscription_id = s.subscription_id
