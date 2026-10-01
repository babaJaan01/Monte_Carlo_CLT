#!/usr/bin/env Rscript

# Write the human-reviewed decision layer from generated diagnostics.
# The selected values below are not simulation output: they are explicit
# evidence decisions made after inspecting the coarse/refined results,
# calibration benchmark, graphical evidence, and nearby-n stability.
source("R/config.R")
source("R/distributions.R")

diagnostics_path <- "results/all_diagnostics.csv"
if (!file.exists(diagnostics_path)) {
  stop("Run scripts/run_project.R before finalizing the evidence summary.", call. = FALSE)
}

diagnostics <- read.csv(diagnostics_path, stringsAsFactors = FALSE)
sensitivity <- read.csv("results/sensitivity_diagnostics.csv", stringsAsFactors = FALSE)

reviewed_decisions <- data.frame(
  population_id = required_population_ids,
  selected_n = c(1L, 100L, 1000L, 1000L, NA_integer_, NA_integer_, 1000L, 300L),
  key_observation = c(
    "Exactly normal for every n; n = 1 is the smallest possible sample size.",
    "At n = 100, skewness and excess kurtosis are near zero, SE agrees with theory, and the Q-Q diagnostic is close to the calibrated range; larger nearby values are stable.",
    "Strong right skew persists at n = 300; n = 1,000 is the first tested value with near-benchmark Q-Q error, near-zero residual shape diagnostics, and correct SE.",
    "The rare-event Binomial is slower than the die; n = 1,000 gives near-benchmark Q-Q error, small shape diagnostics, and agreement with sqrt(0.45 / n).",
    "No finite defensible n was identified through n = 5,000; Cauchy has no population mean or variance and the running mean remains extreme-sensitive.",
    "No defensible n was identified through n = 1,000; dependence and persistent positive skew make the ordinary iid SE shortcut inappropriate.",
    "The correct p_i-specific variance is used; n = 1,000 is the first tested value with the strongest numerical and visual evidence, though convergence is slower than the iid benchmark.",
    "The synthetic irregular mixture becomes stable by about n = 300, with near-zero shape diagnostics and empirical/theoretical SE agreement."
  ),
  stringsAsFactors = FALSE
)

lookup <- function(id, n) {
  if (is.na(n)) return(NULL)
  rows <- diagnostics[diagnostics$population_id == id & diagnostics$n == n, , drop = FALSE]
  if (nrow(rows) != 1L) {
    stop("Selected n is not represented exactly once in all_diagnostics.csv: ", id, " n=", n,
         call. = FALSE)
  }
  rows
}

selected_rows <- lapply(seq_len(nrow(reviewed_decisions)), function(i) {
  decision <- reviewed_decisions[i, ]
  row <- lookup(decision$population_id, decision$selected_n)
  if (is.null(row)) {
    data.frame(
      skewness_at_selected_n = NA_real_,
      excess_kurtosis_at_selected_n = NA_real_,
      qq_rmse_at_selected_n = NA_real_,
      empirical_se_at_selected_n = NA_real_,
      theoretical_se_or_reference = NA_real_,
      sensitivity_qq_rmse = NA_real_,
      stringsAsFactors = FALSE
    )
  } else {
    alt <- sensitivity[sensitivity$population_id == decision$population_id &
                         sensitivity$n == decision$selected_n, , drop = FALSE]
    data.frame(
      skewness_at_selected_n = row$skewness,
      excess_kurtosis_at_selected_n = row$excess_kurtosis,
      qq_rmse_at_selected_n = row$qq_rmse,
      empirical_se_at_selected_n = row$empirical_se,
      theoretical_se_or_reference = row$theoretical_se,
      sensitivity_qq_rmse = if (nrow(alt) == 1L) alt$qq_rmse else NA_real_,
      stringsAsFactors = FALSE
    )
  }
})

specs <- lapply(required_population_ids, population_spec)
summary <- data.frame(
  population_id = required_population_ids,
  population = vapply(specs, `[[`, character(1), "label"),
  independent = vapply(specs, function(x) as.character(x$independent), character(1)),
  identically_distributed = vapply(specs, function(x) as.character(x$identically_distributed), character(1)),
  finite_variance = vapply(specs, function(x) as.character(x$finite_variance), character(1)),
  reviewed_decisions[, setdiff(names(reviewed_decisions), "population_id"), drop = FALSE],
  do.call(rbind, selected_rows),
  tested_max_n = vapply(required_population_ids, function(id) max(diagnostics$n[diagnostics$population_id == id]), numeric(1)),
  stringsAsFactors = FALSE
)

write.csv(summary, "results/final_summary.csv", row.names = FALSE)
message("Wrote evidence-linked results/final_summary.csv from generated diagnostics.")
