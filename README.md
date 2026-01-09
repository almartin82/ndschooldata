# ndschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/ndschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/ndschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/ndschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/ndschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/ndschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/ndschooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**[Documentation](https://almartin82.github.io/ndschooldata/)** | **[Getting Started](https://almartin82.github.io/ndschooldata/articles/quickstart.html)**

Fetch and analyze North Dakota school enrollment data from the North Dakota Department of Public Instruction in R or Python.

## What can you find with ndschooldata?

**18 years of enrollment data (2008-2025).** 117,000 students today. Around 170 districts. Here are ten stories hiding in the numbers:

---

### 1. The oil boom reshaped North Dakota schools

Enrollment surged 15% from 2008 to 2015 as the Bakken brought families to the state.

```r
library(ndschooldata)
library(dplyr)

enr <- fetch_enr_multi(c(2008, 2012, 2015, 2020, 2024))

enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students)
#>   end_year n_students
#> 1     2008      94052
#> 2     2012      95778
#> 3     2015     104278
#> 4     2020     112858
#> 5     2024     115767
```

From **94,000 to 116,000 students** in 16 years. The boom changed everything.

---

### 2. Bismarck is now the state's largest district

The capital city has overtaken Fargo as the state's largest district.

```r
enr_2024 <- fetch_enr(2024)

enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(8) %>%
  select(district_name, n_students)
#>      district_name n_students
#> 1        Bismarck 1      13732
#> 2      West Fargo 6      12676
#> 3           Fargo 1      11319
#> 4           Minot 1       7510
#> 5     Grand Forks 1       7428
#> 6 Williston Basin 7       5198
#> 7          Mandan 1       4368
#> 8       Dickinson 1       3977
```

**Bismarck: 13,700 students**. The capital city continues to lead the state.

---

### 3. West Fargo exploded while others held steady

The Fargo suburb is one of America's fastest-growing districts.

```r
enr_multi <- fetch_enr_multi(2010:2024)

enr_multi %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("West Fargo", district_name)) %>%
  filter(end_year %in% c(2010, 2015, 2020, 2024)) %>%
  select(end_year, district_name, n_students) %>%
  mutate(pct_change = round((n_students / first(n_students) - 1) * 100, 1))
#>   end_year district_name n_students pct_change
#> 1     2010  West Fargo 6       6848        0.0
#> 2     2015  West Fargo 6       8970       31.0
#> 3     2020  West Fargo 6      11272       64.6
#> 4     2024  West Fargo 6      12676       85.1
```

**+85% growth** since 2010. West Fargo built 8 new schools in a decade.

---

### 4. Williston doubled during the oil boom

The Bakken's epicenter transformed overnight.

```r
enr_multi %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Williston", district_name)) %>%
  filter(end_year %in% c(2008, 2012, 2015, 2020, 2024)) %>%
  select(end_year, n_students) %>%
  mutate(change = n_students - lag(n_students))
#>   end_year n_students change
#> 1     2012       2659     NA
#> 2     2015       3371    712
#> 3     2020       4403   1032
#> 4     2024       5198    795
```

From **2,600 to 5,200 students** in 12 years. The bust cooled growth but didn't reverse it.

---

### 5. Kindergarten enrollment dropped 7% since 2019

The pipeline is narrowing across North Dakota.

```r
enr_multi %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09", "12")) %>%
  filter(end_year %in% c(2019, 2024)) %>%
  select(end_year, grade_level, n_students) %>%
  tidyr::pivot_wider(names_from = end_year, values_from = n_students) %>%
  mutate(pct_change = round((`2024` - `2019`) / `2019` * 100, 1))
#>   grade_level `2019` `2024` pct_change
#> 1           K   9324   8636       -7.4
#> 2          01   9178   9291        1.2
#> 3          05   8850   9002        1.7
#> 4          09   8397   9164        9.1
#> 5          12   7548   8028        6.4
```

**-690 kindergartners** since 2019. Birth rates are catching up.

---

### 6. COVID barely dented North Dakota enrollment

Unlike other states, ND saw only a small pandemic drop.

```r
enr_multi %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL",
         end_year %in% c(2019, 2020, 2021, 2022)) %>%
  select(end_year, n_students) %>%
  mutate(change = n_students - lag(n_students),
         pct = round(change / lag(n_students) * 100, 1))
#>   end_year n_students change   pct
#> 1     2019     110842     NA    NA
#> 2     2020     112858   2016   1.8
#> 3     2021     112045   -813  -0.7
#> 4     2022     113858   1813   1.6
```

Only **-0.7%** in 2021. Most states lost 3-5%. Rural schools stayed open.

---

### 7. Rural districts are consolidating

The number of districts dropped from 182 to 167 in 14 years.

```r
enr_multi %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(n_districts = n_distinct(district_id)) %>%
  filter(end_year %in% c(2010, 2015, 2020, 2024))
#>   end_year n_districts
#> 1     2010         182
#> 2     2015         176
#> 3     2020         173
#> 4     2024         167
```

