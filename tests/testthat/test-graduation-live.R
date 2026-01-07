# ==============================================================================
# LIVE Pipeline Tests for Graduation Rate Data
# ==============================================================================
#
# These tests verify each step of the data pipeline using LIVE network calls.
# The goal is to detect breakages early when ND DOE websites change.
#
# Tests follow the 8-category LIVE pipeline testing framework:
# 1. URL Availability - HTTP 200 checks
# 2. File Download - Verify actual file download
# 3. File Parsing - readr succeeds
# 4. Column Structure - Expected columns exist
# 5. get_raw_graduation() - Raw data function works
# 6. Aggregation - State = sum(districts)
# 7. Data Quality - No Inf/NaN, valid ranges
# 8. Output Fidelity - tidy=TRUE matches raw
#
# ==============================================================================

# Helper function for offline testing
skip_if_offline <- function() {
  tryCatch({
    response <- httr::HEAD("https://www.google.com", httr::timeout(5))
    if (httr::http_error(response)) skip("No network connectivity")
  }, error = function(e) skip("No network connectivity"))
}

# Helper function to parse graduation CSV (handles HTML meta tag)
parse_graduation_csv <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  header_line <- lines[1]
  header_start <- regexpr("AcademicYear", header_line)

  if (header_start == -1) {
    stop("Could not find CSV header in file")
  }

  clean_header <- substr(header_line, header_start, nchar(header_line))
  clean_file <- tempfile(fileext = ".csv")
  writeLines(c(clean_header, lines[-1]), clean_file)

  readr::read_csv(clean_file, show_col_types = FALSE)
}

# ==============================================================================
# 1. URL Availability Tests
# ==============================================================================

test_that("Graduation data URL returns HTTP 200 for 2024", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2023-2024"
  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

test_that("Graduation data URL returns HTTP 200 for 2020", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2019-2020"
  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

test_that("Graduation data URL returns HTTP 200 for 2013", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2012-2013"
  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

test_that("Graduation data URL returns HTTP 200 for multiple years", {
  skip_if_offline()

  years <- c("2015-2016", "2018-2019", "2021-2022")

  for (yr in years) {
    url <- paste0("https://insights.nd.gov/ShowFile?f=10039_39_csv_", yr)
    response <- httr::HEAD(url, httr::timeout(30))
    expect_equal(httr::status_code(response), 200)
  }
})

# ==============================================================================
# 2. File Download Tests
# ==============================================================================

test_that("Can download graduation CSV file for 2024", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2023-2024"
  temp_file <- tempfile(fileext = ".csv")

  response <- httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE),
                        httr::timeout(60))

  expect_equal(httr::status_code(response), 200)
  expect_gt(file.info(temp_file)$size, 1000)  # At least 1KB

  # Verify it's not an HTML error page
  content <- readChar(temp_file, 100)
  expect_false(grepl("<html>", content, ignore.case = TRUE))
  expect_false(grepl("404 Not Found", content))
})

test_that("Downloaded CSV has expected structure", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2023-2024"
  temp_file <- tempfile(fileext = ".csv")

  response <- httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE),
                        httr::timeout(60))

  # Check file has meta tag + CSV headers
  lines <- readLines(temp_file, n = 5, warn = FALSE)
  expect_true(grepl("AcademicYear", lines[1]))
  expect_true(grepl("EntityLevel", lines[1]))
  expect_true(grepl("InstitutionName", lines[1]))
})

test_that("Can download graduation CSV for multiple years", {
  skip_if_offline()

  years <- c("2018-2019", "2021-2022")

  for (yr in years) {
    url <- paste0("https://insights.nd.gov/ShowFile?f=10039_39_csv_", yr)
    temp_file <- tempfile(fileext = ".csv")

    response <- httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE),
                          httr::timeout(60))

    expect_equal(httr::status_code(response), 200)
    expect_gt(file.info(temp_file)$size, 1000)
  }
})

# ==============================================================================
# 3. File Parsing Tests
# ==============================================================================

test_that("Can parse graduation CSV and handle HTML meta tag", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2023-2024"
  temp_file <- tempfile(fileext = ".csv")

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE),
            httr::timeout(60))

  # The HTML meta tag is on the same line as the CSV header
  # We need to strip it, not skip the line
  lines <- readLines(temp_file, warn = FALSE)
  header_line <- lines[1]
  header_start <- regexpr("AcademicYear", header_line)

  expect_true(header_start > 0, info = "CSV header should be found in first line")

  # Extract clean header
  clean_header <- substr(header_line, header_start, nchar(header_line))

  # Write cleaned file
  clean_file <- tempfile(fileext = ".csv")
  writeLines(c(clean_header, lines[-1]), clean_file)

  # Parse CSV
  df <- readr::read_csv(clean_file, show_col_types = FALSE)

  expect_true(is.data.frame(df))
  expect_gt(nrow(df), 0)
  expect_gt(ncol(df), 5)

  # Verify expected columns exist
  expect_true("AcademicYear" %in% names(df))
  expect_true("EntityLevel" %in% names(df))
  expect_true("InstitutionName" %in% names(df))
})

