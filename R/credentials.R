
# Get Credentials
#
# Get gpg-encrypted credentials for accessing the LegalServer Report api.
get.credentials <- function(credentials.path = "./credentials.gpg") {
  tmpfile <- tempfile()
  writeLines(
    gpg::gpg_decrypt(credentials.path),
    con = tmpfile
  )
  on.exit(unlink(tmpfile))
  return(
    configr::read.config(file = tmpfile))
}


#' Create Credentials
#'
#' Create a credentials list with just the credentials for the api user.
#' No reports stored here yet.
create.credentials <- function() {
  writeLines("Please enter the legalserver api credentials");
  return(
    list(
      global = list(
        api_user = readline(prompt = "API User name: "),
        api_pass = getPass::getPass(msg = "API User Password: ")
      )
    )
  )
}

#' Save Report Key
#'
#' Add a report and report url to a credentials list.
#'
add.report <- function(credentials, report.name) {
  credentials[[report.name]] <- list(
    url = getPass::getPass(msg = "URL of report to download (with api_key): ")
  )
  return(credentials)
}

#' Remove a report from a credentials list
remove.report <- function(credentials, report.name) {
  credentials[report.name] <- NULL
  return(credentials)
}


#' List reports available in a set of credentials
list.reports <- function(credentials) {
  return(
    names(
      credentials[names(creds) != "global"]
    )
  )
}

# Save credentials
#
# Save credentials to a file encrypted with gpg.
save.credentials <- function(credentials,
                             receiver,
                             path.for.secrets = "./credentials.gpg",
                             return.creds = FALSE) {
  tmpfile <- tempfile()
  configr::write.config(
    credentials, tmpfile, write.type = "ini")
  writeLines(gpg::gpg_encrypt(data = tmpfile, receiver = receiver), path.for.secrets)
  on.exit(unlink(tmpfile))
  if (return.creds) {
    return(credentials)
  }
  return()
}
