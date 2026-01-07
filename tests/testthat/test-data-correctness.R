# Data Correctness Tests for ndschooldata
#
# These tests verify that the tidy=TRUE output maintains fidelity to the raw data
# and follows data quality best practices.

test_that("2024 tidy format has all required columns", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  # Required columns from PRD
  required_cols <- c(
    "end_year", "district_id", "campus_id", "district_name", "campus_name",
    "type", "grade_level", "subgroup", "n_students", "pct"
  )

  for (col in required_cols) {
    expect_true(col %in% names(d), info = paste("Missing column:", col))
  }
})

test_that("2024 tidy format has no Inf or NaN values", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  # Check n_students
  expect_false(any(is.infinite(d$n_students)), info = "Inf in n_students")
  expect_false(any(is.nan(d$n_students)), info = "NaN in n_students")

  # Check pct
  expect_false(any(is.infinite(d$pct)), info = "Inf in pct")
  expect_false(any(is.nan(d$pct)), info = "NaN in pct")
})

test_that("2024 all enrollment counts are non-negative", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  expect_true(all(d$n_students >= 0, na.rm = TRUE),
              info = "Negative enrollment values found")
})

test_that("2024 all percentages are in valid range [0,1]", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  expect_true(all(d$pct >= 0 & d$pct <= 1, na.rm = TRUE),
              info = "Percentage outside [0,1] range")
})

test_that("2024 Fargo grade totals sum to TOTAL", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  fargo <- d %>%
    dplyr::filter(district_id == "09-001", subgroup == "total_enrollment")

  fargo_total <- fargo %>%
    dplyr::filter(grade_level == "TOTAL") %>%
    dplyr::pull(n_students)

  fargo_grades_sum <- fargo %>%
    dplyr::filter(grade_level %in% c("K", paste0("0", 1:9), "10", "11", "12")) %>%
    dplyr::summarize(total = sum(n_students), .groups = "drop") %>%
    dplyr::pull(total)

  expect_equal(fargo_total, fargo_grades_sum,
               info = "Fargo grade totals don't sum to TOTAL")
})

test_that("2024 state total equals sum of districts", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  # Get state total
  state_total <- d %>%
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
    dplyr::pull(n_students)

  # Sum of district totals
  districts_sum <- d %>%
    dplyr::filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
    dplyr::summarize(total = sum(n_students), .groups = "drop") %>%
    dplyr::pull(total)

  # Allow 1% tolerance for rounding
  expect_equal(state_total, districts_sum, tolerance = state_total * 0.01,
               info = "State total doesn't equal sum of districts")
})

test_that("2024 state total enrollment is reasonable for North Dakota", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  state_total <- d %>%
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
    dplyr::pull(n_students)

  # North Dakota has approximately 115,000-125,000 K-12 students
  expect_true(state_total >= 100000 && state_total <= 150000,
              info = paste("State total", state_total, "outside expected range"))
})

test_that("2024 district count is reasonable", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  n_districts <- d %>%
    dplyr::filter(is_district, grade_level == "TOTAL", subgroup == "total_enrollment") %>%
    nrow()

  # North Dakota has approximately 150-180 school districts
  expect_true(n_districts >= 140 && n_districts <= 200,
              info = paste("District count", n_districts, "outside expected range"))
})

test_that("2024 district IDs follow expected format", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  # District IDs should be in "CC-DDD" format (county code-district number)
  districts <- d %>%
    dplyr::filter(is_district) %>%
    dplyr::pull(district_id)

  expect_true(all(grepl("^\\d{2}-\\d{3}$", districts)),
              info = "District IDs don't follow CC-DDD format")
})

test_that("2024 aggregation flags are mutually exclusive", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  # Each row should be exactly one of: state, district, campus
  flags_sum <- d$is_state + d$is_district + d$is_campus

  expect_true(all(flags_sum == 1),
              info = "Aggregation flags are not mutually exclusive")
})

test_that("2024 grade levels are properly labeled", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2024, tidy = TRUE)

  expected_grades <- c("TOTAL", "K", "01", "02", "03", "04", "05",
                       "06", "07", "08", "09", "10", "11", "12")
  actual_grades <- unique(d$grade_level)

  expect_true(all(expected_grades %in% actual_grades),
              info = "Missing expected grade levels")
})

test_that("2023 tidy format maintains data quality", {
  skip_on_cran()
  skip_if_offline()

  d <- fetch_enr(2023, tidy = TRUE)

  # No Inf/NaN
  expect_false(any(is.infinite(d$n_students) | is.nan(d$n_students)),
               info = "Inf/NaN in n_students for 2023")

  # No negative values
  expect_true(all(d$n_students >= 0, na.rm = TRUE),
              info = "Negative enrollment in 2023")

  # Valid percentages
  expect_true(all(d$pct >= 0 & d$pct <= 1, na.rm = TRUE),
              info = "Invalid percentages in 2023")
})

test_that("tidy=FALSE and tidy=TRUE return consistent totals", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE)
  tidy <- fetch_enr(2024, tidy = TRUE)

  # Check state total
  wide_state_total <- wide %>%
    dplyr::filter(type == "State") %>%
    dplyr::pull(row_total)

  tidy_state_total <- tidy %>%
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
    dplyr::pull(n_students)

  expect_equal(wide_state_total, tidy_state_total,
               info = "Wide and tidy state totals don't match")
})

test_that("cache works correctly", {
  skip_on_cran()

  # Clear cache first
  clear_cache()

  # Fetch without cache
  d1 <- fetch_enr(2024, tidy = TRUE, use_cache = FALSE)

  # Should create cache
  expect_true(cache_exists(2024, "tidy"))

  # Fetch with cache
  d2 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Should be identical
  expect_equal(d1, d2, info = "Cached data doesn't match fresh data")
})
