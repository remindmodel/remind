# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(piamValidation)

# default report template, overwritten by a command line argument or by the
# calling environment when this script is sourced directly
if (!exists("validationReportName")) validationReportName <- "default"

lucode2::readArgs("outputdirs", "validationConfig", "validationReportName")

# working directory is assumed to be the remind directory
outputdirs <- normalizePath(outputdirs, mustWork = TRUE)
mifPath <- remind2::getMifScenPath(outputdirs, mustWork = TRUE)
histPath <- remind2::getMifHistPath(outputdirs[1], mustWork = TRUE)
dataPath <- c(mifPath, histPath)

# SCI configs are evaluated against reference data shipped with piamValidation,
# e.g. config "SCI_REMIND_2026.8.3" -> "SCI_reference_data_REMIND_2026.8.3.rds"
if (grepl("^SCI(_|$)", validationConfig)) {
  dataPath <- c(dataPath, piamutils::getSystemFile(
    paste0("extdata/", sub("^SCI", "SCI_reference_data", validationConfig), ".rds"),
    package = "piamValidation", mustWork = TRUE))
}

# option 1: HTML validation Report
piamValidation::validationReport(dataPath, validationConfig,
                                 report = validationReportName)

# option 3: export data (TODO: file location + name)
valiData <- piamValidation::validateScenarios(dataPath, validationConfig)
cat(getwd())

# option 2: pass or fail?
piamValidation::validationPass(valiData)