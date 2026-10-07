# Consistent base-R plotting helpers -------------------------------------

plot_sampling_histogram <- function(
    sample_means,
    n,
    population_label,
    theoretical_mean = NA_real_,
    theoretical_se = NA_real_
) {
  hist(
    sample_means,
    breaks = "FD",
    probability = TRUE,
    col = "#DCEAF4",
    border = "white",
    main = paste(population_label, "sampling distribution, n =", n),
    xlab = "Simulated sample mean"
  )
  if (!is.na(theoretical_mean) && !is.na(theoretical_se) && theoretical_se > 0) {
    curve(
      dnorm(x, mean = theoretical_mean, sd = theoretical_se),
      add = TRUE, col = "#C44E52", lwd = 2
    )
    abline(v = theoretical_mean, col = "#C44E52", lty = 2)
    legend("topright", legend = "Theoretical normal overlay",
           col = "#C44E52", lwd = 2, bty = "n")
  }
}

plot_sampling_qq <- function(sample_means, n, population_label) {
  qqnorm(
    sample_means,
    main = paste(population_label, "normal Q-Q plot, n =", n),
    pch = 19, cex = 0.35, col = "#2F6F8F"
  )
  qqline(sample_means, col = "#C44E52", lwd = 2)
}

plot_convergence_race <- function(diagnostics, log_x = TRUE) {
  old <- par(mar = c(5, 5, 4, 13), xpd = NA)
  on.exit(par(old))
  ids <- unique(diagnostics$population_id)
  colors <- grDevices::hcl.colors(length(ids), palette = "Dark 3")
  y_range <- range(diagnostics$qq_rmse, finite = TRUE)
  plot(NA, xlim = range(diagnostics$n), ylim = y_range,
       log = if (log_x) "xy" else "y",
       xlab = "Sample size n", ylab = "Q-Q RMSE",
       main = "How fast does Normal happen? (log scales)")
  for (i in seq_along(ids)) {
    chunk <- diagnostics[diagnostics$population_id == ids[[i]], ]
    chunk <- chunk[order(chunk$n), ]
    lines(chunk$n, chunk$qq_rmse, type = "b", pch = 19,
          col = colors[[i]], lwd = 2)
  }
  labels <- c(standard_normal = "Normal", six_sided_die = "Die",
    exponential = "Exponential", binomial_small = "Binomial (size 5)",
    cauchy = "Cauchy", dependent_failure = "Dependent failure",
    nonidentical_bernoulli = "Basketball shots", age_at_death = "Synthetic ages")
  legend("topright", inset = c(-0.33, 0), legend = labels[ids],
         col = colors, lty = 1, pch = 19, bty = "n", cex = 0.75)
}

plot_normality_heatmap <- function(diagnostics, selected_summary = NULL) {
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)
  par(mar = c(8, 12, 4, 8) + 0.1)
  ids <- unique(diagnostics$population_id)
  # Keep the heatmap readable: coarse grid plus the actual selected values.
  n_values <- sort(unique(c(coarse_n_grid, selected_summary$selected_n)))
  n_values <- n_values[!is.na(n_values)]
  diagnostics <- diagnostics[diagnostics$n %in% n_values, ]
  matrix_values <- matrix(NA_real_, nrow = length(ids), ncol = length(n_values),
                          dimnames = list(ids, n_values))
  for (i in seq_len(nrow(diagnostics))) {
    matrix_values[diagnostics$population_id[i], as.character(diagnostics$n[i])] <-
      diagnostics$qq_rmse[i]
  }
  image(
    x = seq_along(n_values), y = seq_along(ids), z = t(log10(matrix_values)),
    axes = FALSE, col = grDevices::hcl.colors(20, "YlOrRd", rev = TRUE),
    xlab = "Sample size n", ylab = "",
    main = "Q-Q RMSE heatmap (log10 color scale; white = untested)"
  )
  axis(1, at = seq_along(n_values), labels = n_values, las = 2, cex.axis = 0.75)
  axis(2, at = seq_along(ids),
       labels = vapply(ids, function(id) population_spec(id)$label, character(1)),
       las = 2, cex.axis = 0.7)
  mtext("Population", side = 2, line = 10)
  if (!is.null(selected_summary) && "selected_n" %in% names(selected_summary)) {
    reviewed <- selected_summary[!is.na(selected_summary$selected_n), , drop = FALSE]
    for (i in seq_len(nrow(reviewed))) {
      x_position <- match(reviewed$selected_n[i], n_values)
      y_position <- match(reviewed$population_id[i], ids)
      if (is.finite(x_position) && is.finite(y_position)) {
        points(x_position, y_position, pch = 21, bg = "white", col = "#17212B",
               cex = 1.5, lwd = 1.5)
      }
    }
  }
  box()
  limits <- range(log10(matrix_values), finite = TRUE)
  ticks <- c(0.01, 0.03, 0.1, 0.3, 1)
  palette <- grDevices::hcl.colors(20, "YlOrRd", rev = TRUE)
  positions <- pmax(1, pmin(20, 1 + floor(19 *
    (log10(ticks) - limits[1]) / diff(limits))))
  par(xpd = NA)
  legend(length(n_values) + 1, length(ids), title = "Q-Q RMSE",
         legend = ticks, fill = palette[positions], bty = "n", cex = 0.75)
}

plot_cauchy_running_mean <- function(n = 5000L) {
  observations <- cauchy_generator(n)
  running_mean <- cumsum(observations) / seq_along(observations)
  plot(seq_along(running_mean), running_mean, type = "l",
       col = "#7A5195", xlab = "Observation", ylab = "Running mean",
       main = "Cauchy running mean: extreme observations remain influential")
  abline(h = 0, col = "#C44E52", lty = 2)
}

plot_dependent_process <- function(path) {
  old_par <- par(mfrow = c(2, 2))
  on.exit(par(old_par), add = TRUE)
  plot(path, type = "l", col = "#2F6F8F", xlab = "Time",
       ylab = "Operating time", main = "Dependent failure sequence")
  plot(path[-length(path)], path[-1L], pch = 19, cex = 0.45,
       col = "#C44E52", xlab = "X[t - 1]", ylab = "X[t]",
       main = "Lag plot")
  acf(path, main = "ACF of dependent operating times")
  hist(path, breaks = "FD", col = "#DCEAF4", border = "white",
       main = "Marginal operating times", xlab = "Operating time")
}
