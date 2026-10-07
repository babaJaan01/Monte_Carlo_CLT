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

All eight Quarto investigations and the overview/methodology/AI pages render. The original four-page summary was expanded on October 7 into a 35-page self-contained submission: four overview pages followed by the complete evidence and appendices.

Sample-size selections are explicit practical judgments in `results/decisions.csv`, not automatically discovered mathematical thresholds. Acceptance and smaller-n reservations are documented; borderline neighbors remain uncertain. The student approved the practical standard and delegated completion, but did not independently confirm every boundary integer or claim complete code mastery.

Reproduction commands are in the README. The PDF uses Quarto's bundled Typst, with Helvetica Neue preferred for the macOS layout; font substitution on other platforms can change appearance.

## Complete-PDF validation: October 7, 2026

- Re-read all seven attached instructor documents. The updated guidance defines five required and three extra-credit cases; unrelated older lesson exercises are not added to the project scope.
- Re-ran `scripts/smoke_test.R` and `scripts/validate_results.R`; both passed. Saved vectors are now also explicitly required to contain only finite means.
- Rendered the expanded Quarto/Typst PDF and all eleven website pages successfully. Statistical result CSVs and selected boundaries were not changed by this report revision.
- Inspected every PDF page as a rendered image, then rechecked the pages affected by final typography changes. Fixed sparse overflow pages and shortened awkwardly wrapping headings. Tables, graphs and code remain inside the page area.
- A temporary PDF-output QA script (not statistical analysis) verified that all 215 primary diagnostic rows occur in the PDF with the same displayed precision as the source CSV, all three questions are explicit, and no sparse overflow pages remain.
- The downloadable PDF in `docs/output/pdf/` is byte-identical to `output/pdf/clt_summary.pdf`. All seven preserved instructor files still match the supplied Downloads copies.
- The PDF includes actual AI prompt/correction examples, both seeds' boundary diagnostics, model construction checks, important R code and reproduction commands. It explicitly labels retrospective expectations; no undocumented pre-run prediction or personal surprise is manufactured.

The fresh-directory full simulation check above was completed on October 6; it is not represented as a newly repeated full run on October 7. This revision reuses the validated generated results and rechecks their correspondence to the expanded report.
