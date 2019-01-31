# LegalServer Reader

Library for accessing LegalServer's Reports API

## Getting Started

First, install the library.


```
install_git("devtools::install_git("C://path/to/pkga.git"))
```

You may need to install additional libraries into your system, for example for parsing xml.

Second, create a gpg key, if you do not already have one, and make sure your key has a strong passphrase. Search online for how to do this, if you need help.

Third, save encrypted credentials for accessing your report:

```
> save.credentials("test@test.test", path.for.secrets = "mycredentials.gpg")
Please enter the legalserver api credentials
Name of report to download: Test Report
API User name: api_user
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
