library(quitte)
library(tidyverse)
library(purrr)
# Set GAMS environment variable
Sys.setenv(R_GAMS_SYSDIR = "/p/system/packages/gams/43.4.1")
library(gdxrrw) # Might need a environmental variable to be set:
# Check if operational using
# Load GAMS to R library
#igdx(system("dirname $( which gams )", intern = TRUE))
# Cannot use gamstransfer as it is only distributed as part of a licensed GAMS installation
# library(gamstransfer)

renameVariableMagicc7ToRemind <- function(varName) {
   varName <- gsub("|MAGICCv7.5.3", "", varName, fixed = TRUE)
   varName <- gsub("AR6 climate diagnostics|", "MAGICC7 AR6|", varName, fixed = TRUE)
   return(varName)
}

renameVariableRemindToMagicc7 <- function(varName, magiccVersion = "7.5.3") {
   varName <- gsub("MAGICC7 AR6|", "AR6 climate diagnostics|", varName, fixed = TRUE)
   varName <- gsub(paste0("\\|([^\\|]+)$", "|MAGICCv", magiccVersion, "|\\1"), varName)
   return(varName)
}

args <- commandArgs(trailingOnly = T)
# args <- c("climate-temp/emimif_ar6_harmonized_infilled_IAMC_climateassessment0000.csv")
#args <- c("/p/tmp/tonnru/ca_remind/output/SSP2EU-NPi-ar6_2024-03-25_09.49.11/climate-assessment-data/ar6_climate_assessment_SSP2EU-NPi-ar6_harmonized_infilled_IAMC_climateassessment.xlsx")

climateAssessmentOutput <- args[1]
assessmentData <- read.quitte(climateAssessmentOutput)
usePeriods <- unique(assessmentData$period)
logMsg <- paste0(
   date(), "Read climate assessment output file '", climateAssessmentOutput, "' file with ", 
   length(usePeriods), " years\n"
)
cat(logMsg)

# thesePlease contains all variables IN MAGICC7 format that oughta be written to GDX as NAMES and the GDX file name
# as VALUES. If the variable is not found in the input data, it will be ignored. If you want the the same variable in 
# mutliple files, add another entry to the list. TODO: This could config file...
associateVariablesAndFiles <- as.data.frame(rbind(
      c(
         magicc7Variable = "AR6 climate diagnostics|Surface Temperature (GSAT)|MAGICCv7.5.3|50.0th Percentile",
         gamsVariable = "pm_globalMeanTemperature",
         fileName = "p15_magicc_temp"
      ),
      c(
         magicc7Variable = "AR6 climate diagnostics|Effective Radiative Forcing|Basket|Anthropogenic|MAGICCv7.5.3|50.0th Percentile",
         gamsVariable = "p15_forc_magicc",
         fileName = "p15_forc_magicc"
      ) #,
      # c(
      #    magicc7Variable = "AR6 climate diagnostics|Atmospheric Concentrations|CO2|MAGICCv7.5.3|50.0th Percentile",
      #    gamsVariable = "pm_co2_conc",
      #    fileName = "wdeleteme"
      # )
   )) %>% 
   mutate(remindVariable = sapply(
      .data$magicc7Variable,
      renameVariableMagicc7ToRemind,
      simplify = TRUE, USE.NAMES = FALSE
   ))
#dim(associateVariablesAndFiles)
#associateVariablesAndFiles

# Use the variable/file association to determine which variables shall be extracted from the MAGICC7 data
thesePlease <- unique(associateVariablesAndFiles$magicc7Variable)
relevantData <- assessmentData %>%
   # Exlude all other variables
   filter(variable %in% thesePlease & period %in% usePeriods) %>%
   # Interpolate missing periods: TODO is this actually necessary? We only check for periods in the data anyway..
   interpolate_missing_periods(usePeriods, expand.values = FALSE) %>%
   # Transform data from long to wide format such that yearly values are given in individual columns
   pivot_wider(names_from = "period", values_from = "value") %>%
   # Rename variables to REMIND-style names
   mutate(variable = sapply(.data$variable, renameVariableMagicc7ToRemind, simplify = TRUE,USE.NAMES = FALSE))
#relevantData$variable
#relevantData

# Loop through each file name given in associateVariablesAndFiles and write the associated variables to GDX files
# Note: This arrangement is capable of writing multiple variables to the same GDX file
for (currentFn in unique(associateVariablesAndFiles$fileName)) {
   # gamsVariable <- gdxFilesAndRemindVariables[[fileName]]
   #cat(paste0(currentFn, "\n"))
   whatToWrite <- associateVariablesAndFiles %>%
      filter(.data$fileName == currentFn) %>%
      select(remindVariable, gamsVariable)
   # Build a column vector of the variable values
   values <- cbind(
      # First column has to be enumaration of values 1..n(variable values)
      1:length(usePeriods),
      # Subsequent columns have to be the actual variable values
      relevantData %>%
         filter(.data$variable %in% whatToWrite$remindVariable) %>%
         select(all_of(as.character(usePeriods))) %>%
         t()
   )
   # Drop row names (period/years), since they are provided in the GDX file as "uels"
   rownames(values) <- NULL
   #values
   # Write the GDX file
   # First, create a list of lists that in turn contain the actual data to be written
   wgdx.lst(
      currentFn,
      llist <- purrr::map(2:ncol(values), function(idx) {
         list(
            name = whatToWrite$gamsVariable[idx - 1],
            type = "parameter",
            dim = 1,
            val = values[, c(1, idx)],
            form = "sparse",
            uels = list(usePeriods),
            domains = "tall"
         )
      })
   )
   logMsg <- paste0(date(), "Wrote '", currentFn, "'\n")
}
logMsg <- paste0(date(), "Done writing GDX files\n")

