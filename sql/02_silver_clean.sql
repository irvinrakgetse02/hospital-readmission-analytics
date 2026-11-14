-- Silver layer: cleaned encounter-level table (99,340 rows)
-- Source: retail_analysis.default.diabetic_data (bronze, 101,766 rows)
--
-- Cleaning decisions (all verified against the cleaned table):
-- 1. Remove 2,426 rows:
--      - 1,652 patients who died in hospital (discharge codes 11, 19, 20)
--      -   771 patients discharged to hospice (codes 13, 14)
--      -     3 rows with invalid gender ('Unknown/Invalid')
--    Patients who died or went to hospice cannot be readmitted, so keeping them
--    would understate the readmission rate.
-- 2. Drop `weight` (almost entirely missing in the original data).
-- 3. Keep missing values as an explicit category instead of dropping rows:
--      race ('?' -> 'Unknown'), payer_code ('?' -> 'Unknown'),
--      medical_specialty ('?' -> 'Missing').
-- 4. Keep the original outcome as readmitted_raw and add two target columns:
--      target_readmit_early = readmitted within 30 days ('<30')
--      target_readmit_any   = readmitted at any time ('<30' or '>30')
-- 5. ID columns are stored as strings (they are codes, not quantities).
-- ICD-9 diagnosis grouping is done at analysis time: see 04_cohort_analysis.sql.

CREATE OR REPLACE TABLE retail_analysis.default.diabetic_data_clean_rebuild AS
SELECT
  * EXCEPT (weight, readmitted, race, payer_code, medical_specialty,
            admission_type_id, discharge_disposition_id, admission_source_id),
  CASE WHEN race = '?' THEN 'Unknown' ELSE race END AS race,
  CASE WHEN payer_code = '?' THEN 'Unknown' ELSE payer_code END AS payer_code,
  CASE WHEN medical_specialty = '?' THEN 'Missing' ELSE medical_specialty END AS medical_specialty,
  CAST(admission_type_id AS STRING) AS admission_type_id,
  CAST(discharge_disposition_id AS STRING) AS discharge_disposition_id,
  CAST(admission_source_id AS STRING) AS admission_source_id,
  readmitted AS readmitted_raw,
  CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END AS target_readmit_early,
  CASE WHEN readmitted IN ('<30', '>30') THEN 1 ELSE 0 END AS target_readmit_any
FROM retail_analysis.default.diabetic_data
WHERE discharge_disposition_id NOT IN (11, 13, 14, 19, 20, 21)
  AND gender <> 'Unknown/Invalid';

-- Validation: the rebuilt table must match the existing silver table
SELECT 'rebuild' AS src, COUNT(*) AS n, SUM(target_readmit_early) AS early, SUM(target_readmit_any) AS any_readmit,
       SUM(CASE WHEN race = 'Unknown' THEN 1 ELSE 0 END) AS race_unknown,
       SUM(CASE WHEN payer_code = 'Unknown' THEN 1 ELSE 0 END) AS payer_unknown,
       SUM(CASE WHEN medical_specialty = 'Missing' THEN 1 ELSE 0 END) AS specialty_missing
FROM retail_analysis.default.diabetic_data_clean_rebuild
UNION ALL
SELECT 'clean', COUNT(*), SUM(target_readmit_early), SUM(target_readmit_any),
       SUM(CASE WHEN race = 'Unknown' THEN 1 ELSE 0 END),
       SUM(CASE WHEN payer_code = 'Unknown' THEN 1 ELSE 0 END),
       SUM(CASE WHEN medical_specialty = 'Missing' THEN 1 ELSE 0 END)
FROM retail_analysis.default.diabetic_data_clean;
