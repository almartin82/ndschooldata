# ndschooldata

An R package for fetching and processing school enrollment data from the North Dakota Department of Public Instruction (NDDPI).

## Installation

```r
# Install from GitHub
# install.packages("devtools")
devtools::install_github("almartin82/ndschooldata")
```

## Quick Start

```r
library(ndschooldata)

# Get 2024 enrollment data (2023-24 school year)
enr_2024 <- fetch_enr(2024)

# Get wide format (one row per district)
enr_wide <- fetch_enr(2024, tidy = FALSE)

# Get multiple years
enr_multi <- fetch_enr_multi(2020:2024)

# Check available years
get_available_years()
```

## Data Availability

### What's Available

| Item | Details |
|------|---------|
| **Years** | 2008 to 2026 (19 years) |
| **Aggregation Levels** | State, District |
| **Grade Levels** | K-12 (individual grades) |
| **Update Frequency** | Updated annually each fall |

### What's NOT Available

The main NDDPI enrollment file does **not** include:

- **Campus/School-level data**: Only district aggregates are in this file
- **Demographics by race/ethnicity**: Available via insights.nd.gov dashboard but not downloadable
- **Special populations**: LEP, Special Education, Economically Disadvantaged counts are not in the main file
- **Pre-K enrollment**: Main file is K-12 only

### Known Caveats

1. **District count varies by year**: The number of districts ranges from ~167-173 due to consolidations and reorganizations
2. **State totals row**: Each year includes a "Total" row (district_id = "99-000") with statewide aggregates
3. **No suppression**: Unlike some states, North Dakota does not suppress small cell sizes in this file

## Data Source

Data is downloaded from the [NDDPI Data Portal](https://www.nd.gov/dpi/data):

- **File**: EnrollmentHistoryPublicSchoolDistrict.xlsx
- **Format**: Multi-sheet Excel file (one sheet per school year)
- **Direct URL**: https://www.nd.gov/dpi/sites/www/files/documents/Data/EnrollmentHistoryPublicSchoolDistrict.xlsx

For demographic breakdowns by race/ethnicity, visit [Insights of North Dakota](https://insights.nd.gov/Education/State/EnrollmentDemographics).

## District ID Format

North Dakota uses a "CC-DDD" format for district IDs:

- **CC**: 2-digit county code (01-53)
- **DDD**: 3-digit district number within county

Examples:
- `09-001`: Fargo Public Schools (Cass County)
- `53-007`: Williston Basin School District (Williams County)
- `08-001`: Bismarck Public Schools (Burleigh County)

## Output Schema

### Wide Format (`tidy = FALSE`)

| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end (2024 = 2023-24) |
| type | character | "State" or "District" |
| district_id | character | District ID in CC-DDD format |
| district_name | character | District name |
| county_code | character | 2-digit county code |
| row_total | integer | Total K-12 enrollment |
| grade_k | integer | Kindergarten enrollment |
| grade_01 - grade_12 | integer | Grade-level enrollment |

### Tidy Format (`tidy = TRUE`)

| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end |
| type | character | Aggregation level |
| district_id | character | District ID |
| district_name | character | District name |
| grade_level | character | "TOTAL", "K", "01"-"12" |
| subgroup | character | "total_enrollment" |
| n_students | integer | Student count |
| pct | numeric | Percentage of total |
| is_state | logical | Is state aggregate |
| is_district | logical | Is district record |

## Examples

### Enrollment Trends

```r
library(ndschooldata)
library(dplyr)
library(ggplot2)

# Get 10 years of data
enr <- fetch_enr_multi(2015:2024)

# State enrollment trend
state_trend <- enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students)

ggplot(state_trend, aes(x = end_year, y = n_students)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "North Dakota K-12 Enrollment",
    x = "School Year End",
    y = "Total Students"
  )
```

### Largest Districts

```r
# Find largest districts in 2024
largest <- fetch_enr(2024, tidy = FALSE) %>%
  filter(type == "District") %>%
  arrange(desc(row_total)) %>%
  head(10) %>%
  select(district_name, row_total)
```

### Grade Distribution

```r
# Grade-level enrollment for state
grade_dist <- fetch_enr(2024) %>%
  filter(is_state, subgroup == "total_enrollment", grade_level != "TOTAL") %>%
  mutate(grade_level = factor(grade_level, levels = c("K", sprintf("%02d", 1:12))))

ggplot(grade_dist, aes(x = grade_level, y = n_students)) +
  geom_col() +
  labs(title = "North Dakota Enrollment by Grade (2023-24)")
```

## Caching

Downloaded data is cached locally to avoid repeated downloads:

```r
# Check cache status
cache_status()

# Clear cache for specific year
clear_cache(2024)

# Clear all cached data
clear_cache()

# Force fresh download (ignore cache)
fetch_enr(2024, use_cache = FALSE)
```

## Related Packages

- [txschooldata](https://github.com/almartin82/txschooldata): Texas school data
- [caschooldata](https://github.com/almartin82/caschooldata): California school data
- [ilschooldata](https://github.com/almartin82/ilschooldata): Illinois school data
- [nyschooldata](https://github.com/almartin82/nyschooldata): New York school data
- [ohschooldata](https://github.com/almartin82/ohschooldata): Ohio school data
- [paschooldata](https://github.com/almartin82/paschooldata): Pennsylvania school data

## License
MIT
