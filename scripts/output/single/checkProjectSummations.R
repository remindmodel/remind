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

absDiff <- 0.00001
relDiff <- 0.01

# to be skipped for regional aggregation as they are no extensive variables
varGrep <- paste0("^Tech|CES Price|^Price|^Internal|[Pp]er[- ][Cc]apita|per-GDP|Specific|Interest Rate|",
                  "Intensity|Productivity|Average Extraction Costs|^PVP|Other Fossil Adjusted|Projected|[Ss]hare")
unitList <- c("%", "Percent", "percent", "% pa", "1", "share", "USD/capita", "index", "kcal/cap/day",
             "cm/capita", "kcal/capita/day", "unitless", "kcal/kcal", "m3/ha", "tC/tC", "tC/ha", "years",
             "share of total land", "tDM/capita/yr", "US$05 PPP/cap/yr", "t DM/ha/yr", "US$2010/kW", "US$2010/kW/yr")

# emi variables where bunkers are added only to the World level
gases <- c("BC", "CO", "CO2", "Kyoto Gases", "NOx", "OC", "Sulfur", "VOC")
vars <- c("", "|Energy", "|Energy Demand|Transportation", "|Energy and Industrial Processes",
          "|Energy|Demand", "|Energy|Demand|Transportation")
gasvars <- expand.grid(gases, vars, stringsAsFactors = FALSE)
bunkervars <- unique(sort(paste0("Emissions|", gasvars$Var1, gasvars$Var2)))


# failing <- mif %>%
#   checkSummations(dataDumpFile = NULL, outputDirectory = NULL,  summationsFile = "extractVariableGroups",
#                   absDiff = 5e-7, relDiff = 1e-8) %>%
#   filter(abs(diff) >= 5e-7, abs(reldiff) >= 1e-8) %>%
#   df_variation() %>%
#   droplevels()
# if (nrow(failing) > 0) stopmessage <- c(stopmessage, "extractVariableGroups")

for (template in c("AR6", "NAVIGATE")) {
  message("\n### Check project summations for ", template)
  d <- generateIIASASubmission(mifdata, outputDirectory = NULL, logFile = NULL,
                               mapping = template, checkSummation = FALSE)
  failvars <- d %>%
    checkSummations(template = template, summationsFile = template, logFile = NULL, dataDumpFile = NULL,
                    absDiff = absDiff, relDiff = relDiff) %>%
    filter(abs(diff) >= absDiff, abs(reldiff) >= relDiff) %>%
    df_variation() %>%
    droplevels()
  
  csregi <- d %>%
    filter(! .data$unit %in% unitList, ! grepl(varGrep, .data$variable)) %>%
    checkSummationsRegional() %>%
    rename(World = "total") %>%
    droplevels()
  checkyear <- 2050
  failregi <- csregi %>%
    filter(abs(.data$reldiff) > 0.5, abs(.data$diff) > 0.00015, period == checkyear) %>%
    filter(! .data$variable %in% bunkervars) %>%
    select(-"model", -"scenario")
  if (nrow(failregi) > 0) {
    message("For those ", template, " variables, the sum of regional values does not match the World value in 2050:")
    failregi %>% piamInterfaces::niceround() %>% print(n = 1000)
    print(paste0(failregi$variable, collapse = ", "))
  } else {
    message("Regional summation checks are fine.")
  }

  if (nrow(failvars) > 0 || nrow(failregi) > 0) stopmessage <- c(stopmessage, template)
}

if (length(stopmessage) > 0) {
  stop("Failing summation checks for ", paste(stopmessage, collapse = ", "), ", see above.")
}
