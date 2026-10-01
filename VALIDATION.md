# Validation record

Status: ready for independent reproduction. The complete workflow was rerun successfully in the build environment; an independent clean-room run has not yet been performed.

Validated on 2026-09-30 with R 4.6.1 and Quarto 1.10.18.

## Reproduction inputs

- Student seed: `7616`
- Sensitivity seed: `7617`
- Monte Carlo repetitions per candidate `n`: `B = 10,000`
- Normal calibration repetitions: `30`
- Primary entry point: `Rscript scripts/run_project.R`
- Decision-layer entry point: `Rscript scripts/finalize_summary.R`
- Report entry point: `quarto render`

## Checks completed

- `Rscript scripts/smoke_test.R` passed.
- All ten R source/script files parsed successfully.
- The primary diagnostics contain the coarse grid, reviewed refinement values, and larger special-case checks.
- The final summary has eight population rows and every finite selected value is verified against an actual row in `results/all_diagnostics.csv`.
- Cauchy theoretical mean, SD, and SE fields remain `NA`.
- Dependent failure theoretical iid SE remains `NA`; the simulation preserves sequential dependence and the report includes sequence, lag, and ACF diagnostics.
- Non-identical Bernoulli uses varying `p_i` and the variance `sum(p_i * (1 - p_i)) / n^2`.
- The age-at-death distribution reproduces the instructor construction and has generated mean/SD near 49.98/27.63.
- The alternate-seed run is stored in `results/sensitivity_diagnostics.csv` and is used to check conclusion stability.
- `quarto render` completed all 11 website pages without material warnings or errors.
- The normality heatmap visually marks finite reviewed selections; the Cauchy running-mean figure is included as a special diagnostic.

No Git commit or push was made during this build. The repository is connected to the public GitHub remote, but publication remains a separate user-authorized step.
