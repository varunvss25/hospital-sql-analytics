-- 07_views_mat.sql

-- Recreate clean
DROP VIEW IF EXISTS v_daily_kpis;
CREATE OR REPLACE VIEW v_daily_kpis AS
SELECT
  DATE(a.scheduled_at) AS appt_date,
  COUNT(*) AS total_appts,
  SUM((LOWER(a.status)='no-show')::int)::float / NULLIF(COUNT(*),0) AS no_show_rate,
  SUM(CASE WHEN LOWER(b.payment_status)='paid' THEN b.amount ELSE 0 END) AS paid_revenue
FROM appointments a
LEFT JOIN treatments t ON t.appointment_id = a.appointment_id
LEFT JOIN billing    b ON b.treatment_id   = t.treatment_id
GROUP BY DATE(a.scheduled_at);

DROP MATERIALIZED VIEW IF EXISTS mv_monthly_paid_revenue;
CREATE MATERIALIZED VIEW mv_monthly_paid_revenue AS
SELECT
  DATE_TRUNC('month', b.bill_date) AS month,
  SUM(CASE WHEN LOWER(b.payment_status)='paid' THEN b.amount ELSE 0 END) AS paid_revenue
FROM billing b
GROUP BY 1;

-- Refresh any time after data changes
REFRESH MATERIALIZED VIEW mv_monthly_paid_revenue;