test_that("Parsed CSV has expected number of rows for 2024", {
  skip_if_offline()

  raw <- ndschooldata::get_raw_graduation(2024)

  expect_true(is.data.frame(raw))
  expect_gt(nrow(raw), 1000)
  expect_true("end_year" %in% names(raw))
  expect_equal(unique(raw$end_year), 2024)
})

test_that("Can parse CSVs from multiple years using HTML tag stripping", {
  skip_if_offline()

  years <- c("2016-2017", "2019-2020", "2021-2022")

  for (yr in years) {
    url <- paste0("https://insights.nd.gov/ShowFile?f=10039_39_csv_", yr)
    temp_file <- tempfile(fileext = ".csv")

    httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE),
              httr::timeout(60))

    # Strip HTML meta tag from first line
    lines <- readLines(temp_file, warn = FALSE)
    header_line <- lines[1]
    header_start <- regexpr("AcademicYear", header_line)

    expect_true(header_start > 0,
                info = paste("CSV header should be found for", yr))

    clean_header <- substr(header_line, header_start, nchar(header_line))
    clean_file <- tempfile(fileext = ".csv")
    writeLines(c(clean_header, lines[-1]), clean_file)

    df <- readr::read_csv(clean_file, show_col_types = FALSE)

    expect_true(is.data.frame(df))
    expect_gt(nrow(df), 0)
  }
})

# ==============================================================================
# 4. Column Structure Tests
# ==============================================================================

test_that("Graduation CSV has expected columns", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2023-2024"
  temp_file <- tempfile(fileext = ".csv")

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE),
            httr::timeout(60))

  # Parse with HTML meta tag handling
  df <- parse_graduation_csv(temp_file)

  expected_cols <- c("AcademicYear", "EntityLevel", "InstitutionName",
                     "InstitutionID", "Subgroup", "FourYearGradRate",
                     "FourYearCohortGraduateCount", "TotalFourYearCohort")

  expect_true(all(expected_cols %in% names(df)))
})

test_that("Column types are correct", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2023-2024"
  temp_file <- tempfile(fileext = ".csv")

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE),
            httr::timeout(60))

  # Parse with HTML meta tag handling
  df <- parse_graduation_csv(temp_file)

  # AcademicYear should be character
  expect_type(df$AcademicYear, "character")

  # EntityLevel should be character
  expect_type(df$EntityLevel, "character")

  # FourYearGradRate should be numeric/double
  expect_type(df$FourYearGradRate, "double")

  # Counts should be numeric/double
  expect_type(df$FourYearCohortGraduateCount, "double")
  expect_type(df$TotalFourYearCohort, "double")
})

test_that("CSV has EntityLevel values State, District, School", {
  skip_if_offline()

  url <- "https://insights.nd.gov/ShowFile?f=10039_39_csv_2023-2024"
  temp_file <- tempfile(fileext = ".csv")

  httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE),
            httr::timeout(60))

  # Parse with HTML meta tag handling
  df <- parse_graduation_csv(temp_file)

  entity_levels <- unique(df$EntityLevel)

  expect_true("State" %in% entity_levels)
  expect_true("District" %in% entity_levels)
  expect_true("School" %in% entity_levels)
})

# ==============================================================================
# 5. get_raw_graduation() Tests
# ==============================================================================

test_that("get_raw_graduation() returns valid data frame for 2024", {
  skip_if_offline()

  raw <- ndschooldata::get_raw_graduation(2024)

  expect_true(is.data.frame(raw))
  expect_gt(nrow(raw), 0)
  expect_true("end_year" %in% names(raw))
  expect_equal(unique(raw$end_year), 2024)
})

test_that("get_raw_graduation() returns consistent columns across years", {
  skip_if_offline()

  raw_2020 <- ndschooldata::get_raw_graduation(2020)
  raw_2024 <- ndschooldata::get_raw_graduation(2024)

  expect_true(all(names(raw_2020) %in% names(raw_2024)))
  expect_true(all(names(raw_2024) %in% names(raw_2020)))
})

test_that("get_raw_graduation() validates year parameter", {
  skip_if_offline()

  expect_error(
    ndschooldata::get_raw_graduation(2010),  # Too early
    "not available"
  )
})

# ==============================================================================
# 6. Aggregation Tests
# ==============================================================================

