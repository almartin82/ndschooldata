library(readr)

# Function to download and parse CSV (strip meta tag properly)
download_grad_csv <- function(academic_year) {
  url <- paste0('https://insights.nd.gov/ShowFile?f=10039_39_csv_', academic_year)
  temp <- tempfile(fileext = '.csv')
  clean_temp <- tempfile(fileext = '.csv')

  # Download
  download.file(url, temp, quiet = TRUE, mode = 'wb')

  # Strip the meta tag - the first line has: <meta>...>AcademicYear,EntityLevel,...
  # We need to remove everything before "AcademicYear"
  lines <- readLines(temp, warn = FALSE)

  # Extract the header (after the meta tag)
  header_line <- lines[1]
  header_start <- regexpr('AcademicYear', header_line)
  clean_header <- substr(header_line, header_start, nchar(header_line))

  # Write cleaned file
  writeLines(c(clean_header, lines[-1]), clean_temp)

  # Now read properly
  df <- read_csv(clean_temp, show_col_types = FALSE)
  return(as.data.frame(df))
}

# Download and analyze 5 years
years <- c('2012-2013', '2016-2017', '2019-2020', '2021-2022', '2023-2024')

for (yr in years) {
  df <- download_grad_csv(yr)

  cat(sprintf('\n========== %s ==========\n', yr))
  cat('Columns:', paste(names(df), collapse=', '), '\n')
  cat('Dimensions:', nrow(df), 'x', ncol(df), '\n')

  # State records
  state_rec <- df[df$EntityLevel == 'State', ]
  if (nrow(state_rec) > 0) {
    cat('\n=== STATE-LEVEL DATA ===\n')

    # All students
    all_rec <- state_rec[state_rec$Subgroup == 'All', ]
    if (nrow(all_rec) > 0) {
      cat('All students:\n')
      cat('  Grad Rate:', all_rec$FourYearGradRate, '\n')
      cat('  Graduates:', all_rec$FourYearCohortGraduateCount, '\n')
      cat('  Cohort:', all_rec$TotalFourYearCohort, '\n')
    }

    # Sample subgroups
    cat('\nSample subgroups:\n')
    for (sub in c('Male', 'Female', 'White', 'Native American')) {
      sub_rec <- state_rec[state_rec$Subgroup == sub, ]
      if (nrow(sub_rec) > 0) {
        cat(sprintf('  %s: rate=%.3f, cohort=%d\n', sub, sub_rec$FourYearGradRate[1], sub_rec$TotalFourYearCohort[1]))
      }
    }
  }

  # Sample districts (Fargo, Bismarck, etc.)
  cat('\n=== MAJOR DISTRICTS ===\n')
  major_dist <- c('Fargo 1', 'Bismarck 1', 'Grand Forks 1', 'West Fargo 1', 'Minot 1')
  for (d in major_dist) {
    d_rec <- df[df$InstitutionName == d & df$Subgroup == 'All' & df$EntityLevel == 'District', ]
    if (nrow(d_rec) > 0) {
      cat(sprintf('  %s (ID=%s): rate=%.3f, graduates=%d, cohort=%d\n',
          d, d_rec$InstitutionID[1], d_rec$FourYearGradRate[1],
          d_rec$FourYearCohortGraduateCount[1], d_rec$TotalFourYearCohort[1]))
    }
  }

  # Count unique entity levels and subgroups
  cat('\nEntity levels:', paste(unique(df$EntityLevel), collapse=', '), '\n')
  cat('Total subgroups (state):', nrow(state_rec), '\n')
}
