Uploading scenario data to IIASA database
================
Oliver Richters, 24 October, 2022

Many projects have to upload their scenario data to the database provided by [IIASA](https://iiasa.ac.at/scenario-ensembles-and-database-resources).

## Step 1: model registration

At the beginning of the project, there should be a process to get access to the project Internal Scenario Explorer. In case of problems, contact [Daniel Huppmann](https://iiasa.ac.at/staff/daniel-huppmann).
REMIND model registration files can be found in the [mappings](https://github.com/IAMconsortium/common-definitions/tree/main/mappings) and the [region](https://github.com/IAMconsortium/common-definitions/tree/main/definitions/region/native_regions) folder of the common-definitions repository, or in [piamInterfaces](https://github.com/pik-piam/piamInterfaces/tree/master/inst/registration).
Scenarios and project variables should be registered in the IIASA database.
Often, the variable list is based on the `AR6` template once generated for the IPCC Sixth Assessment Report, or the `NAVIGATE` or `ScenarioMIP` project.
This template file contains the list of variables and associated units may be provided as yaml or xlsx file.
It can be used to check the variable names and units of your submission.

## Step 2: generate file to upload

You can generate the file to be uploaded by either calling [`piamInterfaces::generateIIASASubmission`](https://github.com/pik-piam/piamInterfaces/blob/master/R/generateIIASASubmission.R) or using a wrapper based on `output.R`.
For more information on piamInterfaces and the mappings, check [its tutorial](https://github.com/pik-piam/piamInterfaces/blob/master/tutorial.md).

`generateIIASASubmission` requires the following inputs:

- `mifs`: vector of .mif files or directories that contain the .mif files
- `model`: model name as registered in the database, such as "REMIND-MAgPIE 3.2-4.6"
- `iiasatemplate`: optional path to the xlsx or yaml file obtained in the project with the variables and units that are accepted in the database. If you received a link of the form `https://files.ece.iiasa.ac.at/project-name/projectname-template.xlsx`, you can use that directly and it will be automatically downloaded.
- `addToScen`: optional string added in front of all scenario names
- `removeFromScen`: optional regular expression of parts to be deleted from the scenario names, such as "C_|_bIT|_bit|_bIt"
- `mapping`: vector of mappings from [this directory](https://github.com/pik-piam/piamInterfaces/tree/master/inst/mappings) (such as `c("AR6", "AR6_NGFS")` or `c("NAVIGATE", "SHAPE")`) or a local file with identical structure.

Usually, you will find the result in in the `output` subdirectory, but you can adapt this, see [the function documentation](https://github.com/pik-piam/piamInterfaces/blob/master/R/generateIIASASubmission.R).

Starting from your REMIND directory, you can start this process by running `./output.R`, then selecting `export` and `xlsx_IIASA`. Then choose the directories of the runs you would like to use. This works also for coupled runs, as the `REMIND_generic_*.mif` contains the MAgPIE output since [October 4, 2022](https://github.com/remindmodel/remind/pull/992).

The script requires the inputs as above, expect that it lets you select the `mifs` from a list, and provides additional options:
- mapping: either the path to a mapping or a vector of mapping names such as `c("NAVIGATE", "SHAPE")` referring to the last part of the file names in [this piamInterfaces directory](https://github.com/pik-piam/piamInterfaces/tree/master/inst/mappings)
- filename_prefix: optional prefix of the resulting outputFile, such as your project name

You can specify the information above in two ways: Either edit [`xlsx_IIASA.R`](../scripts/output/export/xlsx_IIASA.R) and add a project in a similar way to `NGFS` or `ENGAGE`. You can then start the scripts with:
```
Rscript output.R comp=export output=xlsx_IIASA project=NGFS
```
You do not need to specify `comp` and `output` in the command line, you can just wait to be asked for it.
An alternative is to specify everything individually as command-line arguments:
```
Rscript output.R comp=export output=xlsx_IIASA model="REMIND 3.2" mapping=AR6,AR6_NGFS addToScen=whatever removeFromScen=C_ filename_prefix=test
```
All the information printed to you during the run will also be present in the logfile whose path will be told you at the end.

## Step 3: check submission

Check the logfile carefully for the variables that were omitted, failing summation checks etc.
If you need information on a specific variable such as "Emi|CO2", you can run `piamInterfaces::variableInfo("Emi|CO2")` and it will provide a human-readable summary of the places this variable shows up in mappings and summation checks.
Running `piamInterfaces::variableInfo("Emi|CO2", mapping = c("AR6", "mapping.csv"))` allows to compare your local mapping with the AR6 mapping with respect to this variable.
On the PIK cluster, the script `variableinfo` is a shortcut, see `variableinfo --help`.

If you specify `iiasatemplate`, the scripts will delete all the variables not in the template. This can be the reason that summation checks fail, simply because some of the variables that were reported by REMIND were omitted.

Additionally, unit mismatches can cause the script to fail. In the past, IIASA has sometimes changed unit names to correct spelling mistakes or harmonize them.
If there were unit mismatches where the units are identical, just spelled differently, you can add them to the [`piamInterfaces::areUnitsIdentical()`](https://github.com/pik-piam/piamInterfaces/blob/master/R/areUnitsIdentical.R).
So if the project template expects `Mt/yr`, but our mappings export it as `Mt/year`, add `c("Mt/yr", "Mt/year")`, and it will in the future not fail on this unit mismatch but correct it to what is required for the submission.
Never use this mechanism if the units are not actually identical in their meaning.

## Step 4: upload file

Go to the project internal Scenario Explorer, click on your login name and then on "uploads" and the "plus" in the upper right corner - submit your xlsx file.
Do not expect it to work flawlessly on the first try so hope for the best.
You will receive an email message with a log and may at some point need the help of the IIASA administrators of your project.

## Step 5: Analyse the snapshots

To compare your submission with other groups, you can generate snapshots in the database.
You receive a zip file with large csv files.
You can try to read the full file into `R` using [`read.snapshot`](https://github.com/pik-piam/quitte/blob/master/R/read.snapshot.R):
```
quitte::read.snapshot("snapshot.csv")
```
But loading the full file might exceed available memory.
You can prefilter the data with:
```
quitte::read.snapshot("snapshot.csv", list(variable = c("GDP|PPP", "GDP|MER"), region = "World", period = 2030))
```
You can also use more sophisticated filtering and pass a filter.function,
see [`read.quitte` documentation](https://github.com/pik-piam/quitte/blob/master/R/read.quitte.R),
or even combine these approaches.
```
library(tidyverse)
yourfilter <- function(x) {
  filter(x, grepl("^Final Energy", .data$variable),
            between(.data$period, 2030, 2050))
}
d <- quitte::read.snapshot("snapshot.csv", list(region = "World"), filter.function = yourfilter)
```
If your computer supports the system commands `grep`, `head` and `tail` (as the PIK cluster does),
using the list-based filtering reduces loading times, as the file size can be reduced _before_ reading the data into `R`.

The following functions from `piamInterfaces` might be helpful for further analysis:
- [`checkSummations()`](https://github.com/pik-piam/piamInterfaces/blob/master/R/checkSummations.R) checks whether the variable summation groups of the template are satisfied.
- [`checkSummationsRegional()`](https://github.com/pik-piam/piamInterfaces/blob/master/R/checkSummationsRegional.R) checks whether regional aggregation is correct.
- [`fixOnRef()`](https://github.com/pik-piam/piamInterfaces/blob/master/R/fixOnRef.R) checks whether the runs are correctly fixed on their reference run for delayed transition scenarios.
- [`plotIntercomparison()`](https://github.com/pik-piam/piamInterfaces/blob/master/R/plotIntercomparison.R) plots area and line plots of selected variables.

## Custom historical.mif

If you like to generate a 'historical.mif' file for a different regional resolution and variable naming scheme than the REMIND one to pass it to plotIntercomparison, you can use the [regionmapping](https://github.com/pik-piam/piamInterfaces/tree/master/inst/regionmapping) ISO files from piamInterfaces, the madrat mappings folder or a similarly formatted file. Check for the latest data revision via `lastrev` anywhere on the cluster or use whichever revision you need by adjusting the `rev` argument of `retrieveData()`. An example could look like this:
```
library(madrat); library(mrremind); library(quitte); library(piamInterfaces)
stopifnot(utils::packageVersion("piamInterfaces") >= "0.36.2")
setConfig(regionmapping = system.file("regionmapping/ISO_2_ISO.csv", package = "piamInterfaces"))
d <- madrat::retrieveData("VALIDATIONREMIND", rev = "<lastrev>")
system(paste("tar -xvf", d, "./historical.mif"))
hist <- read.snapshot("historical.mif")
write.mif(convertHistoricalData(hist, "ScenarioMIP", "ISO_2_R10"), "historical_R10.mif")
```

## Further Information

Please refer to [this repository](https://gitlab.pik-potsdam.de/REMIND/miptemplate) for a showcase of all the tools and best practices when working with data from the IIASA database, including:
- how to download data from the IIASA database
- how read in and validate data in R
- how to create plots from the data in R
