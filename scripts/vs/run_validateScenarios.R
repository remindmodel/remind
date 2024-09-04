# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(piamValidation)

lucode2::readArgs("outputDirs", "validationConfig")

# working directory is assumed to be the remind directory
outputDirs <- normalizePath(outputDirs, mustWork = TRUE)
mifPath <- remind2::getMifScenPath(outputDirs, mustWork = TRUE)
histPath <- remind2::getMifHistPath(outputDirs[1], mustWork = TRUE)

# option 1: HTML validation Report
piamValidation::validationReport(c(mifPath, histPath), validationConfig)

# option 3: export data (TODO: file location + name)
valiData <- piamValidation::validateScenarios(c(mifPath, histPath), validationConfig)
cat(getwd())

# option 2: pass or fail?
piamValidation::validationPass(valiData)


