-- Gold layer: one encounter per patient (keeps observations independent)
CREATE OR REPLACE TABLE retail_analysis.default.readmit_first_encounter AS
SELECT * FROM retail_analysis.default.diabetic_data_clean
QUALIFY ROW_NUMBER() OVER (PARTITION BY patient_nbr ORDER BY encounter_id) = 1;
-- Check: 69,987 patients, 6,285 early readmissions (9.0%)
