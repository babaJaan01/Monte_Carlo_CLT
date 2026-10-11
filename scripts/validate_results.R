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
# Check the compact and boundary layouts without leaving generated test files.
plot_file <- tempfile(fileext = ".pdf")
pdf(plot_file, width = 8, height = 4)
original_layout <- par("mfrow")
plot_review_evidence("standard_normal", 1L)
stopifnot(identical(par("mfrow"), original_layout))
plot_review_evidence("six_sided_die", c(9L, 10L, 12L))
stopifnot(identical(par("mfrow"), original_layout))
invisible(dev.off())
stopifnot(file.info(plot_file)$size > 0)
unlink(plot_file)
message("Both seeds' saved vectors match their diagnostic tables; both plot layouts passed.")
