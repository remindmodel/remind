# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# !/bin/bash
library(dplyr)
require(gdxrrw) # Needs an environmental variable to be set, see below
library(lucode2)
library(magrittr)
library(piamInterfaces)
library(piamenv)
library(piamutils)
library(quitte)
library(readr)
library(remind2)
library(remindClimateAssessment)
library(stringr)
library(tidyverse)
library(yaml)


#################### BASIC CONFIGURATION ##########################################################

runTimes <- c()
runTimes <- c(runTimes, "set_up_assessment start" = Sys.time())

# This script is meant to run the full IIASA climate assessment using a single parameter set,
# meant to be used between REMIND iterations

outputDir <- getwd()
outputDir <- normalizePath(file.path(outputDir, "output/h_cpol_KLW_d50_2025-02-06_18.10.48"))
outputDir
# cfg is a list containing all relevant paths and settings for the climate assessment
cfg <- climateAssessmentConfig(outputDir, "impulse")
# Keep track of runtimes of different parts of the script
cat(
  date(), "climateAssessmentImpulseResponse.R:", reportClimateAssessmentConfig(cfg), file = cfg$logFile, append = TRUE
)
# cat(reportClimateAssessmentConfig(cfg))

#################### PYTHON/MAGICC SETUP ##########################################################

dir.create(cfg$climateDir, showWarnings = FALSE)
dir.create(cfg$workersDir, showWarnings = FALSE)

magiccEnv <- c(
  "MAGICC_EXECUTABLE_7"    = cfg$magiccBin,
  "MAGICC_WORKER_ROOT_DIR" = cfg$workersDir,
  "MAGICC_WORKER_NUMBER"   = 1
)

magiccInit <- condaInit(how = "pik-cluster", log = cfg$logFile, verbose = 1)

# TODO Start: Put this into remindClimateAssessment?
# Read parameter sets file to ascertain how many parsets there are
allparsets <- read_yaml(cfg$probabilisticFile)
nparsets <- length(allparsets$configurations)

# Write parameter file with required modifications
allparsets$configurations[[1]]$nml_allcfgs$endyear <- 2300
probabilisticFileModified <- normalizePath(file.path(cfg$climateDir, "probmod.json"), mustWork = FALSE)
jsonlite::write_json(allparsets, probabilisticFileModified, pretty = TRUE, auto_unbox = TRUE)
# TODO End

runClimateEmulatorCmd <- paste(
  "python", file.path(system.file(package = "remindClimateAssessment"), "runOpenSCM.py"), cfg$emissionsImpulseFile,
  "--climatetempdir", climateTempDir,
  # Note: Option --year-filter-last requires https://github.com/gabriel-abrahao/climate-assessment/tree/yearfilter
  "--endyear", 2200,
  "--num-cfgs", nparsets,
  "--scenario-batch-size", 1,
  "--probabilistic-file", probabilisticFileModified
)

runTimes <- c(runTimes, "set_up_assessment end" = Sys.time())

# END REPEATED PART ========================================================================


# define years and pulse size
scanValsPulse <- c(0, 1) # pulse size in GtC. Keep 0 in here as the baseline against which the pulse run is compared to
scanValsYears <- c(2020, 2030, 2040, 2050, 2060, 2070, 2080, 2090, 2100, 2110, 2130)

# Read base emissions scenario file
mifBaseScen <- read.quitte(fileBaseScen)

# Add emissions data up to 2300, assuming constant emissions of all species after 2100
mifBaseScen <- bind_rows(
  mifBaseScen,
  lapply(2101:2200, function(x) {
    mifBaseScen %>%
      filter(period == 2100) %>%
      mutate(period = x)
  })
) %>%
  arrange(variable, period)

# The variable which to apply the pulse
# Keep flexible, as we may want to do this with other gases as well
# Here we assume the pulse comes from energy emissions. AFOLU emissions
# imply deforestation in some SCMs and would lead to spurious regrowth
emisVarName <- "AR6 climate diagnostics|Infilled|Emissions|CO2|Energy and Industrial Processes"

# Build a quitte with scenarios that scan the range of pulse sizes and years set above
# This is pretty fast, so opting for a readable loop instead of an apply
separatorScen <- "---"
mifAllPulsesScen <- tibble()
for (val_pulse in scanValsPulse) {
  for (val_year in scanValsYears) {
    mifPulse <- mifBaseScen %>%
      mutate(
        value = case_when(
          variable == emisVarName & period == val_year ~ value + val_pulse * 1e3 * 3.66, # GtC to MtCO2
          .default = value
        ),
        scenario = paste0("P", separatorScen, val_pulse, separatorScen, val_year)
      )

    mifAllPulsesScen <- bind_rows(mifAllPulsesScen, mifPulse)
  }
}

# Write the emissions file
# fileAllPulsesScen <- paste0(normalizePath(climateTempDir), "/allpulses.xlsx")
write.IAMCxlsx(mifAllPulsesScen, cfg$emissionsImpulseFile)
# Where we expect the climate output to be

# Start actual runs ====================================================
runTimes <- c(runTimes, "emulation start" = Sys.time())
condaRun(runHarmoniseAndInfillCmd, cfg$condaEnv, env = magiccEnv, init = magiccInit, log = cfg$logFile, verbose = 1)
runTimes <- c(runTimes, "emulation end" = Sys.time())

