# Hospital Readmission Risk Analytics

> Which diabetic patients are most likely to be readmitted within 30 days, what drives it, and what could reducing it save?

**Tools:** Databricks (SQL), Power BI (DAX), Python/SQL for statistics
**Data:** Diabetes 130-US Hospitals (1999-2008), 101,766 encounters, 130 hospitals

## 1. Business problem
Unplanned 30-day readmissions are costly for hospitals and a marker of care quality. This project identifies which patient groups are at highest risk and quantifies the potential saving from targeted follow-up.

**Headline result:** _(fill in at the end: e.g. "Patients with X and Y are 1.8x more likely to be readmitted; targeting them could avoid ~N readmissions per 10,000 patients.")_

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
_(Cohort comparisons: readmission rate by age, diagnosis group, length of stay, medication change, prior inpatient visits. Link to /sql.)_

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
