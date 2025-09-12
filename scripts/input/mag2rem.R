
getMagpieData <- function(path_to_report = "report.mif", mapping = "magppingMAgPIE2REMIND.csv", var_luc = "raw") {
  
  require(gamstransfer, quietly = TRUE, warn.conflicts = FALSE)
  require(quitte,       quietly = TRUE, warn.conflicts = FALSE)
  require(dplyr,        quietly = TRUE, warn.conflicts = FALSE)
  require(readr,        quietly = TRUE, warn.conflicts = FALSE)  
  
  # ---- Define functions ----
  
  # apply eval(parse() to each element of x. 
  # Example: converts the string "1/1000*12/44" to the number 0.0002727273
  calcFromString <- function(x){
    sapply(x, function(i){
      eval(parse(text = i))
    })
  }
  
  # ---- Read mapping of MAgPIE variables to REMIND variables ----
  
  mapping <- readr::read_csv2(mapping)
  #mapping$magName <- gsub(" \\(.*\\)$","",mapping$magName) # remove unit
  
  # ---- Read and prepare MAgPIE data ----
  
  mag <- quitte::read.quitte(path_to_report, check.duplicates = FALSE)
  
  if (var_luc == "smooth") {
    # do nothing and use variable names as defined above
  } else if (var_luc == "raw") {
    # add RAW to variable names
    mapping$mag <- gsub("Emissions|CO2|Land","Emissions|CO2|Land RAW", mapping$mag, fixed = TRUE)
  } else {
    stop(paste0("Unkown setting for 'var_luc': `", var_luc, "`. Only `smooth` or `raw` are allowed."))
  }
  
  # Stop if variables are missing
  variablesMissing <- ! mapping$mag %in% mag$variable
  if (any(variablesMissing)) {
    stop("The following variables defined in the coupling interface could not be found in the MAgPIE report: ", 
         mapping$mag[variablesMissing])
  }
  
  rem <- mag |>
    inner_join(mapping, by = c("variable" = "mag"),          # combine tables keeping relevant variables only
               relationship = "many-to-one",                 # each row in x (mag) matches at most 1 row in y (mapping)
               unmatched = c("drop", "error"))            |> # drop rows from x that are not in y, error: all rows in y must be in x
    mutate(factorMag2Rem = calcFromString(factorMag2Rem)) |> # calculate the conversion factor given as string
    mutate(value = value * factorMag2Rem)                 |> # apply unit conversion
    group_by(period, region, enty, parameter)             |> # define groups for summation
    summarise(value = sum(value))                         |> # sum MAgPIE emissions (variable) that have the same enty in remind
    ungroup()                                             |> # Groups are maintained in dplyr. You can't select off grouping variables (but we need to further down, so we need to ungroup)
    rename(ttot = period, regi = region)                  |> # use REMIND set names 
    filter(, regi != "World", between(ttot, 2005, 2150))  |> # keep REMIND time horizon and remove World region
    select(regi, ttot, enty, parameter, value)               # keep only columns required for import to REMIND

  
  # ---- Create gdx ----
  
  # ---- Define SETS ----
  
  m <- Container$new()
  
  regi <- m$addSet(
    "regi",
    records = unique(rem$regi),
    description = "regions"
  )
  
  ttot <- m$addSet(
    "ttot",
    records = unique(rem$ttot),
    description = "years"
  )
  
  emiMacMagpie <- m$addSet(
    "emiMacMagpie",
    records = mapping |>
              filter(parameter == "f_macBaseMagpie_coupling") |>
              select(enty) |>
              unique(),
    description = "emission types coming from MAgPIE"
  )
  
  # ---- Define PARAMETERS ----
  
  f_macBaseMagpie_coupling <- m$addParameter(
    "f_macBaseMagpie_coupling",
    domain = c(ttot, regi, emiMacMagpie),
    records = rem |>
              filter(parameter == "f_macBaseMagpie_coupling") |>
              select(ttot, regi, enty, value) |>
              rename(emiMacMagpie = enty),
    description = "emissions from MAgPIE"
  )
  
  p30_pebiolc_pricemag <- m$addParameter(
    "p30_pebiolc_pricemag",
    domain = c(ttot, regi),
    records = rem |>
              filter(parameter == "p30_pebiolc_pricemag") |>
              select(ttot, regi, value),
    description = "bioenergy price from MAgPIE"
  )
    
  pm_pebiolc_demandmag <- m$addParameter(
    "pm_pebiolc_demandmag",
    domain = c(ttot, regi),
    records = rem |> 
              filter(parameter == "pm_pebiolc_demandmag") |> 
              select(ttot, regi, value),
    description = "demand for bioenergy in MAgPIE from which the prices result"
  )
  
  p26_totLUcost_coupling <- m$addParameter(
    "p26_totLUcost_coupling",
    domain = c(ttot, regi),
    records = rem |> 
              filter(parameter == "p26_totLUcost_coupling") %>% 
              select(ttot, regi, value),
    description = "total production costs from MAgPIE without costs for GHG"
  )
  
  # ---- Write to gdx file ----
  
  m$write("magpieData.gdx")
}

