# North Dakota School Data Expansion Research

**Last Updated:** 2026-01-04
**Theme Researched:** Graduation

## Executive Summary

Graduation rate data for North Dakota is available via direct CSV downloads from the ND Insights portal (insights.nd.gov). Three datasets are available:
1. Four-Year Cohort Graduation Rate (primary ACGR metric)
2. Traditional Graduation Rate
3. Dropout Rate

All files are accessible via direct HTTP GET requests with no authentication required.

---

## Data Sources Found

### Source 1: Graduation Rate - Four Year Cohort (PRIMARY)

- **URL Pattern:** `https://insights.nd.gov/ShowFile?f=10039_39_csv_{YYYY-YYYY}`
- **HTTP Status:** 200 (all years verified)
- **Format:** CSV with text/csv content type
- **Years Available:** 2012-2013 through 2024-2025 (13 years)
- **Access Method:** Direct HTTP GET, no auth required
- **Update Frequency:** Annual (after school year ends)

**File IDs Verified:**
| Academic Year | CSV URL | HTTP Status |
|--------------|---------|-------------|
| 2012-2013 | `ShowFile?f=10039_39_csv_2012-2013` | 200 |
| 2013-2014 | `ShowFile?f=10039_39_csv_2013-2014` | 200 |
| 2014-2015 | `ShowFile?f=10039_39_csv_2014-2015` | 200 |
| 2015-2016 | `ShowFile?f=10039_39_csv_2015-2016` | 200 |
| 2016-2017 | `ShowFile?f=10039_39_csv_2016-2017` | 200 |
| 2017-2018 | `ShowFile?f=10039_39_csv_2017-2018` | 200 |
| 2018-2019 | `ShowFile?f=10039_39_csv_2018-2019` | 200 |
| 2019-2020 | `ShowFile?f=10039_39_csv_2019-2020` | 200 |
| 2020-2021 | `ShowFile?f=10039_39_csv_2020-2021` | 200 |
| 2021-2022 | `ShowFile?f=10039_39_csv_2021-2022` | 200 |
| 2022-2023 | `ShowFile?f=10039_39_csv_2022-2023` | 200 |
| 2023-2024 | `ShowFile?f=10039_39_csv_2023-2024` | 200 |
| 2024-2025 | `ShowFile?f=10039_39_csv_2024-2025` | 200 |

### Source 2: Graduation Rate - Traditional

- **URL Pattern:** `https://insights.nd.gov/ShowFile?f=10011_11_csv_{YYYY-YYYY}`
- **HTTP Status:** 200
- **Format:** CSV
- **Years Available:** 2013-2014 through 2024-2025 (12 years)
- **Access Method:** Direct HTTP GET, no auth required
- **Description:** Percentage of 12th grade students who graduated with diploma that year

### Source 3: Dropout Rate

- **URL Pattern:** `https://insights.nd.gov/ShowFile?f=10024_24_csv_{YYYY-YYYY}`
- **HTTP Status:** 200
- **Format:** CSV
- **Years Available:** 2019-2020 through 2024-2025 (6 years)
- **Access Method:** Direct HTTP GET, no auth required
- **Note:** Reports ranges (low/high) rather than exact values for privacy

---

## Schema Analysis

### Four-Year Cohort Graduation Rate Columns

| Column | Type | Description |
|--------|------|-------------|
| AcademicYear | text | Format: "YYYY-YYYY" (e.g., "2023-2024") |
| EntityLevel | text | "State", "District", or "School" |
| InstitutionName | text | Name of institution |
| InstitutionID | text | 5-digit district, 10-digit school, or "99999" for state |
| Subgroup | text | Demographic subgroup (see below) |
| FourYearGradRate | numeric | Graduation rate as decimal (0.0 to 1.0) |
| FourYearCohortGraduateCount | integer | Number of graduates |
| TotalFourYearCohort | integer | Total cohort size |

### Traditional Graduation Rate Columns

| Column | Type | Description |
|--------|------|-------------|
| AcademicYear | text | Format: "YYYY-YYYY" |
| EntityLevel | text | "State", "District", or "School" |
| InstitutionName | text | Name of institution |
| InstitutionID | text | Institution identifier |
| Subgroup | text | Demographic subgroup |
| GraduateCount | integer | Number of graduates |
| Total12thGradeStudents | integer | Total 12th graders |
| TraditionalGradRate | numeric | Graduation rate as decimal |

