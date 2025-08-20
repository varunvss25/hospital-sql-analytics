-- 06_analytics.sql

-- A) Daily appointment volume & outcomes
SELECT
  DATE(scheduled_at) AS appt_date,
  COUNT(*) AS total,
  SUM((LOWER(status)='completed')::int) AS completed,
  SUM((LOWER(status)='cancelled')::int) AS cancelled,
  SUM((LOWER(status)='no-show')::int)  AS no_show,
  SUM((LOWER(status)='scheduled')::int) AS still_scheduled
FROM appointments
GROUP BY 1
ORDER BY 1;

-- B) Lead time 
WITH lead_times AS (
   SELECT EXTRACT(EPOCH FROM (scheduled_at - created_at))/3600.0 AS lead_h
   FROM appointments
   WHERE scheduled_at IS NOT NULL AND created_at IS NOT NULL
)
SELECT 
   ROUND(AVG(lead_times.lead_h),2) AS avg_h,
   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lead_times.lead_h) AS p50_h,
   PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY lead_times.lead_h) AS p90_h
FROM lead_times;

-- C) No-show heatmap by weekday × hour
SELECT
  TO_CHAR(scheduled_at,'Dy') AS dow,
  EXTRACT(HOUR FROM scheduled_at) AS hour_of_day,
  ROUND(AVG((LOWER(status)='no-show')::int)::numeric, 3) AS no_show_rate
FROM appointments
WHERE scheduled_at IS NOT NULL
GROUP BY 1,2
ORDER BY 1,2;

-- D) Charges vs. collected per bill_date
SELECT
  bill_date,
  SUM(amount) AS charges,
  SUM(CASE WHEN LOWER(payment_status)='paid' THEN amount ELSE 0 END) AS collected,
  ROUND(
    100.0 * SUM(CASE WHEN LOWER(payment_status)='paid' THEN amount ELSE 0 END)
    / NULLIF(SUM(amount),0), 2
  ) AS collection_rate_pct
FROM billing
GROUP BY bill_date
ORDER BY bill_date;

-- E) Monthly paid revenue by doctor specialization
SELECT
  DATE_TRUNC('month', b.bill_date) AS month,
  d.specialization,
  SUM(CASE WHEN LOWER(b.payment_status)='paid' THEN b.amount ELSE 0 END) AS paid_revenue
FROM billing b
JOIN treatments t   ON t.treatment_id   = b.treatment_id
JOIN appointments a ON a.appointment_id = t.appointment_id
JOIN doctors d      ON d.doctor_id      = a.doctor_id
GROUP BY 1,2
ORDER BY month, paid_revenue DESC;

-- F) Patient lifetime value proxy (paid sums) + visits
SELECT
  p.patient_id,
  p.first_name,
  p.last_name,
  COUNT(DISTINCT a.appointment_id) AS visits,
  SUM(CASE WHEN LOWER(b.payment_status)='paid' THEN b.amount ELSE 0 END) AS lifetime_paid
FROM patients p
LEFT JOIN appointments a ON a.patient_id = p.patient_id
LEFT JOIN treatments  t  ON t.appointment_id = a.appointment_id
LEFT JOIN billing     b  ON b.treatment_id   = t.treatment_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY lifetime_paid DESC NULLS LAST;
