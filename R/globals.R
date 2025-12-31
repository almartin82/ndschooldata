# ==============================================================================
# Global Variable Declarations
# ==============================================================================
#
# This file declares global variables used in NSE (non-standard evaluation)
# contexts like dplyr to avoid R CMD check warnings about undefined globals.
#
# ==============================================================================

# To silence R CMD check NOTEs about "no visible binding for global variable"
# These are column names used in dplyr expressions
utils::globalVariables(c(
  "grade_level",
  "n_students",
  "row_total",
  "subgroup",
  "type"
))
