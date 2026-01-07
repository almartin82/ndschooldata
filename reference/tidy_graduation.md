# Tidy graduation rate data

Transforms processed graduation data into long format with standard
schema.

## Usage

``` r
tidy_graduation(processed_data, end_year)
```

## Arguments

- processed_data:

  Processed data from process_graduation()

- end_year:

  Academic year end (e.g., 2024 for 2023-24 school year)

## Value

Long-format tibble with standard graduation schema