### Dropout Rate Columns

| Column | Type | Description |
|--------|------|-------------|
| AcademicYear | text | Format: "YYYY-YYYY" |
| EntityLevel | text | "State", "District", or "School" |
| InstitutionName | text | Name of institution |
| InstitutionID | text | Institution identifier |
| Subgroup | text | Demographic subgroup |
| DropoutRateRangeLow | numeric | Lower bound of dropout rate |
| DropoutRateRangeHigh | numeric | Upper bound of dropout rate |

### Column Names by Year

Schema is **CONSISTENT across all years** (2012-2025). No column name changes observed.

### Schema Changes Noted

- None observed - schema stable across all available years.

---

## Subgroups Available

The following subgroups are available in the graduation data:

| Subgroup | Description |
|----------|-------------|
| All | Total population |
| Male | Male students |
| Female | Female students |
| White | White/Caucasian |
| Black | Black/African American |
| Hispanic | Hispanic/Latino |
| Asian American | Asian American |
| Native American | American Indian/Alaska Native |
| Native Hawaiian or Pacific Islander | NH/PI |
| English Learner | Current EL students |
| Former English Learner | Reclassified EL students |
| IEP (student with disabilities) | Special education students |
| IEP - Emotional Disturbance | SPED - Emotional Disturbance |
| IEP - English Learner | SPED + EL students |
| Low Income | Economically disadvantaged |
| Foster Care | Students in foster care |
| Homeless | Students experiencing homelessness |
| Migrant | Migrant students |
| Military | Military-connected students |

**Note:** Some subgroups only appear in later years. Data is suppressed when counts < 10 students.

---

## ID System

### District IDs
- **Format:** 5 digits (leading zeros preserved)
- **Examples:** `27002`, `26009`, `02007`
- **Pattern:** Appears to be county code (2 digits) + district number (3 digits)

### School IDs
- **Format:** 10 digits
- **Examples:** `2700203153`, `2600905393`, `0200794633`
- **Pattern:** District ID (5 digits) + School code (5 digits)
- **Composite:** First 5 digits match the district ID

### State ID
- **Fixed Value:** `99999`
- **Name:** "State of North Dakota"

---

## Time Series Heuristics

Based on 2023-2024 data analysis:

### State-Level Benchmarks

| Metric | Value | Range for Tests |
|--------|-------|-----------------|
| State 4-Year Grad Rate (All) | 82.4% | 78% - 88% |
| State Cohort Size | 8,681 | 8,000 - 10,000 |
| State Graduate Count | 7,154 | 7,000 - 9,000 |

### Expected Ranges by Subgroup (State-Level)

| Subgroup | 2023-2024 Rate | Expected Range |
|----------|----------------|----------------|
| All | 82.4% | 78-88% |
| White | 87.5% | 82-92% |
| Native American | 63.4% | 55-75% |
| Black | 70.8% | 60-80% |
| Hispanic | 69.0% | 60-80% |
| Male | 81.0% | 76-86% |
| Female | 83.9% | 79-89% |
| IEP | 65.1% | 55-75% |
| Low Income | 67.6% | 60-78% |

### Year-over-Year Thresholds

- State total grad rate change: < 5% YoY is normal
- Cohort size change: < 10% YoY is normal
- Individual district rates can vary more widely

### Major Districts to Track

Based on enrollment data, major districts include:
- Fargo (09-001)
- Bismarck (08-001)
- Grand Forks (18-001)
- West Fargo (09-006)
- Minot (28-001)

---

## Known Data Issues

### Privacy Suppression
- Data suppressed when cohort < 10 students
- Some subgroups show as asterisk (*) or empty
- Dropout rate shows ranges instead of exact values

