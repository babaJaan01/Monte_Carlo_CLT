#!/usr/bin/env Rscript
source("R/config.R")
source("R/distributions.R")
source("R/diagnostics.R")
source("R/report_helpers.R")

for (label in c("student_seed", "student_seed_plus_one")) {
  file <- if (label == "student_seed") "all_diagnostics.csv" else
    "sensitivity_diagnostics.csv"
  rows <- read.csv(file.path("results", file))
  stopifnot(all(rows$B == monte_carlo_reps), !anyDuplicated(rows[c("population_id", "n")]))
  for (i in seq_len(nrow(rows))) {
    load_sample_means(rows$population_id[i], rows$n[i], label)
  }
  stopifnot(all(is.na(rows$theoretical_se[rows$population_id %in%
    c("cauchy", "dependent_failure")])))
}
for (id in required_population_ids) {
  a <- load_sample_means(id, 1, "student_seed")
  b <- load_sample_means(id, 1, "student_seed_plus_one")
  stopifnot(!identical(a, b))
}
message("Both seeds' saved vectors match their diagnostic tables.")
