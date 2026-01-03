# Fetch North Dakota enrollment data

Downloads and processes enrollment data from the North Dakota Department
of Public Instruction.

## Usage

``` r
fetch_enr(end_year, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  A school year end. Year is the end of the academic year - e.g., 2024
  for the 2023-24 school year. Valid values are 2008-2025.

- tidy:

  If TRUE (default), returns data in long (tidy) format with subgroup
  column. If FALSE, returns wide format.

- use_cache:

  If TRUE (default), uses locally cached data when available. Set to
  FALSE to force re-download from NDDPI.

## Value

Data frame with enrollment data. Wide format includes columns for
district_id, district_name, and enrollment counts by grade. Tidy format
pivots these counts into subgroup and grade_level columns.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 enrollment data (2023-24 school year)
enr_2024 <- fetch_enr(2024)

# Get wide format
enr_wide <- fetch_enr(2024, tidy = FALSE)

# Force fresh download (ignore cache)
enr_fresh <- fetch_enr(2024, use_cache = FALSE)

# Filter to specific district
fargo <- enr_2024 %>%
  dplyr::filter(district_id == "09-001")
} # }
```
