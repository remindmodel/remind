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

stopmessage <- NULL

options(width = 160)

absDiff <- 0.00001
relDiff <- 0.01

# emi variables where bunkers are added only to the World level
gases <- c("BC", "CO", "CO2", "Kyoto Gases", "NOx", "OC", "Sulfur", "VOC")
vars <- c("", "|Energy", "|Energy Demand|Transportation", "|Energy and Industrial Processes",
          "|Energy|Demand", "|Energy|Demand|Transportation")
gasvars <- expand.grid(gases, vars, stringsAsFactors = FALSE)
bunkervars <- unique(sort(c("Gross Emissions|CO2", paste0("Emissions|", gasvars$Var1, gasvars$Var2))))

for (mapping in c("AR6", "NAVIGATE")) {
  message("\n### Check project summations for ", mapping)
  mappingVariables <- mapping %>%
    getMappingVariables(paste0("RT", if (any(grepl("^MAgPIE", levels(mifdata$model)))) "M")) %>%
    unique() %>%
    removePlus()
  computedVariables <- unique(paste0(removePlus(mifdata$variable), " (", gsub("^$", "unitless", mifdata$unit), ")"))
  missingVariables <- sort(setdiff(mappingVariables, computedVariables))
  if (length(missingVariables) > 0) {
    message("# The following ", length(missingVariables), " variables are expected in the piamInterfaces package ",
            "for mapping ", mapping, ", but cannot be found in the reporting:\n- ",
            paste(missingVariables, collapse = ",\n- "), "\n")
  }

  d <- generateIIASASubmission(mifdata, outputDirectory = NULL, logFile = NULL,
                               mapping = mapping, checkSummation = FALSE)
  failvars <- d %>%
    checkSummations(template = mapping, summationsFile = mapping, logFile = NULL, dataDumpFile = NULL,
                    absDiff = absDiff, relDiff = relDiff) %>%
    filter(abs(diff) >= absDiff, abs(reldiff) >= relDiff) %>%
    df_variation() %>%
    droplevels()
  
  csregi <- d %>%
    checkSummationsRegional(skipUnits = TRUE) %>%
    rename(World = "total") %>%
    droplevels()
  checkyear <- 2050
  failregi <- csregi %>%
    filter(abs(.data$reldiff) > 0.5, abs(.data$diff) > 0.00015, period == checkyear) %>%
    filter(! .data$variable %in% bunkervars) %>%
    select(-"model", -"scenario")
  if (nrow(failregi) > 0) {
    message("For those ", mapping, " variables, the sum of regional values does not match the World value in 2050:")
    failregi %>% piamInterfaces::niceround() %>% print(n = 1000)
  } else {
    message("Regional summation checks are fine.")
  }

  if (nrow(failvars) > 0 || nrow(failregi) > 0 || length(missingVariables) > 0) stopmessage <- c(stopmessage, mapping)
}

if (length(stopmessage) > 0) {
  stop("Failing summation checks for ", paste(stopmessage, collapse = ", "), ", see above.")
}
