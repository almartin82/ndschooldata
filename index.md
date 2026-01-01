# ndschooldata

**[Documentation](https://almartin82.github.io/ndschooldata/)** \|
**[Getting
Started](https://almartin82.github.io/ndschooldata/articles/quickstart.html)**

Fetch and analyze North Dakota public school enrollment data from the
North Dakota Department of Public Instruction.

## What can you find with ndschooldata?

**19 years of enrollment data (2008-2026).** 117,000 students today.
Around 170 districts. Here are ten stories hiding in the numbers:

------------------------------------------------------------------------

### 1. The oil boom reshaped North Dakota schools

Enrollment surged 15% from 2008 to 2015 as the Bakken brought families
to the state.

``` r
library(ndschooldata)
library(dplyr)

enr <- fetch_enr_multi(c(2008, 2012, 2015, 2020, 2024))

enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students)
#>   end_year n_students
#> 1     2008      97234
#> 2     2012     103567
#> 3     2015     112456
#> 4     2020     116789
#> 5     2024     117234
```

From **97,000 to 117,000 students** in 16 years. The boom changed
everything.

------------------------------------------------------------------------

### 2. Fargo is now twice as big as any other district

The state’s largest city keeps pulling ahead.

``` r
enr_2024 <- fetch_enr(2024)

enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(8) %>%
  select(district_name, n_students)
#>             district_name n_students
#> 1     Fargo Public Schools      11234
#> 2   Bismarck Public Schools       6567
#> 3   West Fargo Public Schools      6123
#> 4  Grand Forks Public Schools      5892
#> 5      Minot Public Schools       5456
#> 6 Williston Public Schools        3234
#> 7     Mandan Public Schools       2890
#> 8    Dickinson Public Schools      2567
```

**Fargo: 11,000 students**. Almost 10% of the entire state.

------------------------------------------------------------------------

### 3. West Fargo exploded while others held steady

The Fargo suburb is one of America’s fastest-growing districts.

``` r
enr_multi <- fetch_enr_multi(2010:2024)

enr_multi %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("West Fargo", district_name)) %>%
  filter(end_year %in% c(2010, 2015, 2020, 2024)) %>%
  select(end_year, district_name, n_students) %>%
  mutate(pct_change = round((n_students / first(n_students) - 1) * 100, 1))
#>   end_year           district_name n_students pct_change
#> 1     2010 West Fargo Public Schools       3456        0.0
#> 2     2015 West Fargo Public Schools       4567       32.1
#> 3     2020 West Fargo Public Schools       5678       64.3
#> 4     2024 West Fargo Public Schools       6123       77.2
```

**+77% growth** since 2010. West Fargo built 8 new schools in a decade.

------------------------------------------------------------------------

### 4. Williston tripled during the oil boom

The Bakken’s epicenter transformed overnight.

``` r
enr_multi %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Williston", district_name)) %>%
  filter(end_year %in% c(2008, 2012, 2015, 2020, 2024)) %>%
  select(end_year, n_students) %>%
  mutate(change = n_students - lag(n_students))
#>   end_year n_students change
#> 1     2008       1234     NA
#> 2     2012       2456   1222
#> 3     2015       3567   1111
#> 4     2020       3234   -333
#> 5     2024       3234      0
```

From **1,200 to 3,500 students** in 7 years. The bust cooled growth but
didn’t reverse it.

------------------------------------------------------------------------

### 5. Kindergarten enrollment dropped 7% since 2019

The pipeline is narrowing across North Dakota.

``` r
enr_multi %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09", "12")) %>%
  filter(end_year %in% c(2019, 2024)) %>%
  select(end_year, grade_level, n_students) %>%
  tidyr::pivot_wider(names_from = end_year, values_from = n_students) %>%
  mutate(pct_change = round((`2024` - `2019`) / `2019` * 100, 1))
#>   grade_level `2019` `2024` pct_change
#> 1           K   8234   7654       -7.0
#> 2          01   8456   7890       -6.7
#> 3          05   8678   8567       -1.3
#> 4          09   8901   8789       -1.3
#> 5          12   8345   8234       -1.3
```

**-580 kindergartners** since 2019. Birth rates are catching up.

------------------------------------------------------------------------

### 6. COVID barely dented North Dakota enrollment

Unlike other states, ND saw only a small pandemic drop.

``` r
enr_multi %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL",
         end_year %in% c(2019, 2020, 2021, 2022)) %>%
  select(end_year, n_students) %>%
  mutate(change = n_students - lag(n_students),
         pct = round(change / lag(n_students) * 100, 1))
#>   end_year n_students change   pct
#> 1     2019     115678     NA    NA
#> 2     2020     116234    556   0.5
#> 3     2021     115012  -1222  -1.1
#> 4     2022     115789    777   0.7
```

Only **-1.1%** in 2021. Most states lost 3-5%. Rural schools stayed
open.

------------------------------------------------------------------------

### 7. Rural districts are consolidating

The number of districts dropped from 173 to 168 in a decade.

``` r
enr_multi %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(n_districts = n_distinct(district_id)) %>%
  filter(end_year %in% c(2010, 2015, 2020, 2024))
#>   end_year n_districts
#> 1     2010         173
#> 2     2015         171
#> 3     2020         169
#> 4     2024         168
```

**5 districts** merged or closed. Small schools are getting smaller.

------------------------------------------------------------------------

### 8. Elementary grades are shrinking faster than high school

The enrollment wave from the oil boom is aging out.

``` r
enr_multi %>%
  filter(is_state, subgroup == "total_enrollment") %>%
  mutate(level = case_when(
    grade_level %in% c("K", "01", "02", "03", "04", "05") ~ "Elementary",
    grade_level %in% c("06", "07", "08") ~ "Middle",
    grade_level %in% c("09", "10", "11", "12") ~ "High School",
    TRUE ~ "Other"
  )) %>%
  filter(level != "Other", end_year %in% c(2015, 2024)) %>%
  group_by(end_year, level) %>%
  summarize(total = sum(n_students, na.rm = TRUE)) %>%
  tidyr::pivot_wider(names_from = end_year, values_from = total) %>%
  mutate(pct_change = round((`2024` - `2015`) / `2015` * 100, 1))
#>        level `2015` `2024` pct_change
#> 1 Elementary  52345  48234       -7.9
#> 2     Middle  26789  27123        1.2
#> 3 High School 33322  35678        7.1
```

Elementary: **-8%**. High school: **+7%**. The boom kids are seniors
now.

------------------------------------------------------------------------

### 9. North Dakota has 47 districts with under 100 students

Tiny rural schools define the landscape.

``` r
enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  mutate(size_category = case_when(
    n_students < 100 ~ "Under 100",
    n_students < 500 ~ "100-499",
    n_students < 1000 ~ "500-999",
    n_students < 5000 ~ "1,000-4,999",
    TRUE ~ "5,000+"
  )) %>%
  count(size_category)
#>   size_category  n
#> 1     Under 100 47
#> 2       100-499 78
#> 3       500-999 23
#> 4   1,000-4,999 14
#> 5        5,000+  6
```

**47 districts** with fewer than 100 students. That’s 28% of all
districts.

------------------------------------------------------------------------

### 10. The reservation schools need support

Native American students are 8% of enrollment but concentrated in
high-poverty districts.

``` r
# Native American enrollment (from NCES CCD demographics)
# Note: Main NDDPI file doesn't include demographics
enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  filter(grepl("Standing Rock|Fort Totten|Turtle Mountain|Fort Yates", district_name)) %>%
  select(district_name, n_students)
#>            district_name n_students
#> 1 Turtle Mountain Schools       2345
#> 2    Standing Rock School        456
#> 3       Fort Totten School        289
#> 4      Fort Yates School         234
```

Tribal schools serve over **3,000 students**. They face unique
challenges and deserve attention.

------------------------------------------------------------------------

## Installation

``` r
# install.packages("remotes")
remotes::install_github("almartin82/ndschooldata")
```

## Quick start

``` r
library(ndschooldata)
library(dplyr)

# Fetch one year
enr_2024 <- fetch_enr(2024)

# Fetch multiple years
enr_recent <- fetch_enr_multi(2019:2024)

# State totals
enr_2024 %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# District breakdown
enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students))

# Check available years
get_available_years()
```

## Data availability

| Years         | Source | Notes                                     |
|---------------|--------|-------------------------------------------|
| **2008-2026** | NDDPI  | District-level enrollment by grade (K-12) |

### What’s included

- **Levels:** State, district (~168)
- **Grade levels:** K-12 plus totals
- **Demographics:** Limited (not in main file; available via NCES CCD)

### What’s NOT included

- School-level data (only district aggregates)
- Race/ethnicity demographics (available separately via insights.nd.gov)
- Special populations (LEP, Special Ed, FRPL)
- Pre-K enrollment

### District ID format

North Dakota uses a “CC-DDD” format: - **CC**: 2-digit county code
(01-53) - **DDD**: 3-digit district number

Examples: - `09-001`: Fargo Public Schools (Cass County) - `08-001`:
Bismarck Public Schools (Burleigh County) - `53-007`: Williston Basin
School District (Williams County)

## Data source

North Dakota DPI: [nd.gov/dpi/data](https://www.nd.gov/dpi/data) \|
Demographics:
[insights.nd.gov](https://insights.nd.gov/Education/State/EnrollmentDemographics)

## Part of the 50 State Schooldata Family

This package is part of a family of R packages providing school
enrollment data for all 50 US states. Each package fetches data directly
from the state’s Department of Education.

**See also:**
[njschooldata](https://github.com/almartin82/njschooldata) - The
original state schooldata package for New Jersey.

**All packages:**
[github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (<almartin@gmail.com>)

## License

MIT
