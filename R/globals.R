# ==============================================================================
# Global Variable Declarations
# ==============================================================================
#
# This file declares global variables used in NSE (non-standard evaluation)
# contexts like dplyr to avoid R CMD check warnings about undefined globals.
#
# ==============================================================================

#' @importFrom dplyr n
NULL

# To silence R CMD check NOTEs about "no visible binding for global variable"
# These are column names used in dplyr expressions
utils::globalVariables(c(
  "grade_level",
  "n_students",
  "row_total",
  "subgroup",
  "type",
  # Graduation rate variables (processed)
  "academic_year",
  "entity_level",
  "institution_name",
  "institution_id",
  "grad_rate",
  "graduate_count",
  "cohort_count",
  "cohort_type",
  "district_id",
  "district_name",
  "school_id",
  "school_name",
  "is_state",
  "is_district",
  "is_school",
  # Graduation rate variables (raw CSV column names)
  "AcademicYear",
  "EntityLevel",
  "InstitutionName",
  "InstitutionID",
  "Subgroup",
  "FourYearGradRate",
  "FourYearCohortGraduateCount",
  "TotalFourYearCohort"
))

