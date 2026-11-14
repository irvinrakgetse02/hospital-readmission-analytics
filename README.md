# Hospital Readmission Risk Analytics

> Which diabetic patients are most likely to be readmitted within 30 days, what drives it, and what could reducing it save?

- **Tools:** Databricks (SQL), Power BI (DAX), Python/SQL for statistics
- **Data:** Diabetes 130-US Hospitals (1999-2008), 101,766 encounters, 130 hospitals

## 1. Business problem
Unplanned 30-day readmissions are costly for hospitals and a marker of care quality. This project identifies which patient groups are at highest risk and quantifies the potential saving from targeted follow-up.

**Headline result:** Patients with 3+ prior admissions are 3.3x more likely to be readmitted within 30 days than patients with none (26.5% vs 8.1%). The 12% of patients with at least one prior admission account for about 20% of all early readmissions, making them the natural group for targeted follow-up.

## 2. Data pipeline (Bronze / Silver / Gold)
| Layer | Table | What happens |
|-------|-------|--------------|
| Bronze | `diabetic_data_raw` | Raw CSV, untouched |
| Silver | `diabetic_data_clean` | Cleaning, `?` handling, type fixes, target columns. 99,340 rows |
| Gold | `readmit_first_encounter` | One encounter per patient. 69,987 rows, 6,285 early readmissions (9.0%) |

### Cleaning decisions
- _(Why 2,426 rows were removed from the original 101,766. Fill in.)_
- _(How missing values `?` were handled per column.)_
- _(How ICD-9 diagnosis codes were grouped.)_

### Key design decisions
- **Target:** `target_readmit_early` = readmitted in under 30 days. Chosen over "any readmission" (47% of encounters) because it is the standard, actionable business definition.
- **One encounter per patient:** The silver table has 99,340 encounters but only 69,987 patients, so about 29,000 encounters belong to patients already counted. Repeat encounters are not independent, so the analysis uses each patient's first encounter to avoid overstating statistical certainty. The early readmission rate is 11.4% of encounters (11,314 of 99,340) before this step and 9.0% of patients (6,285 of 69,987) after it.
- **Class imbalance:** Only 9% of patients are positive, so accuracy is misleading. Results are reported with recall, precision and PR-AUC.

## 3. SQL analysis
All figures use the gold table (first encounter per patient, n = 69,987; overall 30-day readmission rate 9.0%). The queries are in [`/sql/04_cohort_analysis.sql`](sql/04_cohort_analysis.sql).

### Readmission rate by age
| Age band | Patients | 30-day readmission rate |
|---|---|---|
| 0-10 | 153 | 2.0% |
| 10-20 | 534 | 4.9% |
| 20-30 | 1,121 | 7.4% |
| 30-40 | 2,692 | 7.0% |
| 40-50 | 6,828 | 7.4% |
| 50-60 | 12,351 | 7.1% |
| 60-70 | 15,688 | 9.0% |
| 70-80 | 17,749 | 10.2% |
| 80-90 | 11,110 | 10.8% |
| 90-100 | 1,761 | 9.5% |

Rates are about 7% for ages 20-60 and rise to 10.2% (70-80) and 10.8% (80-90). Groups under 20 have fewer than 700 patients, so their rates are not reliable.

### Readmission rate by prior inpatient admissions
| Prior admissions | Patients | 30-day readmission rate |
|---|---|---|
| 0 | 61,792 | 8.1% |
| 1 | 5,798 | 12.9% |
| 2 | 1,501 | 18.5% |
| 3+ | 896 | 26.5% |

Prior admissions are a stronger signal than age. This is an association, not proof of cause; the statistical analysis adjusts for other factors.

### Risk segments (age and prior admissions combined)
| Segment | Patients | 30-day readmission rate | Share of all readmissions |
|---|---|---|---|
| Aged 70+ with prior admission | 3,935 | 16.3% | 10.2% |
| Under 70 with prior admission | 4,260 | 14.6% | 9.9% |
| Aged 70+, no prior admission | 26,685 | 9.5% | 40.4% |
| Everyone else | 35,107 | 7.1% | 39.5% |

Patients with any prior admission are 11.7% of the population but 20.1% of early readmissions, with a rate of about 15%, around 1.7x the overall 9.0%. Prior admission history separates risk more clearly than age: under-70s with a prior admission (14.6%) are readmitted far more often than 70+ patients with none (9.5%). Targeted follow-up for patients with a prior admission is therefore more efficient than targeting by age.

### Readmission rate by primary diagnosis group
| Diagnosis group | Patients | 30-day readmission rate |
|---|---|---|
| Injury | 4,694 | 10.8% |
| Circulatory | 21,389 | 9.7% |
| Diabetes | 5,748 | 9.1% |
| Neoplasms | 2,538 | 9.1% |
| Other | 12,134 | 9.0% |
| Genitourinary | 3,441 | 9.0% |
| Musculoskeletal | 4,064 | 8.4% |
| Digestive | 6,488 | 8.0% |
| Respiratory | 9,491 | 7.3% |

Diagnosis group separates risk much less than prior admissions (7.3% to 10.8%, versus 8.1% to 26.5%). Circulatory diagnoses are the largest group, with about a third of all early readmissions, but their rate (9.7%) is close to the overall 9.0%. Whether the differences are statistically significant is tested in the next section.

## 4. Statistical analysis
_(Hypothesis tests, logistic regression with odds ratios, confidence intervals. Link to /analysis.)_

## 5. Dashboard
_(Screenshot + link. Pages: Executive summary, Drivers, High-risk segments.)_

## 6. Recommendations and business impact
_(Which segments to target, expected readmissions avoided, estimated saving with stated assumptions.)_

## 7. Limitations
- Data covers 1999-2008 and US hospitals only.
- No cost data in the dataset, so savings are scenario-based using stated assumptions.
- First-encounter filtering reduces sample size but keeps observations independent.

## Repository structure
```
/sql          Bronze, silver, gold and cohort analysis scripts
/analysis     Statistical analysis (notebook or script)
/dashboard    Power BI file and screenshots
/docs         One-page executive brief
README.md
```

## Author
Phooko Irvin Rakgetse, BSc Computer Science & Statistics, University of Limpopo
