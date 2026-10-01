# Reproduction handoff

## Release status

**Ready for independent reproduction.** The project was executed end-to-end in the build environment, but an independent clean-room run has not yet been performed.

## Question and scope

The project asks for the smallest tested sample size at which the sampling distribution of a sample mean is defensibly approximately normal. It compares five required populations and three instructor-provided extra-credit processes. Here `n` is the observations in one sample and `B = 10,000` is the number of Monte Carlo repetitions.

## Canonical commands

From the repository root:

```bash
Rscript scripts/smoke_test.R
Rscript scripts/run_project.R
Rscript scripts/finalize_summary.R
quarto render
```

The run uses `student_seed = 7616` and repeats the simulation with seed `7617` for sensitivity. The main outputs are `results/all_diagnostics.csv`, `results/normal_benchmark_summary.csv`, `results/final_summary.csv`, `figures/`, and `docs/`.

## Authoritative decisions

`results/final_summary.csv` is the canonical decision table. Finite selected values are checked by `scripts/finalize_summary.R` against actual rows in `results/all_diagnostics.csv`. The Normal benchmark is contextual evidence, not an automatic cutoff. Cauchy and the dependent process intentionally retain `N/A` selected values within their tested ranges.

## Environment and limits

- R 4.6.1; Quarto 1.10.18.
- Dependencies are recorded in `renv.lock`; the statistical code uses base R functions.
- Exact Monte Carlo diagnostics can vary slightly across R/platform versions. Compare schemas, selected decisions, theory invariants, and broad diagnostic patterns rather than demanding bit-for-bit equality.
- The synthetic age-at-death distribution is not historical mortality data.
- The dependent process is not assigned an iid theoretical SE.

## Human decision layer

The reviewed boundary choices and rationale are explicit in `scripts/finalize_summary.R`, and the reports explain the graphical, numerical, theoretical, and sensitivity evidence used. These are defensible project decisions, not universal sample-size laws.
