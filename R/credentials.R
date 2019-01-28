
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

# Save credentials
#
# Ask a user for credentials to download reports from LegalServer, and
# save those credentials to a file encrypted with gpg.
save.credentials <- function(receiver, path.for.secrets = "./credentials.gpg", return.creds = FALSE) {
  writeLines("Please enter the legalserver api credentials");
  tmpfile <- tempfile()
  report.name <- readline(prompt = "Name of report to download: ")
  config <- list(
    global = list(
      api_user = readline(prompt = "API User name: "),
      api_pass = getPass::getPass(msg = "API User Password: ")
    )
  )
  config[[report.name]] <- list(
    url = getPass::getPass(msg = "URL of report to download (with api_key): ")
  )
  configr::write.config(
    config, tmpfile, write.type = "ini")
  writeLines(gpg::gpg_encrypt(data = tmpfile, receiver = receiver), path.for.secrets)
  on.exit(unlink(tmpfile))
  if (return.creds) {
    return(config)
  }
  return()
}
