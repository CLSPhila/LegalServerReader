

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
  columns <- xml2::xml_name(
              xml2::xml_children(
                xml2::xml_find_first(doc, "row")))


  column.table <- table(columns)
  revised.columns <- c()
  for (idx in seq(1, length(columns))) {
    col.name <- columns[idx]
    num.prior <- length(which(columns[0:idx] == col.name)) # number of prior times this column name happened.
    revised.columns <- append(revised.columns, ifelse(num.prior>1, paste0(col.name, num.prior), col.name))
  }



  # For each column, add the values of that column to a dataframe.
  message("Converting to a friendly dataframe...")

  df <- data.frame(check.names = FALSE, row.names = seq(1, length(xml2::xml_find_all(doc, "//row"))))

  for (idx in seq(1,length(columns))) {
    col.name <- revised.columns[idx]
    message("processing column: (", idx, ", ", col.name, ")")
    df[col.name] <- xml2::xml_text(xml2::xml_find_all(doc, paste0("//row/*[position()=",idx,"]")))
  }

  message("All done!")
  return(df)
}

#' Given a path to an .ini file (default is ./columnMapper.ini),
#' return a list for mapping the column names returned in a
#' report to more user-friendly names.
#'
#' As in
#' [ReportName]
#' original_col_name = New.Column.Name
#'
get.column.mapper <- function(config.file = "columnMapper.ini") {
  return(configr::fetch.config(config.file))
}


#' Replace column names with friendlier names, given a list for mapping.
#'
#' The list has the form
#' $old.name
#' [[1]] "New Name"
#' ...
#'
#' If using a list from get.column.mapper, you need to subset the correct
#' mapper for a the dataframe (i.e. remap.columns(my.report, mapper[["myReportName"]]))
#'
remap.columns <- function(df, mapper) {
  only.mapped.columns <- select(df, names(mapper))
  names(only.mapped.columns) <- mapper[names(only.mapped.columns)]
  return(only.mapped.columns)
}