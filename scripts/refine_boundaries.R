#!/usr/bin/env Rscript
source("R/config.R")
source("R/distributions.R")
source("R/diagnostics.R")
source("R/simulate_means.R")

# A fixed seed immediately before each new experiment makes refinement
# independent of earlier grid edits. This is not choosing favorable seeds.
for (label in c("student_seed", "student_seed_plus_one")) {
  file <- file.path("results", if (label == "student_seed")
    "all_diagnostics.csv" else "sensitivity_diagnostics.csv")
  rows <- read.csv(file)
  for (id in names(boundary_n_values)) {
    for (n in boundary_n_values[[id]]) {
      set.seed(if (label == "student_seed") student_seed else sensitivity_seed())
      run <- run_population_grid(population_spec(id), n, save_means = TRUE,
        means_directory = file.path("results/sample_means", label))
      run$diagnostics$seed_label <- label
      rows <- rows[!(rows$population_id == id & rows$n == n), ]
      rows <- rbind(rows, run$diagnostics)
    }
  }
  rows <- rows[order(match(rows$population_id, required_population_ids), rows$n), ]
  write.csv(rows, file, row.names = FALSE)
}
