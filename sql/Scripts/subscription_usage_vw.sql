CREATE OR REPLACE VIEW subscription_usage_vw AS

SELECT
    subscription_id,

    SUM(usage_count) AS total_usage_count,
    SUM(usage_duration_secs) AS total_usage_duration_secs,

    COUNT(DISTINCT feature_name) AS feature_breadth,

    SUM(error_count) AS total_error_count,

    SUM(
        CASE
            WHEN is_beta_feature = TRUE THEN usage_count
            ELSE 0
        END
    ) AS beta_usage_count

FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\feature_usage_cleaned.csv'

GROUP BY
    subscription_id;