# Coupling REMIND-MAgPIE

# run REMIND reporting and give path to mif to MAgPIE
scenario <- lucode2::getScenNames(".")
pathToRemindReport <- "REMIND_rem2mag.mif"
message("\n### Start generating short REMIND reporting for MAgPIE - ", round(Sys.time()))
if(!file.exists("fulldata.gdx")) stop("The MAgPIE coupling script 'mag2rem.R' could not find a REMIND fulldata.gdx file!")
remind2::convGDX2MIF_REMIND2MAgPIE(gdx = "fulldata.gdx", file = pathToRemindReport, scenario = scenario)

i <- as.numeric(commandArgs(trailingOnly = TRUE))
write(paste(format(Sys.time(), "%Y-%m-%d_%H.%M.%S"), i), file = "iteration.log", append = TRUE)

load("config.Rdata")
cfg_rem <- cfg
rm(cfg)

# define path to MAgPIE # move to start.R
path_remind <- cfg_rem$remind_folder
path_magpie <- normalizePath(file.path(path_remind, "magpie"), mustWork = FALSE)
if (! dir.exists(path_magpie)) path_magpie <- normalizePath(file.path(path_remind, "..", "magpie"), mustWork = FALSE)

# - load from REMIND config in the REMIND run folder:
#   - MAgPIE settings
# preliminary: since at the moment there is no MAgPIE cfg available here, load MAgPIE default
# ---------------- move to start.R -------------------------------
  source(file.path(path_magpie, "config", "default.cfg")) # retrieve MAgPIE settings
  cfg_mag <- cfg
  rm(cfg)
  cfg_mag$sequential <- TRUE
  cfg_mag$force_replace <- TRUE
  # if provided use ghg prices for land (MAgPIE) from a different REMIND run than the one MAgPIE runs coupled to
  use_external_ghgprices <- ifelse(is.na(cfg_mag$path_to_report_ghgprices), FALSE, TRUE)
  # always select 'coupling' scenario
  cfg_mag <- setScenario(cfg_mag, "coupling", scenario_config = file.path(path_magpie, "config", "scenario_config.csv"))

# ----------------------------------------------------------------

message("### COUPLING ### Preparing MAgPIE")
message("### COUPLING ### Set working directory from ", getwd())
setwd(path_magpie)
message("                                         to ", getwd(), "\n")
source("scripts/start_functions.R")
runname <- gsub("output\\/", "", cfg$results_folder)
cfg_mag$results_folder <- paste0("output/",runname,"-mag-",i)
cfg_mag$title          <- paste0(runname,"-mag-",i)

if (!is.null(renv::project())) {
  cfg_mag$renv_lock <- normalizePath(file.path(path_remind, cfg_rem$results_folder, "renv.lock"))
}

# Providing MAgPIE with gdx from last iteration's solution only for time steps >= cfg_rem$gms$cm_startyear
# For years prior to cfg_rem$gms$cm_startyear MAgPIE output has to be identical across iterations.
# Because gdxes might slightly lead to a different solution exclude gdxes for the fixing years.
if (i > 1) {
  message("### COUPLING ### Copying MAgPIE gdx files from previous iteration")
  gdxlist <- paste0("output/", runname, "-mag-", i-1, "/magpie_y", seq(cfg_rem$gms$cm_startyear,2150,5), ".gdx")
  cfg_mag$files2export$start <- .setgdxcopy(".gdx",cfg_mag$files2export$start,gdxlist)
}

message("### COUPLING ### MAgPIE will be started with\n    Report = ", pathToRemindReport, "\n    Folder = ", cfg_mag$results_folder)
cfg_mag$path_to_report_bioenergy <- pathToRemindReport
# if no different mif was set for GHG prices use the same as for bioenergy
if(! use_external_ghgprices) cfg_mag$path_to_report_ghgprices <- pathToRemindReport
########### START MAGPIE #############
outfolder_mag <- start_run(cfg_mag, codeCheck=FALSE)
######################################
message("### COUPLING ### MAgPIE output was stored in ", outfolder_mag)
pathToMagpieReport <- file.path(path_magpie, outfolder_mag, "report.mif")

# Checking whether MAgPIE is optimal in all years
file_modstat <- file.path(outfolder_mag, "glo.magpie_modelstat.csv")
if (file.exists(file_modstat)) {
  modstat_mag <- read.csv(file_modstat, stringsAsFactors = FALSE, row.names=1, na.strings="")
} else {
  modstat_mag <- readGDX(file.path(outfolder_mag, "fulldata.gdx"), "p80_modelstat", "o_modelstat", format="first_found")
}

if (!all((modstat_mag == 2) | (modstat_mag == 7)))
  stop("Iteration stopped! MAgPIE modelstat is not 2 or 7 for all years.\n")

# what else should be saved?
# save(cfg_rem, cfg_mag, pathToMagpieReport, file = "config.Rdata")
setwd(cfg_rem$results_folder)

getMagpieData(path_to_report = pathToMagpieReport)
