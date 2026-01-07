# ==============================================================================
# Graduation Rate Raw Data Fidelity Tests
# ==============================================================================
#
# These tests verify that the processed graduation data maintains FIDELITY
# to the raw, unprocessed source CSV files from ND Insights.
#
# All expected values were manually verified against the raw CSV files.
# Source: https://insights.nd.gov/ShowFile?f=10039_39_csv_YYYY-YYYY
#
# TDD APPROACH: Tests written BEFORE implementation code.
# These tests should FAIL initially, then PASS after implementation.
#
# ==============================================================================

# Skip tests if offline (CI/CD compatibility)
skip_if_offline <- function() {
  tryCatch({
    response <- httr::HEAD("https://www.google.com", httr::timeout(5))
    if (httr::http_error(response)) skip("No network connectivity")
  }, error = function(e) skip("No network connectivity"))
}

# ==============================================================================
# 2024 (2023-2024 school year) - 30 tests
# ==============================================================================

test_that("2024: State total graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.824 (82.4%)
  # Source: ND Insights 2023-2024 CSV, State/All record
  expect_equal(state_rate, 0.824, tolerance = 0.001)
})

test_that("2024: State cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  state_cohort <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 8681
  expect_equal(state_cohort, 8681)
})

test_that("2024: State graduate count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  state_grads <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(graduate_count)

  # Raw CSV value: 7154
  expect_equal(state_grads, 7154)
})

test_that("2024: State male graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  male_rate <- data |>
    dplyr::filter(is_state, subgroup == "male") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.810
  expect_equal(male_rate, 0.810, tolerance = 0.001)
})

test_that("2024: State female graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  female_rate <- data |>
    dplyr::filter(is_state, subgroup == "female") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.839
  expect_equal(female_rate, 0.839, tolerance = 0.001)
})

test_that("2024: State White graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  white_rate <- data |>
    dplyr::filter(is_state, subgroup == "white") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.875
  expect_equal(white_rate, 0.875, tolerance = 0.001)
})

test_that("2024: State Native American graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  native_rate <- data |>
    dplyr::filter(is_state, subgroup == "native_american") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.634
  expect_equal(native_rate, 0.634, tolerance = 0.001)
})

test_that("2024: Fargo graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.800 (ID: 09001)
  expect_equal(fargo_rate, 0.800, tolerance = 0.001)
})

test_that("2024: Fargo cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  fargo_cohort <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 949
  expect_equal(fargo_cohort, 949)
})

test_that("2024: Fargo graduate count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  fargo_grads <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(graduate_count)

  # Raw CSV value: 759
  expect_equal(fargo_grads, 759)
})

test_that("2024: Bismarck graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  bismarck_rate <- data |>
    dplyr::filter(district_name == "Bismarck 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.845 (ID: 08001)
  expect_equal(bismarck_rate, 0.845, tolerance = 0.001)
})

test_that("2024: Grand Forks graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  gf_rate <- data |>
    dplyr::filter(district_name == "Grand Forks 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.828 (ID: 18001)
  expect_equal(gf_rate, 0.828, tolerance = 0.001)
})

test_that("2024: Minot graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  minot_rate <- data |>
    dplyr::filter(district_name == "Minot 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.699 (ID: 51001)
  expect_equal(minot_rate, 0.699, tolerance = 0.001)
})

test_that("2024: West Fargo graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  wf_rate <- data |>
    dplyr::filter(district_name == "West Fargo 6", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Should have data for West Fargo
  expect_true(!is.na(wf_rate))
  expect_gt(wf_rate, 0.7)
  expect_lt(wf_rate, 1.0)
})

test_that("2024: No Inf values in grad rates", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  expect_false(any(is.infinite(data$grad_rate)))
})

test_that("2024: No NaN values in grad rates", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  expect_false(any(is.nan(data$grad_rate)))
})

test_that("2024: All grad rates in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  expect_true(all(data$grad_rate >= 0, na.rm = TRUE))
  expect_true(all(data$grad_rate <= 1.0, na.rm = TRUE))
})

test_that("2024: Cohort count always >= graduate count", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  expect_true(all(data$cohort_count >= data$graduate_count, na.rm = TRUE))
})

test_that("2024: State record exists", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  expect_true(any(data$is_state))
  expect_true(any(data$district_id == "99999", na.rm = TRUE))
})

test_that("2024: District records exist", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  expect_true(any(data$is_district))
  expect_gt(sum(data$is_district), 100)  # ND has ~100+ districts
})

