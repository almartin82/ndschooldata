# Fetch district directory data

Downloads and processes district-level directory data from the North
Dakota Insights portal. This returns district-only information with
superintendent and business manager contacts.

## Usage

``` r
fetch_district_directory(end_year = NULL, use_cache = TRUE)
```

## Arguments

- end_year:

  A school year end (e.g., 2024 for 2023-24). If NULL, uses the most
  recent available year.

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

Data frame with district directory data

## Examples

``` r
if (FALSE) { # \dontrun{
# Get district directory
districts <- fetch_district_directory(2024)

# Find districts with missing superintendents
missing <- districts |>
  dplyr::filter(is.na(superintendent_name) | superintendent_name == "")
} # }
```
