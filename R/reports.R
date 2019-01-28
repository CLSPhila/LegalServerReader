

# Get Reports
#
#
get.report <- function(credentials, report.name) {
  # Get the report as xml from LegalServer using supplied credentials
  message("Downloading report...")
  xml.response <- httr::GET(
    credentials[[report.name]]$url,
    httr::authenticate(credentials$global$api_user, credentials$global$api_pass)
  )

  message("Parsing xml...")
  # Parse the xml as an xml doc, using xml2.
  doc <- httr::content(xml.response, as="parsed", type="text/xml", encoding="utf-8")

  # Extract the column names.
  # This assumes that every row in the report xml has the same columns as the first row.
  # Because the xml is an xml-encoding of a 2-d table, I think this is a fine assumption to
  # make.
  columns <- xml_name(
              xml_children(
                xml_find_first(doc, "row")))

  message("Initializing empty dataframe of the length of the report.")
  df <- data.frame(row.names = seq(1, length(xml2::xml_find_all(doc, "//row"))))
  # For each column, add the values of that column to a dataframe.
  message("Converting to a friendly dataframe...")
  mapply(
    function(col.name, df, doc) {
      message("Processing column: ", col.name)
      df[col.name] <- xml2::xml_find_all(doc, paste0("//",col.name,"/text()"))
    },
    columns,
    MoreArgs = list(df,doc)
  )
  message("All done!")
  return(df)
}
