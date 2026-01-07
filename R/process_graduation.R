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
#' Note: When tidy=FALSE, keeps original column names (EntityLevel, etc.)
#' When tidy=TRUE, converts to lowercase with underscores.
#'
#' @param raw_data Raw data from get_raw_graduation()
#' @param end_year Academic year end (e.g., 2024 for 2023-24 school year)
#' @return Data frame with standardized column names
#' @keywords internal
process_graduation <- function(raw_data, end_year) {

  # For tidy=FALSE compatibility, keep original column names
  # Just add end_year and ensure proper data types
  processed <- raw_data

  # Add end_year column by parsing AcademicYear
  # AcademicYear format: "2023-2024" -> end_year = 2024
  processed$end_year <- stringr::str_extract(processed$AcademicYear, "\\d{4}$") |> as.integer()

  # Ensure IDs are character (preserve leading zeros)
  processed$InstitutionID <- as.character(processed$InstitutionID)

  # Convert counts to integer (may be double from CSV parsing)
  processed$FourYearCohortGraduateCount <- as.integer(processed$FourYearCohortGraduateCount)
  processed$TotalFourYearCohort <- as.integer(processed$TotalFourYearCohort)

  # Standardize subgroup names (lowercase, replace spaces with underscores)
  # Map common subgroup names to standard format
  subgroup_map <- c(
    "all students" = "all",
    "all" = "all",
    "male" = "male",
    "female" = "female",
    "white" = "white",
    "black" = "black",
    "hispanic" = "hispanic",
    "asian american" = "asian_american",
    "native american" = "native_american",
    "native hawaiian or pacific islander" = "native_hawaiian_pacific_islander",
    "english learner" = "english_learner",
    "former english learner" = "former_english_learner",
    "iep (student with disabilities)" = "iep",
    "iep - emotional disturbance" = "iep_emotional_disturbance",
    "iep - english learner" = "iep_english_learner",
    "low income" = "low_income",
    "foster care" = "foster_care",
    "homeless" = "homeless",
    "migrant" = "migrant",
    "military" = "military"
  )

  # First, convert to lowercase
  processed$Subgroup <- tolower(processed$Subgroup)

  # Apply subgroup mapping where available
  for (i in seq_along(processed$Subgroup)) {
    key <- processed$Subgroup[i]
    if (key %in% names(subgroup_map)) {
      processed$Subgroup[i] <- subgroup_map[key]
    }
  }

  # For any remaining subgroups not in the map, replace special chars with underscores
  # But don't modify already-mapped subgroups
  needs_replacement <- !processed$Subgroup %in% subgroup_map
  processed$Subgroup[needs_replacement] <- gsub(" ", "_", processed$Subgroup[needs_replacement])
  processed$Subgroup[needs_replacement] <- gsub("-", "_", processed$Subgroup[needs_replacement])
  processed$Subgroup[needs_replacement] <- gsub("\\(", "_", processed$Subgroup[needs_replacement])
  processed$Subgroup[needs_replacement] <- gsub("\\)", "_", processed$Subgroup[needs_replacement])

  # Validate required columns exist
  required_cols <- c("AcademicYear", "EntityLevel", "InstitutionName",
                     "InstitutionID", "Subgroup", "FourYearGradRate",
                     "FourYearCohortGraduateCount", "TotalFourYearCohort",
                     "end_year")

  missing_cols <- setdiff(required_cols, names(processed))
  if (length(missing_cols) > 0) {
    stop("Missing required columns after processing: ",
         paste(missing_cols, collapse = ", "))
  }

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
