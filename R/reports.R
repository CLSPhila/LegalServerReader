

# Get Reports
#
#
get.report <- function(credentials, report.name) {
  return(httr::GET(
    credentials$reports$url,
    httr::authenticate(credentials$defaults$api_user, credentials$defaults$api_pass)
  ))
}
