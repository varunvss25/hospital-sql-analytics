-- 04_quality.sql

-- Row counts
SELECT 'patients' tbl, COUNT(*) FROM patients
UNION ALL SELECT 'doctors', COUNT(*) FROM doctors
UNION ALL SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL SELECT 'treatments', COUNT(*) FROM treatments
UNION ALL SELECT 'billing', COUNT(*) FROM billing;

-- Orphan checks
SELECT COUNT(*) AS trt_without_appt
FROM treatments t LEFT JOIN appointments a ON a.appointment_id = t.appointment_id
WHERE a.appointment_id IS NULL;

SELECT COUNT(*) AS bills_without_treatment
FROM billing b LEFT JOIN treatments t ON t.treatment_id = b.treatment_id
WHERE t.treatment_id IS NULL;

SELECT COUNT(*) AS bills_without_patient
FROM billing b LEFT JOIN patients p ON p.patient_id = b.patient_id
WHERE p.patient_id IS NULL;
