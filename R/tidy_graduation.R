# ==============================================================================
# Tidy Graduation Rate Data
# ==============================================================================
#
# This file contains functions for transforming processed graduation rate data
# into a long (tidy) format following the standard package schema.
#
# ==============================================================================

#' Tidy graduation rate data
#'
#' Transforms processed graduation data into long format with standard schema.
#'
#' @param processed_data Processed data from process_graduation()
#' @param end_year Academic year end (e.g., 2024 for 2023-24 school year)
#' @return Long-format tibble with standard graduation schema
#' @keywords internal
tidy_graduation <- function(processed_data, end_year) {

  # The data is already in long format by subgroup, so we just need to
  # standardize column names and add helper columns

  tidy <- processed_data |>
    dplyr::mutate(
      # Convert entity_level to type (State, District, School)
      type = entity_level,

      # Split institution_id into district_id and school_id
      district_id = dplyr::case_when(
        entity_level == "State" ~ "99999",
        entity_level == "District" ~ institution_id,
        entity_level == "School" ~ substr(institution_id, 1, 5),
        TRUE ~ NA_character_
      ),

      school_id = dplyr::case_when(
        entity_level == "State" ~ NA_character_,
        entity_level == "District" ~ NA_character_,
        entity_level == "School" ~ institution_id,
        TRUE ~ NA_character_
      ),

      # Names
      district_name = dplyr::case_when(
        entity_level == "State" ~ "State of North Dakota",
        entity_level == "District" ~ institution_name,
        entity_level == "School" ~ NA_character_,  # Will fill in via join below
        TRUE ~ NA_character_
      ),

      school_name = dplyr::case_when(
        entity_level == "State" ~ NA_character_,
        entity_level == "District" ~ NA_character_,
        entity_level == "School" ~ institution_name,
        TRUE ~ NA_character_
      ),

      # Cohort type (4-year)
      cohort_type = "4-year",

      # Add aggregation flags
      is_state = entity_level == "State",
      is_district = entity_level == "District",
      is_school = entity_level == "School"
    ) |>
    # Select standard columns
    dplyr::select(
      end_year,
      type,
      district_id,
      district_name,
      school_id,
      school_name,
      subgroup,
      cohort_type,
      cohort_count,
      graduate_count,
      grad_rate,
      is_state,
      is_district,
      is_school
    ) |>
    # Fill in district_name for school records by joining with district records
    dplyr::group_by(district_id) |>
    dplyr::mutate(
      district_name = dplyr::if_else(
        is.na(district_name) & is_school,
        dplyr::first(district_name[is_district]),
        district_name
      )
    ) |>
    dplyr::ungroup()

  tidy
}
