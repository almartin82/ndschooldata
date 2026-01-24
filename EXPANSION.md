# North Dakota School Data Expansion Research

**Last Updated:** 2026-01-11
**Package:** ndschooldata
**Theme Researched:** Assessment Data

---

## Current Package Capabilities

### Currently Implemented:
- **Enrollment Data:** 2008-2025 (18 years) - district-level by grade
- **Graduation Rate Data:** 2013-2024 (12 years) - 4-year cohort graduation rates
- **Directory Data:** District and school listings

### NOT Currently Implemented:
- Assessment data (NDSA, NDAA, ACT)
- Attendance data
- Demographics (race/ethnicity, ELL, SpED, FRPL)
- Chronic absenteeism
- Staffing data

---

## Assessment Data Sources Found

### Primary Source: ND Insights Portal

**Portal URL:** https://insights.nd.gov/Data
**Access Method:** Direct HTTP GET (no authentication required)
**Data Format:** CSV, JSON, and Excel downloads available

---

### Source 1: Assessment Performance Data

**Description:** Performance of students who took North Dakota's required state assessments (NDSA, NDAA, ACT)

**URL Pattern:**
```
https://insights.nd.gov/ShowFile?f=10028_28_csv_{ACADEMIC_YEAR}
```

**Examples:**
- 2023-2024: `https://insights.nd.gov/ShowFile?f=10028_28_csv_2023-2024`
- 2020-2021: `https://insights.nd.gov/ShowFile?f=10028_28_csv_2020-2021`
- 2014-2015: `https://insights.nd.gov/ShowFile?f=10028_28_csv_2014-2015`

**HTTP Status:** 200 (verified for 2023-2024)

**File Format:** CSV

**Years Available:** 2014-2015 through 2023-2024 (10 years)
- **Note:** 2019-2020 is a placeholder year containing 2018-2019 data (COVID waiver)
- All years available EXCEPT 2019-2020 actual assessment data

**Grade Levels:**
- K-8: Grades 3-8 (NDSA - North Dakota State Assessment)
- High School: Grade 11 (ACT exam)
- Alternate: NDAA (North Dakota Alternate Assessment)

**Subjects:**
- English Language Arts (ELA)
- Mathematics
- Science

**Achievement Levels Reported:**
- Novice
- Partially Proficient
- Proficient
- Advanced

**Data Suppression:**
- Small cell sizes (< 10) suppressed with asterisk (*) or empty cells
- Privacy ranges used (low/high columns) instead of exact values

---

### Source 2: Assessment Participation Data

**Description:** Percentage of students who took North Dakota's required state assessments

**URL Pattern:**
```
https://insights.nd.gov/ShowFile?f=10027_27_csv_{ACADEMIC_YEAR}
```

**Years Available:** 2014-2015 through 2023-2024 (10 years)
- Same year availability as Assessment Performance

**File Format:** CSV

**Data Elements:**
- Percent tested (range: low/high)
- Grade level
- Subject
- Assessment type (NDSA, NDAA, ACT)
- Accommodations
- Subgroup

---

### Source 3: Assessment Growth Data

**Description:** Student progress against growth expectations over current and prior achievement results in ELA and Math

**URL Pattern:**
```
https://insights.nd.gov/ShowFile?f=10035_35_csv_{ACADEMIC_YEAR}
```

**Years Available:** 2016-2017 through 2023-2024 (8 years)

**File Format:** CSV

**Growth Levels:**
- Does Not Meet
- Approaches
- Meets
- Exceeds

**Overall Growth Percentile:** Reported

---

## Schema Analysis

### Assessment Performance Data Schema (Consistent Across Years)

Based on ND Insights portal documentation, the Assessment Performance CSV contains:

