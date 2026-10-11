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

  cat("**Decision status:** ", decision$decision_status, "\n\n", sep = "")

  if (is.na(decision$selected_n)) {
    cat("**Selected N:** No finite n: standard Cauchy averages remain Cauchy by theory.\n\n")
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
  cat("**I chose this n because:** ", decision$acceptance_reason, "\n\n", sep = "")
  cat("**Why I did not choose smaller tested values:** ", decision$smaller_n_reason, "\n\n", sep = "")
  cat("**Issue / limitation:** ", decision$key_observation, "\n", sep = "")
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

load_sample_means <- function(id, n, seed_label = "student_seed") {
  path <- project_file("results", "sample_means", seed_label,
                       paste0(id, "_n_", n, ".rds"))
  if (!file.exists(path)) stop("Missing evidence: ", path)
  means <- readRDS(path)
  table_path <- project_file("results", if (seed_label == "student_seed")
    "all_diagnostics.csv" else "sensitivity_diagnostics.csv")
  rows <- read.csv(table_path)
  row <- rows[rows$population_id == id & rows$n == n, ]
  stopifnot(nrow(row) == 1L, length(means) == row$B, all(is.finite(means)),
            abs(mean(means) - row$empirical_mean) < 1e-9,
            abs(sd(means) - row$empirical_se) < 1e-9,
            abs(qq_rmse(means) - row$qq_rmse) < 1e-9)
  means
}

plot_review_evidence <- function(id, n_values) {
  spec <- population_spec(id)
  single <- length(n_values) == 1L
  old <- par(mfrow = if (single) c(1, 2) else c(2, length(n_values)),
             mar = if (single) c(3, 3.5, 2, 1) else c(4, 4, 3, 1),
             mgp = c(1.8, 0.55, 0), col.main = "#17212B", cex.main = 0.85)
  on.exit(par(old))
  for (n in n_values) {
    x <- load_sample_means(id, n)
    # Fixed bins avoid allocating millions of FD bins for Cauchy extremes.
    breaks <- 40
    if (id %in% c("six_sided_die", "binomial_small",
                  "nonidentical_bernoulli", "age_at_death")) {
      # Align bins to the 1/n lattice so arbitrary breaks do not create spikes.
      width <- max(1, ceiling(diff(range(x)) * n / 30)) / n
      left <- floor(min(x) / width) * width - 0.5 / n
      breaks <- seq(left, max(x) + width, by = width)
    }
    if (id == "cauchy") {
      central <- x[abs(x) <= 10]
      hist(central, breaks = seq(-10, 10, length.out = 41), probability = TRUE,
           col = "#72B7B2", border = "white",
           main = paste0("n = ", n, "; kept ", length(central), "/", length(x)),
           xlab = "Mean, central window only", ylab = "Conditional density")
    } else {
      hist(x, breaks = breaks, probability = TRUE, col = "#72B7B2",
           border = "white", main = paste("n =", n), xlab = "Sample mean")
    }
    mu <- theoretical_mean_for(spec, n)
    se <- theoretical_se_for(spec, n)
    if (is.finite(mu) && is.finite(se)) {
      curve(dnorm(x, mu, se), add = TRUE, col = "#D66B32", lwd = 2)
    }
  }
  for (n in n_values) {
    x <- load_sample_means(id, n)
    z <- (x - mean(x)) / sd(x)
    qqnorm(z, pch = 16, cex = 0.2, col = "#247F83",
           main = paste("Q-Q RMSE", round(qq_rmse(x), 3)),
           ylab = "Standardized mean")
    qqline(z, col = "#D66B32", lwd = 2)
  }
}

review_table <- function(id) {
  rows <- population_rows(id)
  decision <- selected_row(id)
  ns <- sort(unique(na.omit(c(review_n_values[[id]], decision$below_n,
                             decision$selected_n, decision$above_n))))
  rows <- rows[rows$n %in% ns, ]
  options(knitr.kable.NA = "N/A")
  knitr::kable(rows[, c("n", "empirical_mean", "theoretical_mean",
    "empirical_se", "theoretical_se", "relative_se_error", "skewness",
    "excess_kurtosis", "qq_rmse")], digits = 3)
}

plot_population <- function(id) {
  if (id == "standard_normal") {
    curve(dnorm(x), -4, 4, col = "#007D83", lwd = 2,
          xlab = "Observation", ylab = "Density", main = "Standard Normal population")
  } else if (id == "exponential") {
    curve(dexp(x), 0, 7, col = "#007D83", lwd = 2,
          xlab = "Observation", ylab = "Density", main = "Exponential population")
  } else if (id == "cauchy") {
    curve(dcauchy(x), -10, 10, col = "#007D83", lwd = 2,
          xlab = "Observation", ylab = "Density",
          main = "Cauchy: central window only; tails extend indefinitely")
  } else if (id == "six_sided_die") {
    barplot(rep(1/6, 6), names.arg = 1:6, col = "#72B7B2", border = NA,
            xlab = "Die outcome", ylab = "Probability", main = "Six-sided die population")
  } else if (id == "binomial_small") {
    barplot(dbinom(0:5, size = 5, prob = 0.1), names.arg = 0:5,
            col = "#72B7B2", border = NA, xlab = "Successes in five trials",
            ylab = "Probability", main = "Binomial(size = 5, p = 0.10)")
  }
}