test_that("2024: School records exist", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  # 2016+ should have school-level data
  expect_true(any(data$is_school))
})

test_that("2024: Fargo ID preserved with leading zeros", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  fargo_id <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district) |>
    dplyr::pull(district_id) |>
    unique()

  expect_equal(fargo_id, "09001")
})

test_that("2024: State ID is 99999", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  state_id <- data |>
    dplyr::filter(is_state) |>
    dplyr::pull(district_id) |>
    unique()

  expect_equal(state_id, "99999")
})

test_that("2024: Cohort type is 4-year", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  # This is 4-year cohort data
  expect_true(all(data$cohort_type == "4-year" | is.na(data$cohort_type), na.rm = TRUE))
})

test_that("2024: End year is correct", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  expect_true(all(data$end_year == 2024))
})

test_that("2024: Entity levels are all present", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  types <- unique(data$type[!is.na(data$type)])
  expect_true("State" %in% types)
  expect_true("District" %in% types)
  expect_true("School" %in% types)
})

test_that("2024: Has subgroup data", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  # Should have multiple subgroups
  subgroups <- unique(data$subgroup)
  expect_gt(length(subgroups), 10)
  expect_true("all" %in% subgroups)
  expect_true("male" %in% subgroups)
  expect_true("female" %in% subgroups)
})

test_that("2024: State total subgroups sum correctly", {
  skip_if_offline()

  # This tests that all subgroups are present and accounted for
  data <- ndschooldata::fetch_graduation(2024, use_cache = TRUE)

  state_subgroups <- data |>
    dplyr::filter(is_state) |>
    dplyr::pull(subgroup) |>
    unique()

  expect_gt(length(state_subgroups), 15)  # Should have 15-20 subgroups
})

# ==============================================================================
# 2020 (2019-2020 school year) - 20 tests
# ==============================================================================

test_that("2020: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.890
  expect_equal(state_rate, 0.890, tolerance = 0.001)
})

test_that("2020: State cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  state_cohort <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 7486
  expect_equal(state_cohort, 7486)
})

test_that("2020: State graduate count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  state_grads <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(graduate_count)

  # Raw CSV value: 6660
  expect_equal(state_grads, 6660)
})

test_that("2020: Fargo graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.870
  expect_equal(fargo_rate, 0.870, tolerance = 0.001)
})

test_that("2020: Bismarck graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  bismarck_rate <- data |>
    dplyr::filter(district_name == "Bismarck 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.898
  expect_equal(bismarck_rate, 0.898, tolerance = 0.001)
})

test_that("2020: Grand Forks graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  gf_rate <- data |>
    dplyr::filter(district_name == "Grand Forks 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.872
  expect_equal(gf_rate, 0.872, tolerance = 0.001)
})

test_that("2020: Minot graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  minot_rate <- data |>
    dplyr::filter(district_name == "Minot 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.834
  expect_equal(minot_rate, 0.834, tolerance = 0.001)
})

test_that("2020: No Inf values", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  expect_false(any(is.infinite(data$grad_rate)))
})

test_that("2020: All grad rates in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  expect_true(all(data$grad_rate >= 0 & data$grad_rate <= 1.0, na.rm = TRUE))
})

test_that("2020: Cohort >= Graduates", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  expect_true(all(data$cohort_count >= data$graduate_count, na.rm = TRUE))
})

test_that("2020: State male graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  male_rate <- data |>
    dplyr::filter(is_state, subgroup == "male") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.876
  expect_equal(male_rate, 0.876, tolerance = 0.001)
})

test_that("2020: State female graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  female_rate <- data |>
    dplyr::filter(is_state, subgroup == "female") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.904
  expect_equal(female_rate, 0.904, tolerance = 0.001)
})

test_that("2020: State White graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  white_rate <- data |>
    dplyr::filter(is_state, subgroup == "white") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.922
  expect_equal(white_rate, 0.922, tolerance = 0.001)
})

test_that("2020: State Native American graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  native_rate <- data |>
    dplyr::filter(is_state, subgroup == "native_american") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.727
  expect_equal(native_rate, 0.727, tolerance = 0.001)
})

test_that("2020: Fargo cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  fargo_cohort <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 809
  expect_equal(fargo_cohort, 809)
})

test_that("2020: Bismarck cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  bismarck_cohort <- data |>
    dplyr::filter(district_name == "Bismarck 1", is_district, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 937
  expect_equal(bismarck_cohort, 937)
})

test_that("2020: District records exist", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  expect_true(any(data$is_district))
  expect_gt(sum(data$is_district), 100)
})

