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

all_n_values <- sort(unique(unlist(c(
  list(coarse_n_grid),
  lapply(refinement_centers, refine_n_grid)
))))
benchmark_n_values <- sort(unique(c(all_n_values, unlist(additional_n_values))))

run_once <- function(seed_value, seed_label) {
  set.seed(seed_value)
  project_results <- run_all_populations(
    n_values = all_n_values,
    B = monte_carlo_reps,
    save_means = TRUE,
    additional_n_values_by_population = additional_n_values
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

final_summary_template <- data.frame(
  population_id = required_population_ids,
  population = vapply(required_population_ids,
                       function(id) population_spec(id)$label, character(1)),
  independent = vapply(required_population_ids,
                        function(id) as.character(population_spec(id)$independent), character(1)),
  identically_distributed = vapply(required_population_ids,
                                   function(id) as.character(population_spec(id)$identically_distributed), character(1)),
  finite_variance = vapply(required_population_ids,
                           function(id) as.character(population_spec(id)$finite_variance), character(1)),
  selected_n = NA_integer_,
  skewness_at_selected_n = NA_real_,
  excess_kurtosis_at_selected_n = NA_real_,
  qq_rmse_at_selected_n = NA_real_,
  empirical_se_at_selected_n = NA_real_,
  theoretical_se_or_reference = NA_real_,
  key_observation = "Complete after reviewing generated evidence",
  stringsAsFactors = FALSE
)
if (!file.exists("results/final_summary.csv")) {
  write.csv(final_summary_template, "results/final_summary.csv", row.names = FALSE)
} else {
  message("Preserving existing results/final_summary.csv; selected N values are human-reviewed evidence decisions.")
}

writeLines(c(
  paste("student_seed:", seed),
  paste("sensitivity_seed:", sensitivity_seed(seed)),
  paste("B:", monte_carlo_reps),
  paste("calibration_reps:", calibration_reps),
  paste("R version:", getRversion()),
  paste("generated_at:", format(Sys.time(), tz = "UTC")),
  "selected_n values are maintained separately as human-reviewed evidence decisions."
), "results/run_metadata.txt")

source("scripts/make_figures.R")

message("Simulation results written to results/. Review diagnostics before choosing any selected N.")
