-- Bronze layer: raw data, loaded unchanged
-- Source: "Diabetes 130-US hospitals for years 1999-2008" (diabetic_data.csv)
-- Loaded into Databricks as retail_analysis.default.diabetic_data (no transformations)

-- Sanity check: expect 101,766 encounters
SELECT COUNT(*) AS raw_rows,
       COUNT(DISTINCT patient_nbr) AS raw_patients
FROM retail_analysis.default.diabetic_data;