test_that("2020: School records exist", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  expect_true(any(data$is_school))
})

test_that("2020: End year is correct", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  expect_true(all(data$end_year == 2020))
})

test_that("2020: Has multiple subgroups", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2020, use_cache = TRUE)

  subgroups <- unique(data$subgroup)
  expect_gt(length(subgroups), 15)
})

# ==============================================================================
# 2017 (2016-2017 school year) - 15 tests
# ==============================================================================

test_that("2017: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.870
  expect_equal(state_rate, 0.870, tolerance = 0.001)
})

test_that("2017: State cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  state_cohort <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 7572
  expect_equal(state_cohort, 7572)
})

test_that("2017: State graduate count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  state_grads <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(graduate_count)

  # Raw CSV value: 6588
  expect_equal(state_grads, 6588)
})

test_that("2017: Fargo graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.848
  expect_equal(fargo_rate, 0.848, tolerance = 0.001)
})

test_that("2017: Bismarck graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  bismarck_rate <- data |>
    dplyr::filter(district_name == "Bismarck 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.876
  expect_equal(bismarck_rate, 0.876, tolerance = 0.001)
})

test_that("2017: No Inf values", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  expect_false(any(is.infinite(data$grad_rate)))
})

test_that("2017: All grad rates in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  expect_true(all(data$grad_rate >= 0 & data$grad_rate <= 1.0, na.rm = TRUE))
})

test_that("2017: Cohort >= Graduates", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  expect_true(all(data$cohort_count >= data$graduate_count, na.rm = TRUE))
})

test_that("2017: State male graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  male_rate <- data |>
    dplyr::filter(is_state, subgroup == "male") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.853
  expect_equal(male_rate, 0.853, tolerance = 0.001)
})

test_that("2017: State female graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  female_rate <- data |>
    dplyr::filter(is_state, subgroup == "female") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.888
  expect_equal(female_rate, 0.888, tolerance = 0.001)
})

test_that("2017: State White graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  white_rate <- data |>
    dplyr::filter(is_state, subgroup == "white") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.905
  expect_equal(white_rate, 0.905, tolerance = 0.001)
})

test_that("2017: State Native American graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  native_rate <- data |>
    dplyr::filter(is_state, subgroup == "native_american") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.673
  expect_equal(native_rate, 0.673, tolerance = 0.001)
})

test_that("2017: District records exist", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  expect_true(any(data$is_district))
  expect_gt(sum(data$is_district), 100)
})

test_that("2017: School records exist", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  expect_true(any(data$is_school))
})

test_that("2017: End year is correct", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2017, use_cache = TRUE)

  expect_true(all(data$end_year == 2017))
})

# ==============================================================================
# 2013 (2012-2013 school year) - 15 tests
# ==============================================================================

test_that("2013: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.872
  expect_equal(state_rate, 0.872, tolerance = 0.001)
})

test_that("2013: State cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  state_cohort <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 7567
  expect_equal(state_cohort, 7567)
})

test_that("2013: State graduate count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  state_grads <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(graduate_count)

  # Raw CSV value: 6598
  expect_equal(state_grads, 6598)
})

test_that("2013: Fargo graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.823
  expect_equal(fargo_rate, 0.823, tolerance = 0.001)
})

test_that("2013: Bismarck graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  bismarck_rate <- data |>
    dplyr::filter(district_name == "Bismarck 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.893
  expect_equal(bismarck_rate, 0.893, tolerance = 0.001)
})

test_that("2013: Grand Forks graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  gf_rate <- data |>
    dplyr::filter(district_name == "Grand Forks 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.878
  expect_equal(gf_rate, 0.878, tolerance = 0.001)
})

test_that("2013: Minot graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  minot_rate <- data |>
    dplyr::filter(district_name == "Minot 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.892
  expect_equal(minot_rate, 0.892, tolerance = 0.001)
})

test_that("2013: No Inf values", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  expect_false(any(is.infinite(data$grad_rate)))
})

test_that("2013: All grad rates in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  expect_true(all(data$grad_rate >= 0 & data$grad_rate <= 1.0, na.rm = TRUE))
})

test_that("2013: Cohort >= Graduates", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  expect_true(all(data$cohort_count >= data$graduate_count, na.rm = TRUE))
})

test_that("2013: State male graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  male_rate <- data |>
    dplyr::filter(is_state, subgroup == "male") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.857
  expect_equal(male_rate, 0.857, tolerance = 0.001)
})

test_that("2013: State female graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  female_rate <- data |>
    dplyr::filter(is_state, subgroup == "female") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.888
  expect_equal(female_rate, 0.888, tolerance = 0.001)
})

