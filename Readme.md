# LegalServer Reader

Library for accessing LegalServer's Reports API

## Getting Started

First, install the library.


```
install_git("devtools::install_git("C://path/to/pkga.git"))
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
