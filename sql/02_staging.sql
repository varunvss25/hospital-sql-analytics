-- 02_staging.sql

DROP SCHEMA IF EXISTS stg CASCADE;
CREATE SCHEMA stg;

CREATE TABLE stg.patients (
  patient_id TEXT, first_name TEXT, last_name TEXT, gender TEXT,
  date_of_birth TEXT, contact_number TEXT, address TEXT, registration_date TEXT,
  insurance_provider TEXT, insurance_number TEXT, email TEXT
);

CREATE TABLE stg.doctors (
  doctor_id TEXT, first_name TEXT, last_name TEXT, specialization TEXT,
  phone_number TEXT, years_experience TEXT, hospital_branch TEXT, email TEXT
);

CREATE TABLE stg.appointments (
  appointment_id TEXT, patient_id TEXT, doctor_id TEXT,
  appointment_date TEXT, appointment_time TEXT,
  reason_for_visit TEXT, status TEXT
);

CREATE TABLE stg.treatments (
  treatment_id TEXT, appointment_id TEXT, treatment_type TEXT,
  description TEXT, cost TEXT, treatment_date TEXT
);

CREATE TABLE stg.billing (
  bill_id TEXT, patient_id TEXT, treatment_id TEXT,
  bill_date TEXT, amount TEXT, payment_method TEXT, payment_status TEXT
);