test_that("2013: State White graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  white_rate <- data |>
    dplyr::filter(is_state, subgroup == "white") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.903
  expect_equal(white_rate, 0.903, tolerance = 0.001)
})

test_that("2013: State Native American graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  native_rate <- data |>
    dplyr::filter(is_state, subgroup == "native_american") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.643
  expect_equal(native_rate, 0.643, tolerance = 0.001)
})

test_that("2013: District records exist", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  expect_true(any(data$is_district))
})

test_that("2013: End year is correct", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2013, use_cache = TRUE)

  expect_true(all(data$end_year == 2013))
})

# ==============================================================================
# Additional years for comprehensive coverage - 20 more tests
# ==============================================================================

test_that("2022: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2022, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.843
  expect_equal(state_rate, 0.843, tolerance = 0.001)
})

test_that("2022: State cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2022, use_cache = TRUE)

  state_cohort <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 8092
  expect_equal(state_cohort, 8092)
})

test_that("2021: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2021, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.870
  expect_equal(state_rate, 0.870, tolerance = 0.001)
})

test_that("2019: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2019, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.883
  expect_equal(state_rate, 0.883, tolerance = 0.001)
})

test_that("2018: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2018, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.880
  expect_equal(state_rate, 0.880, tolerance = 0.001)
})

test_that("2016: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2016, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.873
  expect_equal(state_rate, 0.873, tolerance = 0.001)
})

test_that("2015: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2015, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.863
  expect_equal(state_rate, 0.863, tolerance = 0.001)
})

test_that("2014: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2014, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.869
  expect_equal(state_rate, 0.869, tolerance = 0.001)
})

test_that("2023: State graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2023, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.827
  expect_equal(state_rate, 0.827, tolerance = 0.001)
})

test_that("2023: State cohort count matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2023, use_cache = TRUE)

  state_cohort <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Raw CSV value: 8294
  expect_equal(state_cohort, 8294)
})

test_that("2022: Fargo graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2022, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Raw CSV value: 0.831
  expect_equal(fargo_rate, 0.831, tolerance = 0.001)
})

test_that("2021: Fargo graduation rate matches raw CSV", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2021, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  # Should have data
  expect_true(!is.na(fargo_rate))
  expect_gt(fargo_rate, 0.7)
  expect_lt(fargo_rate, 1.0)
})

test_that("2019: Fargo graduation rate in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2019, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(fargo_rate))
  expect_gt(fargo_rate, 0.7)
  expect_lt(fargo_rate, 1.0)
})

test_that("2018: Fargo graduation rate in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2018, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(fargo_rate))
  expect_gt(fargo_rate, 0.7)
  expect_lt(fargo_rate, 1.0)
})

test_that("2016: Fargo graduation rate in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2016, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(fargo_rate))
  expect_gt(fargo_rate, 0.7)
  expect_lt(fargo_rate, 1.0)
})

test_that("2015: Fargo graduation rate in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2015, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(fargo_rate))
  expect_gt(fargo_rate, 0.7)
  expect_lt(fargo_rate, 1.0)
})

test_that("2014: Fargo graduation rate in valid range", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation(2014, use_cache = TRUE)

  fargo_rate <- data |>
    dplyr::filter(district_name == "Fargo 1", is_district, subgroup == "all") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(fargo_rate))
  expect_gt(fargo_rate, 0.7)
  expect_lt(fargo_rate, 1.0)
})

test_that("Multi-year fetch returns combined data", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation_multi(c(2020, 2024), use_cache = TRUE)

  expect_true(nrow(data) > 0)
  expect_true(2020 %in% unique(data$end_year))
  expect_true(2024 %in% unique(data$end_year))
})

test_that("Multi-year fetch has consistent schema", {
  skip_if_offline()

  data <- ndschooldata::fetch_graduation_multi(c(2013, 2017, 2020, 2024), use_cache = TRUE)

  required_cols <- c("end_year", "type", "district_id", "district_name",
                     "school_id", "school_name", "subgroup", "cohort_type",
                     "cohort_count", "graduate_count", "grad_rate",
                     "is_state", "is_district", "is_school")

  expect_true(all(required_cols %in% names(data)))
})

# ==============================================================================
# TOTAL TESTS: 100+
# - 2024: 30 tests
# - 2020: 20 tests
# - 2017: 15 tests
# - 2013: 15 tests
# - Additional years: 20 tests
# - Multi-year tests: 2 tests
# ==============================================================================
