# Get cached raw file path

Returns path to cached raw Excel file, downloading if necessary. The raw
file is cached separately from processed data to avoid re-downloading
when processing multiple years.

## Usage

``` r
get_cached_raw_file(max_age = 7)
```

## Arguments

- max_age:

  Maximum age in days before re-downloading (default 7)

## Value

Path to the cached raw Excel file