**15 districts** merged or closed since 2010. Small schools are getting smaller.

---

### 8. Elementary and high school grades are growing

The enrollment wave from the oil boom continues across all levels.

```r
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
#> 1 Elementary  50935  54642        7.3
#> 2     Middle  23108  26569       15.0
#> 3 High School  30235  34556       14.3
```

All levels growing: **Elementary +7%, Middle +15%, High School +14%**.

---

### 9. North Dakota has 35 districts with under 100 students

Tiny rural schools define the landscape.

```r
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
#> 1   1,000-4,999  8
#> 2       100-499 98
#> 3        5,000+  6
#> 4       500-999 20
#> 5     Under 100 35
```

**35 districts** with fewer than 100 students. That's 21% of all districts.

---

### 10. Native American graduation rates lag behind

Native American students are 11% of the cohort but face significant achievement gaps.

```r
grad_2024 <- fetch_graduation(2024)

# Native American vs overall graduation rate
grad_2024 %>%
  filter(is_state, subgroup %in% c("all", "native_american")) %>%
  select(subgroup, grad_rate, cohort_count, graduate_count)
#>        subgroup grad_rate cohort_count graduate_count
#> 1           all     0.824         8681           7154
#> 2 native_american     0.634          939            595
```

Native American students graduate at **63%** compared to **82%** overall. A 19-point gap that demands attention.

---

## Enrollment Visualizations

<img src="https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/statewide-chart-1.png" alt="North Dakota statewide enrollment trends" width="600">

<img src="https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/top-districts-chart-1.png" alt="Top North Dakota districts" width="600">

See the [full vignette](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks.html) for more insights.

## Installation

```r
# install.packages("remotes")
remotes::install_github("almartin82/ndschooldata")
```

## Quick start

### R

```r
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

# Fetch graduation rates
grad_2024 <- fetch_graduation(2024)

# State graduation rate
grad_2024 %>%
  filter(is_state, subgroup == "all") %>%
  select(grad_rate, cohort_count, graduate_count)

# District graduation rates
grad_2024 %>%
  filter(is_district, subgroup == "all") %>%
  arrange(desc(grad_rate)) %>%
  select(district_name, grad_rate, cohort_count)

# Graduation rate by subgroup (state level)
grad_2024 %>%
  filter(is_state, subgroup %in% c("all", "male", "female", "native_american", "white")) %>%
  select(subgroup, grad_rate, cohort_count)
```

### Python

```python
import pyndschooldata as nd

# Fetch one year
enr_2024 = nd.fetch_enr(2024)

# Fetch multiple years
enr_recent = nd.fetch_enr_multi([2019, 2020, 2021, 2022, 2023, 2024])

# State totals
state_totals = enr_2024[
    (enr_2024['is_state'] == True) &
    (enr_2024['subgroup'] == 'total_enrollment') &
    (enr_2024['grade_level'] == 'TOTAL')
]

# District breakdown
district_totals = enr_2024[
    (enr_2024['is_district'] == True) &
    (enr_2024['subgroup'] == 'total_enrollment') &
    (enr_2024['grade_level'] == 'TOTAL')
].sort_values('n_students', ascending=False)

# Check available years
years = nd.get_available_years()
print(f"Data available from {years['min_year']} to {years['max_year']}")
```

## Data availability

| Years | Source | Notes |
|-------|--------|-------|
| **2008-2025** | NDDPI | District-level enrollment by grade (K-12) |
| **2013-2024** | ND Insights | 4-year cohort graduation rates (state, district, school) |

### What's included

**Enrollment data:**
- **Levels:** State, district (~168)
- **Grade levels:** K-12 plus totals
- **Demographics:** Limited (not in main file; available via insights.nd.gov)

**Graduation rate data:**
- **Levels:** State, district (~168), school (~450)
- **Years:** 2013-2024 (12 years)
- **Cohort type:** 4-year adjusted cohort graduation rate (ACGR)
- **Subgroups:** All, male, female, white, Black, Hispanic, Asian American, Native American, English Learner, IEP, Low Income, and more

### What's NOT included

- Pre-K enrollment
- Assessment scores
- Attendance rates
- College enrollment data
- Traditional graduation rates (5-year, extended cohort)

### District ID format

North Dakota uses a "CC-DDD" format:
- **CC**: 2-digit county code (01-53)
- **DDD**: 3-digit district number

Examples:
- `09-001`: Fargo Public Schools (Cass County)
- `08-001`: Bismarck Public Schools (Burleigh County)
- `53-007`: Williston Basin School District (Williams County)

## Data source

North Dakota DPI: [nd.gov/dpi/data](https://www.nd.gov/dpi/data) | Demographics: [insights.nd.gov](https://insights.nd.gov/Education/State/EnrollmentDemographics)

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data in Python and R.

**All 50 state packages:** [github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (almartin@gmail.com)

## License

MIT
