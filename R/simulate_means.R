# Monte Carlo simulation and coarse-to-fine search helpers ---------------

simulate_sample_means <- function(generator, n, B = monte_carlo_reps) {
  if (length(n) != 1L || n < 1L || n != as.integer(n)) {
    stop("n must be a positive integer", call. = FALSE)
  }
  if (length(B) != 1L || B < 1L || B != as.integer(B)) {
    stop("B must be a positive integer", call. = FALSE)
  }
  vapply(seq_len(B), function(i) mean(generator(as.integer(n))), numeric(1))
}

refine_n_grid <- function(center_n, offsets = refinement_offsets) {
  if (length(center_n) != 1L || is.na(center_n)) return(integer(0))
  sort(unique(pmax(1L, as.integer(center_n) + offsets)))
}

run_population_grid <- function(
    spec,
    n_values,
    B = monte_carlo_reps,
    save_means = FALSE,
    means_directory = "results/sample_means"
) {
  if (save_means) dir.create(means_directory, recursive = TRUE, showWarnings = FALSE)
  diagnostics <- vector("list", length(n_values))
  means_by_n <- vector("list", length(n_values))

  for (i in seq_along(n_values)) {
    n <- n_values[[i]]
    means <- simulate_sample_means(spec$generator, n = n, B = B)
    means_by_n[[i]] <- means
    diagnostics[[i]] <- diagnose_sample_means(
      sample_means = means,
      n = n,
      population_id = spec$id,
      theoretical_mean = theoretical_mean_for(spec, n),
      theoretical_sd = spec$theoretical_sd,
      theoretical_se = theoretical_se_for(spec, n)
    )
    if (save_means) {
      saveRDS(means, file.path(means_directory, paste0(spec$id, "_n_", n, ".rds")))
    }
  }

  list(
    diagnostics = do.call(rbind, diagnostics),
    means = stats::setNames(means_by_n, n_values)
  )
}

run_all_populations <- function(
    n_values = coarse_n_grid,
    B = monte_carlo_reps,
    save_means = TRUE,
    additional_n_values_by_population = list()
) {
  specs <- all_population_specs()
  results <- lapply(specs, function(spec) {
    population_extra <- additional_n_values_by_population[[spec$id]]
    population_n <- sort(unique(c(n_values, population_extra)))
    run_population_grid(spec, n_values = population_n, B = B,
                        save_means = save_means)
  })
  diagnostics <- do.call(rbind, lapply(results, `[[`, "diagnostics"))
  rownames(diagnostics) <- NULL
  list(results = results, diagnostics = diagnostics)
}
