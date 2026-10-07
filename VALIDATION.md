# Validation record

Validated October 6, 2026, with R 4.6.1 and Quarto 1.10.18 on macOS.

## Fresh-directory reproduction

A temporary checkout was created without the local R library, saved sample-mean vectors, figures or rendered reports. `renv::restore()` restored the locked dependencies, using the package cache. The full simulation was rerun with seeds 7616/7617 and B = 10,000.

The regenerated primary diagnostics, sensitivity diagnostics, Normal calibration summary and final summary matched the working repository byte-for-byte on this R version. There are 215 tested population/n rows per seed. This checks reproducibility on the same machine, not independent scientific review or bitwise portability to every R/platform version.

## Statistical and programming checks

- Smoke tests check varying Bernoulli probabilities and their exact SE, synthetic-age moments, Cauchy's undefined theoretical moments, and an exact seeded replay of the dependent recurrence.
- Both seeds' saved vectors reproduce their CSV mean, SD and Q-Q RMSE; the seed directories contain different vectors.
- Finalization checks the selected, below-boundary and above-boundary evidence for both seeds and fails on missing or duplicate rows. Cauchy is the only no-finite-n conclusion.
- No iid theoretical SE is assigned to the dependent process. Finite individual second moments do not imply that a dependent CLT has been proved.
- Calibration uses 30 independent Monte Carlo experiments at each coarse n. Its diagnostic ranges are contextual, not exact thresholds.
- Original instructor files match the supplied files and remain unchanged.

## Reports and judgment limits

All eight Quarto investigations and the overview/methodology/AI pages render. The four-page Typst PDF is inspected page by page for legibility, table width, clipping and consistency with the saved results.

Sample-size selections are explicit practical judgments in `results/decisions.csv`, not automatically discovered mathematical thresholds. Acceptance and smaller-n reservations are documented; borderline neighbors remain uncertain. The student approved the practical standard and delegated completion, but did not independently confirm every boundary integer or claim complete code mastery.

Reproduction commands are in the README. The PDF uses Quarto's bundled Typst, with Helvetica Neue preferred for the macOS layout; font substitution on other platforms can change appearance.
