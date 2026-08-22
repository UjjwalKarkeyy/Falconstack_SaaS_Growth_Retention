CREATE OR REPLACE VIEW segment_subscription_info_vw AS

SELECT
    s.subscription_id,
    s.account_id,

    s.industry,
    s.country,
    s.referral_source,
    s.plan_tier,

    s.arr_amount,
    s.mrr_amount,
    s.is_trial,
    s.churn_flag,
    s.is_active,

    COALESCE(u.total_usage_count, 0) AS total_usage_count,

    COALESCE(
        u.total_usage_duration_secs,
        0
    ) AS total_usage_duration_secs,

    COALESCE(
        u.feature_breadth,
        0
    ) AS feature_breadth,

    COALESCE(
        u.total_error_count,
        0
    ) AS total_error_count

FROM
    subscription_base_vw AS s

LEFT JOIN
    subscription_usage_vw AS u

ON
    s.subscription_id = u.subscription_id;
