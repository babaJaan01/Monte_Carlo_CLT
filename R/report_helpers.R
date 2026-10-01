# Helpers used by the Quarto reports ------------------------------------

load_diagnostics <- function() {
  path <- project_file("results", "all_diagnostics.csv")
  if (!file.exists(path)) return(NULL)
  read.csv(path, stringsAsFactors = FALSE)
}

load_final_summary <- function() {
  path <- project_file("results", "final_summary.csv")
  if (!file.exists(path)) return(NULL)
  read.csv(path, stringsAsFactors = FALSE)
}

selected_row <- function(population_id) {
  summary <- load_final_summary()
  if (is.null(summary)) return(NULL)
  summary[summary$population_id == population_id, , drop = FALSE]
}

report_selection <- function(population_id) {
  decision <- selected_row(population_id)
  if (is.null(decision) || nrow(decision) == 0L) {
    cat("The evidence-linked final summary has not been generated yet.\n")
    return(invisible(NULL))
  }

  if (is.na(decision$selected_n)) {
    cat("**Selected N:** No finite defensible value identified within the tested range.\n\n")
  } else {
    cat("**Selected N:** `n = ", format(decision$selected_n, big.mark = ","), "`\n\n", sep = "")
    cat("- skewness: ", round(decision$skewness_at_selected_n, 4), "\n",
        "- excess kurtosis: ", round(decision$excess_kurtosis_at_selected_n, 4), "\n",
        "- Q-Q RMSE: ", round(decision$qq_rmse_at_selected_n, 4), "\n",
        "- empirical SE: ", round(decision$empirical_se_at_selected_n, 4), "\n",
        "- theoretical/reference SE: ",
        ifelse(is.na(decision$theoretical_se_or_reference), "N/A",
               round(decision$theoretical_se_or_reference, 4)), "\n", sep = "")
  }
  cat("**Evidence decision:** ", decision$key_observation, "\n", sep = "")
  invisible(decision)
}

report_status <- function() {
  diagnostics <- load_diagnostics()
  if (is.null(diagnostics) || nrow(diagnostics) == 0L) {
    cat("Simulation results are not populated yet. Replace student_seed in R/config.R, then run scripts/run_project.R.\n")
  } else {
    summary <- load_final_summary()
    if (is.null(summary) || all(is.na(summary$selected_n))) {
      cat("Diagnostics loaded from results/all_diagnostics.csv. Selected N values remain a human-reviewed decision.\n")
    } else {
      cat("Diagnostics and the evidence-linked final summary are loaded from results/.\n")
    }
  }
  invisible(diagnostics)
}

population_rows <- function(population_id) {
  diagnostics <- load_diagnostics()
  if (is.null(diagnostics)) return(NULL)
  diagnostics[diagnostics$population_id == population_id, , drop = FALSE]
}

display_candidate_table <- function(population_id) {
  rows <- population_rows(population_id)
  if (is.null(rows) || nrow(rows) == 0L) {
    cat("No generated diagnostics yet.\n")
  } else {
    print(rows)
  }
  invisible(rows)
}
