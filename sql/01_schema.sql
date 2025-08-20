-- 01_schema.sql

-- Drop in FK-safe order (only if they exist)
DROP TABLE IF EXISTS billing       CASCADE;
DROP TABLE IF EXISTS treatments    CASCADE;
DROP TABLE IF EXISTS appointments  CASCADE;
DROP TABLE IF EXISTS doctors       CASCADE;
DROP TABLE IF EXISTS patients      CASCADE;

-- Patients
CREATE TABLE patients (
  patient_id         TEXT PRIMARY KEY,
  first_name         TEXT,
  last_name          TEXT,
  gender             TEXT,
  date_of_birth      DATE,
  contact_number     TEXT,
  address            TEXT,
  registration_date  DATE,
  insurance_provider TEXT,
  insurance_number   TEXT,
  email              TEXT
);

-- Doctors
CREATE TABLE doctors (
  doctor_id        TEXT PRIMARY KEY,
  first_name       TEXT,
  last_name        TEXT,
  specialization   TEXT,
  phone_number     TEXT,
  years_experience INT,
  hospital_branch  TEXT,
  email            TEXT
);

-- Appointments (merge CSV date+time → scheduled_at)
CREATE TABLE appointments (
  appointment_id   TEXT PRIMARY KEY,
  patient_id       TEXT NOT NULL REFERENCES patients(patient_id),
  doctor_id        TEXT NOT NULL REFERENCES doctors(doctor_id),
  scheduled_at     TIMESTAMP,
  reason_for_visit TEXT,
  status           TEXT
  -- Optional (uncomment if you choose to simulate booking times)
  -- , created_at   TIMESTAMP
);

-- Treatments
CREATE TABLE treatments (
  treatment_id   TEXT PRIMARY KEY,
  appointment_id TEXT NOT NULL REFERENCES appointments(appointment_id),
  treatment_type TEXT,
  description    TEXT,
  cost           NUMERIC(10,2),
  treatment_date DATE
);

-- Billing
CREATE TABLE billing (
  bill_id        TEXT PRIMARY KEY,
  patient_id     TEXT NOT NULL REFERENCES patients(patient_id),
  treatment_id   TEXT NOT NULL REFERENCES treatments(treatment_id),
  bill_date      DATE,
  amount         NUMERIC(12,2),
  payment_method TEXT,
  payment_status TEXT
);
