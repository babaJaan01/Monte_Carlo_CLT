# Project configuration --------------------------------------------------
# Confirmed student ID seed; alternate seed is used only for sensitivity.
student_seed <- 7616L

monte_carlo_reps <- 10000L
calibration_reps <- 30L

# This is the starting grid only. Refined values should be added after the
# coarse diagnostics have been inspected, not chosen to force a conclusion.
coarse_n_grid <- c(1L, 2L, 3L, 5L, 10L, 15L, 20L, 30L, 50L,
                   75L, 100L, 150L, 200L, 300L, 500L)

# Earlier exploratory refinements are retained to replay saved results.
# They are not final decisions; targeted boundary experiments follow below.
refinement_centers <- list(
  standard_normal = NA_integer_,
  six_sided_die = 100L,
  exponential = 300L,
  binomial_small = 300L,
  cauchy = 500L,
  dependent_failure = 750L,
  nonidentical_bernoulli = 500L,
  age_at_death = 100L
)

refinement_offsets <- c(-10L, -5L, -2L, -1L, 0L, 1L, 2L, 5L, 10L)

# Values to discuss during the paired review; these are not final choices.
review_n_values <- list(
  standard_normal = c(1L, 2L, 5L),
  six_sided_die = c(5L, 10L, 20L, 30L, 50L),
  exponential = c(30L, 50L, 100L, 200L, 300L),
  binomial_small = c(20L, 30L, 50L, 100L, 200L),
  cauchy = c(1L, 100L, 5000L),
  dependent_failure = c(100L, 300L, 1000L),
  nonidentical_bernoulli = c(30L, 50L, 100L, 200L, 500L),
  age_at_death = c(10L, 20L, 30L, 50L, 100L)
)

# Targeted experiments added during the boundary review, for both seeds.
boundary_n_values <- list(
  six_sided_die = c(6L, 7L, 8L, 9L, 12L, 18L, 19L, 21L, 25L),
  exponential = c(60L, 80L, 90L, 110L),
  binomial_small = c(60L, 80L, 90L, 110L),
  dependent_failure = c(350L, 400L, 450L, 550L),
  nonidentical_bernoulli = c(110L, 125L, 140L, 160L),
  age_at_death = c(12L, 16L, 18L, 22L)
)

# Extra diagnostic values are population-specific. They keep the common
# coarse grid comparable while allowing especially slow cases (notably
# Cauchy) to be examined at much larger n.
additional_n_values <- list(
  exponential = c(1000L),
  binomial_small = c(750L, 1000L),
  cauchy = c(1000L, 2000L, 5000L),
  dependent_failure = c(750L, 1000L),
  nonidentical_bernoulli = c(750L, 1000L)
)

sensitivity_seed <- function(seed = student_seed) {
  assert_student_seed(seed)
  as.integer((seed + 1L) %% (.Machine$integer.max - 1L))
}

required_population_ids <- c(
  "standard_normal", "six_sided_die", "exponential", "binomial_small",
  "cauchy", "dependent_failure", "nonidentical_bernoulli", "age_at_death"
)

assert_student_seed <- function(seed = student_seed) {
  if (length(seed) != 1L || is.na(seed) || !is.finite(seed) ||
      seed < 0 || seed > .Machine$integer.max) {
    stop(
      "Set student_seed in R/config.R to the last four digits of the student ID " ,
      "before running project simulations.",
      call. = FALSE
    )
  }
  invisible(as.integer(seed))
}

project_file <- function(...) {
  candidates <- c(
    file.path(...),
    file.path("..", ...)
  )
  found <- candidates[file.exists(candidates)]
  if (length(found) == 0L) {
    file.path(...)
  } else {
    found[[1L]]
  }
}

ensure_output_directories <- function() {
  dirs <- c("results", "results/sample_means", "figures", "docs")
  invisible(lapply(dirs, dir.create, showWarnings = FALSE, recursive = TRUE))
}
