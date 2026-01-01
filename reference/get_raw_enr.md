# Download raw enrollment data from NDDPI

Downloads the enrollment history Excel file from NDDPI and extracts the
sheet for the requested year. Uses a cached copy of the raw file to
avoid repeated downloads.

## Usage

``` r
get_raw_enr(end_year)
```

## Arguments

- end_year:

  School year end (e.g., 2024 for 2023-24 school year)

## Value

Data frame with raw enrollment data for the requested year
