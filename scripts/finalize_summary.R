#!/usr/bin/env Rscript
# Choices are explicit judgments; diagnostics come only from real rows.
source("R/config.R")
source("R/distributions.R")
source("R/diagnostics.R")
source("R/report_helpers.R")
decisions <- read.csv("results/decisions.csv", stringsAsFactors = FALSE)
stopifnot(identical(decisions$population_id, required_population_ids),
          !anyDuplicated(decisions$population_id))
primary <- read.csv("results/all_diagnostics.csv")
alternate <- read.csv("results/sensitivity_diagnostics.csv")
lookup <- function(table, id, n) {
  row <- table[table$population_id == id & table$n == n, ]
  stopifnot(nrow(row) == 1L, row$B == monte_carlo_reps)
  row
}
summary <- do.call(rbind, lapply(seq_len(nrow(decisions)), function(i) {
  d <- decisions[i, ]
  spec <- population_spec(d$population_id)
  ns <- na.omit(c(d$below_n, d$selected_n, d$above_n))
  stopifnot(length(ns) >= 2L, nzchar(d$acceptance_reason), nzchar(d$smaller_n_reason))
  for (n in ns) {
    load_sample_means(d$population_id, n, "student_seed")
    load_sample_means(d$population_id, n, "student_seed_plus_one")
  }
  if (is.na(d$selected_n)) stopifnot(d$population_id == "cauchy")
  a <- if (is.na(d$selected_n)) NULL else lookup(primary, d$population_id, d$selected_n)
  b <- if (is.na(d$selected_n)) NULL else lookup(alternate, d$population_id, d$selected_n)
  value <- function(row, name) if (is.null(row)) NA_real_ else row[[name]]
  data.frame(d, population = spec$label, independent = spec$independent,
    identically_distributed = spec$identically_distributed,
    finite_variance = spec$finite_variance,
    skewness_at_selected_n = value(a, "skewness"),
    excess_kurtosis_at_selected_n = value(a, "excess_kurtosis"),
    qq_rmse_at_selected_n = value(a, "qq_rmse"),
    empirical_mean_at_selected_n = value(a, "empirical_mean"),
    theoretical_mean = value(a, "theoretical_mean"),
    empirical_se_at_selected_n = value(a, "empirical_se"),
    theoretical_se_or_reference = value(a, "theoretical_se"),
    relative_se_error = value(a, "relative_se_error"),
    sensitivity_skewness = value(b, "skewness"),
    sensitivity_qq_rmse = value(b, "qq_rmse"),
    tested_max_n = max(primary$n[primary$population_id == d$population_id]))
}))
write.csv(summary, "results/final_summary.csv", row.names = FALSE)
message("Summary generated from decisions and validated evidence for both seeds.")
