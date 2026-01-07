# ==============================================================================
# Graduation Rate Data Fetching Functions
# ==============================================================================
#
# This file contains the main user-facing functions for downloading graduation
# rate data from the North Dakota Insights portal.
#
# ==============================================================================

#' Fetch North Dakota graduation rate data
#'
#' Downloads and processes 4-year cohort graduation rate data from the North
#' Dakota Insights portal (insights.nd.gov).
#'
#' @param end_year A school year end. Year is the end of the academic year - e.g.,
#'   2024 for the 2023-24 school year. Valid values are 2013-2024.
#' @param tidy If TRUE (default), returns data in long (tidy) format with subgroup
#'   column. If FALSE, returns wide format (closer to source).
#' @param use_cache If TRUE (default), uses locally cached data when available.
#'   Set to FALSE to force re-download from ND Insights.
#' @return Data frame with graduation rate data. Wide format includes columns for
#'   entity_level, institution_name, subgroup, grad_rate, cohort_count,
#'   graduate_count. Tidy format adds type, district_id, school_id, and
#'   aggregation flags.
#' @export
#' @examples
#' \dontrun{
#' # Get 2024 graduation rates (2023-24 school year)
#' grad_2024 <- fetch_graduation(2024)
#'
#' # Get wide format
#' grad_wide <- fetch_graduation(2024, tidy = FALSE)
#'
#' # Force fresh download (ignore cache)
#' grad_fresh <- fetch_graduation(2024, use_cache = FALSE)
#'
#' # Filter to state level
#' state <- grad_2024 |>
#'   dplyr::filter(is_state, subgroup == "all")
#'
#' # Filter to specific district
#' fargo <- grad_2024 |>
#'   dplyr::filter(district_name == "Fargo 1", subgroup == "all")
#' }
fetch_graduation <- function(end_year, tidy = TRUE, use_cache = TRUE) {

  # Validate year
  available_years <- get_available_grad_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "Graduation data not available for ", end_year,
      ". Available years: ", paste(min(available_years), "-", max(available_years), sep = ""),
      ". Data source: ND Insights 4-Year Cohort Graduation Rate"
    ))
  }

  # Determine cache type based on tidy parameter
  cache_type <- if (tidy) "grad_tidy" else "grad_wide"

  # Check cache first
  if (use_cache) {
    cache_file <- get_cache_file_path(end_year, cache_type)
    if (file.exists(cache_file)) {
      file_info <- file.info(cache_file)
      age_days <- as.numeric(difftime(Sys.time(), file_info$mtime, units = "days"))

      # Use cached file if less than 7 days old
      if (age_days <= 7) {
        message(paste("Using cached graduation data for", end_year))
        return(readRDS(cache_file))
      }
    }
  }

  # Get raw data from ND Insights
  raw <- get_raw_graduation(end_year)

  # Process to standard schema
  processed <- process_graduation(raw, end_year)

  # Optionally tidy
  if (tidy) {
    result <- tidy_graduation(processed, end_year)
  } else {
    # Keep processed data with entity_level preserved
    result <- processed
  }

  # Cache the result
  if (use_cache) {
    cache_file <- get_cache_file_path(end_year, cache_type)
    saveRDS(result, cache_file)
  }

  result
}


#' Fetch graduation rate data for multiple years
#'
#' Downloads and combines graduation rate data for multiple school years.
#'
#' @param end_years Vector of school year ends (e.g., c(2020, 2021, 2024))
#' @param tidy If TRUE (default), returns data in long (tidy) format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return Combined data frame with graduation rate data for all requested years
#' @export
#' @examples
#' \dontrun{
#' # Get 5 years of data
#' grad_multi <- fetch_graduation_multi(2020:2024)
#'
#' # Track state graduation rate trends
#' grad_multi |>
#'   dplyr::filter(is_state, subgroup == "all") |>
#'   dplyr::select(end_year, grad_rate, cohort_count, graduate_count)
#'
#' # Compare districts
#' grad_multi |>
#'   dplyr::filter(district_name %in% c("Fargo 1", "Bismarck 1"),
#'                 subgroup == "all") |>
#'   dplyr::select(end_year, district_name, grad_rate)
#' }
fetch_graduation_multi <- function(end_years, tidy = TRUE, use_cache = TRUE) {

  # Validate years
  available_years <- get_available_grad_years()
  invalid_years <- end_years[!end_years %in% available_years]

  if (length(invalid_years) > 0) {
    stop(paste0(
      "Graduation data not available for: ", paste(invalid_years, collapse = ", "),
      ". Available years: ", paste(min(available_years), "-", max(available_years), sep = ""),
      ". Data source: ND Insights 4-Year Cohort Graduation Rate"
    ))
  }

  # Fetch each year
  results <- purrr::map(
    end_years,
    function(yr) {
      message(paste("Fetching", yr, "..."))
      fetch_graduation(yr, tidy = tidy, use_cache = use_cache)
    }
  )

  # Combine
  dplyr::bind_rows(results)
}


#' Get cache file path for graduation data
#'
#' @param end_year Academic year end
#' @param cache_type Cache type ("grad_tidy" or "grad_wide")
#' @return File path for cache file
#' @keywords internal
get_cache_file_path <- function(end_year, cache_type) {
  cache_dir <- get_cache_dir()
  academic_year <- paste0(end_year - 1L, "-", end_year)
  file.path(cache_dir, paste0(cache_type, "_", academic_year, ".rds"))
}
