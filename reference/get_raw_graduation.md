# Download raw graduation rate data from ND Insights

Downloads the 4-year cohort graduation rate CSV from ND Insights portal.
The CSV file has an HTML meta tag on the first line that must be
stripped before parsing.

## Usage

``` r
get_raw_graduation(end_year, cache_dir = NULL)
```

## Arguments

- end_year:

  Academic year end (e.g., 2024 for 2023-24 school year)

- cache_dir:

  Directory to cache downloaded files (uses package cache if NULL)

## Value

Data frame with raw graduation data as provided by ND Insights

## Examples

``` r
if (FALSE) { # \dontrun{
# Get raw 2024 graduation data
raw <- get_raw_graduation(2024)

# View raw structure
names(raw)
head(raw)
} # }
```
