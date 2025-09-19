
# Transfer coupling variables from MAgPIE report to magpieData.gdx read by REMIND between the Nash iterations
getMagpieData <- function(path_to_report = "report.mif", mapping = "mappingMAgPIE2REMIND.csv", var_luc = "raw") {
  
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
  
  mapping <- readr::read_csv2(mapping, col_types = cols(), show_col_types = FALSE)
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

# Delete entries in stack that contain needle and append new
.setgdxcopy <- function(needle,stack,new){
  matches <- grepl(needle,stack)
  out <- c(stack[!matches],new)
  return(out)
}

# Obtain number of MAgPIE iteration passed to this script by GAMS
i <- as.numeric(commandArgs(trailingOnly = TRUE))

# Rename gdx from previous MAgPIE iteration so that REMIND can only continue if a new one could be successfully created
if(file.exists("magpieData.gdx")) file.rename("magpieData.gdx", paste0("magpieData-", i-1,".gdx")) 

# Log MAgPIE iterations (can be removed late)
write(paste(format(Sys.time(), "%Y-%m-%d_%H.%M.%S"), i), file = "iteration.log", append = TRUE)

# Create reduced REMIND reporting
message("\n### COUPLING ", i, " ### Generating reduced REMIND reporting for MAgPIE - ", round(Sys.time()))
if(!file.exists("fulldata.gdx")) stop("The MAgPIE coupling script 'mag2rem.R' could not find a REMIND fulldata.gdx file!")
scenario <- lucode2::getScenNames(".")
remind2::convGDX2MIF_REMIND2MAgPIE(gdx = "fulldata.gdx", file = "REMIND_rem2mag.mif", scenario = scenario)
message("\nFinished reporting - ", round(Sys.time()))

# Load REMIND config
load("config.Rdata")
cfg_rem <- cfg
rm(cfg)

# Define path to MAgPIE 
# Later: move to start.R
path_remind_run    <- file.path(cfg_rem$remind_folder, cfg_rem$results_folder)
pathToRemindReport <- file.path(cfg_rem$remind_folder, cfg_rem$results_folder, "REMIND_rem2mag.mif")
path_magpie <- normalizePath(file.path(cfg_rem$remind_folder, "magpie"), mustWork = FALSE)
if (! dir.exists(path_magpie)) path_magpie <- normalizePath(file.path(cfg_rem$remind_folder, "..", "magpie"), mustWork = FALSE)

# Switch to MAgPIE main folder
message("### COUPLING ", i, " ### Preparing MAgPIE - ", round(Sys.time()))
message("Set working directory from ", getwd())
message("                      to   ", path_magpie, "\n")
setwd(path_magpie)
source("scripts/start_functions.R")

# preliminary: since at the moment there is no MAgPIE cfg available here, load MAgPIE default
# later: load MAgPIE cfg from REMIND config in the REMIND run folder
source(file.path(path_magpie, "config", "default.cfg"))
cfg_mag <- cfg
rm(cfg)

runname <- gsub("output\\/", "", cfg_rem$results_folder)
cfg_mag$results_folder <- paste0("output/",runname,"-mag-",i)
cfg_mag$title          <- paste0(runname,"-mag-",i)
cfg_mag$path_to_report_bioenergy <- pathToRemindReport
# if no different mif was set for GHG prices use the same as for bioenergy
if(! use_external_ghgprices) cfg_mag$path_to_report_ghgprices <- pathToRemindReport

# ---------------- move to start.R -------------------------------
  cfg_mag$sequential <- TRUE
  cfg_mag$force_replace <- TRUE
  # if provided use ghg prices for land (MAgPIE) from a different REMIND run than the one MAgPIE runs coupled to
  use_external_ghgprices <- ifelse(is.na(cfg_mag$path_to_report_ghgprices), FALSE, TRUE)
  # always select 'coupling' scenario
  cfg_mag <- gms::setScenario(cfg_mag, "coupling", scenario_config = file.path(path_magpie, "config", "scenario_config.csv"))
  
  magpie_empty <- FALSE
  if (magpie_empty) {
    # Find latest fulldata.gdx from automated model test (AMT) runs
    amtRunDirs <- list.files("/p/projects/landuse/tests/magpie/output",
                            pattern = "default_\\d{4}-\\d{2}-\\d{2}_\\d{2}\\.\\d{2}.\\d{2}",
                            full.names = TRUE)
    fullDataGdxs <- file.path(amtRunDirs, "fulldata.gdx")
    latestFullData <- sort(fullDataGdxs[file.exists(fullDataGdxs)], decreasing = TRUE)[[1]]
    cfg_mag <- configureEmptyModel(cfg_mag, latestFullData)  # defined in start_functions.R
    # also configure magpie to only run the reportings necessary for coupling
    # the other reportings are pointless anyway with an empty model
    cfg_mag$output <- c("extra/reportMAgPIE2REMIND")
  }

# ----------------------------------------------------------------

if (!is.null(renv::project())) {
  message("Using REMIND's renv.lock for MAgPIE")
  cfg_mag$renv_lock <- normalizePath(file.path(path_remind_run, "renv.lock"))
}

# Providing MAgPIE with gdx from last iteration's solution only for time steps >= cfg_rem$gms$cm_startyear
# For years prior to cfg_rem$gms$cm_startyear MAgPIE output has to be identical across iterations.
# Because gdxes might slightly lead to a different solution exclude gdxes for the fixing years.
if (i > 1) {
  message("### COUPLING ", i, " ### Copying MAgPIE gdx files from previous iteration")
  gdxlist <- paste0("output/", runname, "-mag-", i-1, "/magpie_y", seq(cfg_rem$gms$cm_startyear,2150,5), ".gdx")
  cfg_mag$files2export$start <- .setgdxcopy(".gdx",cfg_mag$files2export$start,gdxlist)
}

# Start MAgPIE
message("### COUPLING ", i, " ### Starting MAgPIE - ", round(Sys.time()), "\nwith  Report = ", pathToRemindReport, "\n      Folder = ", cfg_mag$results_folder)
outfolder_mag <- start_run(cfg_mag, codeCheck=FALSE)
pathToMagpieReport <- file.path(path_magpie, outfolder_mag, "report.mif")
message("### COUPLING ", i, " ### MAgPIE finished in ", outfolder_mag, " - ", round(Sys.time()))

# Checking whether MAgPIE is optimal in all years
file_modstat <- file.path(outfolder_mag, "glo.magpie_modelstat.csv")
if (file.exists(file_modstat)) {
  modstat_mag <- read.csv(file_modstat, stringsAsFactors = FALSE, row.names=1, na.strings="")
} else {
  modstat_mag <- gdx::readGDX(file.path(outfolder_mag, "fulldata.gdx"), "p80_modelstat", "o_modelstat", format="first_found")
}

if (!all((modstat_mag == 2) | (modstat_mag == 7)))
  stop("Iteration stopped! MAgPIE modelstat is not 2 or 7 for all years.\n")

# Switch back to REMIND run folder
message("### COUPLING ", i, " ### Preparing REMIND")
message("Set working directory from ", getwd())
message("                      to   ", path_remind_run, "\n")
setwd(path_remind_run)

message("### COUPLING ", i, " ### Transferring data from MAgPIE ", pathToMagpieReport, " to REMIND magpieData.gdx - ", round(Sys.time()))
getMagpieData(path_to_report = pathToMagpieReport)
message("\n### COUPLING ", i, " ### Continuing with REMIND Nash iteration - ", round(Sys.time()))

# what else should be saved?
# save(cfg_rem, cfg_mag, pathToMagpieReport, file = "config.Rdata")
