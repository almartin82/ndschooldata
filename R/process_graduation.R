# ==============================================================================
# Process Graduation Rate Data
# ==============================================================================
#
# This file contains functions for processing raw graduation rate data from
# ND Insights into a standardized schema.
#
# ==============================================================================

#' Process raw graduation rate data
#'
#' Standardizes column names and types from the raw ND Insights CSV data.
#'
#' @param raw_data Raw data from get_raw_graduation()
#' @param end_year Academic year end (e.g., 2024 for 2023-24 school year)
#' @return Data frame with standardized column names
#' @keywords internal
process_graduation <- function(raw_data, end_year) {

  # Standardize column names
  processed <- raw_data |>
    dplyr::rename(
      academic_year = AcademicYear,
      entity_level = EntityLevel,
      institution_name = InstitutionName,
      institution_id = InstitutionID,
      subgroup = Subgroup,
      grad_rate = FourYearGradRate,
      graduate_count = FourYearCohortGraduateCount,
      cohort_count = TotalFourYearCohort
    )

  # Standardize subgroup names (lowercase, replace spaces with underscores)
  processed$subgroup <- tolower(processed$subgroup)
  processed$subgroup <- gsub(" ", "_", processed$subgroup)
  processed$subgroup <- gsub("-", "_", processed$subgroup)

  # Standardize entity level to Title Case
  processed$entity_level <- tools::toTitleCase(tolower(processed$entity_level))

  # Convert counts to integer (may be double from CSV parsing)
  processed$graduate_count <- as.integer(processed$graduate_count)
  processed$cohort_count <- as.integer(processed$cohort_count)

  # Ensure IDs are character (preserve leading zeros)
  processed$institution_id <- as.character(processed$institution_id)

  # Validate required columns exist
  required_cols <- c("academic_year", "entity_level", "institution_name",
                     "institution_id", "subgroup", "grad_rate",
                     "graduate_count", "cohort_count", "end_year")

  missing_cols <- setdiff(required_cols, names(processed))
  if (length(missing_cols) > 0) {
    stop("Missing required columns after processing: ",
         paste(missing_cols, collapse = ", "))
  }

  # Handle suppressed values (NA in source)
  # ND Insights uses NA for suppressed data (cohort < 10)

  processed
}


#' Standardize graduation rate value
#'
#' Ensures graduation rate is on 0-1 scale (not percentage).
#' ND Insights data is already on 0-1 scale, so this is a validation function.
#'
#' @param rate Graduation rate value
#' @return Numeric value on 0-1 scale
#' @keywords internal
standardize_grad_rate <- function(rate) {
  # ND Insights provides rates on 0-1 scale (0.824 = 82.4%)
  # Validate this assumption
  if (any(rate > 1.5, na.rm = TRUE)) {
    warning("Some graduation rates > 1.5 detected. ",
            "Data may be in percentage format (0-100) instead of decimal (0-1).")
  }
  rate
}
