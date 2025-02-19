# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(piamutils)
library(piamInterfaces)
library(quitte)
suppressPackageStartupMessages(library(tidyverse))

if(! exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  lucode2::readArgs("outputdir")
}

scen <- lucode2::getScenNames(outputdir)
mif  <- file.path(outputdir, paste0("REMIND_generic_", scen, ".mif"))
mifdata <- as.quitte(mif)
envi <- new.env()
load(file.path(outputdir, "config.Rdata"), env =  envi)

stopmessage <- NULL

options(width = 160)

absDiff <- 0.00001
relDiff <- 0.01

sources <- paste0("R",
                  if (isTRUE(envi$cfg$gms$CES_parameters == "load")) "T",
                  if (any(grepl("^MAgPIE", levels(mifdata$model)))) "M")
message("\n### Check existence of variables in mappings.")
missingVariables <- checkMissingVars(mifdata, setdiff(names(mappingNames()), c("AgMIP", "AR6_MAgPIE")), sources)
if (length(missingVariables) > 0) message("Check piamInterfaces::variableInfo('variablename') etc.")

checkMappings <- list( # list(mappings, summationsFile, skipBunkers)
  list(c("NAVIGATE", "ELEVATE"), "NAVIGATE", FALSE),
  list("ScenarioMIP", NULL, FALSE)
)

for (i in seq_along(checkMappings)) {
  mapping <- checkMappings[[i]][[1]]
  message("\n### Check project summations for ", paste(mapping, collapse = ", "))
  # checkMissingVars
  checkMissingVars(mifdata, mapping, sources)

  # generate IIASASubmission
  d <- generateIIASASubmission(mifdata, outputDirectory = NULL, outputFilename = NULL, logFile = NULL,
                               mapping = mapping, checkSummation = FALSE, generatePlots = FALSE)
  # Check variable summation, but using only the first mapping
  failvars <- data.frame()
  if (length(checkMappings[[i]][[2]]) > 0) {
    failvars <- d %>%
      checkSummations(template = mapping[[1]], summationsFile = checkMappings[[i]][[2]], logFile = NULL,
                      dataDumpFile = NULL, absDiff = absDiff, relDiff = relDiff) %>%
      filter(abs(diff) >= absDiff, abs(reldiff) >= relDiff) %>%
      df_variation() %>%
      droplevels()
  }

  csregi <- d %>%
    filter(.data$region %in% unique(c("GLO", "World", read.csv2(envi$cfg$regionmapping)$RegionCode))) %>%
    checkSummationsRegional(intensiveUnits = TRUE, skipBunkers = isTRUE(checkMappings[[i]][[3]])) %>%
    rename(World = "total") %>%
    droplevels()
  checkyear <- 2050
  failregi <- csregi %>%
    filter(abs(.data$reldiff) > 0.5, abs(.data$diff) > 0.00015, period == checkyear) %>%
    select(-"model", -"scenario")
  if (nrow(failregi) > 0) {
    message("For those variables from ", paste(mapping, collapse = ", "),
            ", the sum of regional values does not match the World value in 2050:")
    failregi %>% piamInterfaces::niceround() %>% print(n = 1000)
  } else {
    message("Regional summation checks are fine.")
  }

  if (nrow(failvars) > 0 || nrow(failregi) > 0 || length(missingVariables) > 0) stopmessage <- c(stopmessage, paste(mapping, collapse = "+"))
}

if (length(stopmessage) > 0 || length(missingVariables) > 0) {
  warning("Project-related issues found checks for ", paste(stopmessage, collapse = ", "), " and ",
          length(missingVariables), " missing variables found, see above.")
}
