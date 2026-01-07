# Fetch North Dakota graduation rate data

Downloads and processes 4-year cohort graduation rate data from the
North Dakota Insights portal (insights.nd.gov).

## Usage

``` r
fetch_graduation(end_year, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  A school year end. Year is the end of the academic year - e.g., 2024
  for the 2023-24 school year. Valid values are 2013-2024.

- tidy:

  If TRUE (default), returns data in long (tidy) format with subgroup
  column. If FALSE, returns wide format (closer to source).

- use_cache:

  If TRUE (default), uses locally cached data when available. Set to
  FALSE to force re-download from ND Insights.

## Value

Data frame with graduation rate data. Wide format includes columns for
entity_level, institution_name, subgroup, grad_rate, cohort_count,
graduate_count. Tidy format adds type, district_id, school_id, and
aggregation flags.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 graduation rates (2023-24 school year)
grad_2024 <- fetch_graduation(2024)

# Get wide format
grad_wide <- fetch_graduation(2024, tidy = FALSE)

# Force fresh download (ignore cache)
grad_fresh <- fetch_graduation(2024, use_cache = FALSE)

# Filter to state level
state <- grad_2024 |>
  dplyr::filter(is_state, subgroup == "all")

# Filter to specific district
fargo <- grad_2024 |>
  dplyr::filter(district_name == "Fargo 1", subgroup == "all")
} # }
```