| Column | Type | Description |
|--------|------|-------------|
| AcademicYear | character | "YYYY-YYYY" format (e.g., "2023-2024") |
| InstitutionName | character | School, district, or state name |
| InstitutionID | character | 5-digit district, 10-digit school, or "99999" for state |
| Grade | character | Grade level ("03" through "11") |
| Subject | character | "Math", "Reading/ELA", "Science" |
| AssessmentType | character | "NDSA", "NDAA", or "ACT" |
| Accommodations | character | Whether accommodations were provided |
| Subgroup | character | Demographic subgroup (see below) |
| NoviceRangeLow | numeric | Low end of Novice achievement range |
| NoviceRangeHigh | numeric | High end of Novice achievement range |
| PartiallyRangeLow | numeric | Low end of Partially Proficient range |
| PartiallyRangeHigh | numeric | High end of Partially Proficient range |
| ProficientRangeLow | numeric | Low end of Proficient range |
| ProficientRangeHigh | numeric | High end of Proficient range |
| AdvancedRangeLow | numeric | Low end of Advanced range |
| AdvancedRangeHigh | numeric | High end of Advanced range |

**Note:** Schema appears consistent across all years (2014-2024) based on portal documentation.

---

### ID System

**Matches Graduation Rate Pattern:**
- **State ID:** "99999"
- **District IDs:** 5 digits (preserve leading zeros, e.g., "27002")
- **School IDs:** 10 digits (district ID + school code, e.g., "2700203153")

**Important:** Must preserve leading zeros - always read IDs as character type

---

### Subgroups Available

Based on ND Insights documentation, typical subgroups include:
- All Students
- Male
- Female
- White
- Black / African American
- Hispanic / Latino
- Asian American
- Native American
- Native Hawaiian or Pacific Islander
- English Learner
- Former English Learner
- IEP (Special Education)
- IEP - Emotional Disturbance
- IEP - English Learner
- Low Income
- Foster Care
- Homeless
- Migrant
- Military

**Note:** Subgroup set has expanded over time (earlier years may have fewer subgroups)

---

## Known Data Issues

### 1. Privacy Suppression (Range Values)
- **Issue:** Instead of exact percentages, data uses ranges (low/high columns)
- **Impact:** Cannot calculate exact percentages, only ranges
- **Example:** ProficientRangeLow = 45.2, ProficientRangeHigh = 48.7 (actual value between 45.2% and 48.7%)

### 2. Small Cell Suppression
- **Issue:** Cells with n < 10 show asterisk (*) or are empty
- **Impact:** Missing data for small schools or subgroups
- **Solution:** Treat as NA/null in processing

### 3. 2019-2020 Placeholder Year
- **Issue:** 2019-2020 data is actually 2018-2019 data repeated
- **Impact:** No actual 2019-2020 assessment data (COVID waiver year)
- **Solution:** Skip 2019-2020 or document as placeholder

### 4. HTML Meta Tag (Likely)
- **Issue:** CSV files may have HTML meta tag on first line (like graduation data)
- **Pattern:** `<meta http-quiv='ContentType' content='text/csv; charset=UTF8'>`
- **Solution:** Skip first line or strip meta tag before parsing

---

## Time Series Heuristics

Based on ND assessment data characteristics:

| Metric | Expected Range | Red Flag If |
|--------|---------------|-------------|
| State proficiency (Math) | 40-50% | Change >5% YoY |
| State proficiency (ELA) | 45-55% | Change >5% YoY |
| District count | 160-170 districts | Sudden drop/spike |
| Proficient + Advanced range | Should equal state total | Ranges don't align |

**Major Districts to Verify Present:**
- Bismarck (08-001)
- West Fargo (06-006)
- Fargo (09-001)
- Minot (017-001)
- Grand Forks (035-001)
- Williston Basin (53-007)

**Sample Fidelity Values to Verify (2023-2024):**
- State overall ELA proficient %: ~48%
- State overall Math proficient %: ~44%
- Major districts should be present in all years

---

## Data Quality

**Expected Issues:**
- Range values instead of exact percentages
- Suppressed small cells (n < 10)
- Missing 2019-2020 data (COVID year)
- Potential HTML meta tag on first line

**Data Validation Rules:**
- All proficiency ranges should be 0-100%
- Low range ≤ High range (always)
- Proficient + Advanced ranges should align with totals
- No negative values in range columns
- State record present in all years (except 2019-2020 placeholder)

---

## Recommended Implementation

### Priority: MEDIUM
**Complexity: MEDIUM**
**Estimated Files to Modify:** 6-8

