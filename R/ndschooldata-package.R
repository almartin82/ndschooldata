#' @keywords internal
"_PACKAGE"

#' ndschooldata: North Dakota School Enrollment Data
#'
#' The ndschooldata package provides functions for downloading and processing
#' school enrollment data from the North Dakota Department of Public Instruction
#' (NDDPI).
#'
#' @section Data Source:
#' Data is downloaded from the NDDPI website:
#' \url{https://www.nd.gov/dpi/data}
#'
#' The primary data file is "EnrollmentHistoryPublicSchoolDistrict.xlsx" which
#' contains district-level enrollment by grade from 2008 to present.
#'
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{fetch_enr}}: Fetch enrollment data for a single year
#'   \item \code{\link{fetch_enr_multi}}: Fetch enrollment data for multiple years
#'   \item \code{\link{tidy_enr}}: Convert wide data to tidy (long) format
#'   \item \code{\link{get_available_years}}: List available data years
#' }
#'
#' @section Data Availability:
#' \itemize{
#'   \item Years: 2008 to 2026 (19 years of data)
#'   \item Aggregation levels: State and District only (no campus/school level)
#'   \item Demographics: NOT available in main file (see insights.nd.gov)
#'   \item Grades: K-12 (no Pre-K in main file)
#' }
#'
#' @section District ID Format:
#' North Dakota uses a "CC-DDD" format for district IDs:
#' \itemize{
#'   \item CC: 2-digit county code (01-53)
#'   \item DDD: 3-digit district number within county
#' }
#' Example: "09-001" is Fargo Public Schools (Cass County, District 1)
#'
#' @docType package
#' @name ndschooldata-package
NULL
