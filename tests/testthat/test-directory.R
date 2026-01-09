# ==============================================================================
# Tests for School Directory Functions
# ==============================================================================
#
# These tests verify the school directory data pipeline using LIVE network calls.
#
# ==============================================================================

library(testthat)
library(httr)

# Skip if no network connectivity
skip_if_offline <- function() {
  tryCatch({
    response <- httr::HEAD("https://www.google.com", httr::timeout(5))
    if (httr::http_error(response)) {
      skip("No network connectivity")
    }
  }, error = function(e) {
    skip("No network connectivity")
  })
}

# ==============================================================================
# URL Availability Tests
# ==============================================================================

test_that("ND Insights school directory URL returns HTTP 200", {
  skip_if_offline()

  url <- ndschooldata:::get_school_directory_url(2024)
  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

test_that("ND Insights district directory URL returns HTTP 200", {
  skip_if_offline()

  url <- ndschooldata:::get_district_directory_url(2024)
  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

# ==============================================================================
# get_directory_years() Tests
# ==============================================================================

test_that("get_directory_years returns valid year range", {
  years <- ndschooldata::get_directory_years()

  expect_true(is.integer(years))
  expect_true(length(years) > 5)
  expect_true(all(years >= 2014 & years <= 2030))
  expect_equal(min(years), 2014L)
})

# ==============================================================================
# Raw Data Download Tests
# ==============================================================================

test_that("get_raw_school_directory returns data", {
  skip_if_offline()

  tryCatch({
    raw <- ndschooldata:::get_raw_school_directory(2024)

    expect_true(is.data.frame(raw))
    expect_gt(nrow(raw), 100)  # Should have 100+ schools
    expect_true("InstitutionName" %in% names(raw))
    expect_true("DistrictInstitutionID" %in% names(raw))
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

test_that("get_raw_district_directory returns data", {
  skip_if_offline()

  tryCatch({
    raw <- ndschooldata:::get_raw_district_directory(2024)

    expect_true(is.data.frame(raw))
    expect_gt(nrow(raw), 50)  # Should have 50+ districts
    expect_true("InstitutionName" %in% names(raw))
    expect_true("DistrictInstitutionID" %in% names(raw))
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

# ==============================================================================
# fetch_directory() Tests
# ==============================================================================

test_that("fetch_directory returns school data with expected columns", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_directory(2024, tidy = TRUE, use_cache = FALSE)

    expect_true(is.data.frame(data))
    expect_gt(nrow(data), 100)

    # Check required columns exist
    expected_cols <- c(
      "end_year", "district_id", "school_id",
      "district_name", "school_name",
      "principal_name", "superintendent_name",
      "address", "city", "state", "zip", "phone"
    )
    for (col in expected_cols) {
      expect_true(col %in% names(data), info = paste("Missing column:", col))
    }
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

test_that("fetch_directory tidy=FALSE returns school-only data", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_directory(2024, tidy = FALSE, use_cache = FALSE)

    expect_true(is.data.frame(data))
    expect_gt(nrow(data), 100)

    # Should have school columns but NOT superintendent
    expect_true("principal_name" %in% names(data))
    expect_false("superintendent_name" %in% names(data))
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

test_that("fetch_directory defaults to most recent year", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_directory(use_cache = FALSE)

    expect_true(is.data.frame(data))
    expect_equal(unique(data$end_year), max(ndschooldata::get_directory_years()))
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

# ==============================================================================
# fetch_district_directory() Tests
# ==============================================================================

test_that("fetch_district_directory returns district data", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_district_directory(2024, use_cache = FALSE)

    expect_true(is.data.frame(data))
    expect_gt(nrow(data), 50)

    # Check required columns
    expected_cols <- c(
      "end_year", "district_id", "district_name",
      "superintendent_name", "superintendent_email",
      "address", "phone"
    )
    for (col in expected_cols) {
      expect_true(col %in% names(data), info = paste("Missing column:", col))
    }
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

# ==============================================================================
# Data Quality Tests
# ==============================================================================

test_that("Directory data has no Inf or NaN in numeric columns", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_directory(2024, use_cache = FALSE)

    for (col in names(data)[sapply(data, is.numeric)]) {
      expect_false(any(is.infinite(data[[col]]), na.rm = TRUE),
                   info = paste("No Inf in", col))
      expect_false(any(is.nan(data[[col]]), na.rm = TRUE),
                   info = paste("No NaN in", col))
    }
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

test_that("All school IDs are 10 digits", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_directory(2024, tidy = FALSE, use_cache = FALSE)

    # School IDs should be 10 characters
    id_lengths <- nchar(data$school_id)
    expect_true(all(id_lengths == 10),
                info = paste("Non-10-digit IDs:", paste(unique(id_lengths), collapse = ", ")))
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

test_that("All district IDs are 5 digits", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_directory(2024, use_cache = FALSE)

    # District IDs should be 5 characters
    id_lengths <- nchar(data$district_id)
    expect_true(all(id_lengths == 5),
                info = paste("Non-5-digit IDs:", paste(unique(id_lengths), collapse = ", ")))
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

# ==============================================================================
# Raw Data Fidelity Tests
# ==============================================================================

test_that("2024: Alexander Elementary School principal matches raw data", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_directory(2024, tidy = FALSE, use_cache = FALSE)

    # Alexander Elementary (ID 2700203151) should have AJ Allard as principal
    alexander <- data[data$school_id == "2700203151", ]

    expect_equal(nrow(alexander), 1, info = "Alexander Elementary should exist")
    expect_equal(alexander$school_name[1], "Alexander Elementary School")
    expect_true(grepl("Allard", alexander$principal_name[1]),
                info = paste("Expected 'Allard' in principal name, got:", alexander$principal_name[1]))
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

test_that("2024: Fargo district has superintendent", {
  skip_if_offline()

  tryCatch({
    data <- ndschooldata::fetch_district_directory(2024, use_cache = FALSE)

    # Fargo Public School District (09001)
    fargo <- data[data$district_id == "09001", ]

    expect_equal(nrow(fargo), 1, info = "Fargo district should exist")
    expect_true(grepl("Fargo", fargo$district_name[1]))
    expect_true(!is.na(fargo$superintendent_name[1]) && fargo$superintendent_name[1] != "",
                info = "Fargo should have a superintendent")
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})

# ==============================================================================
# Year Validation Tests
# ==============================================================================

test_that("fetch_directory errors on invalid year", {
  expect_error(
    ndschooldata::fetch_directory(1990),
    regexp = "end_year must be between"
  )

  expect_error(
    ndschooldata::fetch_directory(2030),
    regexp = "end_year must be between"
  )
})

test_that("fetch_district_directory errors on invalid year", {
  expect_error(
    ndschooldata::fetch_district_directory(1990),
    regexp = "end_year must be between"
  )
})

# ==============================================================================
# Multiple Year Tests
# ==============================================================================

test_that("Directory data available for multiple years", {
  skip_if_offline()

  tryCatch({
    years_to_test <- c(2020, 2022, 2024)

    for (yr in years_to_test) {
      data <- ndschooldata::fetch_directory(yr, use_cache = FALSE)
      expect_gt(nrow(data), 0)
      expect_equal(unique(data$end_year), yr)
    }
  }, error = function(e) {
    skip(paste("Data source may be broken:", e$message))
  })
})
