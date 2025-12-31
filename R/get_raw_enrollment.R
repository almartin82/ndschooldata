# ==============================================================================
# Raw Enrollment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from the
# North Dakota Department of Public Instruction (NDDPI).
#
# Data Source:
#   https://www.nd.gov/dpi/data
#
# File: EnrollmentHistoryPublicSchoolDistrict.xlsx
#   - Multi-sheet Excel file with one sheet per school year
#   - Sheet names: "2007-08" through "2025-26" (and newer as added)
#   - Each sheet contains district-level enrollment by grade
#
# ==============================================================================

#' NDDPI enrollment data URL
#'
#' @return URL string for the enrollment history Excel file
#' @keywords internal
get_nddpi_url <- function() {
  "https://www.nd.gov/dpi/sites/www/files/documents/Data/EnrollmentHistoryPublicSchoolDistrict.xlsx"
}


#' Download raw enrollment data from NDDPI
#'
#' Downloads the enrollment history Excel file from NDDPI and extracts
#' the sheet for the requested year. Uses a cached copy of the raw file
#' to avoid repeated downloads.
#'
#' @param end_year School year end (e.g., 2024 for 2023-24 school year)
#' @return Data frame with raw enrollment data for the requested year
#' @keywords internal
get_raw_enr <- function(end_year) {

  # Validate year
  available_years <- get_available_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "end_year must be between ", min(available_years), " and ", max(available_years),
      "\nAvailable years: ", paste(range(available_years), collapse = "-")
    ))
  }

  message(paste("Fetching NDDPI enrollment data for", end_year, "..."))

  # Get the cached raw file (downloads if needed)
  raw_file <- get_cached_raw_file()

  # Read the sheet for this year
  sheet_name <- end_year_to_sheet(end_year)

  # Check if sheet exists
  available_sheets <- readxl::excel_sheets(raw_file)
  if (!sheet_name %in% available_sheets) {
    stop(paste0(
      "Sheet '", sheet_name, "' not found in NDDPI data file.\n",
      "Available sheets: ", paste(head(available_sheets, 5), collapse = ", "), "..."
    ))
  }

  # Read the sheet - skip header rows
  # Row 1: Title (e.g., "Public School District Fall Enrollment 2024-25")
  # Row 2: Column headers (CoDist, DistrictName, K, Gr1, ..., Total)
  # Row 3+: Data
  df <- readxl::read_excel(
    raw_file,
    sheet = sheet_name,
    skip = 2,
    col_names = c(
      "district_id", "district_name",
      "grade_k", "grade_01", "grade_02", "grade_03", "grade_04",
      "grade_05", "grade_06", "grade_07", "grade_08", "grade_09",
      "grade_10", "grade_11", "grade_12", "total"
    ),
    col_types = "text"
  )

  # Add end_year column
  df$end_year <- end_year

  df
}


#' Download NDDPI file to temp location
#'
#' @param url URL to download
#' @return Path to downloaded temp file
#' @keywords internal
download_nddpi_file <- function(url) {

  temp_file <- tempfile(
    pattern = "nddpi_enrollment_",
    tmpdir = tempdir(),
    fileext = ".xlsx"
  )

  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(temp_file, overwrite = TRUE),
      httr::timeout(120),
      httr::user_agent("ndschooldata R package")
    )

    if (httr::http_error(response)) {
      stop(paste("HTTP error:", httr::status_code(response)))
    }

    # Verify file was downloaded and is not empty
    file_info <- file.info(temp_file)
    if (is.na(file_info$size) || file_info$size < 1000) {
      stop("Downloaded file is too small or empty")
    }

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    stop(paste(
      "Failed to download NDDPI enrollment data.\n",
      "URL:", url, "\n",
      "Error:", e$message
    ))
  })

  temp_file
}


#' Get cached raw file path
#'
#' Returns path to cached raw Excel file, downloading if necessary.
#' The raw file is cached separately from processed data to avoid
#' re-downloading when processing multiple years.
#'
#' @param max_age Maximum age in days before re-downloading (default 7)
#' @return Path to the cached raw Excel file
#' @keywords internal
get_cached_raw_file <- function(max_age = 7) {

  cache_dir <- get_cache_dir()
  raw_file <- file.path(cache_dir, "EnrollmentHistoryPublicSchoolDistrict.xlsx")

  # Check if cached file exists and is fresh
  if (file.exists(raw_file)) {
    file_info <- file.info(raw_file)
    age_days <- as.numeric(difftime(Sys.time(), file_info$mtime, units = "days"))

    if (age_days <= max_age) {
      return(raw_file)
    }
  }

  # Download fresh copy
  message("Downloading fresh NDDPI data file...")
  url <- get_nddpi_url()

  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(raw_file, overwrite = TRUE),
      httr::timeout(120),
      httr::user_agent("ndschooldata R package")
    )

    if (httr::http_error(response)) {
      stop(paste("HTTP error:", httr::status_code(response)))
    }

  }, error = function(e) {
    stop(paste(
      "Failed to download NDDPI enrollment data.\n",
      "URL:", url, "\n",
      "Error:", e$message
    ))
  })

  raw_file
}
