-- Cohort analysis on gold table: first encounter per patient (n = 69,987; overall 30-day readmission rate 9.0%)

-- 1. Readmission rate by age band
SELECT age,
       COUNT(*) AS patients,
       SUM(target_readmit_early) AS readmitted_30d,
       ROUND(100.0 * AVG(target_readmit_early), 1) AS readmit_rate_pct
FROM retail_analysis.default.readmit_first_encounter
GROUP BY age
ORDER BY age;

-- 2. Readmission rate by number of prior inpatient admissions
SELECT CASE WHEN number_inpatient >= 3 THEN '3+' ELSE CAST(number_inpatient AS STRING) END AS prior_inpatient_visits,
       COUNT(*) AS patients,
       ROUND(100.0 * AVG(target_readmit_early), 1) AS readmit_rate_pct
FROM retail_analysis.default.readmit_first_encounter
GROUP BY 1
ORDER BY 1;

-- 3. Risk segments (age and prior admissions) with share of all readmissions
WITH seg AS (
  SELECT *,
    CASE
      WHEN number_inpatient >= 1 AND age IN ('[70-80)','[80-90)','[90-100)') THEN '1. Aged 70+ with prior admission'
      WHEN number_inpatient >= 1 THEN '2. Under 70 with prior admission'
      WHEN age IN ('[70-80)','[80-90)','[90-100)') THEN '3. Aged 70+, no prior admission'
      ELSE '4. Everyone else'
    END AS segment
  FROM retail_analysis.default.readmit_first_encounter
)
SELECT segment,
       COUNT(*) AS patients,
       SUM(target_readmit_early) AS readmitted_30d,
       ROUND(100.0 * AVG(target_readmit_early), 1) AS readmit_rate_pct,
       ROUND(100.0 * SUM(target_readmit_early) / SUM(SUM(target_readmit_early)) OVER (), 1) AS pct_of_all_readmissions
FROM seg
GROUP BY segment
ORDER BY segment;

-- 4. Readmission rate by primary diagnosis group (ICD-9 grouping)
WITH d AS (
  SELECT *,
    CASE
      WHEN diag_1 LIKE '250%' THEN 'Diabetes'
      WHEN try_cast(diag_1 AS DOUBLE) BETWEEN 390 AND 459 OR try_cast(diag_1 AS DOUBLE) = 785 THEN 'Circulatory'
      WHEN try_cast(diag_1 AS DOUBLE) BETWEEN 460 AND 519 OR try_cast(diag_1 AS DOUBLE) = 786 THEN 'Respiratory'
      WHEN try_cast(diag_1 AS DOUBLE) BETWEEN 520 AND 579 OR try_cast(diag_1 AS DOUBLE) = 787 THEN 'Digestive'
      WHEN try_cast(diag_1 AS DOUBLE) BETWEEN 580 AND 629 OR try_cast(diag_1 AS DOUBLE) = 788 THEN 'Genitourinary'
      WHEN try_cast(diag_1 AS DOUBLE) BETWEEN 800 AND 999 THEN 'Injury'
      WHEN try_cast(diag_1 AS DOUBLE) BETWEEN 710 AND 739 THEN 'Musculoskeletal'
      WHEN try_cast(diag_1 AS DOUBLE) BETWEEN 140 AND 239 THEN 'Neoplasms'
      ELSE 'Other'
    END AS diagnosis_group
  FROM retail_analysis.default.readmit_first_encounter
)
SELECT diagnosis_group,
       COUNT(*) AS patients,
       ROUND(100.0 * AVG(target_readmit_early), 1) AS readmit_rate_pct
FROM d
GROUP BY diagnosis_group
ORDER BY readmit_rate_pct DESC;
