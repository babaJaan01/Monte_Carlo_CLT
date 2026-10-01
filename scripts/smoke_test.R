#!/usr/bin/env Rscript

# Fast structural test. The seed here is test-only and is not the student's
# project seed; it does not create project result files or scientific claims.
set.seed(20260930)
source("R/config.R")
source("R/distributions.R")
source("R/diagnostics.R")
source("R/simulate_means.R")

stopifnot(length(simulate_sample_means(standard_normal_generator, 5L, 20L)) == 20L)
stopifnot(identical(nonidentical_probabilities(20L)[c(1L, 20L)], c(0.9, 0.5)))
stopifnot(abs(mean(nonidentical_probabilities(20L)) - 0.7) < 1e-12)
stopifnot(abs(nonidentical_bernoulli_theory(20L)$sd -
             sqrt(sum(nonidentical_probabilities(20L) *
                      (1 - nonidentical_probabilities(20L))) / 20^2)) < 1e-12)
stopifnot(is.na(population_spec("cauchy")$theoretical_mean))
stopifnot(is.na(population_spec("cauchy")$theoretical_sd))

age_theory <- age_at_death_theory()
stopifnot(abs(age_theory$mean - 49.9809755) < 1e-6)
stopifnot(abs(age_theory$sd - 27.63) < 0.1)

dependent_path <- simulate_dependent_failure(200L)
stopifnot(length(dependent_path) == 200L, all(is.finite(dependent_path)))
diagnostics <- diagnose_sample_means(
  simulate_sample_means(exponential_generator, 10L, 100L),
  n = 10L, population_id = "smoke", theoretical_mean = 1,
  theoretical_sd = 1, theoretical_se = 1 / sqrt(10)
)
stopifnot(nrow(diagnostics) == 1L, is.finite(diagnostics$qq_rmse))

message("Smoke test passed: generators, theory metadata, simulation, and diagnostics are structurally valid.")
