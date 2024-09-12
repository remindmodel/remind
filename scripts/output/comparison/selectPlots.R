# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# The selectPlots script is called via output.R -> comparison -> selectPlots.
# This script expects a variable `outputdirs` to be defined.
# The variable `filename_prefix` is used if defined.
# It allows the user to select line and area plots to be collected in a pdf file.
# The user can select regions, periods and bar plot years to be used.
# Another option is whether the difference to one of the scenarios should be plotted.
# For more details, see piamInterfaces::plotIntercomparison description.

suppressPackageStartupMessages(library(tidyverse))
library(quitte)
library(piamInterfaces)

if (! exists("outputdirs")) {
  stop(
    "Variable outputdirs does not exist. ",
    "Please call selectPlots.R via output.R, which defines outputdirs.")
}

timeStamp <- format(Sys.time(), "_%Y-%m-%d_%H.%M.%S")
if (! exists("filename_prefix")) filename_prefix <- ""
postfix <- paste0(ifelse(filename_prefix == "", "", "-"), filename_prefix, timeStamp)

histPath <- remind2::getMifHistPath(outputdirs[1], mustWork = TRUE)

scenarios <- lucode2::getScenNames(outputdirs)
mifs      <- file.path(outputdirs, paste0("REMIND_generic_", scenarios, ".mif"))
newnames  <- make.unique(basename(outputdirs), sep = "_")
message("Do you want to remove the timestamp from scenario names and shorten coupled runs? y/N")
if (tolower(gms::getLine()) %in% c("y", "yes")) {
  newnames <- make.unique(gsub("^C_", "", gsub("-rem-([0-9]+)$", "-\\1", scenarios)), sep = "_")
  duplicates <- duplicated(scenarios) | duplicated(scenarios, fromLast = TRUE)
  if (any(duplicates)) {
    message("\nAvoiding duplicates:\n",
            paste(paste(basename(outputdirs), "->", newnames)[duplicates], collapse = "\n"))
  }
}

message("\nLoading data...")
loadAdjust <- function(x) {
  mutate(as.quitte(mifs[x]), model = factor("REMIND"), scenario = factor(newnames[x]))
}
mifs <- lapply(seq_along(mifs), loadAdjust)

plotIntercomparison(list(mifs, histPath), summationsFile = "extractVariableGroups",
                    outputDirectory = "output/plots",
                    plotby = "onefile", postfix = postfix,
                    interactive = c("region", "period", "variable", "diffto", "yearsBarPlot"))

