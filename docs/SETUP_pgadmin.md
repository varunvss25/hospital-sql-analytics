# SETUP (PostgreSQL + pgAdmin) — Hospital SQL Analytics

This guide rebuilds the project from scratch using pgAdmin.

## Prereqs
- PostgreSQL 14+ (15+ preferred)
- pgAdmin 4
- Git

## 1) Create database
1. Open **pgAdmin** → connect to your local server.
2. Right-click **Databases** → **Create → Database…**
3. Name: **hospital** → Save.

## 2) Run schema & staging scripts
1. Right-click **hospital** → **Query Tool**.
2. Open `sql/01_schema.sql` → **Execute** (lightning icon).
3. Open `sql/02_staging.sql` → **Execute**.

This creates final tables and empty staging tables (`stg.*`).

## 3) Import CSVs into staging
Import to **stg.\*** tables using pgAdmin’s **Import/Export** dialog.

For each table:

- Right-click the staging table (e.g., **stg.appointments**) → **Import/Export Data…**
- **Import**: ON  
- **Filename**: your CSV file  
- **Format**: CSV  
- **Header**: ✓  
- **Delimiter**: match your file (`,` or **Tab**).  
  - If your file looks like `"A001"    "P034" ...`, set **Delimiter** to a **Tab** and **Quote** to `"`  
- **Quote**: `"`  
- **Encoding**: UTF8  
- **Columns** tab: verify the order and count match the CSV header.

Repeat for: `stg.patients`, `stg.doctors`, `stg.appointments`, `stg.treatments`, `stg.billing`.

### Quick checks
```sql
SELECT COUNT(*) FROM stg.patients;
SELECT COUNT(*) FROM stg.doctors;
SELECT COUNT(*) FROM stg.appointments;
SELECT COUNT(*) FROM stg.treatments;
SELECT COUNT(*) FROM stg.billing;

-- Spot check date/time landed (no blanks)
SELECT appointment_id, appointment_date, appointment_time FROM stg.appointments LIMIT 10;
```

## 4) Transform → final tables
Run:

```sql
\i sql/03_transform.sql
```

This trims quotes/spaces, parses dates/times, merges `appointment_date + appointment_time → scheduled_at`, and inserts into final tables.

## 5) Quality checks & indexes
Run:

```sql
\i sql/04_quality.sql
\i sql/05_indexes.sql
```

(Counts, orphan checks, useful indexes + a sample EXPLAIN.)

## 6) Analytics & views
Run:

```sql
\i sql/06_analytics.sql
\i sql/07_views_mat.sql
```

(View + materialized view.)

## 7) Export sample outputs (for GitHub)
In pgAdmin result grid:
- Right-click → **Save Data** → **CSV**
- Save to: `sample_outputs/` as:
  - `daily_appointments.csv` (A)
  - `lead_time_summary.csv` (B) *(only if you added `created_at`)*
  - `no_show_heatmap.csv` (C)
  - `daily_collections.csv` (D)
  - `monthly_revenue_by_specialty.csv` (E)
  - `patient_ltv.csv` (F)

## Troubleshooting
- **All NULL dates**: check regex/date format; use provided transform (handles `-`/`/`, trims quotes).
- **scheduled_at NULL**: likely wrong **Delimiter/Quote** on import. Re-import `stg.appointments` using correct settings.
- **TRUNCATE blocked**: use `TRUNCATE appointments CASCADE;` or truncate in child→parent order (treatments → appointments).
- **Windows COPY permissions**: use **Import/Export Data…** instead of `COPY FROM` in Query Tool (server can’t see your local path).
