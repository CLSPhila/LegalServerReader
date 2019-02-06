
#' Get Credentials
#'
#' Get gpg-encrypted credentials for accessing the LegalServer Report api.
#'
#' @param credentials.path Character path to a gpg encrypted file of Report API credentials.
#' @return A list with the unencrypted credentials stored to `credential.path`.
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
#'
#' No reports are stored in this list yet. Use `add.report` for to add
#' report information.
#'
#' @return A list that contains a global element, which is a list containing
#'     the username and password for a Report API user in LegalServer.
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
#'@param credentials List of credentials (see `create.credentials`)
#'@param report.name Name of a report to add. This is a name just to help you be organized. Does
#'    not have to be the name of the LegalServer report, as it is in LegalServer.
#'@return List of credentials, with a list added keyed to the new report name, which includes the url of the report
#'    you have added.
add.report <- function(credentials, report.name) {
  credentials[[report.name]] <- list(
    url = getPass::getPass(msg = "URL of report to download (with api_key): ")
  )
  return(credentials)
}

#' Remove a report from a credentials list
#'
#' @param credentials A credentials list (See `create.credentials` and `add.report`)
#' @param report.name The character string indicating the name of the report you wish to remove from
#'     these credentials.
#' @return A credentials list with information relating to the report `report.name` removed.
remove.report <- function(credentials, report.name) {
  credentials[report.name] <- NULL
  return(credentials)
}


#' List reports available in a set of credentials
#'
#' @param credentials A credentials list (See `create.credentials` and `add.report`)
#' @return A vector of the names of reports with credentials in `credentials`.
list.reports <- function(credentials) {
  return(
    names(
      credentials[names(creds) != "global"]
    )
  )
}

#' Save credentials
#'
#' Save credentials to a file encrypted with gpg.
#'
#' @param credentials A credentials list (See `create.credentials` and `add.report`)
#' @param receiver A string that is the id or email identifier of the gpg key you wish to use to encrypt these
#'     credentials.
#' @param path.for.secrets A string that is the path, including file name, to the file where the encrypted
#'     credentials should be written.
#' @param return.creds Boolean indicating if the function should return the credentials list, in addition to
#'     writing it to the disk.
#' @return `credentials`, if `return.creds` is TRUE, otherwise nothing.
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