**Rationale:**
- ✅ Direct HTTP GET access (no authentication)
- ✅ CSV format (easy to parse)
- ✅ 10 years of data (2014-2024, excluding 2020 placeholder)
- ✅ Consistent schema across years
- ⚠️ Range values instead of exact percentages (limitation)
- ⚠️ Small cell suppression (expected)

**Comparison to Other States:**
- Easier than NM (no auth required)
- Similar complexity to graduation rate (same portal)
- More accessible than NV, PA (no interactive portal navigation)

---

## Implementation Steps

### 1. Research and Discovery (COMPLETED)
- ✅ Identified data source (ND Insights)
- ✅ Verified URL pattern
- ✅ Confirmed HTTP 200 access
- ✅ Documented schema structure

### 2. Download Sample Files
- Download 3 sample years (2014-2015, 2018-2019, 2023-2024)
- Verify actual file contents and schema
- Document any schema changes across years
- Identify specific values for fidelity tests

### 3. Create Helper Functions
```r
# Build assessment performance URL
build_assess_perf_url <- function(end_year) {
  start_year <- end_year - 1L
  academic_year <- paste0(start_year, "-", end_year)
  paste0("https://insights.nd.gov/ShowFile?f=10028_28_csv_", academic_year)
}

# Get available assessment years
get_available_assess_years <- function() {
  # 2014-2015 through 2023-2024
  # Exclude 2019-2020 (placeholder)
  c(2015:2019, 2021:2024)
}
```

### 4. Implement Core Functions
- `get_raw_assessment(end_year)` - Download raw CSV
- `process_assessment(raw_data, end_year)` - Standardize schema
- `tidy_assessment(processed_data, end_year)` - Transform to long format
- `fetch_assessment(end_year, tidy, use_cache)` - User-facing function
- `fetch_assessment_multi(end_years, tidy, use_cache)` - Multi-year fetch

### 5. Handle Data Quirks
- Strip HTML meta tag (if present, like graduation data)
- Parse range columns (ProficientRangeLow, ProficientRangeHigh)
- Handle suppressed values (* or empty cells)
- Skip 2019-2020 placeholder year

### 6. Implement Tests
- **LIVE Pipeline Tests** (8 categories):
  1. URL availability (HTTP 200)
  2. File download (correct size)
  3. File parsing (readr succeeds)
  4. Column structure (expected columns present)
  5. Year extraction (single year works)
  6. Data quality (no Inf/NaN, valid ranges)
  7. Aggregation (state record exists)
  8. Output fidelity (tidy matches raw)

- **Raw Data Fidelity Tests:**
  - Test 3 years (2015, 2019, 2024)
  - Verify state proficiency ranges
  - Test major districts present
  - Verify subgroup data integrity

---

## Test Requirements

### Raw Data Fidelity Tests Needed:

**Example tests (once sample files downloaded):**
```r
test_that("2024: State ELA proficiency ranges contain expected values", {
  skip_if_offline()

  data <- fetch_assessment(2024, use_cache = TRUE)

  state_ela <- data %>%
    filter(is_state, subject == "ELA", subgroup == "all")

  # Verify ranges are present and reasonable
  expect_true(!is.na(state_ela$proficient_range_low))
  expect_true(state_ela$proficient_range_low >= 40)
  expect_true(state_ela$proficient_range_high <= 60)
})
```

### Data Quality Checks:
- No negative values in range columns
- Low range ≤ High range (always true)
- State record present in all years
- Major districts present (Bismarck, Fargo, etc.)
- Subgroup data integrity

---

## Alternative Assessment Data Sources

### ACT Data (Excluded per Requirements)
- **Source:** ND Insights ACT datasets
- **File IDs:** Various (2_52_csv, etc.)
- **Status:** NOT implementing (excluded by user request)

### NDAA (Alternate Assessment)
- **Source:** Same as Assessment Performance (filter by AssessmentType)
- **Implementation:** Same pipeline, filtered by AssessmentType = "NDAA"

---

## Implementation Complexity Analysis

### Challenges (MEDIUM Complexity):

1. **Range Values Instead of Exact Percentages**
   - Must store both low and high range columns
   - Cannot calculate exact proficiency rates
   - Different from other states with exact values

