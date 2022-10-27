Uploading scenario data to IIASA database
================
Oliver Richters, 24 October, 2022

Many projects have to upload their scenario data to the database provided by [IIASA](https://iiasa.ac.at/scenario-ensembles-and-database-resources).

## Step 1: model registration

At the beginning of the project, there should be a process to get access to the project Internal Scenario Explorer.

Model, scenarios and project variables should be registered in the IIASA database. The variable list can be based on the `AR6` template once generate for the IPCC Sixth Assessment Report, or the new template for the NAVIGATE project.

In case of problems, contact [Daniel Huppmann](https://iiasa.ac.at/staff/daniel-huppmann). A template file containing the list of variables and associated units should be provided as yaml or xlsx file. Save it in your REMIND repository, the suggested place is `./output/export/`.

## Step 2: generate file to upload

The script that generates the xlsx file required for a submission is [`scripts/output/export/xlsx_IIASA.R`](../scripts/output/export/xlsx_IIASA.R). It is called by running `./output.R`, then selecting `export` and `xlsx_IIASA`. Then choose the directories of the runs you would like to use.

The script requires the following project-specific inputs:
- model: model name as registered in the database, such as "REMIND-MAgPIE 3.0-4.4"
- mapping: either the path to a mapping file you generated using [`piamInterfaces::generateMappingfile`](https://github.com/pik-piam/piamInterfaces/blob/master/R/generateMappingfile.R), or a vector of templates such as `c("NAVIGATE", "SHAPE")` referring to the last part of the file names in [this piamInterfaces directory](https://github.com/pik-piam/piamInterfaces/tree/master/inst/templates)
- iiasatemplate: path to the file with variables and units obtained in the project
- addToScen: optional string added in front of all scenario names
- removeFromScen: optional regular expression of parts to be deleted from the scenario names, such as "C_|_bIT|_bit|_bIt"
- filename_prefix: optional prefix of the resulting outputFile, such as your project name

You can specify the information above in two ways: Either edit [`xlsx_IIASA.R`](../scripts/output/export/xlsx_IIASA.R) and add a project in a similar way to `NGFS_v3` or `ENGAGE_4p5`. You can then start the scripts with:
```
Rscript output.R comp=export output=xlsx_IIASA project=NGFS_v3
```
You do not need to specify `comp` and `output` in the command line, you can just wait to be asked for it.
An alternative is to specify everything individually as command-line arguments:
```
Rscript output.R comp=export output=xlsx_IIASA model="REMIND 3.0" mapping=AR6,AR6_NGFS addToScen=whatever removeFromScen=C_ filename_prefix=test
```
All the information printed to you during the run will also be present in the logfile whose path will be told you at the end.

## Step 3: check submission

Check the logfile carefully for the variables that were omitted, failing summation checks etc. If you need information on a specific variable such as "Emi|CO2", you can run `piamInterfaces::variableInfo("Emi|CO2")` and it will provide a human-readable summary of the places this variable shows up in mapping templates and summation checks.

If you specify `iiasatemplate`, the scripts will delete all the variables not in the template. This can be the reason that summation checks fail, simply because some of the variables that were reported by REMIND were omitted.

Additionally, unit mismatches can cause the script to fail. In the past, IIASA has sometimes changed unit names to correct spelling mistakes or harmonize them. If there were unit mismatches where the units are identical, just spelled differently, you can add them to the named vector `identicalUnits` in [`piamInterfaces::checkIIASASubmission`](https://github.com/pik-piam/piamInterfaces/blob/master/R/checkIIASASubmission.R). So if the project template expects `Mt/yr`, but our templates export it as `Mt/year`, add `"Mt/yr" = "Mt/year"` to the vector, and it will in the future not fail on this unit mismatch but correct it to what is required in the project. Never use this mechanism if the units are not actually identical in their meaning.

## Step 4: upload file

Go to the project internal Scenario Explorer, click on your login name and then on "uploads" and the "plus" in the upper right corner - submit your xlsx file. Do not expect it to work flawlessly on the first try so hope for the best. You will receive an email message with a log and may at some point need the help of the IIASA administrators of your project.
