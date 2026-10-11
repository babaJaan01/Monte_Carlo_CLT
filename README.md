# How Fast Does Normal Happen?

## [Read the final report — 13-page PDF](output/pdf/clt_summary.pdf)

[Download the PDF directly](https://github.com/babaJaan01/Monte_Carlo_CLT/raw/refs/heads/main/output/pdf/clt_summary.pdf)

**Stress-testing the Central Limit Theorem with Monte Carlo simulation**

Shayaan Tanveer · Math 167R · R + Quarto

The PDF is my complete summary argument: what I investigated, what I mean by “normal enough,” which n I chose, and why the evidence supports each choice. The repository holds the detailed, reproducible supporting analysis.

| In the report | Pages |
|---|---:|
| Three direct answers: sample size, approximate Normality, assumptions | 2 |
| Actual AI iteration and corrections | 3 |
| Decision standard and simulation method | 4 |
| Master results and histogram/Q-Q evidence | 5–9 |
| Smaller-n reservations and complicated cases | 10–11 |
| Mean/SE validation and alternate-seed experiment | 12 |
| Conclusions and detailed file map | 13 |

## My decisions and the reasons behind them

I asked when a sample average becomes approximately Normal, and whether **n = 30** is a universal rule. My results say **no**. These are practical central-shape judgments, not exact thresholds or guarantees for extreme-tail probabilities. Borderline neighbors may also be defensible.

| Population / detailed investigation | Selected n | Why I accept this choice | Smaller-n reservation / special issue |
|---|---:|---|---|
| [Standard Normal](analyses/01_standard_normal.qmd) | 1 | Exact Normality; simulated shape and SE agree. | No smaller positive n exists. |
| [Six-sided die](analyses/02_six_sided_die.qmd) | 10 | Symmetric bell; broadly linear Q-Q plot with fine steps. | 6–9 are borderline; I do not claim 9 fails. |
| [Exponential](analyses/03_exponential.qmd) | 90 | Useful central bell, modest right skew, correct SE under both seeds. | 75–80 are borderline; stronger curvature at 30–60. |
| [Binomial small](analyses/04_binomial_small.qmd) | 75 | Modest skew, useful Q-Q line apart from steps, correct SE. | 60 has coarser steps; Binomial size=5 is not n. |
| [Cauchy](analyses/05_cauchy.qmd) | No finite n | No Normal convergence: averages remain Cauchy by theory. | No population mean/variance; tested through 5000. |
| [Dependent failure — extra credit](analyses/06_extra_dependent_failure.qmd) | 350 | Qualified empirical bell and Q-Q agreement across seeds. | 300 is borderline; no iid SE or proved dependent CLT. |
| [Basketball shots — extra credit](analyses/07_extra_nonidentical_bernoulli.qmd) | 140 | Small skew and fine steps; SE uses individual probabilities. | 110–125 have clearer gaps; independent, not identical. |
| [Synthetic ages — extra credit](analyses/08_extra_age_at_death.qmd) | 15 | Mixture smooths to a bell with modest left skew and correct SE. | 12 is borderline; synthetic, not historical mortality data. |

For each n, I generate **B = 10,000 fresh samples**, then assess their means using histograms, Q-Q plots, skewness, excess kurtosis, Q-Q RMSE, valid theoretical moments and nearby larger values. Normal calibration provides context, not an automatic cutoff. All three designated extra-credit investigations are included.

## Reproduce the project

Install R and Quarto. Run these commands from the repository root:

```sh
Rscript -e 'renv::restore(prompt = FALSE)'
Rscript scripts/smoke_test.R
Rscript scripts/run_project.R
Rscript scripts/validate_results.R
Rscript scripts/render_summary.R
quarto render
```

Seed **7616** is the confirmed student seed; **7617** is the fixed sensitivity seed. The full run regenerates both experiments, calibration, figures and the evidence-linked summary. Statistics use base R; `renv` records the rendering dependencies. Quarto's bundled Typst creates the PDF without a separate TeX installation.

`R/`: reusable functions · `analyses/`: eight investigations · `results/`: diagnostics and explicit decisions · `figures/`: summary visuals · `output/pdf/`: submission · `docs/`: rendered reports · `references/`: unchanged instructor sources.

## AI assistance and validation

I prompted AI to build the project, questioned its smallest-n reasoning and requested corrections. AI proposed the working integers under the practical standard I approved; I can confirm every boundary or claim complete code mastery. The [four real exchanges and validation record](ai/ai_interactions.md) distinguish my input, AI responses, resulting changes and computational checks.
