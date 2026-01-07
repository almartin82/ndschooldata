# Claude Code Instructions

## CRITICAL DATA SOURCE RULES

**NEVER use Urban Institute API, NCES CCD, or ANY federal data source**
— the entire point of these packages is to provide STATE-LEVEL data
directly from state DOEs. Federal sources aggregate/transform data
differently and lose state-specific details. If a state DOE source is
broken, FIX IT or find an alternative STATE source — do not fall back to
federal data.

------------------------------------------------------------------------

### GIT COMMIT POLICY

- Commits are allowed
- NO Claude Code attribution, NO Co-Authored-By trailers, NO emojis
- Write normal commit messages as if a human wrote them

------------------------------------------------------------------------

## Local Testing Before PRs (REQUIRED)

**PRs will not be merged until CI passes.** Run these checks locally
BEFORE opening a PR:

### CI Checks That Must Pass

| Check        | Local Command                                                                  | What It Tests                                  |
|--------------|--------------------------------------------------------------------------------|------------------------------------------------|
| R-CMD-check  | `devtools::check()`                                                            | Package builds, tests pass, no errors/warnings |
| Python tests | `pytest tests/test_pyndschooldata.py -v`                                       | Python wrapper works correctly                 |
| pkgdown      | [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html) | Documentation and vignettes render             |

### Quick Commands

``` r
# R package check (required)
devtools::check()

# Python tests (required)
system("pip install -e ./pyndschooldata && pytest tests/test_pyndschooldata.py -v")

# pkgdown build (required)
pkgdown::build_site()
```

### Pre-PR Checklist

Before opening a PR, verify: - \[ \] `devtools::check()` — 0 errors, 0
warnings - \[ \] `pytest tests/test_pyndschooldata.py` — all tests
pass - \[ \]
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
— builds without errors - \[ \] Vignettes render (no `eval=FALSE` hacks)

------------------------------------------------------------------------

## LIVE Pipeline Testing

This package includes `tests/testthat/test-pipeline-live.R` with LIVE
network tests.

### Test Categories:

1.  URL Availability - HTTP 200 checks
2.  File Download - Verify actual file (not HTML error)
3.  File Parsing - readxl/readr succeeds
4.  Column Structure - Expected columns exist
5.  get_raw_enr() - Raw data function works
6.  Data Quality - No Inf/NaN, non-negative counts
7.  Aggregation - State total \> 0
8.  Output Fidelity - tidy=TRUE matches raw

### Running Tests:

``` r
devtools::test(filter = "pipeline-live")
```

See `state-schooldata/CLAUDE.md` for complete testing framework
documentation.

------------------------------------------------------------------------

## Git Workflow (REQUIRED)

### Feature Branch + PR + Auto-Merge Policy

**NEVER push directly to main.** All changes must go through PRs with
auto-merge:

``` bash
# 1. Create feature branch
git checkout -b fix/description-of-change

# 2. Make changes, commit
git add -A
git commit -m "Fix: description of change"

# 3. Push and create PR with auto-merge
git push -u origin fix/description-of-change
gh pr create --title "Fix: description" --body "Description of changes"
gh pr merge --auto --squash

# 4. Clean up stale branches after PR merges
git checkout main && git pull && git fetch --prune origin
```

### Branch Cleanup (REQUIRED)

**Clean up stale branches every time you touch this package:**

``` bash
# Delete local branches merged to main
git branch --merged main | grep -v main | xargs -r git branch -d

# Prune remote tracking branches
git fetch --prune origin
```

### Auto-Merge Requirements

PRs auto-merge when ALL CI checks pass: - R-CMD-check (0 errors, 0
warnings) - Python tests (if py{st}schooldata exists) - pkgdown build
(vignettes must render)

If CI fails, fix the issue and push - auto-merge triggers when checks
pass.

------------------------------------------------------------------------

## README Images from Vignettes (REQUIRED)

**NEVER use `man/figures/` or `generate_readme_figs.R` for README
images.**

README images MUST come from pkgdown-generated vignette output so they
auto-update on merge:

``` markdown
![Chart name](https://almartin82.github.io/{package}/articles/{vignette}_files/figure-html/{chunk-name}-1.png)
```

**Why:** Vignette figures regenerate automatically when pkgdown builds.
Manual `man/figures/` requires running a separate script and is easy to
forget, causing stale/broken images.

------------------------------------------------------------------------

## Graduation Rate Data (Stage 1 Complete - Ready for Stage 2 TDD)

**Status:** Research complete, ready for implementation **Implementation
Difficulty:** EASY (Tier 1) **Last Updated:** 2026-01-07

### Data Source

**Portal:** ND Insights (insights.nd.gov) **Base URL:**
`https://insights.nd.gov/ShowFile?f=10039_39_csv_{ACADEMIC_YEAR}` **File
Format:** CSV with UTF-8 encoding **Years Available:** 2012-2013 through
2024-2025 (13 years) **Access Method:** Direct HTTP GET, no
authentication required

### URL Pattern

    https://insights.nd.gov/ShowFile?f=10039_39_csv_{START_YEAR}-{END_YEAR}

**Examples:** - 2023-2024:
`https://insights.nd.gov/ShowFile?f=10039_39_csv_2023-2024` - 2018-2019:
`https://insights.nd.gov/ShowFile?f=10039_39_csv_2018-2019` - 2012-2013:
`https://insights.nd.gov/ShowFile?f=10039_39_csv_2012-2013`

