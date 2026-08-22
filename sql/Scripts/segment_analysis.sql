SELECT
    s.industry,
    s.is_trial,
    s.churn_flag,
    s.usage_count,
    s.usage_duration_secs,
    s.support_ticket_count
FROM
    segment_info_tbl AS s
LIMIT 10;