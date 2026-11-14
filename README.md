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
- **Target:** `target_readmit_early` = readmitted in under 30 days. Chosen over "any readmission" (47% positive) because it is the standard, actionable business definition.
- **One encounter per patient:** The dataset has 99,340 encounters but only 69,987 patients. Repeat encounters are not independent, so the analysis uses each patient's first encounter to avoid overstating statistical certainty.
- **Class imbalance:** Only 9% of patients are positive, so accuracy is misleading. Results are reported with recall, precision and PR-AUC.

## 3. SQL analysis
All figures use the gold table (first encounter per patient, n = 69,987; overall 30-day readmission rate 9.0%).

### Readmission rate by age
- Rates are about 7% for ages 20-60, rising to 10.2% (70-80) and 10.8% (80-90).
- Groups under 20 have fewer than 700 patients, so their rates are not reliable.

### Readmission rate by prior inpatient admissions
| Prior admissions | Patients | 30-day readmission rate |
|---|---|---|
| 0 | 61,792 | 8.1% |
| 1 | 5,798 | 12.9% |
| 2 | 1,501 | 18.5% |
| 3+ | 896 | 26.5% |

Prior admissions are a stronger signal than age. This is an association, not proof of cause; the statistical analysis adjusts for other factors.

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
/sql          Bronze, silver and gold scripts
/analysis     Statistical analysis (notebook or script)
/dashboard    Power BI file and screenshots
/docs         One-page executive brief
README.md
```

## Author
Phooko Irvin Rakgetse, BSc Computer Science & Statistics, University of Limpopo
