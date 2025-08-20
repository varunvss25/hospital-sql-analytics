-- 05_indexes.sql

-- Appointments
CREATE INDEX IF NOT EXISTS idx_appt_patient_time ON appointments(patient_id, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_appt_doctor_time  ON appointments(doctor_id, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_appt_status       ON appointments(status);

-- Treatments
CREATE INDEX IF NOT EXISTS idx_trt_appt          ON treatments(appointment_id);

-- Billing
CREATE INDEX IF NOT EXISTS idx_bill_patient_date ON billing(patient_id, bill_date);
CREATE INDEX IF NOT EXISTS idx_bill_treatment    ON billing(treatment_id);
CREATE INDEX IF NOT EXISTS idx_bill_status       ON billing(payment_status);

-- Benchmark example (record runtime)
EXPLAIN ANALYZE
SELECT DATE(scheduled_at), COUNT(*)
FROM appointments
GROUP BY 1;
