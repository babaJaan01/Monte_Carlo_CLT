#!/usr/bin/env Rscript

# Run the reproducible Monte Carlo pipeline. This script intentionally stops
# until the required student seed has been entered in R/config.R.

script_argument <- grep("^--file=", commandArgs(), value = TRUE)
if (length(script_argument) == 1L) {
  script_path <- normalizePath(sub("^--file=", "", script_argument))
  setwd(dirname(dirname(script_path)))
}

source("R/config.R")
source("R/distributions.R")
source("R/diagnostics.R")
source("R/simulate_means.R")
source("R/plotting.R")

ensure_output_directories()
seed <- assert_student_seed()

all_n_values <- coarse_n_grid
benchmark_n_values <- coarse_n_grid

run_once <- function(seed_value, seed_label) {
  set.seed(seed_value)
  project_results <- run_all_populations(
    n_values = all_n_values,
    B = monte_carlo_reps,
    save_means = TRUE,
    additional_n_values_by_population = additional_n_values,
    means_directory = file.path("results/sample_means", seed_label)
  )
  diagnostics <- project_results$diagnostics
  diagnostics$seed_label <- seed_label
  diagnostics
}

student_diagnostics <- run_once(seed, "student_seed")
sensitivity_diagnostics <- run_once(sensitivity_seed(seed), "student_seed_plus_one")

write.csv(student_diagnostics, "results/all_diagnostics.csv", row.names = FALSE)
write.csv(sensitivity_diagnostics, "results/sensitivity_diagnostics.csv", row.names = FALSE)

set.seed(seed)
benchmark <- normal_benchmark(
  n_values = benchmark_n_values,
  B = monte_carlo_reps,
  calibration_reps = calibration_reps
)
write.csv(benchmark, "results/normal_benchmark_replicates.csv", row.names = FALSE)
write.csv(summarize_normal_benchmark(benchmark),
          "results/normal_benchmark_summary.csv", row.names = FALSE)

writeLines(c(
  paste("student_seed:", seed),
  paste("sensitivity_seed:", sensitivity_seed(seed)),
  paste("B:", monte_carlo_reps),
  paste("calibration_reps:", calibration_reps),
  paste("R version:", getRversion()),
  paste("generated_at:", format(Sys.time(), tz = "UTC")),
  "selected_n values are maintained separately as human-reviewed evidence decisions."
), "results/run_metadata.txt")

source("scripts/refine_boundaries.R")
source("scripts/finalize_summary.R")
source("scripts/make_figures.R")

message("Simulation results written to results/. Review diagnostics before choosing any selected N.")
