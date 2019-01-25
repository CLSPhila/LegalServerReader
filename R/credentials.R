
# Get Credentials
#
# Get gpg-encrypted credentials for accessing the LegalServer Report api.
get.credentials <- function(credentials.path = "./credentials.gpg") {
  tmpfile <- tempfile()
  credentials.path %>%
    gpg::gpg_decrypt(.) %>%
    writeLines(con = tmpfile)

  configr::read.config(file = tmpfile) %>%
    return
}

# Save credentials
#
# Ask a user for credentials to download reports from LegalServer, and
# save those credentials to a file encrypted with gpg.
save.credentials <- function(path.for.secrets = "./credentials.gpg", receiver) {
  writeLines("Please enter the legalserver api credentials");
  tmpfile <- tempfile()
  configr::write.config(list(
    defaults = list(
      api_user = readline(prompt = "API User name: "),
      api_pass = getPass::getPass(msg = "API User Password: ")
    ),
    reports = list(
      title = readline(prompt = "Name of report to download: "),
      url = getPass::getPass(msg = "URL of report to download (with api_key): ")
    )
  ), tmpfile, write.type = "ini")
  writeLines(gpg::gpg_encrypt(data = tmpfile, receiver = receiver), path.for.secrets)
  on.exit(unlink(tmpfile))
}