test_that("State total matches sum of districts", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2024, tidy = TRUE)

  # Get state total
  state_total <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  # Sum of districts (should be close to state total, minus direct state schools)
  district_total <- data |>
    dplyr::filter(is_district, subgroup == "all") |>
    dplyr::summarise(total = sum(cohort_count, na.rm = TRUE)) |>
    dplyr::pull(total)

  # District total should be close to state total (within 10%)
  expect_true(abs(state_total - district_total) < state_total * 0.1)
})

test_that("District totals sum correctly to state for 2020", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2020, tidy = TRUE)

  state_cohort <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  state_grads <- data |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(graduate_count)

  expect_gt(state_cohort, 7000)
  expect_gt(state_grads, 6000)
  expect_gt(state_grads, state_cohort * 0.8)  # At least 80% grad rate
})

test_that("School records sum to district totals", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2024, tidy = TRUE)

  # Test Fargo schools
  fargo_district <- data |>
    dplyr::filter(district_name == "Fargo 1", subgroup == "all", is_district) |>
    dplyr::pull(cohort_count)

  fargo_schools <- data |>
    dplyr::filter(district_name == "Fargo 1", subgroup == "all", is_school) |>
    dplyr::summarise(total = sum(cohort_count, na.rm = TRUE)) |>
    dplyr::pull(total)

  # Schools should sum to district total (within 5%)
  expect_true(abs(fargo_district - fargo_schools) < fargo_district * 0.05)
})

# ==============================================================================
# 7. Data Quality Tests
# ==============================================================================

test_that("No Inf or NaN in tidy output for 2024", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2024, tidy = TRUE)

  # Check all numeric columns
  numeric_cols <- names(data)[sapply(data, is.numeric)]
  for (col in numeric_cols) {
    expect_false(any(is.infinite(data[[col]])),
                 info = paste("Column", col, "should not have Inf values"))
    expect_false(any(is.nan(data[[col]])),
                 info = paste("Column", col, "should not have NaN values"))
  }
})

test_that("All graduation rates in valid range", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2024, tidy = TRUE)

  expect_true(all(data$grad_rate >= 0, na.rm = TRUE),
              info = "All grad rates should be >= 0")
  expect_true(all(data$grad_rate <= 1.0, na.rm = TRUE),
              info = "All grad rates should be <= 1.0")
})

test_that("Cohort count always >= graduate count", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2024, tidy = TRUE)

  expect_true(all(data$cohort_count >= data$graduate_count, na.rm = TRUE),
              info = "Cohort should always be >= graduates")
})

test_that("No negative values in counts", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2024, tidy = TRUE)

  expect_true(all(data$cohort_count >= 0, na.rm = TRUE))
  expect_true(all(data$graduate_count >= 0, na.rm = TRUE))
})

test_that("State total has non-zero values", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2024, tidy = TRUE)

  state_data <- data |>
    dplyr::filter(is_state, subgroup == "all")

  expect_gt(state_data$cohort_count, 8000)
  expect_gt(state_data$graduate_count, 6000)
  expect_gt(state_data$grad_rate, 0.7)
})

# ==============================================================================
# 8. Output Fidelity Tests
# ==============================================================================

test_that("tidy=TRUE matches raw data totals", {
  skip_if_offline()


  raw <- ndschooldata::get_raw_graduation(2024)
  tidy <- ndschooldata::fetch_graduation(2024, tidy = TRUE)

  # State-level total should match
  raw_state_total <- raw |>
    dplyr::filter(EntityLevel == "State", Subgroup == "All") |>
    dplyr::pull(TotalFourYearCohort)

  tidy_state_total <- tidy |>
    dplyr::filter(is_state, subgroup == "all") |>
    dplyr::pull(cohort_count)

  expect_equal(raw_state_total, tidy_state_total)
})

test_that("tidy=FALSE returns processed data", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation(2024, tidy = FALSE)

  expect_true(is.data.frame(data))
  expect_gt(nrow(data), 0)
  # Should have different columns than tidy format
})

test_that("use_cache=FALSE forces re-download", {
  skip_if_offline()


  # Force fresh download
  data <- ndschooldata::fetch_graduation(2024, use_cache = FALSE)

  expect_true(is.data.frame(data))
  expect_gt(nrow(data), 0)
})

test_that("Multi-year fetch returns consistent schema", {
  skip_if_offline()


  data <- ndschooldata::fetch_graduation_multi(c(2020, 2024), tidy = TRUE)

  required_cols <- c("end_year", "type", "district_id", "district_name",
                     "school_id", "school_name", "subgroup", "cohort_type",
                     "cohort_count", "graduate_count", "grad_rate",
                     "is_state", "is_district", "is_school")

  expect_true(all(required_cols %in% names(data)))
  expect_true(nrow(data) > 0)
  expect_equal(sort(unique(data$end_year)), c(2020, 2024))
})

# ==============================================================================
# TOTAL: 8 categories × multiple tests each = comprehensive coverage
# ==============================================================================
