# How Fast Does Normal Happen?

## Stress-testing the Central Limit Theorem with Monte Carlo simulation

This Math 167R Project 1 asks:

> What is the smallest sample size (n) at which I would be comfortable calling the sampling distribution of the sample mean approximately normal?

There is no universal answer. This repository investigates whether the familiar “(n=30)” rule is useful across very different populations and processes.

The study uses R, Quarto, and reproducible Monte Carlo simulation. Each candidate (n) is the number of observations inside one sample; (B=10{,}000) is the number of repeated samples used to study the sampling distribution of the mean.

## What is simulated

Required cases:

- Standard Normal;
- a six-sided die;
- Exponential(rate = 1);
- Binomial(size = 5, p = 0.10); and
- Cauchy(location = 0, scale = 1).

Extra credit:

- the instructor’s dependent machine-failure process;
- independent but non-identically distributed basketball shots; and
- the instructor’s synthetic age-at-death distribution.

The analysis combines histograms, theoretical normal overlays where valid, Q-Q plots, skewness, excess kurtosis, empirical and theoretical standard errors, and a reusable Q-Q RMSE metric. The Standard Normal case calibrates the amount of diagnostic variation produced by Monte Carlo noise even when normality is exact.

After a successful run, the [CLT convergence race](figures/convergence_race.png) and [normality heatmap](figures/normality_heatmap.png) provide the project’s high-level visual overview.

The rendered Quarto website is available at [`docs/index.html`](docs/index.html) after rendering.

## Results status

The primary simulation uses the confirmed student seed `7616`, with `B = 10,000` repetitions per candidate `n`. The final values below are evidence decisions linked to generated diagnostics, not universal mathematical cutoffs. `N/A` means no defensible finite value was identified within the tested range or the ordinary finite-variance reference is not applicable.

| Population | Selected N | Evidence status |
|---|---:|---|
| Standard Normal | 1 | Exact normality for every n |
| Six-Sided Die | 100 | Near-zero shape diagnostics and theoretical SE agreement |
| Exponential | 1,000 | Strong right skew requires much larger n |
| Binomial Small | 1,000 | Rare-event discreteness converges slowly |
| Cauchy | N/A through 5,000 | No finite mean/variance; extreme sensitivity persists |
| Dependent Failure | N/A through 1,000 | Dependence and residual skew remain material |
| Non-Identical Bernoulli | 1,000 | Correct p_i-specific variance; slower than iid benchmark |
| Synthetic Age-at-Death | 300 | Irregular synthetic mixture stabilizes by about n = 300 |

## Reproduce the project

1. Install R, Quarto, and the packages in `renv.lock`.
2. Confirm that `student_seed` in `R/config.R` contains the last four digits of the student ID.
3. From this directory, run:

```bash
Rscript scripts/smoke_test.R
Rscript scripts/run_project.R
Rscript scripts/finalize_summary.R
quarto render
```

The runner writes diagnostics to `results/`, saves reproducible sample-mean vectors under `results/sample_means/`, and creates a seed-plus-one sensitivity run. The reviewed refinement centers and population-specific larger checks are documented in `R/config.R`. `scripts/finalize_summary.R` verifies that selected values are present in the generated rows before building the executive table.

## Repository map

- `R/`: reusable population, simulation, diagnostic, and plotting functions;
- `analyses/`: one consistent Quarto investigation per population/process;
- `results/`: generated diagnostics and final-summary schema;
- `references/`: preserved instructor-provided source documents;
- `ai/`: template for recording real AI interactions and independent checks;
- `figures/`: generated portfolio visuals; and
- `docs/`: Quarto website output when rendered.

## AI usage

AI helped scaffold reusable code and documentation. The interaction log records prompts, weaknesses found, corrections, and independent checks. Statistical conclusions are intentionally based on generated simulation output, not on AI-generated guesses.
