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

stopmessage <- NULL

absDiff <- 0.00001
relDiff <- 0.01

# failing <- mif %>%
#   checkSummations(dataDumpFile = NULL, outputDirectory = NULL,  summationsFile = "extractVariableGroups",
#                   absDiff = 5e-7, relDiff = 1e-8) %>%
#   filter(abs(diff) >= 5e-7, abs(reldiff) >= 1e-8) %>%
#   df_variation() %>%
#   droplevels()
# if (nrow(failing) > 0) stopmessage <- c(stopmessage, "extractVariableGroups")

for (template in c("AR6", "NAVIGATE")) {
  message("\n### Check project summations for ", template)
  d <- generateIIASASubmission(mif, outputDirectory = NULL, logFile = NULL, mapping = template, checkSummation = FALSE)
  failing <- d %>%
    checkSummations(template = template, summationsFile = template, logFile = NULL, dataDumpFile = NULL,
                    absDiff = absDiff, relDiff = relDiff) %>%
    filter(abs(diff) >= absDiff, abs(reldiff) >= relDiff) %>%
    df_variation() %>%
    droplevels()
  
  if (nrow(failing) > 0) stopmessage <- c(stopmessage, template)
}

if (length(stopmessage) > 0) {
  stop("Failing summation checks for ", paste(stopmessage, collapse = ", "), ", see above.")
}
