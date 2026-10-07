#!/usr/bin/env Rscript

# Generate portfolio visuals from already-generated results. This script does
# not choose a boundary or write scientific conclusions.
source("R/config.R")
source("R/distributions.R")
source("R/diagnostics.R")
source("R/simulate_means.R")
source("R/plotting.R")
source("R/report_helpers.R")

diagnostics_path <- "results/all_diagnostics.csv"
if (!file.exists(diagnostics_path) || file.info(diagnostics_path)$size == 0) {
  stop("Run scripts/run_project.R first; no diagnostics file is populated.", call. = FALSE)
}

diagnostics <- read.csv(diagnostics_path, stringsAsFactors = FALSE)
dir.create("figures", showWarnings = FALSE)

png("figures/convergence_race.png", width = 1600, height = 1000, res = 160)
plot_convergence_race(diagnostics)
dev.off()

png("figures/normality_heatmap.png", width = 1600, height = 1000, res = 160)
selected_summary <- if (file.exists("results/final_summary.csv")) {
  read.csv("results/final_summary.csv", stringsAsFactors = FALSE)
} else {
  NULL
}
plot_normality_heatmap(diagnostics, selected_summary = selected_summary)
dev.off()

if (exists("student_seed") && !is.na(student_seed)) {
  set.seed(student_seed)
  png("figures/cauchy_running_mean.png", width = 1600, height = 1000, res = 160)
  plot_cauchy_running_mean(5000L)
  dev.off()
}

message("Figures written to figures/.")
