# Standardize graduation rate value

Ensures graduation rate is on 0-1 scale (not percentage). ND Insights
data is already on 0-1 scale, so this is a validation function.

## Usage

``` r
standardize_grad_rate(rate)
```

## Arguments

- rate:

  Graduation rate value

## Value

Numeric value on 0-1 scale
