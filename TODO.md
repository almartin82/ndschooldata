# TODO - ndschooldata

## pkgdown Build Issues

### Network Timeout Error (2026-01-01)

The pkgdown build fails due to a network timeout when checking CRAN for the package:

```
Error in `httr2::req_perform(req)`:
! Failed to perform HTTP request.
Caused by error in `curl::curl_fetch_memory()`:
! Timeout was reached [cloud.r-project.org]:
Connection timed out after 10003 milliseconds
```

**Backtrace shows:**
- `pkgdown:::data_home_sidebar_links(pkg)`
- `pkgdown:::cran_link(pkg$package)`
- The build is trying to check if the package exists on CRAN to add a CRAN badge/link

**Possible solutions:**
1. Wait for network connectivity to `cloud.r-project.org` to be restored
2. Consider adding a development mode build that skips CRAN checks
3. The GitHub Actions workflow may work fine since GitHub runners typically have better connectivity to CRAN mirrors

**Note:** This is a transient network issue, not a code/vignette problem. The vignette code itself appears correct.
