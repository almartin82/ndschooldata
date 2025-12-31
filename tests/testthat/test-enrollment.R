# Tests for enrollment functions
# Note: Most tests are marked as skip_on_cran since they require network access

test_that("safe_numeric handles various inputs", {
  # Normal numbers
  expect_equal(safe_numeric("100"), 100)
  expect_equal(safe_numeric("1,234"), 1234)

  # Suppressed values
  expect_true(is.na(safe_numeric("*")))
  expect_true(is.na(safe_numeric("-1")))
  expect_true(is.na(safe_numeric("<5")))
  expect_true(is.na(safe_numeric("<10")))
  expect_true(is.na(safe_numeric("")))
  expect_true(is.na(safe_numeric("Total")))

  # Whitespace handling
  expect_equal(safe_numeric("  100  "), 100)
})

test_that("parse_school_year handles various formats", {
  # Standard format
  expect_equal(parse_school_year("2023-24"), 2024L)
  expect_equal(parse_school_year("2007-08"), 2008L)

  # Full year format
  expect_equal(parse_school_year("2023-2024"), 2024L)

  # Single year
  expect_equal(parse_school_year("2024"), 2024L)
})

test_that("end_year_to_sheet converts correctly", {
  expect_equal(end_year_to_sheet(2024), "2023-24")
  expect_equal(end_year_to_sheet(2008), "2007-08")
  expect_equal(end_year_to_sheet(2010), "2009-10")
})

test_that("get_available_years returns valid range", {
  years <- get_available_years()

  expect_true(is.integer(years))
  expect_true(min(years) == 2008)
  expect_true(max(years) >= 2024)
  expect_true(length(years) >= 17)  # At least 17 years of data
})

test_that("fetch_enr validates year parameter", {
  expect_error(fetch_enr(2000), "end_year must be between")
  expect_error(fetch_enr(2050), "end_year must be between")
})

test_that("get_cache_dir returns valid path", {
  cache_dir <- get_cache_dir()
  expect_true(is.character(cache_dir))
  expect_true(grepl("ndschooldata", cache_dir))
})

test_that("cache functions work correctly", {
  # Test cache path generation
  path <- get_cache_path(2024, "tidy")
  expect_true(grepl("enr_tidy_2024.rds", path))

  # Test cache_exists returns FALSE for non-existent cache
  # (Assuming no cache exists for year 9999)
  expect_false(cache_exists(9999, "tidy"))
})

test_that("get_nddpi_url returns valid URL", {
  url <- get_nddpi_url()
  expect_true(grepl("nd.gov/dpi", url))
  expect_true(grepl(".xlsx", url))
})

# Integration tests (require network access)
test_that("fetch_enr downloads and processes data", {
  skip_on_cran()
  skip_if_offline()

  # Use a recent year
  result <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  # Check structure
  expect_true(is.data.frame(result))
  expect_true("district_id" %in% names(result))
  expect_true("district_name" %in% names(result))
  expect_true("row_total" %in% names(result))
  expect_true("type" %in% names(result))
  expect_true("end_year" %in% names(result))

  # Check we have state and district levels
  expect_true("State" %in% result$type)
  expect_true("District" %in% result$type)

  # Check grade columns exist
  expect_true("grade_k" %in% names(result))
  expect_true("grade_12" %in% names(result))

  # Check district count (should be around 167-173)
  n_districts <- sum(result$type == "District")
  expect_true(n_districts >= 150 && n_districts <= 200)

  # Check district ID format (CC-DDD)
  districts <- result[result$type == "District", ]
  expect_true(all(grepl("^\\d{2}-\\d{3}$", districts$district_id)))
})

test_that("fetch_enr works for earliest year", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2008, tidy = FALSE, use_cache = TRUE)

  expect_true(is.data.frame(result))
  expect_true(all(result$end_year == 2008))
  expect_true("State" %in% result$type)
})

test_that("tidy_enr produces correct long format", {
  skip_on_cran()
  skip_if_offline()

  # Get wide data
  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  # Tidy it
  tidy_result <- tidy_enr(wide)

  # Check structure
  expect_true("grade_level" %in% names(tidy_result))
  expect_true("subgroup" %in% names(tidy_result))
  expect_true("n_students" %in% names(tidy_result))
  expect_true("pct" %in% names(tidy_result))

  # Check subgroups include expected values
  subgroups <- unique(tidy_result$subgroup)
  expect_true("total_enrollment" %in% subgroups)

  # Check grade levels
  grades <- unique(tidy_result$grade_level)
  expect_true("TOTAL" %in% grades)
  expect_true("K" %in% grades)
  expect_true("12" %in% grades)
})

test_that("id_enr_aggs adds correct flags", {
  skip_on_cran()
  skip_if_offline()

  # Get tidy data with aggregation flags
  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Check flags exist
  expect_true("is_state" %in% names(result))
  expect_true("is_district" %in% names(result))
  expect_true("is_campus" %in% names(result))

  # Check flags are boolean
  expect_true(is.logical(result$is_state))
  expect_true(is.logical(result$is_district))
  expect_true(is.logical(result$is_campus))

  # Check mutual exclusivity for state and district
  # (campus should all be FALSE for ND data)
  state_district_sums <- result$is_state + result$is_district
  expect_true(all(state_district_sums == 1))
  expect_true(all(!result$is_campus))  # No campus data in ND
})

test_that("enr_grade_aggs creates correct aggregates", {
  skip_on_cran()
  skip_if_offline()

  # Get tidy data
  tidy_data <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Create aggregates
  aggs <- enr_grade_aggs(tidy_data)

  # Check grade levels created
  expect_true("K8" %in% aggs$grade_level)
  expect_true("HS" %in% aggs$grade_level)
  expect_true("K12" %in% aggs$grade_level)

  # Get state totals for validation
  state_k8 <- aggs[aggs$is_state & aggs$grade_level == "K8", "n_students"]
  state_hs <- aggs[aggs$is_state & aggs$grade_level == "HS", "n_students"]
  state_k12 <- aggs[aggs$is_state & aggs$grade_level == "K12", "n_students"]

  # K-8 + HS should equal K-12
  expect_equal(state_k8$n_students + state_hs$n_students, state_k12$n_students)
})

test_that("fetch_enr_multi works correctly", {
  skip_on_cran()
  skip_if_offline()

  # Fetch two years
  result <- fetch_enr_multi(2023:2024, tidy = FALSE, use_cache = TRUE)

  expect_true(is.data.frame(result))
  expect_true(2023 %in% result$end_year)
  expect_true(2024 %in% result$end_year)

  # Check we have data from both years
  expect_true(sum(result$end_year == 2023) > 0)
  expect_true(sum(result$end_year == 2024) > 0)
})

test_that("state totals are reasonable", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  # Get state total
  state_row <- result[result$type == "State", ]
  expect_equal(nrow(state_row), 1)

  # North Dakota has ~120,000-130,000 K-12 students
  state_total <- state_row$row_total
  expect_true(state_total >= 100000 && state_total <= 150000)
})
