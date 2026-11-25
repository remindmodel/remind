# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# Does the actual xlsx_IIASA export work. Started either directly or via
# slurm by scripts/output/export/xlsx_IIASA.R, which collects and resolves
# all settings (interactively, if needed) and writes them to settingsFile.

require(data.table)
library(dplyr, warn.conflicts = FALSE)
library(quitte)
library(lucode2)
library(piamInterfaces)
library(stringr) # str_sub, str_split
library(tibble)
library(tidyr)

options(warn = 1)

if (!exists("settingsFile")) {
  lucode2::readArgs("settingsFile")
}
settings <- readRDS(settingsFile)
list2env(settings, envir = environment())

message("### Find various logs in ", logFile)
withCallingHandlers({ # piping messages to logFile
  
  outputXlsx <- paste0(outputFilename, ".xlsx")
  message("\n### Generating ", outputXlsx, ".")

  # outputdirs/scenNames/mifPath already checked by xlsx_IIASA.R
  message("\n### These mif files are used:\n- ", paste0(mifPath, collapse = "\n- "))

  message("\n### Load mif files...")
  mifdata <- bind_rows(lapply(mifPath, read.quitte, factors = FALSE)) # combine all scenarios into one data frame
  mifdata$scenario <- gsub("^C_|-(rem|mag)-[0-9]{1,2}$", "", mifdata$scenario) # remove C_, -rem-xx, mag-xx from scenario names

  # rename scenarios
  if (! is.null(renameScen)) {
    message("Old names: ", paste(sort(unique(mifdata$scenario)), collapse = ", "))
    for (i in names(renameScen)) {
      message("Rename scenario: ", i, " -> ", renameScen[[i]])
      mifdata$scenario[i == mifdata$scenario] <- renameScen[[i]]
    }
    message("New names: ", paste(sort(unique(mifdata$scenario)), collapse = ", "))
  }

  message("# ", length(temporarydelete), " variables are in the list to be temporarily deleted, ",
          length(unique(mifdata$variable[mifdata$variable %in% temporarydelete])), " were deleted.")
  write(paste0("  - ", paste(unique(mifdata$variable[mifdata$variable %in% temporarydelete]), collapse = "\n  - "), "\n\n"),
        file = logFile, append = TRUE)
  mifdata <- droplevels(filter(mifdata, ! variable %in% temporarydelete))

  generateIIASASubmission(mifdata, mapping = mapping, model = model,
                          removeFromScen = removeFromScen, addToScen = addToScen,
                          outputDirectory = outputFolder, checkSummation = checkSummation,
                          logFile = logFile, outputFilename = basename(outputXlsx),
                          iiasatemplate = iiasatemplate, generatePlots = TRUE,
                          timesteps = timesteps)

}, message = function(x) {
  cat(x$message, file = logFile, append = TRUE)
}) # end of piping message to logfile

message("\n### See details log file: less ", logFile, "\n")

unlink(settingsFile)
