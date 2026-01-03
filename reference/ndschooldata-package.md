# ndschooldata: Fetch and Process North Dakota School Data

Downloads and processes school enrollment data from the North Dakota
Department of Public Instruction (NDDPI). Provides functions for
fetching enrollment data and transforming it into tidy format for
analysis. Data is available from 2008 to present at the district level.

The ndschooldata package provides functions for downloading and
processing school enrollment data from the North Dakota Department of
Public Instruction (NDDPI).

## Data Source

Data is downloaded from the NDDPI website: <https://www.nd.gov/dpi/data>

The primary data file is "EnrollmentHistoryPublicSchoolDistrict.xlsx"
which contains district-level enrollment by grade from 2008 to present.

## Main Functions

- [`fetch_enr`](https://almartin82.github.io/ndschooldata/reference/fetch_enr.md):
  Fetch enrollment data for a single year

- [`fetch_enr_multi`](https://almartin82.github.io/ndschooldata/reference/fetch_enr_multi.md):
  Fetch enrollment data for multiple years

- [`tidy_enr`](https://almartin82.github.io/ndschooldata/reference/tidy_enr.md):
  Convert wide data to tidy (long) format

- [`get_available_years`](https://almartin82.github.io/ndschooldata/reference/get_available_years.md):
  List available data years

## Data Availability

- Years: 2008 to 2025 (18 years of data)

- Aggregation levels: State and District only (no campus/school level)

- Demographics: NOT available in main file (see insights.nd.gov)

- Grades: K-12 (no Pre-K in main file)

## District ID Format

North Dakota uses a "CC-DDD" format for district IDs:

- CC: 2-digit county code (01-53)

- DDD: 3-digit district number within county

Example: "09-001" is Fargo Public Schools (Cass County, District 1)

## See also

Useful links:

- <https://github.com/almartin82/ndschooldata>

- Report bugs at <https://github.com/almartin82/ndschooldata/issues>

Useful links:

- <https://github.com/almartin82/ndschooldata>

- Report bugs at <https://github.com/almartin82/ndschooldata/issues>

## Author

**Maintainer**: Al Martin <almartin@example.com>
