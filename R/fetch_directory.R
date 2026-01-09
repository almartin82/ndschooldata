# ==============================================================================
# School Directory Data Fetching Functions
# ==============================================================================
#
# This file contains functions for downloading and processing school directory
# data from the North Dakota Insights portal (insights.nd.gov).
#
# Data Sources:
#   - Schools: https://insights.nd.gov/ShowFile?f=10089_89_csv_{YYYY-YYYY}
#   - Districts: https://insights.nd.gov/ShowFile?f=10090_90_csv_{YYYY-YYYY}
#
# The school directory includes:
#   - School and district names and IDs
#   - Principal name and email
#   - Address and phone
#   - School level and grade span
#   - Geographic coordinates
#
# The district directory includes:
#   - District name and ID
#   - Superintendent name and email
#   - Business manager name and email
#   - Address and phone
#
# ==============================================================================


#' Get directory URL for schools
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @return URL string
#' @keywords internal
get_school_directory_url <- function(end_year) {
  academic_year <- paste0(end_year - 1, "-", end_year)
  paste0("https://insights.nd.gov/ShowFile?f=10089_89_csv_", academic_year)
}


#' Get directory URL for districts
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @return URL string
#' @keywords internal
get_district_directory_url <- function(end_year) {
  academic_year <- paste0(end_year - 1, "-", end_year)
  paste0("https://insights.nd.gov/ShowFile?f=10090_90_csv_", academic_year)
}


#' Get available years for directory data
#'
#' Returns the years available in the ND Insights directory data.
#' Currently 2014-2024 (based on verified URL availability).
#'
#' @return Integer vector of available end years
#' @export
#' @examples
#' get_directory_years()
get_directory_years <- function() {
  # Based on verified URL availability: 2013-2014 through 2023-2024
  2014L:2024L
}


#' Download raw school directory data
#'
#' Downloads the school directory CSV from ND Insights and parses it.
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @return Data frame with raw school directory data
#' @keywords internal
get_raw_school_directory <- function(end_year) {

  available_years <- get_directory_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "end_year must be between ", min(available_years), " and ", max(available_years),
      "\nAvailable years: ", paste(range(available_years), collapse = "-")
    ))
  }

  url <- get_school_directory_url(end_year)
  message(paste("Fetching ND school directory for", end_year, "..."))

  temp_file <- tempfile(fileext = ".csv")

  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(temp_file, overwrite = TRUE),
      httr::timeout(60),
      httr::user_agent("ndschooldata R package")
    )

    if (httr::http_error(response)) {
      stop(paste("HTTP error:", httr::status_code(response)))
    }

    # Check file size (empty responses are ~6 bytes)
    file_info <- file.info(temp_file)
    if (is.na(file_info$size) || file_info$size < 100) {
      stop(paste("No data available for year", end_year))
    }

    # Read the CSV, stripping the HTML meta tag from line 1 if present
    lines <- readLines(temp_file, warn = FALSE)
    if (length(lines) > 0 && grepl("^<meta", lines[1])) {
      # Remove only the meta tag, keep the CSV header that follows
      lines[1] <- sub("^<meta[^>]*>", "", lines[1])
    }

    # Parse CSV
    df <- utils::read.csv(
      text = paste(lines, collapse = "\n"),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )

    df$end_year <- end_year

    df

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    stop(paste(
      "Failed to download ND school directory.\n",
      "URL:", url, "\n",
      "Error:", e$message
    ))
  }, finally = {
    if (file.exists(temp_file)) unlink(temp_file)
  })
}


#' Download raw district directory data
#'
#' Downloads the district directory CSV from ND Insights and parses it.
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @return Data frame with raw district directory data
#' @keywords internal
get_raw_district_directory <- function(end_year) {

  available_years <- get_directory_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "end_year must be between ", min(available_years), " and ", max(available_years),
      "\nAvailable years: ", paste(range(available_years), collapse = "-")
    ))
  }

  url <- get_district_directory_url(end_year)
  message(paste("Fetching ND district directory for", end_year, "..."))

  temp_file <- tempfile(fileext = ".csv")

  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(temp_file, overwrite = TRUE),
      httr::timeout(60),
      httr::user_agent("ndschooldata R package")
    )

    if (httr::http_error(response)) {
      stop(paste("HTTP error:", httr::status_code(response)))
    }

    # Check file size (empty responses are ~6 bytes)
    file_info <- file.info(temp_file)
    if (is.na(file_info$size) || file_info$size < 100) {
      stop(paste("No data available for year", end_year))
    }

    # Read the CSV, stripping the HTML meta tag from line 1 if present
    lines <- readLines(temp_file, warn = FALSE)
    if (length(lines) > 0 && grepl("^<meta", lines[1])) {
      # Remove only the meta tag, keep the CSV header that follows
      lines[1] <- sub("^<meta[^>]*>", "", lines[1])
    }

    # Parse CSV
    df <- utils::read.csv(
      text = paste(lines, collapse = "\n"),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )

    df$end_year <- end_year

    df

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    stop(paste(
      "Failed to download ND district directory.\n",
      "URL:", url, "\n",
      "Error:", e$message
    ))
  }, finally = {
    if (file.exists(temp_file)) unlink(temp_file)
  })
}


