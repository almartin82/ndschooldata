# ==============================================================================
# Enrollment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw NDDPI enrollment data into a
# clean, standardized format.
#
# North Dakota Data Notes:
#   - District IDs are in "CC-DDD" format (county code-district number)
#   - No campus/school-level data in the main enrollment file
#   - No demographic breakdowns in the main enrollment file
#   - The last row is a state total (district_id = "99-000")
#
# ==============================================================================

#' Process raw NDDPI enrollment data
#'
#' Transforms raw NDDPI data into a standardized schema.
#'
#' @param raw_data Data frame from get_raw_enr
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_enr <- function(raw_data, end_year) {

  # Remove the header row if present (first row may be column names)
  raw_data <- raw_data[!grepl("^CoDist$|^DistrictName$", raw_data$district_id, ignore.case = TRUE), ]

  # Identify state total row (district_id = "99-000" or district_name contains "Total")
  is_state_row <- raw_data$district_id == "99-000" |
                  grepl("^Total$", raw_data$district_name, ignore.case = TRUE)

  # Process district rows
  district_data <- raw_data[!is_state_row, ]
  district_processed <- process_district_enr(district_data, end_year)

  # Process state total row
  state_data <- raw_data[is_state_row, ]
  if (nrow(state_data) > 0) {
    state_processed <- process_state_enr(state_data, end_year)
  } else {
    # Create state aggregate from district data if not in source
    state_processed <- create_state_aggregate(district_processed, end_year)
  }

  # Combine state and district data
  result <- dplyr::bind_rows(state_processed, district_processed)

  result
}


#' Process district-level enrollment data
#'
#' @param df Raw district data frame
#' @param end_year School year end
#' @return Processed district data frame
#' @keywords internal
process_district_enr <- function(df, end_year) {

  n_rows <- nrow(df)

  result <- data.frame(
    end_year = rep(end_year, n_rows),
    type = rep("District", n_rows),
    district_id = trimws(df$district_id),
    campus_id = rep(NA_character_, n_rows),
    district_name = trimws(df$district_name),
    campus_name = rep(NA_character_, n_rows),
    stringsAsFactors = FALSE
  )

  # Extract county code from district_id (format: "CC-DDD")
  result$county_code <- substr(result$district_id, 1, 2)

  # Total enrollment
  result$row_total <- safe_numeric(df$total)

  # Grade-level enrollment
  result$grade_k <- safe_numeric(df$grade_k)
  result$grade_01 <- safe_numeric(df$grade_01)
  result$grade_02 <- safe_numeric(df$grade_02)
  result$grade_03 <- safe_numeric(df$grade_03)
  result$grade_04 <- safe_numeric(df$grade_04)
  result$grade_05 <- safe_numeric(df$grade_05)
  result$grade_06 <- safe_numeric(df$grade_06)
  result$grade_07 <- safe_numeric(df$grade_07)
  result$grade_08 <- safe_numeric(df$grade_08)
  result$grade_09 <- safe_numeric(df$grade_09)
  result$grade_10 <- safe_numeric(df$grade_10)
  result$grade_11 <- safe_numeric(df$grade_11)
  result$grade_12 <- safe_numeric(df$grade_12)

  # Demographics not available in main NDDPI file
  # Set to NA for schema consistency
  result$white <- NA_integer_
  result$black <- NA_integer_
  result$hispanic <- NA_integer_
  result$asian <- NA_integer_
  result$native_american <- NA_integer_
  result$pacific_islander <- NA_integer_
  result$multiracial <- NA_integer_
  result$male <- NA_integer_
  result$female <- NA_integer_
  result$econ_disadv <- NA_integer_
  result$lep <- NA_integer_
  result$special_ed <- NA_integer_

  result
}


#' Process state-level enrollment data
#'
#' @param df State total row from raw data
#' @param end_year School year end
#' @return Processed state row as data frame
#' @keywords internal
process_state_enr <- function(df, end_year) {

  result <- data.frame(
    end_year = end_year,
    type = "State",
    district_id = NA_character_,
    campus_id = NA_character_,
    district_name = NA_character_,
    campus_name = NA_character_,
    county_code = NA_character_,
    row_total = safe_numeric(df$total[1]),
    grade_k = safe_numeric(df$grade_k[1]),
    grade_01 = safe_numeric(df$grade_01[1]),
    grade_02 = safe_numeric(df$grade_02[1]),
    grade_03 = safe_numeric(df$grade_03[1]),
    grade_04 = safe_numeric(df$grade_04[1]),
    grade_05 = safe_numeric(df$grade_05[1]),
    grade_06 = safe_numeric(df$grade_06[1]),
    grade_07 = safe_numeric(df$grade_07[1]),
    grade_08 = safe_numeric(df$grade_08[1]),
    grade_09 = safe_numeric(df$grade_09[1]),
    grade_10 = safe_numeric(df$grade_10[1]),
    grade_11 = safe_numeric(df$grade_11[1]),
    grade_12 = safe_numeric(df$grade_12[1]),
    # Demographics NA
    white = NA_integer_,
    black = NA_integer_,
    hispanic = NA_integer_,
    asian = NA_integer_,
    native_american = NA_integer_,
    pacific_islander = NA_integer_,
    multiracial = NA_integer_,
    male = NA_integer_,
    female = NA_integer_,
    econ_disadv = NA_integer_,
    lep = NA_integer_,
    special_ed = NA_integer_,
    stringsAsFactors = FALSE
  )

  result
}


#' Create state-level aggregate from district data
#'
#' Used as fallback if state total row is not in source data.
#'
#' @param district_df Processed district data frame
#' @param end_year School year end
#' @return Single-row data frame with state totals
#' @keywords internal
create_state_aggregate <- function(district_df, end_year) {

  # Columns to sum
  sum_cols <- c(
    "row_total",
    "grade_k", "grade_01", "grade_02", "grade_03", "grade_04",
    "grade_05", "grade_06", "grade_07", "grade_08",
    "grade_09", "grade_10", "grade_11", "grade_12"
  )

  # Filter to columns that exist
  sum_cols <- sum_cols[sum_cols %in% names(district_df)]

  # Create state row
  state_row <- data.frame(
    end_year = end_year,
    type = "State",
    district_id = NA_character_,
    campus_id = NA_character_,
    district_name = NA_character_,
    campus_name = NA_character_,
    county_code = NA_character_,
    stringsAsFactors = FALSE
  )

  # Sum each column
  for (col in sum_cols) {
    state_row[[col]] <- sum(district_df[[col]], na.rm = TRUE)
  }

  # Demographics NA
  state_row$white <- NA_integer_
  state_row$black <- NA_integer_
  state_row$hispanic <- NA_integer_
  state_row$asian <- NA_integer_
  state_row$native_american <- NA_integer_
  state_row$pacific_islander <- NA_integer_
  state_row$multiracial <- NA_integer_
  state_row$male <- NA_integer_
  state_row$female <- NA_integer_
  state_row$econ_disadv <- NA_integer_
  state_row$lep <- NA_integer_
  state_row$special_ed <- NA_integer_

  state_row
}