### No Issues Observed
- No division errors (/0 or #DIV/0!)
- No negative values
- No impossible percentages (> 100%)
- No schema variations across years

---

## Recommended Implementation

### Priority: HIGH
- Graduation rate is a key accountability metric
- Data is clean, well-structured, and freely accessible
- Consistent schema across 13 years of data

### Complexity: EASY
- Simple CSV download via HTTP GET
- No authentication required
- Consistent schema - no year-specific parsing needed
- Direct URL pattern with predictable file IDs

### Estimated Files to Modify/Create

| File | Action |
|------|--------|
| R/get_raw_graduation.R | Create - download functions |
| R/process_graduation.R | Create - processing functions |
| R/tidy_graduation.R | Create - tidy transformation |
| R/fetch_graduation.R | Create - main user function |
| R/utils.R | Modify - add graduation URL helper |
| tests/testthat/test-pipeline-grad-live.R | Create - live tests |
| tests/testthat/test-raw-data-fidelity-grad.R | Create - fidelity tests |

### Implementation Steps

1. **Add URL helper functions**
   ```r
   get_grad_cohort_url <- function(end_year) {
     academic_year <- paste0(end_year - 1, "-", end_year)
     paste0("https://insights.nd.gov/ShowFile?f=10039_39_csv_", academic_year)
   }
   ```

2. **Create get_raw_grad() function**
   - Download CSV directly via httr::GET
   - Parse with readr::read_csv
   - Strip HTML meta tag from first line

3. **Create process_grad() function**
   - Convert rate to numeric (already 0-1 scale)
   - Parse academic year to end_year integer
   - Standardize entity level names

4. **Create tidy_grad() function**
   - Already in long format by subgroup
   - Add aggregation flags (is_state, is_district, is_school)

5. **Create fetch_grad() function**
   - Main user-facing function
   - Support tidy=TRUE/FALSE
   - Support caching

6. **Write tests**
   - URL availability tests
   - File download tests
   - Schema validation tests
   - Fidelity tests with known values

---

## Test Requirements

### Raw Data Fidelity Tests Needed

| Year | Entity | Subgroup | Metric | Expected Value |
|------|--------|----------|--------|----------------|
| 2024 | State | All | FourYearGradRate | 0.824 |
| 2024 | State | All | TotalFourYearCohort | 8681 |
| 2024 | State | All | FourYearCohortGraduateCount | 7154 |
| 2024 | State | Native American | FourYearGradRate | 0.634 |
| 2024 | State | White | FourYearGradRate | 0.875 |
| 2019 | State | All | FourYearGradRate | (verify from raw file) |
| 2013 | State | All | FourYearGradRate | (verify from raw file) |

### Data Quality Checks

1. **No negative values**
   ```r
   expect_true(all(data$FourYearGradRate >= 0, na.rm = TRUE))
   ```

2. **No rates > 1.0**
   ```r
   expect_true(all(data$FourYearGradRate <= 1.0, na.rm = TRUE))
   ```

3. **Cohort >= Graduates**
   ```r
   expect_true(all(data$TotalFourYearCohort >= data$FourYearCohortGraduateCount))
   ```

4. **State record exists**
   ```r
   expect_true(any(data$EntityLevel == "State"))
   expect_true(any(data$InstitutionID == "99999"))
   ```

5. **All entity levels present**
   ```r
   expect_setequal(unique(data$EntityLevel), c("State", "District", "School"))
   ```

---

## Alternative Data Sources Considered

### ND DPI Main Data Page (nd.gov/dpi/data)
- No graduation data available as direct Excel downloads
- Only enrollment data in downloadable format
- Graduation data referenced via Insights portal

### NCES/Federal Sources
- **NOT USED** per project policy
- Would lose state-specific subgroups (Military, Former EL)
- Less timely data updates

---

## Data Source Page References

1. **Main Data Portal:** https://insights.nd.gov/Data
   - Lists all downloadable datasets with file IDs
   - Includes data dictionaries and descriptions

2. **Graduation Rate Dashboard:** https://insights.nd.gov/Education/State/GraduationRate
   - Interactive visualization
   - Same data as CSV downloads

3. **ND DPI Data Page:** https://www.nd.gov/dpi/data
   - Enrollment data only
   - Links to Insights for other metrics

---

## Notes for Implementation

### File Format Quirk
The CSV files have an HTML meta tag on the first line:
```
<meta http-quiv='ContentType' content='text/csv; charset=UTF8'>
```
This should be stripped when reading the file.

### Year Format Conversion
- Files use academic year format: "2023-2024"
- Package convention uses end year: 2024
- Conversion: `end_year <- as.integer(substr(academic_year, 6, 9))`

### Caching Strategy
- Cache both raw and processed data
- Raw file per year (small, ~100KB each)
- Consider single multi-year cache for common queries
