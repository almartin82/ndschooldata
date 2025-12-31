# ==============================================================================
# Utility Functions
# ==============================================================================

#' Pipe operator
#'
#' See \code{dplyr::\link[dplyr:reexports]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL


#' Convert to numeric, handling suppression markers
#'
#' NDDPI uses various markers for suppressed data.
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric <- function(x) {
  # Remove commas and whitespace
  x <- gsub(",", "", x)
  x <- trimws(x)

  # Handle common suppression markers
  x[x %in% c("*", ".", "-", "-1", "<5", "<10", "N/A", "NA", "", "Total")] <- NA_character_

  suppressWarnings(as.numeric(x))
}


#' Convert school year string to end year
#'
#' Converts formats like "2023-24" to 2024 (the end year).
#'
#' @param year_str Character string in "YYYY-YY" format
#' @return Integer end year
#' @keywords internal
parse_school_year <- function(year_str) {
  # Handle "2023-24" format
  if (grepl("^\\d{4}-\\d{2}$", year_str)) {
    start_year <- as.integer(substr(year_str, 1, 4))
    return(start_year + 1L)
  }

  # Handle "2023-2024" format
  if (grepl("^\\d{4}-\\d{4}$", year_str)) {
    return(as.integer(substr(year_str, 6, 9)))
  }

  # Handle single year
  if (grepl("^\\d{4}$", year_str)) {
    return(as.integer(year_str))
  }

  NA_integer_
}


#' Convert end year to sheet name format
#'
#' Converts end year (e.g., 2024) to sheet name format (e.g., "2023-24").
#'
#' @param end_year Integer end year
#' @return Character sheet name
#' @keywords internal
end_year_to_sheet <- function(end_year) {
  start_year <- end_year - 1L
  end_suffix <- sprintf("%02d", end_year %% 100)
  paste0(start_year, "-", end_suffix)
}


#' Get available years from NDDPI data
#'
#' Returns the years available in the NDDPI enrollment data.
#' Currently 2008-2026 (based on sheet names in the Excel file).
#'
#' @return Integer vector of available end years
#' @export
#' @examples
#' get_available_years()
get_available_years <- function() {
  # Based on the Excel file sheets: 2007-08 through 2025-26
  # These represent end years 2008 through 2026
  2008L:2026L
}
