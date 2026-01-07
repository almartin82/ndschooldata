# Fetch North Dakota school directory data

Downloads and processes school directory data from the North Dakota
Insights portal. Returns a combined dataset with school and district
information, including principal and superintendent contacts.

## Usage

``` r
fetch_directory(end_year = NULL, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  A school year end. Year is the end of the academic year - e.g., 2024
  for the 2023-24 school year. Valid values are 2014-2024. If NULL
  (default), returns the most recent available year.

- tidy:

  If TRUE (default), returns combined school+district data. If FALSE,
  returns only school-level data without superintendent info.

- use_cache:

  If TRUE (default), uses locally cached data when available. Set to
  FALSE to force re-download from ND Insights.

## Value

Data frame with directory data including:

- district_id, school_id - Institution identifiers

- district_name, school_name - Institution names

- principal_name, superintendent_name - Administrator names

- address, city, state, zip, phone - Contact information

## Examples

``` r
if (FALSE) { # \dontrun{
# Get most recent directory data
dir_2024 <- fetch_directory()

# Get specific year
dir_2020 <- fetch_directory(2020)

# Get school-only data (no superintendent info)
schools <- fetch_directory(2024, tidy = FALSE)

# Find schools in Fargo
fargo <- dir_2024 |>
  dplyr::filter(grepl("Fargo", district_name))
} # }
```