#' Process school directory data
#'
#' Transforms raw school directory data to standardized schema.
#'
#' @param raw_data Data frame from get_raw_school_directory
#' @return Processed data frame with standardized columns
#' @keywords internal
process_school_directory <- function(raw_data) {

  # Standardize column names (handle typo in source: "PrinicpalName")
  result <- data.frame(
    end_year = raw_data$end_year,
    district_id = as.character(raw_data$DistrictInstitutionID),
    school_id = as.character(raw_data$InstitutionID),
    district_name = trimws(raw_data$DistrictName),
    school_name = trimws(raw_data$InstitutionName),
    school_level = trimws(raw_data$SchoolLevel),
    grade_span = trimws(raw_data$GradeSpan),
    # Handle the typo in the source data
    principal_name = if ("PrinicpalName" %in% names(raw_data)) {
      trimws(raw_data$PrinicpalName)
    } else if ("PrincipalName" %in% names(raw_data)) {
      trimws(raw_data$PrincipalName)
    } else {
      NA_character_
    },
    principal_email = trimws(raw_data$PrincipalEmail),
    address = trimws(raw_data$Street),
    city = trimws(raw_data$City),
    state = trimws(raw_data$State),
    zip = trimws(raw_data$ZipCode),
    phone = trimws(raw_data$Phone),
    website = trimws(raw_data$Website),
    latitude = safe_numeric(raw_data$Latitude),
    longitude = safe_numeric(raw_data$Longitude),
    stringsAsFactors = FALSE
  )

  # Pad district_id to 5 digits
  result$district_id <- sprintf("%05s", result$district_id)

  # Pad school_id to 10 digits
  result$school_id <- sprintf("%010s", result$school_id)

  result
}


#' Process district directory data
#'
#' Transforms raw district directory data to standardized schema.
#'
#' @param raw_data Data frame from get_raw_district_directory
#' @return Processed data frame with standardized columns
#' @keywords internal
process_district_directory <- function(raw_data) {

  # Handle typo in source: "SuperintendantName" (should be Superintendent)
  result <- data.frame(
    end_year = raw_data$end_year,
    district_id = as.character(raw_data$DistrictInstitutionID),
    district_name = trimws(raw_data$InstitutionName),
    county = trimws(raw_data$County),
    # Handle typo in source data
    superintendent_name = if ("SuperintendantName" %in% names(raw_data)) {
      trimws(raw_data$SuperintendantName)
    } else if ("SuperintendentName" %in% names(raw_data)) {
      trimws(raw_data$SuperintendentName)
    } else {
      NA_character_
    },
    superintendent_email = if ("SuperintendantEmail" %in% names(raw_data)) {
      trimws(raw_data$SuperintendantEmail)
    } else if ("SuperintendentEmail" %in% names(raw_data)) {
      trimws(raw_data$SuperintendentEmail)
    } else {
      NA_character_
    },
    business_manager_name = trimws(raw_data$BusinessManagerName),
    business_manager_email = trimws(raw_data$BusinessManagerEmail),
    address = trimws(raw_data$Street),
    city = trimws(raw_data$City),
    state = trimws(raw_data$State),
    zip = trimws(raw_data$ZipCode),
    phone = trimws(raw_data$Phone),
    website = trimws(raw_data$Website),
    stringsAsFactors = FALSE
  )

  # Pad district_id to 5 digits
  result$district_id <- sprintf("%05s", result$district_id)

  result
}


#' Combine school and district directory data
#'
#' Merges school-level data with district-level data to get a combined
#' directory with both principal and superintendent information.
#'
#' @param schools Processed school directory data
#' @param districts Processed district directory data
#' @return Combined data frame
#' @keywords internal
combine_directory <- function(schools, districts) {

  # Select district-level columns to merge
  district_cols <- districts[, c(
    "end_year", "district_id",
    "superintendent_name", "superintendent_email",
    "county"
  )]

  # Merge on district_id and end_year
  result <- merge(
    schools,
    district_cols,
    by = c("end_year", "district_id"),
    all.x = TRUE
  )

  # Reorder columns
  col_order <- c(
    "end_year",
    "district_id", "school_id",
    "district_name", "school_name",
    "school_level", "grade_span",
    "principal_name", "principal_email",
    "superintendent_name", "superintendent_email",
    "address", "city", "state", "zip",
    "phone", "website", "county",
    "latitude", "longitude"
  )
  col_order <- col_order[col_order %in% names(result)]
  result <- result[, col_order]

  result
}


