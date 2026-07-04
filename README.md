# Reproducibility package

This folder contains a compact, public-facing version of the code and data used to reproduce the main analyses and revision analyses for the manuscript.

The scripts are intentionally simplified. They use analysis-ready data objects and CSV files rather than the large internal simulation objects, so that readers can run the workflow on a standard computer.

## Folder structure

- `code/`: numbered R scripts.
- `data/`: analysis-ready data used by the scripts.
- `data/revise/`: derived datasets for the revision and sensitivity analyses.
- `output/`: figures and tables created by the public scripts.

## How to run

Open R in this `github` folder and run:

```r
source("run_all.R")
```

Alternatively, run individual scripts in numerical order.

## Script index

- `00_setup.R`: package checks, paths, common plotting theme, and helper functions.
- `01_scenario1_main_results.R`: reproduces the main scenario 1 ERF-by-scale curve and the observed-versus-theoretical underestimation plot.
- `02_scenario2_main_results.R`: reproduces the representative scenario 2 city-level curves with monthly temperature support.
- `03_monthly_analytical_estimand.R`: reproduces the monthly analytical estimand comparison used to separate scale-transition error from spline-fitting artifacts.
- `04_formula_based_correction.R`: reproduces the simple formula-based post-hoc correction and attributable-fraction comparison.
- `05_validation_agreement_metrics.R`: reproduces agreement statistics and Bland-Altman diagnostics.
- `06_sensitivity_analyses.R`: reproduces the minimal sensitivity analyses and the large intra-group variance extension.

## Data note

The public data files are analysis-ready derivatives of the original simulation workflow. The full internal objects include gridded daily temperatures and simulated mortality counts and are too large for a lightweight GitHub repository. The included files are sufficient to reproduce the manuscript figures and revision analyses covered by these scripts.
