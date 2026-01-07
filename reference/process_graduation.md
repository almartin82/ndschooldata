# Process raw graduation rate data

Standardizes column names and types from the raw ND Insights CSV data.
Note: When tidy=FALSE, keeps original column names (EntityLevel, etc.)
When tidy=TRUE, converts to lowercase with underscores.

## Usage

``` r
process_graduation(raw_data, end_year)
```

## Arguments

- raw_data:

  Raw data from get_raw_graduation()

- end_year:

  Academic year end (e.g., 2024 for 2023-24 school year)

## Value

Data frame with standardized column names
