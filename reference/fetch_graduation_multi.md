# Fetch graduation rate data for multiple years

Downloads and combines graduation rate data for multiple school years.

## Usage

``` r
fetch_graduation_multi(end_years, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_years:

  Vector of school year ends (e.g., c(2020, 2021, 2024))

- tidy:

  If TRUE (default), returns data in long (tidy) format.

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

Combined data frame with graduation rate data for all requested years

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 5 years of data
grad_multi <- fetch_graduation_multi(2020:2024)

# Track state graduation rate trends
grad_multi |>
  dplyr::filter(is_state, subgroup == "all") |>
  dplyr::select(end_year, grad_rate, cohort_count, graduate_count)

# Compare districts
grad_multi |>
  dplyr::filter(district_name %in% c("Fargo 1", "Bismarck 1"),
                subgroup == "all") |>
  dplyr::select(end_year, district_name, grad_rate)
} # }
```
