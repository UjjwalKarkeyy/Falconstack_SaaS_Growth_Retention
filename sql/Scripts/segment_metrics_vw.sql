CREATE OR REPLACE VIEW segment_metrics_vw AS

WITH segment_data AS (

    SELECT
        'Industry' AS segment_type,
        industry AS segment_name,
        *
    FROM segment_subscription_info_vw

    UNION ALL

    SELECT
        'Country',
        country,
        *
    FROM segment_subscription_info_vw

    UNION ALL

    SELECT
        'Referral Source',
        referral_source,
        *
    FROM segment_subscription_info_vw

    UNION ALL

    SELECT
        'Plan Tier',
        plan_tier,
        *
    FROM segment_subscription_info_vw
)

SELECT
    segment_type,
    segment_name,

    COUNT(DISTINCT subscription_id)
        AS total_subscriptions,

    COUNT(
        DISTINCT CASE
            WHEN churn_flag = TRUE
            THEN subscription_id
        END
    ) AS churned_subscriptions,

    100.0 *
    COUNT(
        DISTINCT CASE
            WHEN churn_flag = TRUE
            THEN subscription_id
        END
    )
    /
    NULLIF(
        COUNT(DISTINCT subscription_id),
        0
    ) AS churn_rate,

    SUM(
        CASE
            WHEN is_active = TRUE
            THEN arr_amount
            ELSE 0
        END
    ) AS active_arr,

    AVG(total_usage_count)
        AS avg_usage_count,

    AVG(total_usage_duration_secs)
        AS avg_usage_duration_secs,

    AVG(feature_breadth)
        AS avg_feature_breadth,

    AVG(total_error_count)
        AS avg_error_count

FROM
    segment_data

WHERE
    segment_name IS NOT NULL

GROUP BY
    segment_type,
    segment_name;