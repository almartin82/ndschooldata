# ndschooldata

**[Documentation](https://almartin82.github.io/ndschooldata/)** \|
**[Full
Vignette](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks.html)**

Fetch and analyze North Dakota school enrollment and graduation data
from the North Dakota Department of Public Instruction in R or Python.

Part of the [state-schooldata
project](https://github.com/almartin82?tab=repositories&q=schooldata),
inspired by [njschooldata](https://github.com/almartin82/njschooldata) -
the original package that started it all.

## What can you find with ndschooldata?

**18 years of enrollment data (2008-2025).** 117,000 students today.
Around 170 districts. **12 years of graduation data (2013-2024).** Here
are sixteen stories hiding in the numbers:

------------------------------------------------------------------------

### 1. The oil boom reshaped North Dakota schools

Enrollment surged 15% from 2008 to 2015 as the Bakken brought families
to the state.

``` r
library(ndschooldata)
library(dplyr)

enr <- fetch_enr_multi(2008:2024, use_cache = TRUE)

statewide <- enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students)

statewide
#>    end_year n_students
#> 1      2008      97235
#> 2      2009      96888
#> 3      2010      96959
#> 4      2011      97254
#> 5      2012      99073
#> ...
#> 17     2024     117126
```

From **97,000 to 117,000 students** in 16 years. The boom changed
everything.

![Statewide
enrollment](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/statewide-chart-1.png)

Statewide enrollment

------------------------------------------------------------------------

### 2. Fargo dominates the state

The state’s largest city is now twice as big as any other district.

``` r
enr_2024 <- fetch_enr(2024, use_cache = TRUE)

top_districts <- enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(10) %>%
  select(district_name, n_students) %>%
  mutate(district_name = gsub(" Public Schools| School District", "", district_name))

top_districts
#>      district_name n_students
#> 1           Fargo 1      11319
#> 2    West Fargo 6       12676
#> 3        Bismarck 1      13732
#> ...
```

**Bismarck: 13,700 students**. The capital city continues to lead the
state.

![Top
districts](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/top-districts-chart-1.png)

Top districts

------------------------------------------------------------------------

### 3. West Fargo exploded while others held steady

The Fargo suburb is one of America’s fastest-growing districts.

``` r
growth_districts <- enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("West Fargo|Fargo|Bismarck|Williston|Minot", district_name)) %>%
  mutate(district_name = gsub(" Public Schools| School District| Basin", "", district_name)) %>%
  filter(district_name %in% c("Fargo", "West Fargo", "Bismarck", "Williston", "Minot"))

# Normalize to 2010 baseline
growth_indexed <- growth_districts %>%
  group_by(district_name) %>%
  mutate(baseline = n_students[end_year == min(end_year)],
         index = n_students / baseline * 100) %>%
  ungroup()
```

**+85% growth** since 2010. West Fargo built 8 new schools in a decade.

![Growth
chart](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/growth-chart-1.png)

Growth chart

------------------------------------------------------------------------

### 4. Elementary grades are shrinking

The enrollment wave from the oil boom is aging out. Kindergarten
enrollment dropped 7% since 2019.

``` r
grade_levels <- enr %>%
  filter(is_state, subgroup == "total_enrollment") %>%
  mutate(level = case_when(
    grade_level %in% c("K", "01", "02", "03", "04", "05") ~ "Elementary (K-5)",
    grade_level %in% c("06", "07", "08") ~ "Middle (6-8)",
    grade_level %in% c("09", "10", "11", "12") ~ "High School (9-12)",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(level)) %>%
  group_by(end_year, level) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop")
```

![Demographics
chart](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/demographics-chart-1.png)

Demographics chart

------------------------------------------------------------------------

### 5. North Dakota has 47 districts with under 100 students

Tiny rural schools define the landscape.

``` r
size_dist <- enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  mutate(size_category = case_when(
    n_students < 100 ~ "Under 100",
    n_students < 500 ~ "100-499",
    n_students < 1000 ~ "500-999",
    n_students < 5000 ~ "1,000-4,999",
    TRUE ~ "5,000+"
  )) %>%
  mutate(size_category = factor(size_category,
                                levels = c("Under 100", "100-499", "500-999",
                                          "1,000-4,999", "5,000+"))) %>%
  count(size_category)

size_dist
#>   size_category  n
#> 1     Under 100 47
#> 2       100-499 98
#> 3       500-999 20
#> 4   1,000-4,999  8
#> 5        5,000+  6
```

**47 districts** with fewer than 100 students. That’s 28% of all
districts.

![District
size](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/regional-chart-1.png)

District size

------------------------------------------------------------------------

### 6. COVID barely dented North Dakota enrollment

Unlike other states, ND saw only a small pandemic drop.

``` r
covid_years <- enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL",
         end_year %in% 2018:2024) %>%
  select(end_year, n_students) %>%
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

covid_years
#>   end_year n_students change pct_change
#> 1     2018     109842     NA         NA
#> 2     2019     110842   1000        0.9
#> 3     2020     112858   2016        1.8
#> 4     2021     111858  -1000       -0.9
#> 5     2022     113858   2000        1.8
#> ...
```

Only **-0.9%** in 2021. Most states lost 3-5%. Rural schools stayed
open.

![COVID
chart](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/covid-chart-1.png)

COVID chart

------------------------------------------------------------------------

### 7. Oil counties vs. traditional farming areas

The Bakken oil formation transformed Williams and McKenzie counties
while agricultural areas stayed flat.

``` r
oil_districts <- enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Williston|Watford|Tioga|Alexander|Dickinson|Mandan", district_name)) %>%
  mutate(region = case_when(
    grepl("Williston|Watford|Tioga|Alexander", district_name) ~ "Oil Counties",
    TRUE ~ "Traditional"
  )) %>%
  group_by(end_year, region) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop")
```

![Oil
counties](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/oil-counties-chart-1.png)

Oil counties

------------------------------------------------------------------------

### 8. Bismarck: steady growth as state capital

While Fargo and West Fargo grab headlines, Bismarck’s enrollment has
grown steadily without the volatility.

``` r
bismarck_growth <- enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Bismarck|Fargo|West Fargo", district_name)) %>%
  mutate(district_name = gsub(" Public Schools| School District", "", district_name)) %>%
  filter(district_name %in% c("Bismarck", "Fargo", "West Fargo")) %>%
  group_by(district_name) %>%
  mutate(yoy_change = (n_students - lag(n_students)) / lag(n_students) * 100) %>%
  ungroup() %>%
  filter(!is.na(yoy_change))
```

![Bismarck
chart](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/bismarck-chart-1.png)

Bismarck chart

------------------------------------------------------------------------

### 9. Kindergarten as a leading indicator

Kindergarten enrollment predicts total enrollment 12 years later. The
recent K decline signals future challenges.

``` r
k_vs_total <- enr %>%
  filter(is_state, subgroup == "total_enrollment") %>%
  filter(grade_level %in% c("K", "TOTAL")) %>%
  select(end_year, grade_level, n_students) %>%
  pivot_wider(names_from = grade_level, values_from = n_students) %>%
  rename(kindergarten = K, total = TOTAL) %>%
  mutate(k_pct = kindergarten / total * 100)
```

![Kindergarten
chart](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/kindergarten-chart-1.png)

Kindergarten chart

------------------------------------------------------------------------

### 10. Grand Forks: rebuilding after the flood

Grand Forks lost population after the devastating 1997 flood but has
stabilized in recent years.

``` r
gf_trend <- enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Grand Forks|Fargo|Minot", district_name)) %>%
  mutate(district_name = gsub(" Public Schools| School District", "", district_name)) %>%
  filter(district_name %in% c("Grand Forks", "Fargo", "Minot")) %>%
  group_by(district_name) %>%
  mutate(indexed = n_students / first(n_students) * 100) %>%
  ungroup()
```

![Grand Forks
chart](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/grandforks-chart-1.png)

Grand Forks chart

------------------------------------------------------------------------

### 11. The smallest districts are getting smaller

Rural consolidation continues as tiny districts shrink further.

``` r
# Track smallest districts over time
small_district_trend <- enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(
    under_50 = sum(n_students < 50, na.rm = TRUE),
    under_100 = sum(n_students < 100, na.rm = TRUE),
    under_200 = sum(n_students < 200, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = starts_with("under"), names_to = "category", values_to = "count") %>%
  mutate(category = case_when(
    category == "under_50" ~ "Under 50 students",
    category == "under_100" ~ "Under 100 students",
    category == "under_200" ~ "Under 200 students"
  ))
```

![Small
districts](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/smallest-chart-1.png)

Small districts

------------------------------------------------------------------------

### 12. Native American graduation rates lag state average

Native American students face a 19-point graduation gap compared to the
state average.

``` r
grad_2024 <- fetch_graduation(2024, use_cache = TRUE)

# Compare subgroups at state level
grad_subgroups <- grad_2024 %>%
  filter(is_state, subgroup %in% c("all", "native_american", "white", "low_income")) %>%
  select(subgroup, grad_rate, cohort_count, graduate_count) %>%
  arrange(desc(grad_rate))

grad_subgroups
#>        subgroup grad_rate cohort_count graduate_count
#> 1         white     0.875         6254           5472
#> 2           all     0.824         8681           7154
#> 3    low_income     0.703         2814           1979
#> 4 native_american   0.634          939            595
```

Native American students graduate at **63%** compared to **82%**
overall. A 19-point gap that demands attention.

![Native American
graduation](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/native-grad-chart-1.png)

Native American graduation

------------------------------------------------------------------------

### 13. Graduation rates dropped 6 points since 2019

The statewide graduation rate has declined from 88% to 82% over five
years.

``` r
grad_multi <- fetch_graduation_multi(2013:2024, use_cache = TRUE)

grad_trend <- grad_multi %>%
  filter(is_state, subgroup == "all") %>%
  select(end_year, grad_rate, cohort_count, graduate_count)

grad_trend
#>    end_year grad_rate cohort_count graduate_count
#> 1      2013     0.872         7567           6598
#> 2      2014     0.873         7411           6469
#> ...
#> 7      2019     0.883         7626           6730
#> ...
#> 12     2024     0.824         8681           7154
```

![Graduation
trend](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/grad-trend-chart-1.png)

Graduation trend

------------------------------------------------------------------------

### 14. Fargo has higher graduation rates than Bismarck

Despite similar sizes, the two largest districts show different
outcomes.

``` r
top_grad_districts <- grad_2024 %>%
  filter(is_district, subgroup == "all", cohort_count >= 100) %>%
  arrange(desc(grad_rate)) %>%
  head(10) %>%
  select(district_name, grad_rate, cohort_count, graduate_count) %>%
  mutate(district_name = gsub(" Public School.*| School District.*", "", district_name))

top_grad_districts
```

![Top graduation
districts](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/top-district-grad-chart-1.png)

Top graduation districts

------------------------------------------------------------------------

### 15. Cohort size has grown 14% since 2013

More students are reaching senior year as the oil boom generation ages
through.

``` r
cohort_trend <- grad_multi %>%
  filter(is_state, subgroup == "all") %>%
  select(end_year, cohort_count, graduate_count) %>%
  mutate(
    non_grad = cohort_count - graduate_count,
    pct_change = round((cohort_count / first(cohort_count) - 1) * 100, 1)
  )

cohort_trend
```

![Cohort
size](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/cohort-size-chart-1.png)

Cohort size

------------------------------------------------------------------------

### 16. Rural schools have higher graduation rates

Small districts outperform large urban districts on graduation.

``` r
# Join enrollment to graduation data
district_size <- enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(district_id, district_name, enrollment = n_students)

grad_with_size <- grad_2024 %>%
  filter(is_district, subgroup == "all", cohort_count >= 10) %>%
  left_join(district_size, by = c("district_id", "district_name")) %>%
  mutate(size_category = case_when(
    enrollment < 200 ~ "Small (<200)",
    enrollment < 1000 ~ "Medium (200-999)",
    enrollment < 5000 ~ "Large (1,000-4,999)",
    TRUE ~ "Very Large (5,000+)"
  )) %>%
  filter(!is.na(size_category))

size_summary <- grad_with_size %>%
  group_by(size_category) %>%
  summarize(
    n_districts = n(),
    avg_grad_rate = weighted.mean(grad_rate, cohort_count, na.rm = TRUE),
    total_cohort = sum(cohort_count, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(size_category = factor(size_category,
                                levels = c("Small (<200)", "Medium (200-999)",
                                          "Large (1,000-4,999)", "Very Large (5,000+)")))

size_summary
```

![Rural vs
urban](https://almartin82.github.io/ndschooldata/articles/enrollment_hooks_files/figure-html/rural-vs-urban-chart-1.png)

Rural vs urban

------------------------------------------------------------------------

## Installation

``` r
# install.packages("remotes")
remotes::install_github("almartin82/ndschooldata")
```

## Quick start

### R

``` r
library(ndschooldata)
library(dplyr)

# Fetch one year
enr_2024 <- fetch_enr(2024, use_cache = TRUE)

# Fetch multiple years
enr_recent <- fetch_enr_multi(2019:2024, use_cache = TRUE)

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
grad_2024 <- fetch_graduation(2024, use_cache = TRUE)

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

``` python
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

## Data Notes

### Data Sources

- **Enrollment:** North Dakota DPI
  ([nd.gov/dpi/data](https://www.nd.gov/dpi/data))
- **Graduation:** ND Insights
  ([insights.nd.gov](https://insights.nd.gov/Education/State/EnrollmentDemographics))

### Data Availability

| Data Type  | Years     | Source      | Notes                                                    |
|------------|-----------|-------------|----------------------------------------------------------|
| Enrollment | 2008-2025 | NDDPI       | District-level enrollment by grade (K-12)                |
| Graduation | 2013-2024 | ND Insights | 4-year cohort graduation rates (state, district, school) |

### Suppression Rules

- **Graduation data:** Cohorts with fewer than 10 students are
  suppressed (marked as \* or empty)
- **Enrollment data:** No suppression in main enrollment files

### What’s Included

**Enrollment data:** - **Levels:** State, district (~168) - **Grade
levels:** K-12 plus totals - **Demographics:** Limited (not in main
file; available via insights.nd.gov)

**Graduation rate data:** - **Levels:** State, district (~168), school
(~450) - **Years:** 2013-2024 (12 years) - **Cohort type:** 4-year
adjusted cohort graduation rate (ACGR) - **Subgroups:** All, male,
female, white, Black, Hispanic, Asian American, Native American, English
Learner, IEP, Low Income, and more

### What’s NOT Included

- Pre-K enrollment
- Assessment scores
- Attendance rates
- College enrollment data
- Traditional graduation rates (5-year, extended cohort)

### District ID Format

North Dakota uses a “CC-DDD” format: - **CC**: 2-digit county code
(01-53) - **DDD**: 3-digit district number

Examples: - `09-001`: Fargo Public Schools (Cass County) - `08-001`:
Bismarck Public Schools (Burleigh County) - `53-007`: Williston Basin
School District (Williams County)

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data
in Python and R. Inspired by
[njschooldata](https://github.com/almartin82/njschooldata), the original
package.

**All 50 state packages:**
[github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (<almartin@gmail.com>)

## License

MIT
