# ==============================================================================
# Raw Graduation Rate Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw graduation rate data from
# the North Dakota Insights portal (insights.nd.gov).
#
# Data Source:
#   https://insights.nd.gov/ShowFile?f=10039_39_csv_YYYY-YYYY
#
# File Format:
#   CSV with HTML meta tag on first line
#   Academic year format: "YYYY-YYYY" (e.g., "2023-2024")
#
# ==============================================================================

#' Build ND Insights graduation rate URL
#'
#' @param end_year Academic year end (e.g., 2024 for 2023-24 school year)
#' @return URL string for the graduation rate CSV file
#' @keywords internal
build_grad_url <- function(end_year) {
  start_year <- end_year - 1L
  academic_year <- paste0(start_year, "-", end_year)
  paste0("https://insights.nd.gov/ShowFile?f=10039_39_csv_", academic_year)
}


#' Get available graduation rate years
#'
#' Returns the years available in the ND Insights graduation rate data.
#' Currently 2013-2024 (based on verified CSV downloads).
#'
#' @return Integer vector of available end years
#' @export
#' @examples
#' get_available_grad_years()
get_available_grad_years <- function() {
  # Verified years: 2012-2013 through 2023-2024
  # These represent end years 2013 through 2024
  # Note: 2024-2025 data not yet available as of 2026-01-07
  2013L:2024L
}


#' Download raw graduation rate data from ND Insights
#'
#' Downloads the 4-year cohort graduation rate CSV from ND Insights portal.
#' The CSV file has an HTML meta tag on the first line that must be stripped
#' before parsing.
#'
#' @param end_year Academic year end (e.g., 2024 for 2023-24 school year)
#' @param cache_dir Directory to cache downloaded files (uses package cache if NULL)
#' @return Data frame with raw graduation data as provided by ND Insights
#' @export
#' @examples
#' \dontrun{
#' # Get raw 2024 graduation data
#' raw <- get_raw_graduation(2024)
#'
#' # View raw structure
#' names(raw)
#' head(raw)
#' }
get_raw_graduation <- function(end_year, cache_dir = NULL) {

  # Validate year
  available_years <- get_available_grad_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "Graduation data not available for ", end_year,
      ". Available years: ", paste(min(available_years), "-", max(available_years), sep = ""),
      ". Data source: ND Insights 4-Year Cohort Graduation Rate"
    ))
  }

  # Build URL
  url <- build_grad_url(end_year)

  # Set cache directory
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  # Build file path for cached CSV
  academic_year <- paste0(end_year - 1L, "-", end_year)
  cache_file <- file.path(cache_dir, paste0("graduation_", academic_year, ".csv"))

  # Check if cached file exists and is fresh
  if (file.exists(cache_file)) {
    file_info <- file.info(cache_file)
    age_days <- as.numeric(difftime(Sys.time(), file_info$mtime, units = "days"))

    # Use cached file if less than 7 days old
    if (age_days <= 7) {
      message(paste("Using cached graduation data for", end_year))
      return(parse_graduation_csv(cache_file))
    }
  }

  # Download fresh copy
  message(paste("Downloading graduation data for", end_year, "..."))

  tryCatch({
    # Download to temp location first
    temp_file <- tempfile(fileext = ".csv")

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
    if (is.na(file_info$size) || file_info$size < 100) {
      stop("Downloaded file is too small or empty")
    }

    # Save to cache
    file.copy(temp_file, cache_file, overwrite = TRUE)

    # Parse and return
    df <- parse_graduation_csv(temp_file)

    # Clean up temp file
    unlink(temp_file)

    return(df)

  }, error = function(e) {
    stop(paste(
      "Failed to download ND graduation data.\n",
      "URL:", url, "\n",
      "Year:", end_year, "\n",
      "Error:", e$message
    ))
  })
}


#' Parse graduation CSV file
#'
#' Parses the ND Insights graduation CSV file, handling the HTML meta tag
#' on the first line.
#'
#' @param file_path Path to the CSV file
#' @return Data frame with raw graduation data
#' @keywords internal
parse_graduation_csv <- function(file_path) {

  # Read all lines
  lines <- readLines(file_path, warn = FALSE)

  # Strip HTML meta tag from first line
  # First line format: <meta...>AcademicYear,EntityLevel,...
  header_line <- lines[1]
  header_start <- regexpr("AcademicYear", header_line)

  if (header_start == -1) {
    stop("Could not find CSV header in file. File may be corrupted.")
  }

  # Extract clean header
  clean_header <- substr(header_line, header_start, nchar(header_line))

  # Write cleaned file to temp location
  clean_file <- tempfile(fileext = ".csv")
  writeLines(c(clean_header, lines[-1]), clean_file)

  # Parse CSV
  df <- readr::read_csv(clean_file, show_col_types = FALSE)

  # Clean up temp file
  unlink(clean_file)

  # Add end_year column by parsing AcademicYear
  # AcademicYear format: "2023-2024" -> end_year = 2024
  df$end_year <- stringr::str_extract(df$AcademicYear, "\\d{4}$") |> as.integer()

  df
}
