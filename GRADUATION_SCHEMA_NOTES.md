# ND Graduation Rate Data - Schema Documentation

## Summary
North Dakota graduation rate data is available via direct CSV downloads from ND Insights portal.
- **URL Pattern**: `https://insights.nd.gov/ShowFile?f=10039_39_csv_YYYY-YYYY`
- **Years Available**: 2012-2013 through 2023-2024 (12 years verified, possibly 13)
- **Format**: CSV with HTML meta tag on first line
- **Access Method**: Direct HTTP GET, no authentication required

## File Quirk
The first line contains an HTML meta tag prepended to the CSV headers:
```
<meta http-quiv='ContentType' content='text/csv; charset=UTF8'>AcademicYear,EntityLevel,InstitutionName,InstitutionID,Subgroup,FourYearGradRate,FourYearCohortGraduateCount,TotalFourYearCohort
```

**Solution**: Strip everything before "AcademicYear" from the first line.

## Schema (Consistent Across All Years)

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| AcademicYear | text | Format: "YYYY-YYYY" | "2023-2024" |
| EntityLevel | text | "State", "District", or "School" | "District" |
| InstitutionName | text | Name of institution | "Fargo 1" |
| InstitutionID | text | 5-digit district, 10-digit school, or "99999" for state | "09001" |
| Subgroup | text | Demographic subgroup | "All", "Male", "White", etc. |
| FourYearGradRate | numeric | Graduation rate on 0-1 scale | 0.824 |
| FourYearCohortGraduateCount | integer | Number of graduates | 7154 |
| TotalFourYearCohort | integer | Total cohort size | 8681 |

**No schema changes observed** across 2012-2024.

## Subgroups Available (Sample)
- All (total population)
- Male, Female
- White, Black, Hispanic, Asian American, Native American, Native Hawaiian or Pacific Islander
- English Learner, Former English Learner
- IEP (special education)
- Low Income
- Foster Care, Homeless, Migrant, Military

## ID System
- **State ID**: "99999" (fixed value)
- **District IDs**: 5 digits with leading zeros preserved (e.g., "09001" for Fargo)
- **School IDs**: 10 digits (district ID + 5-digit school code)

## Verified State Totals (for Fidelity Tests)

| Year | Rate | Cohort | Graduates |
|------|------|--------|-----------|
| 2013 | 0.872 | 7567 | 6598 |
| 2014 | 0.869 | 7603 | 6609 |
| 2015 | 0.863 | 7635 | 6589 |
| 2016 | 0.873 | 7661 | 6687 |
| 2017 | 0.870 | 7572 | 6588 |
| 2018 | 0.880 | 7399 | 6512 |
| 2019 | 0.883 | 7626 | 6730 |
| 2020 | 0.890 | 7486 | 6660 |
| 2021 | 0.870 | 7843 | 6825 |
| 2022 | 0.843 | 8092 | 6823 |
| 2023 | 0.827 | 8294 | 6863 |
| 2024 | 0.824 | 8681 | 7154 |

## Verified District Data (2024)
- Fargo 1 (09001): rate=0.800, cohort=949, graduates=759
- Bismarck 1 (08001): rate=0.845, cohort=1057, graduates=893
- Grand Forks 1 (18001): rate=0.828, cohort=599, graduates=496
- Minot 1 (51001): rate=0.699, cohort=559, graduates=391

## Verified Subgroup Data (2024, State Level)
- All: rate=0.824, cohort=8681, graduates=7154
- Male: rate=0.810, cohort=4489, graduates=3636 (calculated)
- Female: rate=0.839, cohort=4192, graduates=3517 (calculated)
- White: rate=0.875, cohort=6420, graduates=5617 (calculated)
- Native American: rate=0.634, cohort=939, graduates=595 (calculated)

## Data Quality Notes
- No division errors (/0 or #DIV/0!) observed
- No negative values
- All rates are on 0-1 scale (not percentages)
- Data suppression: Values may be missing when cohort < 10 students
- All Entity levels present in later years (2016+)
- Earlier years (2012-2015) appear to only have District and State levels
