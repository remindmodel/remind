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

for (template in c("AR6", "NAVIGATE")) {

  d <- generateIIASASubmission(mif, outputDirectory = NULL, logFile = NULL, mapping = template, checkSummation = FALSE)
  failing <- d %>%
    checkSummations(template = template, summationsFile = template, logFile = NULL, dataDumpFile = NULL,
                    absDiff = absDiff, relDiff = relDiff) %>%
    filter(abs(diff) >= absDiff, abs(reldiff) >= relDiff) %>%
    df_variation() %>%
    droplevels()
  
  if (nrow(failing) > 0) {
    stopmessage <- c(stopmessage,
                     paste0("\nThe following variables do not satisfy the ", template, " summation checks:"),
                     paste("\n-", unique(failing$variable), collapse = ""))
  }
}
if (length(stopmessage) > 0) {
  stop("Failing summation checks, see above.", stopmessage)
}
