# LegalServer Reader

Library for accessing LegalServer's Reports API.

This library isn't created by, maintained by, or affiliated in any way with the makers of the LegalServer software. It is a community-run project for using a particular LegalServer feature. 

## Motivation

LegalServer's original interface for extracting data - the Reports module - has some important limitations. The Reports API helps address two of these, and this R library's purpose is to make the Reports API easier to use.  

_Too much clicking._ The traditional means of getting data out of LegalServer involves a _lot_ of clicking. As long as your account has the right permissions, you click on the Reports tab and look for the report you need. Perhaps a report has already been built with the precise filters and data columns that you need. In that case, you can click to run the report, then click to download. Then click to open it, and then start clicking around in Excel to turn on filters or pivot tables or whatever else you need. Or perhaps there isn't a report that meets your needs, so you have to open up a more general report and click through the options for data columns and filers before you can run the report. 

All this clicking isn't just tedious. It leads to errors and wasted time. A clicking based workflow is a sequence of manual operations. You need to remember the sequence and perform it properly in order to get the data that you need. And if you make a mistake, you need to repeat parts of the sequence. If you've ever gone through a process of manually configuring a report, downloading it, manipulating it, and then discovering you need an extra column so you have to start over again, you'll know this pain.

_Accumulating data outside legalserver_. Protecting confidential data about our clients is one of our most important obligations as advocates. We have to access that data to report to funders and analyze our own work, so we can't just keep that data locked up. However the primary mechanism for extracting data is to download spreadsheet files to a computer's persistent storage. Do you always delete those report downloads when you're done with them? Do you know for sure that there aren't spreadsheets of client data in folders inside of folders inside of folders, somewhere on your computer? Wouldn't it be great if that client data never ended up in your computer's hard drive?

**Less clicking, fewer spreadsheets, more writing.** This library, `LegalServerReader` uses LegalServer's Reports API to help improve these two problems. With the LegalServer API and this library, we can replace a lot of our clicking and a lot of our spreadsheet-downloading with text. We can replace a very manual workflow involving a lot of buttons and downloaded files with something like this, saved in a simple text file:

```
  # Note: The `%>%` means "send the results of the last command to the next command."
  #       This is called a 'pipeline' because it pipes data from the top to the bottom.
  get.creds %>%
  get.report %>%
  process.data.for.important.project %>%
  save.processed.data("CaseReport.csv")
  
```

Once you've set up your report in Legalserver (see "Limitations" below) and your API credentials (see [LegalServer's Documentation](https://legalserver.stoplight.io/docs/ls-stoplight-legacy-public/docs/2-Authentication.md)), running your data-processing workflow is just a questions of running the code above. You don't need to remember long sequences of "click here, now here, now ... ." And the raw data from LegalServer isn't saved to your computer. Its downloaded to your computer's memory, and only the processed results, such as anonymized, aggregated data need to be saved to final storage.  **Fewer clicks, fewer files.**


## Limitations

The Reports API and this library have limitations that are still important to understand. The Reports API does not give you SQL-like access to the LegalServer database, so you still have to manually configure reports with the columns and filters you need. (Although there is some support for adding filters to API queries.). That means the API and this library are most useful when you need to download the same report repeatedly.

You also need to manage the credentials for accessing LegalServer Reports. The API and this library can help you avoid saving spreadsheets of client data, but the credentials for using the API can still access the confidential data. So its important that you keep those credentials secure. This library helps with that by using a common encryption system called `libsodium` to encrypt credentials. 

Finally, LegalServer has a limited capacity to download large reports. The API and this library make it very easy to download enormous amounts of data. Use this power responsibly! Avoid making repeated requests and consider caching partly-processed data. You might try writing your code to separate downloading from processing, so that raw data sits in a variable that you can use without re-downloading anything from LegalServer. 

This project is experimental, so use at your own risk. Also note that this project isn't endorsed or supported by LegalServer in any way. 

## Getting Started

First, install the library.


```
devtools::install_github("https://github.com/CLSPhila/LegalServerReader")
```

You may need to install additional libraries into your system, for example for parsing xml. When you run the command above, the installation messages will let you know what else you might need.


Dependencies include: 

* Sodium, available on Debian as`libsodium-dev`,
* 

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
