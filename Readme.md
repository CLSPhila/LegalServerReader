# LegalServer Reader

Library for accessing LegalServer's Reports API

This project is experimental, so use at your own risk. Also note that this project isn't endorsed or supported by LegalServer in any way. 

## Getting Started

First, install the library.


```
devtools::install_github("https://github.com/CLSPhila/LegalServerReader")
```

You may need to install additional libraries into your system, for example for parsing xml.

Next, save encrypted credentials for accessing your report. See the Getting Started vignette for more details.

```
> create.credentials() %>%
    add.report("Test Report") %>%
    add.report("Second Report") %>%
    save.credentials(path.for.secrets="./mycredentials.creds", return.creds=FALSE)
```

You will be prompted for secrets: the password for the api user account and the url of the legalserver report, including the api key.

Now you can download a report as a dataframe using the credentials you just saved:

```
creds <- get.credentials("mycredentials.gpg")
rpt <- get.report(creds, "Test Report")
```

LegalServer reports download with column names that may not be helpful. You can create an .ini file for mapping the downloaded default names to new, more helpful names, as in

```
[Test Report]
original_column_name_with_internal_ls_stuff=Case ID
...
```

To map the columns, 

```
mapper <- get.column.mapper("myconfigfile.ini")
remapped.rpt <- remap.columns(rpt, mapper[["Test Report"]])
```

See the "Getting Started" vignette for more info:

```
browseVignettes("LegalServerReader")
```
