# Get available years from NDDPI data

Returns the years available in the NDDPI enrollment data. Currently
2008-2025 (based on sheet names in the Excel file).

## Usage

``` r
get_available_years()
```

## Value

Integer vector of available end years

## Examples

``` r
get_available_years()
#>  [1] 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022
#> [16] 2023 2024 2025
```