2. **Small Cell Suppression**
   - Must handle asterisk (*) and empty cells
   - NA/null treatment needed

3. **HTML Meta Tag**
   - Likely present (like graduation data)
   - Must strip before parsing CSV

4. **Placeholder Year (2019-2020)**
   - Must document and skip or handle specially
   - No actual assessment data for this year

### Advantages (EASY-MEDIUM Overall):

1. **Direct Download Access**
   - No authentication required
   - Predictable URL pattern
   - Same portal as graduation (proven approach)

2. **CSV Format**
   - Easy to parse with readr
   - No PDF scraping
   - No JavaScript required

3. **Consistent Schema**
   - Same columns across all years
   - No schema era detection needed

4. **10 Years of Data**
   - Good historical coverage
   - Pre- and post-COVID comparison possible

---

## Comparison to Existing Implementation

The assessment data can follow the same pattern as the existing graduation rate implementation:

**Similarities:**
- Same ND Insights portal
- Same URL pattern structure
- CSV format with potential HTML meta tag
- Same ID system (district/school/state)
- Same cache strategy
- Same error handling approach

**Differences:**
- Range values instead of exact percentages
- Achievement levels (4 levels vs 1 graduation rate)
- Multiple subjects and grades (vs single metric)
- Assessment types (NDSA, NDAA, ACT)

**Implementation Reuse:**
- Can borrow URL building logic
- Can reuse CSV parsing with meta tag stripping
- Can reuse cache directory structure
- Can reuse test patterns from graduation

---

## Estimated Implementation Effort

### Breakdown:
- **Sample File Download & Schema Analysis:** 2-3 hours
- **Helper Function Implementation:** 1-2 hours
- **Core Function Implementation:** 6-8 hours
  - get_raw_assessment: 2 hours
  - process_assessment: 3 hours
  - tidy_assessment: 2 hours
  - fetch_assessment functions: 1 hour
- **Testing:** 4-6 hours
  - LIVE pipeline tests: 2 hours
  - Fidelity tests: 2-3 hours
  - Test debugging: 1 hour
- **Documentation:** 2-3 hours
  - EXPANSION.md: 1 hour (this file)
  - Code comments: 1 hour
  - README/vignette updates: 1 hour

**Total Estimate:** 15-22 hours (2-3 work days)

---

## Next Steps

### Immediate Actions:
1. **Download sample files** (2014-2015, 2018-2019, 2023-2024)
   - Verify actual file structure
   - Identify specific fidelity test values
   - Confirm schema consistency

2. **Create implementation branch**
   - `git checkout -b feat/assessment-data`
   - Follow git workflow from CLAUDE.md

3. **Write tests first** (TDD approach)
   - LIVE pipeline test skeleton
   - Fidelity test structure with placeholders
   - Data quality checks

4. **Implement core functions**
   - Start with get_raw_assessment
   - Then process_assessment
   - Then tidy_assessment
   - Finally fetch_assessment

5. **Run tests and iterate**
   - devtools::test()
   - Fix issues until all tests pass
   - Add missing tests as needed

6. **Update documentation**
   - README with assessment examples
   - Vignette with assessment visualizations
   - Code comments

7. **Create PR**
   - Follow git workflow from CLAUDE.md
   - Ensure CI passes before merging

---

## Sources

- [ND Insights Data Portal](https://insights.nd.gov/Data)
- [ND Insights About Page](https://insights.nd.gov/About)
- [North Dakota Department of Public Instruction](https://www.nd.gov/dpi)
- [ndschooldata Package](https://github.com/almartin82/ndschooldata)
- [Graduation Rate Implementation](R/get_raw_graduation.R) (reference for URL patterns)

---

## Conclusion

North Dakota assessment data is **RECOMMENDED for implementation** with MEDIUM complexity:

**Strengths:**
- Direct download access (no auth)
- 10 years of comprehensive data
- Consistent schema across years
- Same proven portal as graduation data

**Limitations:**
- Range values instead of exact percentages
- Small cell suppression
- No 2019-2020 data (COVID year)

**Best Next Enhancement:** After enrollment and graduation rates, assessment data is the logical next step for ndschooldata package expansion.

**Implementation Priority:** HIGH (after attendance/demographics, which may be easier)
