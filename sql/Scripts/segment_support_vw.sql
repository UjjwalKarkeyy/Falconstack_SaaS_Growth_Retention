CREATE OR REPLACE VIEW segment_support_vw AS

WITH account_info AS (

    SELECT
        a.account_id,
        a.industry,
        a.country,
        a.referral_source,
        a.plan_tier,

        COALESCE(
            s.support_ticket_count,
            0
        ) AS support_ticket_count,

        s.avg_resolution_hours,
        s.avg_first_response_minutes,
        s.avg_satisfaction_score,
        s.escalation_count

    FROM
        'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\accounts_cleaned.csv' AS a

    LEFT JOIN
        account_support_vw AS s

    ON
        a.account_id = s.account_id
),

segment_data AS (

    SELECT
        'Industry' AS segment_type,
        industry AS segment_name,
        *
    FROM account_info

    UNION ALL

    SELECT
        'Country',
        country,
        *
    FROM account_info

    UNION ALL

    SELECT
        'Referral Source',
        referral_source,
        *
    FROM account_info

    UNION ALL

    SELECT
        'Plan Tier',
        plan_tier,
        *
    FROM account_info
)

SELECT
    segment_type,
    segment_name,

    COUNT(DISTINCT account_id)
        AS account_count,

    SUM(support_ticket_count)
        AS support_ticket_count,

    100.0 *
    SUM(support_ticket_count)
    /
    NULLIF(
        COUNT(DISTINCT account_id),
        0
    ) AS tickets_per_100_accounts,

    AVG(avg_resolution_hours)
        AS avg_resolution_hours,

    AVG(avg_first_response_minutes)
        AS avg_first_response_minutes,

    AVG(avg_satisfaction_score)
        AS avg_satisfaction_score,

    SUM(escalation_count)
        AS escalation_count

FROM
    segment_data

WHERE
    segment_name IS NOT NULL

GROUP BY
    segment_type,
    segment_name;