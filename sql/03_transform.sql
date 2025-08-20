-- 03_transform.sql

-- Clear targets in FK order
TRUNCATE billing, treatments, appointments, doctors, patients;

-- Patients
INSERT INTO patients (
  patient_id, first_name, last_name, gender, date_of_birth,
  contact_number, address, registration_date, insurance_provider,
  insurance_number, email
)
SELECT
  NULLIF(BTRIM(patient_id,        '" '), ''),
  NULLIF(BTRIM(first_name,        '" '), ''),
  NULLIF(BTRIM(last_name,         '" '), ''),
  NULLIF(BTRIM(gender,            '" '), ''),
  CASE
    WHEN BTRIM(date_of_birth,     '" ') ~ '^[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}$'
      THEN TO_DATE(REPLACE(BTRIM(date_of_birth,'" '), '/', '-'), 'DD-MM-YYYY')
    WHEN BTRIM(date_of_birth,     '" ') ~ '^[0-9]{4}[-/][0-9]{2}[-/][0-9]{2}$'
      THEN TO_DATE(REPLACE(BTRIM(date_of_birth,'" '), '/', '-'), 'YYYY-MM-DD')
    ELSE NULL
  END,
  NULLIF(BTRIM(contact_number,    '" '), ''),
  NULLIF(BTRIM(address,           '" '), ''),
  CASE
    WHEN BTRIM(registration_date, '" ') ~ '^[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}$'
      THEN TO_DATE(REPLACE(BTRIM(registration_date,'" '), '/', '-'), 'DD-MM-YYYY')
    WHEN BTRIM(registration_date, '" ') ~ '^[0-9]{4}[-/][0-9]{2}[-/][0-9]{2}$'
      THEN TO_DATE(REPLACE(BTRIM(registration_date,'" '), '/', '-'), 'YYYY-MM-DD')
    ELSE NULL
  END,
  NULLIF(BTRIM(insurance_provider, '" '), ''),
  NULLIF(BTRIM(insurance_number,  '" '), ''),
  NULLIF(BTRIM(email,             '" '), '')
FROM stg.patients;

-- Doctors
INSERT INTO doctors (
  doctor_id, first_name, last_name, specialization, phone_number,
  years_experience, hospital_branch, email
)
SELECT
  NULLIF(BTRIM(doctor_id,        '" '), ''),
  NULLIF(BTRIM(first_name,       '" '), ''),
  NULLIF(BTRIM(last_name,        '" '), ''),
  NULLIF(BTRIM(specialization,   '" '), ''),
  NULLIF(BTRIM(phone_number,     '" '), ''),
  NULLIF(BTRIM(years_experience, '" '), '')::INT,
  NULLIF(BTRIM(hospital_branch,  '" '), ''),
  NULLIF(BTRIM(email,            '" '), '')
FROM stg.doctors;

-- Appointments: merge date + time → scheduled_at
INSERT INTO appointments (
  appointment_id, patient_id, doctor_id, scheduled_at, reason_for_visit, status
)
WITH norm AS (
  SELECT
    BTRIM(appointment_id,   '" ') AS appointment_id,
    BTRIM(patient_id,       '" ') AS patient_id,
    BTRIM(doctor_id,        '" ') AS doctor_id,
    REPLACE(BTRIM(appointment_date, '" '), '/', '-') AS appt_date,  -- prefers YYYY-MM-DD or DD-MM-YYYY
    BTRIM(appointment_time, '" ') AS appt_time,                      -- HH:MM or HH:MM:SS
    BTRIM(reason_for_visit, '" ') AS reason_for_visit,
    BTRIM(status,           '" ') AS status
  FROM stg.appointments
)
SELECT
  appointment_id,
  patient_id,
  doctor_id,
  CASE
    WHEN appt_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' AND appt_time ~ '^[0-9]{2}:[0-9]{2}:[0-9]{2}$'
      THEN TO_TIMESTAMP(appt_date || ' ' || appt_time, 'YYYY-MM-DD HH24:MI:SS')
    WHEN appt_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' AND appt_time ~ '^[0-9]{2}:[0-9]{2}$'
      THEN TO_TIMESTAMP(appt_date || ' ' || appt_time || ':00', 'YYYY-MM-DD HH24:MI:SS')
    WHEN appt_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' AND appt_time ~ '^[0-9]{2}:[0-9]{2}:[0-9]{2}$'
      THEN TO_TIMESTAMP(appt_date || ' ' || appt_time, 'DD-MM-YYYY HH24:MI:SS')
    WHEN appt_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' AND appt_time ~ '^[0-9]{2}:[0-9]{2}$'
      THEN TO_TIMESTAMP(appt_date || ' ' || appt_time || ':00', 'DD-MM-YYYY HH24:MI:SS')
    ELSE NULL
  END AS scheduled_at,
  NULLIF(reason_for_visit,''),
  NULLIF(status,'')
FROM norm;

-- Treatments
INSERT INTO treatments (
  treatment_id, appointment_id, treatment_type, description, cost, treatment_date
)
SELECT
  NULLIF(BTRIM(treatment_id,   '" '), ''),
  NULLIF(BTRIM(appointment_id, '" '), ''),
  NULLIF(BTRIM(treatment_type, '" '), ''),
  NULLIF(BTRIM(description,    '" '), ''),
  CASE
    WHEN NULLIF(BTRIM(cost,'" '), '') IS NOT NULL
      THEN REPLACE(BTRIM(cost,'" '), ',', '')::NUMERIC(10,2)
    ELSE NULL
  END,
  CASE
    WHEN BTRIM(treatment_date,'" ') ~ '^[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}$'
      THEN TO_DATE(REPLACE(BTRIM(treatment_date,'" '), '/', '-'), 'DD-MM-YYYY')
    WHEN BTRIM(treatment_date,'" ') ~ '^[0-9]{4}[-/][0-9]{2}[-/][0-9]{2}$'
      THEN TO_DATE(REPLACE(BTRIM(treatment_date,'" '), '/', '-'), 'YYYY-MM-DD')
    ELSE NULL
  END
FROM stg.treatments;

-- Billing
INSERT INTO billing (
  bill_id, patient_id, treatment_id, bill_date, amount, payment_method, payment_status
)
SELECT
  NULLIF(BTRIM(bill_id,      '" '), ''),
  NULLIF(BTRIM(patient_id,   '" '), ''),
  NULLIF(BTRIM(treatment_id, '" '), ''),
  CASE
    WHEN BTRIM(bill_date,'" ') ~ '^[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}$'
      THEN TO_DATE(REPLACE(BTRIM(bill_date,'" '), '/', '-'), 'DD-MM-YYYY')
    WHEN BTRIM(bill_date,'" ') ~ '^[0-9]{4}[-/][0-9]{2}[-/][0-9]{2}$'
      THEN TO_DATE(REPLACE(BTRIM(bill_date,'" '), '/', '-'), 'YYYY-MM-DD')
    ELSE NULL
  END,
  CASE
    WHEN NULLIF(BTRIM(amount,'" '), '') IS NOT NULL
      THEN REPLACE(BTRIM(amount,'" '), ',', '')::NUMERIC(12,2)
    ELSE NULL
  END,
  NULLIF(BTRIM(payment_method,'" '), ''),
  NULLIF(BTRIM(payment_status,'" '), '');

-- Simulating booking times 1–30 days before scheduled_at
ALTER TABLE appointments ADD COLUMN created_at TIMESTAMP;
UPDATE appointments
SET created_at = scheduled_at - (INTERVAL '1 day' * (random() * 30)::int);