runTimes <- c(runTimes, "postprocessing start" = Sys.time())
# Actual runs done, read the output, already filtering what we need
# temperatureVarName <- "AR6 climate diagnostics|Surface Temperature (GSAT)|MAGICCv7.5.3|50.0th Percentile"
temperatureVarName <- "Surface Air Temperature Change"
mifAllPulsesClimate <- read.quitte(cfg$climateAssessmentFile) %>%
  filter(variable == temperatureVarName) %>%
  filter(between(period, 2020, 2300))

tirf <- mifAllPulsesClimate %>%
  select(scenario, period, value) %>%
  separate(scenario, c("dummy", "size_pulse", "year_pulse"), sep = separatorScen) %>%
  select(year_pulse, size_pulse, period, value) %>%
  mutate(
    year_pulse = as.numeric(year_pulse),
    size_pulse = as.numeric(size_pulse)
  ) %>%
  as.data.frame()

#calculate difference to baseline to get TIRF, normalize to 1 GtCO2eq emission.
tirf <- tirf %>%
  group_by(period, year_pulse) %>%
  summarize(tirf = (value[size_pulse != 0] - value[size_pulse == 0]) / size_pulse[size_pulse != 0] / (44 / 12)) %>%
  ungroup()

# Extend period back to 2010 to all year_pulses, assuming tirf 0
tirf <- tirf %>%
  nest(-year_pulse) %>%
  mutate(data = map(data, function(x) {
    rbind(data.frame(
      period = 2010:2019, tirf = 0
    ), x) %>%
      arrange(period)
  })) %>%
  unnest()

# Assume tirf has the same shape in year_pulse 2010 as in 2020
tirf <- rbind(
    tirf %>%
      filter(year_pulse == 2020) %>%
      mutate(year_pulse = year_pulse - 10, period = period - 10),
    tirf
  ) %>%
  filter(period >= 2010)

# NOTE the result for 2150 is just zero, don't know why. work around by assuming the TIRF in 2150 is equal to the one 
# in 2130. From 2150 to 2250, assume the same.
tirf <- rbind(
  tirf,
  tirf %>%
    filter(year_pulse == 2130) %>%
    mutate(
      year_pulse = 2250,
      period = period + 120
    )
)

## interpolate for the years we didn't explicitly run a pulse experiment:
# prepare data by shifting als pulses so that they start at period=0
tirfInterpolated <- tirf %>%
  group_by(year_pulse) %>%
  mutate(period = period - year_pulse)

# only try to interpolate if there is at least two datapoints (not the case for the earliet pulse in the last couple 
# of years :)
tirfInterpolated <- tirfInterpolated %>%
  group_by(period) %>%
  filter(length(tirf) > 1)

#interpolation:
oupt <- do.call(rbind, lapply(as.integer(unique(tirfInterpolated$period)), function(p) {
  dt <- tirfInterpolated %>% filter(period == p)
  out <- approx(dt$year_pulse, dt$tirf,
    xout = seq(min(tirfInterpolated$year_pulse), max(tirfInterpolated$year_pulse), 1),
    method = "linear", yleft = 0, yright = 0, rule = 2:1)
  out <- data.frame(tall1 = out$x, tirf = out$y)
  out$tall <- p
  out
}))

# reverse shift and limit output to until 2250
oupt <- oupt %>%
  mutate(tall = tall + tall1) %>%
  filter(tall <= 2250, tall >= 2005) %>%
  select(tall, tall1, tirf)
runTimes <- c(runTimes, "postprocessing end" = Sys.time())

runTimes <- c(runTimes, "write_gdx start" = Sys.time())

writeToGdx <- function(file = "pm_magicc_temperatureImpulseResponse", df) {
  df$tall <- factor(df$tall)
  df$tall1 <- factor(df$tall1)
  attr(df, which = "symName") <- "pm_temperatureImpulseResponse"
  attr(df, which = "domains") <- c("tall", "tall")
  attr(df, which = "domInfo") <- "full"

  wgdx.lst(file, df, squeeze = FALSE)
}

# write to GDX:
writeToGdx("pm_magicc_temperatureImpulseResponse", oupt)
cat(date(), "climateAssessmentImpulseResponse.R: Wrote results to 'pm_magicc_temperatureImpulseResponse.gdx'\n")
runTimes <- c(runTimes, "write_gdx end" = Sys.time())

#################### CLEAN UP WORKERS FOLDER ######################################################

# openscm_runner does not remnove up temp dirs. Do this manually since we keep running into file ownership issues
if (dir.exists(cfg$workersDir)) {
  # Check if directory is empty
  if (length(list.files(cfg$workersDir)) == 0) {
    # Remove directory. Option recursive must be TRUE for some reason, otherwise unlink won't do its job
    unlink(cfg$workersDir, recursive = TRUE)
  }
}
cat(date(), "climateAssessmentImpulseResponse.R: Removed workers folder\n", file = cfg$logFile, append = TRUE)

#################### RUNTIME REPORT ###############################################################

cat(
  date(), " climateAssessmentImpulseResponse.R: Run times in secs:\n", runTimeReport(runTimes, prefix = "  "), "\n",
  sep = "", file = cfg$logFile, append = TRUE
)
cat(date(), "climateAssessmentImpulseResponse.R: Done!\n", file = cfg$logFile, append = TRUE)