**All 13 years verified:** HTTP 200 status confirmed

### File Format Quirk

**IMPORTANT:** Each CSV file has an HTML meta tag on the first line:

    <meta http-quiv='ContentType' content='text/csv; charset=UTF8'>

**Solution:** Use `skip = 1` when parsing with
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)

### Data Schema (Consistent Across All Years)

| Column                      | Type      | Description                                             |
|-----------------------------|-----------|---------------------------------------------------------|
| AcademicYear                | character | “YYYY-YYYY” format (e.g., “2023-2024”)                  |
| EntityLevel                 | character | “State”, “District”, or “School”                        |
| InstitutionName             | character | Institution name                                        |
| InstitutionID               | character | 5-digit district, 10-digit school, or “99999” for state |
| Subgroup                    | character | Demographic subgroup (see below)                        |
| FourYearGradRate            | numeric   | Graduation rate as decimal (0.0 to 1.0)                 |
| FourYearCohortGraduateCount | integer   | Number of graduates                                     |
| TotalFourYearCohort         | integer   | Total cohort size                                       |

**No schema changes observed** across 13 years - column names identical
in all files.

### Subgroups Available (2023-2024)

All students, Male, Female, White, Black, Hispanic, Asian American,
Native American, Native Hawaiian or Pacific Islander, English Learner,
Former English Learner, IEP (student with disabilities), IEP - Emotional
Disturbance, IEP - English Learner, Low Income, Foster Care, Homeless,
Migrant, Military.

**Note:** Subgroup set expanded over time (13 in 2012 → 19 in 2018+).
All subgroups are additive (no breaking changes).

### ID System

**State ID:** “99999” **District IDs:** 5 digits (preserve leading
zeros, e.g., “27002”) **School IDs:** 10 digits (district ID + school
code, e.g., “2700203153”)

### Verified Fidelity Values

#### 2023-2024 State Totals

- All Students Grad Rate: 0.824 (82.4%)
- Cohort Size: 8,681
- Graduate Count: 7,154
- Native American Grad Rate: 0.634 (63.4%)
- White Grad Rate: 0.875 (87.5%)

#### 2018-2019 State Totals

- All Students Grad Rate: 0.883 (88.3%)
- Cohort Size: 7,626
- Graduate Count: 6,730

#### 2012-2013 State Totals (First Year)

- All Students Grad Rate: 0.872 (87.2%)
- Cohort Size: 7,567
- Graduate Count: 6,598

### Data Quality

**Excellent** - No issues found: - No division errors (/0 or \#DIV/0!) -
No negative values - No invalid percentages (\> 100%) - Cohort counts
\>= graduate counts (always) - State record present in all years

**Privacy Suppression:** Data suppressed when cohort \< 10 students
(marked as \* or empty)

### Implementation Notes

#### Year Conversion

- **Input format:** Academic year “2023-2024”
- **Package convention:** End year integer 2024
- **Conversion:** `end_year <- as.integer(substr(academic_year, 6, 9))`

#### Required R Packages

``` r
Imports:
    dplyr,
    tidyr,
    readr,   # CSV parsing
    httr,    # HTTP requests
    tibble
```

No additional dependencies needed (no pdftools, readxl, RSelenium, etc.)

#### Implementation Complexity

**EASY** - Estimated 2-3 hours - Direct HTTP GET (no auth) - CSV format
(simple parsing) - Consistent schema (no era detection) - Predictable
URL pattern - All years available (no gaps)

### Test Strategy

**LIVE Pipeline Tests (8 categories):** 1. URL availability (HTTP 200)
2. File download (correct size) 3. File parsing (readr succeeds) 4.
Column structure (expected columns present) 5. Year extraction (single
year works) 6. Data quality (no Inf/NaN, valid ranges) 7. Aggregation
(state record exists) 8. Output fidelity (tidy matches raw)

**Raw Data Fidelity Tests:** - Test 3+ years (2013, 2019, 2024) - Use
exact values from this document - Test state totals and key subgroups -
Verify cohort counts and graduate counts

### Additional Data Sources (Not Required)

**Traditional Graduation Rate:** - File ID: `10011_11_csv_{YEAR}` -
Years: 2013-2014 through 2024-2025 (12 years) - Description: Percentage
of 12th graders who graduated

**Dropout Rate:** - File ID: `10024_24_csv_{YEAR}` - Years: 2019-2020
through 2024-2025 (6 years) - Description: Dropout rate ranges (not
exact values)

### Research Documentation

Comprehensive research report:
`/Users/almartin/Documents/state-schooldata/docs/ND-GRADUATION-RESEARCH.md`

Includes: - Complete URL verification for all 13 years - Sample data
files downloaded and examined - Full schema documentation - Test
strategy with verified values - Implementation code snippets

### Next Steps (Stage 2: TDD)

1.  Write LIVE pipeline tests (8 tests)
2.  Write raw data fidelity tests (6+ tests)
3.  Watch tests fail (TDD approach)
4.  Implement functions to make tests pass
5.  Update documentation

**Proof of Concept Candidate:** ND is recommended in
GRADUATION-RATE-IMPLEMENTATION-PLAN.md as one of the first 4 Tier 1
states to implement (MA, ND, PA, VA).
