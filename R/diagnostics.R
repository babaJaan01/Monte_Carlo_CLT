# Diagnostics for simulated sampling distributions ----------------------

sample_skewness <- function(x) {
  x <- x[is.finite(x)]
  n <- length(x)
  if (n < 3L) return(NA_real_)
  centered <- x - mean(x)
  m2 <- mean(centered^2)
  m3 <- mean(centered^3)
  if (m2 == 0) return(NA_real_)
  sqrt(n * (n - 1)) / (n - 2) * m3 / m2^(3 / 2)
}

sample_excess_kurtosis <- function(x) {
  x <- x[is.finite(x)]
  n <- length(x)
  if (n < 4L) return(NA_real_)
  centered <- x - mean(x)
  m2 <- mean(centered^2)
  m4 <- mean(centered^4)
  if (m2 == 0) return(NA_real_)
  g2 <- m4 / m2^2 - 3
  ((n - 1) / ((n - 2) * (n - 3))) * ((n + 1) * g2 + 6)
}

qq_rmse <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 2L || sd(x) == 0) return(NA_real_)
  standardized <- sort((x - mean(x)) / sd(x))
  theoretical <- qnorm(ppoints(length(standardized)))
  sqrt(mean((standardized - theoretical)^2))
}

relative_error <- function(estimate, reference) {
  if (length(reference) != 1L || is.na(reference) || reference == 0) {
    return(NA_real_)
  }
  abs(estimate - reference) / abs(reference)
}

diagnose_sample_means <- function(
    sample_means,
    n,
    population_id,
    theoretical_mean = NA_real_,
    theoretical_sd = NA_real_,
    theoretical_se = NA_real_,
    seed_label = "student_seed"
) {
  empirical_mean <- mean(sample_means)
  empirical_se <- sd(sample_means)
  data.frame(
    population_id = population_id,
    n = as.integer(n),
    B = length(sample_means),
    empirical_mean = empirical_mean,
    theoretical_mean = theoretical_mean,
    mean_error = if (is.na(theoretical_mean)) NA_real_ else
      empirical_mean - theoretical_mean,
    empirical_se = empirical_se,
    theoretical_se = theoretical_se,
    relative_se_error = relative_error(empirical_se, theoretical_se),
    skewness = sample_skewness(sample_means),
    excess_kurtosis = sample_excess_kurtosis(sample_means),
    qq_rmse = qq_rmse(sample_means),
    seed_label = seed_label,
    stringsAsFactors = FALSE
  )
}

theoretical_se_for <- function(spec, n) {
  if (spec$id == "nonidentical_bernoulli") {
    return(nonidentical_bernoulli_theory(n)$sd)
  }
  if (isTRUE(spec$finite_variance) && !is.na(spec$theoretical_sd)) {
    return(spec$theoretical_sd / sqrt(n))
  }
  NA_real_
}

theoretical_mean_for <- function(spec, n) {
  if (spec$id == "nonidentical_bernoulli") {
    return(nonidentical_bernoulli_theory(n)$mean)
  }
  spec$theoretical_mean
}

normal_benchmark <- function(
    n_values,
    B = monte_carlo_reps,
    calibration_reps = 30L
) {
  rows <- vector("list", length(n_values) * calibration_reps)
  row_number <- 0L
  for (n in n_values) {
    for (replicate_id in seq_len(calibration_reps)) {
      row_number <- row_number + 1L
      means <- simulate_sample_means(standard_normal_generator, n, B)
      metrics <- diagnose_sample_means(
        means, n = n, population_id = "normal_benchmark",
        theoretical_mean = 0, theoretical_sd = 1,
        theoretical_se = 1 / sqrt(n), seed_label = "calibration"
      )
      metrics$calibration_replicate <- replicate_id
      rows[[row_number]] <- metrics
    }
  }
  do.call(rbind, rows)
}

summarize_normal_benchmark <- function(benchmark_results) {
  rows <- lapply(split(benchmark_results, benchmark_results$n), function(chunk) {
    data.frame(
      n = chunk$n[1L],
      skewness_q025 = unname(quantile(chunk$skewness, 0.025, na.rm = TRUE)),
      skewness_q975 = unname(quantile(chunk$skewness, 0.975, na.rm = TRUE)),
      excess_kurtosis_q025 = unname(quantile(chunk$excess_kurtosis, 0.025, na.rm = TRUE)),
      excess_kurtosis_q975 = unname(quantile(chunk$excess_kurtosis, 0.975, na.rm = TRUE)),
      qq_rmse_q025 = unname(quantile(chunk$qq_rmse, 0.025, na.rm = TRUE)),
      qq_rmse_q975 = unname(quantile(chunk$qq_rmse, 0.975, na.rm = TRUE))
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}
