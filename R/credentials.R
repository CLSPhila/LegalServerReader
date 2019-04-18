
#' Get Credentials
#'
#' Get encrypted credentials for accessing the LegalServer Report api.
#'
#' @param credentials.path Character path to a gpg encrypted file of Report API credentials.
#' @return A list with the unencrypted credentials stored to `credential.path`.
get.credentials <- function(credentials.path = "./secret.creds") {
  full.message <- sodium::hex2bin(readr::read_file(credentials.path))
  nonce <- tail(full.message, 24)
  secret <- head(full.message, -24)
  key <- sodium::sha256(charToRaw(getPass::getPass("Password for encrypting credentials: ")))
  revealed <- jsonlite::fromJSON(rawToChar(sodium::data_decrypt(secret, key, nonce)))
  revealed$global$api_pass <- make.secret(revealed$global$api_pass)
  revealed <- lapply(creds, FUN=function(item) {
    if ("url" %in% names(item)) {item$url <- make.secret(item$url)}; return(item)})
  return(revealed)
}

#' Save credentials
#'
#' Save credentials to a file encrypted with sodium and a sha256 key.
#'
#' @param credentials A credentials list (See `create.credentials` and `add.report`)
#' @param path.for.secrets A string that is the path, including file name, to the file where the encrypted
#'     credentials should be written.
#' @param return.creds Boolean indicating if the function should return the credentials list, in addition to
#'     writing it to the disk.
#' @return `credentials`, if `return.creds` is TRUE, otherwise nothing. This allows method chaining/piping.
save.credentials <- function(credentials,
                             path.for.secrets = "./secret.creds",
                             return.creds = FALSE) {
  msg <- charToRaw(jsonlite::toJSON(credentials, force=TRUE))
  key <- sodium::sha256(charToRaw(getPass::getPass("Password for encrypting credentials: ")))
  cipher <- sodium::data_encrypt(msg, key)
  full.message <- paste0(sodium::bin2hex(cipher), sodium::bin2hex(attr(cipher,"nonce")))
  file.conn <- file(path.for.secrets)
  writeLines(full.message, file.conn)
  if (return.creds) {
    return(credentials)
  }
  return()
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
  creds <-
  return(
    list(
      global = list(
        api_user = readline(prompt = "API User name: "),
        api_pass = make.secret(getPass::getPass(msg = "API User Password: "))
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
    url = make.secret(getPass::getPass(msg = "URL of report to download (with api_key): "))
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

#' Make an object a secret.
make.secret <- function(s) {
  class(s) <- "secret"
  return(s)
}

#' S3 method for overriding default printing for things that shouldn't print to screen
print.secret <- function(x, ...) {
  print("...")
}