#' Fetch North Dakota school directory data
#'
#' Downloads and processes school directory data from the North Dakota
#' Insights portal. Returns a combined dataset with school and district
#' information, including principal and superintendent contacts.
#'
#' @param end_year A school year end. Year is the end of the academic year - e.g.,
#'   2024 for the 2023-24 school year. Valid values are 2014-2024.
#'   If NULL (default), returns the most recent available year.
#' @param tidy If TRUE (default), returns combined school+district data.
#'   If FALSE, returns only school-level data without superintendent info.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#'   Set to FALSE to force re-download from ND Insights.
#' @return Data frame with directory data including:
#'   \itemize{
#'     \item district_id, school_id - Institution identifiers
#'     \item district_name, school_name - Institution names
#'     \item principal_name, superintendent_name - Administrator names
#'     \item address, city, state, zip, phone - Contact information
#'   }
#' @export
#' @examples
#' \dontrun{
#' # Get most recent directory data
#' dir_2024 <- fetch_directory()
#'
#' # Get specific year
#' dir_2020 <- fetch_directory(2020)
#'
#' # Get school-only data (no superintendent info)
#' schools <- fetch_directory(2024, tidy = FALSE)
#'
#' # Find schools in Fargo
#' fargo <- dir_2024 |>
#'   dplyr::filter(grepl("Fargo", district_name))
#' }
fetch_directory <- function(end_year = NULL, tidy = TRUE, use_cache = TRUE) {

  # Default to most recent year
  available_years <- get_directory_years()
  if (is.null(end_year)) {
    end_year <- max(available_years)
  }

  # Validate year
  if (!end_year %in% available_years) {
    stop(paste0(
      "end_year must be between ", min(available_years), " and ", max(available_years),
      "\nAvailable years: ", paste(range(available_years), collapse = "-")
    ))
  }

  # Determine cache type
  cache_type <- if (tidy) "directory_tidy" else "directory_schools"

  # Check cache first
  if (use_cache && cache_exists(end_year, cache_type)) {
    message(paste("Using cached directory data for", end_year))
    return(read_cache(end_year, cache_type))
  }

  # Get raw data
  raw_schools <- get_raw_school_directory(end_year)
  processed_schools <- process_school_directory(raw_schools)

  if (tidy) {
    # Also get district data for superintendent info
    raw_districts <- get_raw_district_directory(end_year)
    processed_districts <- process_district_directory(raw_districts)

    # Combine
    result <- combine_directory(processed_schools, processed_districts)
  } else {
    result <- processed_schools
  }

  # Cache the result
  if (use_cache) {
    write_cache(result, end_year, cache_type)
  }

  result
}


#' Fetch district directory data
#'
#' Downloads and processes district-level directory data from the North Dakota
#' Insights portal. This returns district-only information with superintendent
#' and business manager contacts.
#'
#' @param end_year A school year end (e.g., 2024 for 2023-24). If NULL, uses
#'   the most recent available year.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return Data frame with district directory data
#' @export
#' @examples
#' \dontrun{
#' # Get district directory
#' districts <- fetch_district_directory(2024)
#'
#' # Find districts with missing superintendents
#' missing <- districts |>
#'   dplyr::filter(is.na(superintendent_name) | superintendent_name == "")
#' }
fetch_district_directory <- function(end_year = NULL, use_cache = TRUE) {

  # Default to most recent year
  available_years <- get_directory_years()
  if (is.null(end_year)) {
    end_year <- max(available_years)
  }

  # Validate year
  if (!end_year %in% available_years) {
    stop(paste0(
      "end_year must be between ", min(available_years), " and ", max(available_years),
      "\nAvailable years: ", paste(range(available_years), collapse = "-")
    ))
  }

  cache_type <- "directory_districts"

  # Check cache first
  if (use_cache && cache_exists(end_year, cache_type)) {
    message(paste("Using cached district directory data for", end_year))
    return(read_cache(end_year, cache_type))
  }

  # Get raw data
  raw_districts <- get_raw_district_directory(end_year)
  result <- process_district_directory(raw_districts)

  # Cache the result
  if (use_cache) {
    write_cache(result, end_year, cache_type)
  }

  result
}
