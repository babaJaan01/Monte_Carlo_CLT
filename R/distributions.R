# Population and process definitions ------------------------------------

standard_normal_generator <- function(n) {
  rnorm(n, mean = 0, sd = 1)
}

six_sided_die_generator <- function(n) {
  sample(1:6, size = n, replace = TRUE)
}

exponential_generator <- function(n) {
  rexp(n, rate = 1)
}

binomial_small_generator <- function(n) {
  # binomial_size is the Binomial distribution parameter. It is not CLT n.
  binomial_size <- 5L
  binomial_probability <- 0.10
  rbinom(n, size = binomial_size, prob = binomial_probability)
}

cauchy_generator <- function(n) {
  rcauchy(n, location = 0, scale = 1)
}

simulate_dependent_failure <- function(
    n,
    baseline_rate = 1,
    beta = 1.25,
    reference_time = 1
) {
  if (n < 1L) stop("n must be at least 1", call. = FALSE)

  operating_time <- numeric(n)
  failure_rate <- numeric(n)

  failure_rate[1L] <- baseline_rate
  operating_time[1L] <- rexp(1L, rate = failure_rate[1L])

  if (n >= 2L) {
    for (t in 2:n) {
      failure_rate[t] <- baseline_rate *
        exp(beta * (operating_time[t - 1L] - reference_time))
      operating_time[t] <- rexp(1L, rate = failure_rate[t])
    }
  }

  operating_time
}

nonidentical_probabilities <- function(
    n,
    probability_start = 0.90,
    probability_end = 0.50
) {
  seq(probability_start, probability_end, length.out = n)
}

nonidentical_bernoulli_generator <- function(n) {
  probabilities <- nonidentical_probabilities(n)
  # size = 1 creates one Bernoulli outcome per shot, with varying p_i.
  rbinom(n, size = 1L, prob = probabilities)
}

age_at_death_distribution <- function() {
  age <- 0:100
  early_component <- 0.045 * exp(-age / 5)
  adult_component <- 0.030 * exp(-0.5 * ((age - 65) / 10)^2)
  weight <- early_component + adult_component
  probability <- weight / sum(weight)
  data.frame(
    age = age,
    probability = probability,
    percent = 100 * probability
  )
}

rdeath <- function(n, distribution = age_at_death_distribution()) {
  sample(
    x = distribution$age,
    size = n,
    replace = TRUE,
    prob = distribution$probability
  )
}

age_at_death_generator <- function(n) {
  rdeath(n)
}

age_at_death_theory <- function() {
  distribution <- age_at_death_distribution()
  population_mean <- sum(distribution$age * distribution$probability)
  population_variance <- sum(
    (distribution$age - population_mean)^2 * distribution$probability
  )
  list(mean = population_mean, sd = sqrt(population_variance))
}

nonidentical_bernoulli_theory <- function(n) {
  probabilities <- nonidentical_probabilities(n)
  list(
    mean = mean(probabilities),
    sd = sqrt(sum(probabilities * (1 - probabilities)) / n^2)
  )
}

population_spec <- function(id) {
  specs <- list(
    standard_normal = list(
      id = "standard_normal", label = "Standard Normal", required = TRUE,
      generator = standard_normal_generator, independent = TRUE,
      identically_distributed = TRUE, finite_variance = TRUE,
      theoretical_mean = 0, theoretical_sd = 1,
      theoretical_note = "Exact normality for every n"
    ),
    six_sided_die = list(
      id = "six_sided_die", label = "Six-Sided Die", required = TRUE,
      generator = six_sided_die_generator, independent = TRUE,
      identically_distributed = TRUE, finite_variance = TRUE,
      theoretical_mean = 3.5, theoretical_sd = sqrt(35 / 12),
      theoretical_note = "Discrete uniform on 1, ..., 6"
    ),
    exponential = list(
      id = "exponential", label = "Exponential(rate = 1)", required = TRUE,
      generator = exponential_generator, independent = TRUE,
      identically_distributed = TRUE, finite_variance = TRUE,
      theoretical_mean = 1, theoretical_sd = 1,
      theoretical_note = "SE(mean) = 1 / sqrt(n)"
    ),
    binomial_small = list(
      id = "binomial_small", label = "Binomial(size = 5, p = 0.10)",
      required = TRUE, generator = binomial_small_generator,
      independent = TRUE, identically_distributed = TRUE, finite_variance = TRUE,
      theoretical_mean = 0.5, theoretical_sd = sqrt(0.45),
      theoretical_note = "Binomial size parameter is 5; CLT sample size is n"
    ),
    cauchy = list(
      id = "cauchy", label = "Cauchy(location = 0, scale = 1)", required = TRUE,
      generator = cauchy_generator, independent = TRUE,
      identically_distributed = TRUE, finite_variance = FALSE,
      theoretical_mean = NA_real_, theoretical_sd = NA_real_,
      theoretical_note = "Mean and variance do not exist"
    ),
    dependent_failure = list(
      id = "dependent_failure", label = "Dependent Machine Failure",
      required = FALSE, generator = simulate_dependent_failure,
      # Times are nonnegative, so rates >= exp(-1.25); conditional
      # second moments are bounded by 2 * exp(2.5). This does not prove a CLT.
      independent = FALSE, identically_distributed = FALSE, finite_variance = TRUE,
      theoretical_mean = NA_real_, theoretical_sd = NA_real_,
      theoretical_note = "Dependence changes Var(mean) through covariance"
    ),
    nonidentical_bernoulli = list(
      id = "nonidentical_bernoulli", label = "Non-Identical Bernoulli Shots",
      required = FALSE, generator = nonidentical_bernoulli_generator,
      independent = TRUE, identically_distributed = FALSE, finite_variance = TRUE,
      theoretical_mean = NA_real_, theoretical_sd = NA_real_,
      theoretical_note = "Use p_i-specific Poisson-binomial moments"
    ),
    age_at_death = list(
      id = "age_at_death", label = "Synthetic Age-at-Death", required = FALSE,
      generator = age_at_death_generator, independent = TRUE,
      identically_distributed = TRUE, finite_variance = TRUE,
      theoretical_mean = age_at_death_theory()$mean,
      theoretical_sd = age_at_death_theory()$sd,
      theoretical_note = "Synthetic discrete mixture, not historical mortality data"
    )
  )

  if (!id %in% names(specs)) stop("Unknown population id: ", id, call. = FALSE)
  specs[[id]]
}

all_population_specs <- function() {
  lapply(required_population_ids, population_spec)
}
