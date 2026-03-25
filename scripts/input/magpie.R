
# Mapping of MAgPIE variables to REMIND variables
# If you change the mapping, check whether the structure of the gdx object in “getMagpieData” (see below) needs to be adjusted.
mag2rem <- tibble::tribble(
    ~mag                                                                             ,   ~enty                        ,   ~factorMag2Rem  ,   ~parameter                ,
    'Demand|Bioenergy|2nd generation|++|Bioenergy crops'                             ,   NA                           ,   1/31.536        ,   'pm_pebiolc_demandmag'    ,
    'Costs Accounting|Costs without incentives'                                      ,   NA                           ,   1/1000/1000     ,   'p26_totLUcost_coupling'  ,
    'Prices|Bioenergy'                                                               ,   NA                           ,   0.0315576       ,   'p30_pebiolc_pricemag'    ,
    'Emissions|CO2|Land|+|Land-use Change'                                           ,   'co2luc'                     ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|+|Deforestation'                             ,   'co2lucPos'                  ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|+|Forest degradation'                        ,   'co2lucPos'                  ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|+|Other land conversion'                     ,   'co2lucPos'                  ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|+|Wood Harvest'                              ,   'co2lucPos'                  ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Peatland|+|Positive'                         ,   'co2lucPos'                  ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Peatland|+|Negative'                         ,   'co2lucNegIntentPeat'        ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Regrowth|+|CO2-price AR'                     ,   'co2lucNegIntentAR'          ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Regrowth|+|NPI_NDC AR'                       ,   'co2lucNegIntentAR'          ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Regrowth|+|Cropland Tree Cover'              ,   'co2lucNegIntentAgroforestry',   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Regrowth|+|Other Land'                       ,   'co2lucNegUnintent'          ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Regrowth|+|Secondary Forest'                 ,   'co2lucNegUnintent'          ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Regrowth|+|Timber Plantations'               ,   'co2lucNegUnintent'          ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Residual|+|Positive'                         ,   'co2lucPos'                  ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Residual|+|Negative'                         ,   'co2lucNegUnintent'          ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Soil|++|Emissions'                           ,   'co2lucPos'                  ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Soil|Cropland management|+|Withdrawals'      ,   'co2lucNegUnintent'          ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Soil|Land Conversion|+|Withdrawals'          ,   'co2lucNegUnintent'          ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Soil|Soil Carbon Management|+|Withdrawals'   ,   'co2lucNegIntentSCM'         ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Timber|+|Storage in HWP'                     ,   'co2lucNegIntentTimber'      ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|CO2|Land|Land-use Change|Timber|+|Release from HWP'                   ,   'co2lucPos'                  ,   1/1000*12/44    ,   'f_macBaseMagpie_coupling',
    'Emissions|N2O|Land|Agriculture|+|Animal Waste Management'                       ,   'n2oanwstm'                  ,   28/44           ,   'f_macBaseMagpie_coupling',
    'Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Inorganic Fertilizers'      ,   'n2ofertin'                  ,   28/44           ,   'f_macBaseMagpie_coupling',
    'Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Manure applied to Croplands',   'n2oanwstc'                  ,   28/44           ,   'f_macBaseMagpie_coupling',
    'Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Decay of Crop Residues'     ,   'n2ofertcr'                  ,   28/44           ,   'f_macBaseMagpie_coupling',
    'Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Soil Organic Matter Loss'   ,   'n2ofertsom'                 ,   28/44           ,   'f_macBaseMagpie_coupling',
    'Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Pasture'                    ,   'n2oanwstp'                  ,   28/44           ,   'f_macBaseMagpie_coupling',
    'Emissions|N2O|Land|+|Peatland'                                                  ,   'n2opeatland'                ,   28/44           ,   'f_macBaseMagpie_coupling',
    'Emissions|CH4|Land|Agriculture|+|Rice'                                          ,   'ch4rice'                    ,   1               ,   'f_macBaseMagpie_coupling',
    'Emissions|CH4|Land|Agriculture|+|Animal waste management'                       ,   'ch4anmlwst'                 ,   1               ,   'f_macBaseMagpie_coupling',
    'Emissions|CH4|Land|Agriculture|+|Enteric fermentation'                          ,   'ch4animals'                 ,   1               ,   'f_macBaseMagpie_coupling',
    'Emissions|CH4|Land|+|Peatland'                                                  ,   'ch4peatland'                ,   1               ,   'f_macBaseMagpie_coupling')


# Delete entries in stack that contain needle and append new
.setgdxcopy <- function(needle,stack,new){
  matches <- grepl(needle,stack)
  out <- c(stack[!matches],new)
  return(out)
}

# Returns TRUE if fullname ends with extension (eg. if "C_SSP2-Base/fulldata.gdx" ends with "fulldata.gdx")
# AND if the file given in fullname exists.
.isFileAndAvailable <- function(fullname, extension) {
  isTRUE(stringr::str_sub(fullname, -nchar(extension), -1) == extension) &&
    file.exists(fullname)
}

createREMINDReporting <- function(gdx) {
  # Record the time when the preparation for MAgPIE starts in runtime.log
  write(paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "convGDX2MIF_REMIND2MAgPIE", NashIteration, sep = ","), file = paste0("runtime.log"), append = TRUE)
  # Create reduced REMIND reporting
  message(round(Sys.time()), " Generating reduced REMIND reporting for MAgPIE")
  if(!file.exists(gdx)) stop("The MAgPIE coupling script 'magpie.R' could not find a REMIND fulldata.gdx file:", gdx)
  scenario <- lucode2::getScenNames(".")
  remind2::convGDX2MIF_REMIND2MAgPIE(gdx = gdx, file = paste0("REMIND_rem2mag-", i,".mif"), scenario = scenario, extraData = "reporting")
  message(round(Sys.time()), " Finished reporting")
  return(file.path(cfg$remind_folder, cfg$results_folder, paste0("REMIND_rem2mag-", i,".mif")))
}

runMAgPIE <- function(pathToRemindReport) {
  # Record the time when MAgPIE starts in runtime.log
  write(paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "MAgPIE", NashIteration, sep = ","), file = paste0("runtime.log"), append = TRUE)
  
  # Switch to MAgPIE main folder
  message(round(Sys.time()), " Preparing MAgPIE")
  message("                    Switching from REMIND ", getwd())
  message("                                to MAgPIE ", cfg$path_magpie)
  withr::with_dir(cfg$path_magpie,{
    source("scripts/start_functions.R")

    runname <- gsub("output\\/", "", cfg$results_folder)
    cfg$cfg_mag$results_folder <- paste0("output/",runname,"-mag-",i)
    cfg$cfg_mag$title          <- paste0(runname,"-mag-",i)
    cfg$cfg_mag$path_to_report_bioenergy <- pathToRemindReport
    # Set path for GHG prices only if path_to_report_ghgprices is NA. This can only be the case in the first 
    # Nash iteration. In all later iterations it will not be NA anymore since they inherit it from the preceding
    # iteration. If in the first iteration path_to_report_ghgprices is not NA (path to external mif) nothing 
    # will be changed and MAgPIE will thus use the GHG prices from the externel path.
    if (is.na(cfg$cfg_mag$path_to_report_ghgprices)) cfg$cfg_mag$path_to_report_ghgprices <- pathToRemindReport

    # ---------------- MAgPIE empty -------------------------------
    # Needs to be done once per scenario actually. Thus, could be moved to start.R
    # However, so far MAgPIE 'start_functions.R' only needs to be sourced here and
    # not in start.R. So to avoid also sourcing it there, this code block stays here.
    if (cfg$magpie_empty) {
      # Find latest fulldata.gdx from automated model test (AMT) runs
      amtRunDirs <- list.files("/p/projects/landuse/tests/magpie/output",
                              pattern = "default_\\d{4}-\\d{2}-\\d{2}_\\d{2}\\.\\d{2}.\\d{2}",
                              full.names = TRUE)
      fullDataGdxs <- file.path(amtRunDirs, "fulldata.gdx")
      latestFullData <- sort(fullDataGdxs[file.exists(fullDataGdxs)], decreasing = TRUE)[[1]]
      cfg$cfg_mag <- configureEmptyModel(cfg$cfg_mag, latestFullData)  # defined in start_functions.R
      # also configure magpie to only run the reportings necessary for coupling
      # the other reportings are pointless anyway with an empty model
      cfg$cfg_mag$output <- c("extra/reportMAgPIE2REMIND")
    }

    # ----------------------------------------------------------------
    if (!is.null(renv::project())) {
      message("                    Using REMIND's renv.lock for MAgPIE")
      cfg$cfg_mag$renv_lock <- normalizePath(file.path(cfg$remind_folder, cfg$results_folder, "renv.lock"))
    }

    # Providing MAgPIE with gdx from last iteration's solution only for time steps >= cfg$gms$cm_startyear
    # For years prior to cfg$gms$cm_startyear MAgPIE output has to be identical across iterations.
    # Because gdxes might slightly lead to a different solution exclude gdxes for the fixing years.
    if (i > 1) {
      message("                    Copying MAgPIE gdx files from previous iteration")
      gdxlist <- paste0("output/", runname, "-mag-", i-1, "/magpie_y", seq(cfg$gms$cm_startyear,2150,5), ".gdx")
      cfg$cfg_mag$files2export$start <- .setgdxcopy(".gdx",cfg$cfg_mag$files2export$start,gdxlist)
    }
    
    # Save the same (potentially updated) elements that were loaded to make MAgPIE paths accessible for getRunStatus
    save(list = elementsLoaded, file = file.path(cfg$remind_folder, cfg$results_folder, "config.Rdata"))

    # Start MAgPIE
    message(round(Sys.time()), " Starting MAgPIE\n                    with  Report = ", pathToRemindReport, "\n                          Folder = ", cfg$cfg_mag$results_folder)
    outfolder_mag <- start_run(cfg$cfg_mag, codeCheck = FALSE)
    pathToMagpieReport <- file.path(cfg$path_magpie, outfolder_mag, "report.mif")
    message(round(Sys.time()), " MAgPIE finished")

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
    message("                    Switching from MAgPIE ", getwd())
    message("                           back to REMIND ", file.path(cfg$remind_folder, cfg$results_folder), "\n")
    return(pathToMagpieReport)
  })
}

# Transfer coupling variables from MAgPIE report to magpieData.gdx read by REMIND between the Nash iterations
getMagpieData <- function(path_to_report = "report.mif", mapping) {
  
  require(gamstransfer, quietly = TRUE, warn.conflicts = FALSE)
  require(quitte,       quietly = TRUE, warn.conflicts = FALSE)
  require(dplyr,        quietly = TRUE, warn.conflicts = FALSE)
  require(readr,        quietly = TRUE, warn.conflicts = FALSE)  
  
  # ---- Record runtime when the data transfer from MAgPIE to REMIND starts in runtime.log ----

  write(paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "getMagpieData", NashIteration, sep = ","), file = paste0("runtime.log"), append = TRUE)
  message(round(Sys.time()), " Transferring MAgPIE data")
  message("                    from ", path_to_report)
  message("                      to ./magpieData.gdx")
  
  # ---- Read and prepare MAgPIE data ----
  
  mag <- quitte::read.quitte(path_to_report, check.duplicates = FALSE)
  
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
    mutate(value = value * factorMag2Rem)                 |> # apply unit conversion
    group_by(period, region, enty, parameter)             |> # define groups for summation
    summarise(value = sum(value), .groups = "drop")       |> # sum MAgPIE emissions (variable) that have the same enty in remind
    rename(ttot = period, regi = region)                  |> # use REMIND set names 
    filter(, regi != "World", between(ttot, 2005, 2150))  |> # keep REMIND time horizon and remove World region
    select(regi, ttot, enty, parameter, value)               # keep only columns required for import to REMIND

  
  # ---- Start creating objects that will be written to gdx ----
  
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

# Obtain number of MAgPIE iteration and Nash iteration passed to this script by GAMS
args <- commandArgs(trailingOnly = TRUE)
i <- as.numeric(args[1])
NashIteration <- as.numeric(args[2])

message("\n", round(Sys.time()), " ### MAgPIE-COUPLING ###")
message("                    MAgPIE iteration ", i)
message("                    Nash   iteration ", NashIteration)

# Rename gdx from previous MAgPIE iteration so that REMIND can only continue if a new one could be successfully created
if(file.exists("magpieData.gdx")) file.rename("magpieData.gdx", paste0("magpieData-", i-1,".gdx")) 

# Load REMIND config
elementsLoaded <- load("config.Rdata")

if (is.null(cfg$continueFromHere) || NashIteration > 1) {
  # Regular magpie iteration
  pathToRemindReport <- createREMINDReporting(gdx = "fulldata.gdx")
  pathToMagpieReport <- runMAgPIE(pathToRemindReport)
  
} else if (names(cfg$continueFromHere) %in% "full") {
  # No regular magpie iteration
  # Continue from an external REMIND fulldata.gdx
  message(round(Sys.time()), " Continuing with createREMINDReporting using ", cfg$continueFromHere)
  pathToRemindReport <- createREMINDReporting(gdx = cfg$continueFromHere)
  pathToMagpieReport <- runMAgPIE(pathToRemindReport)

} else if (names(cfg$continueFromHere) %in% "runMAgPIE") {
  # No regular magpie iteration 
  # Continue from an external REMIND mif
  message(round(Sys.time()), " Continuing with runMAgPIE using ", cfg$continueFromHere)
  pathToRemindReport <- cfg$continueFromHere
  pathToMagpieReport <- runMAgPIE(pathToRemindReport)

} else if (names(cfg$continueFromHere) %in% "getMagpieData") {
  # No regular magpie iteration
  # Continue from an external MAgPIE mif
  message(round(Sys.time()), " Continuing with getMagpieData using ", cfg$continueFromHere)
  pathToMagpieReport <- cfg$continueFromHere
}

# Write pathToMagpieReport to cfg, so reporting.R can find the MAgPIE report and append it to the REMIND reporting
cfg$pathToMagpieReport <- pathToMagpieReport

# In any case transfer MAgPIE data from report to magpieData.gdx
getMagpieData(path_to_report = pathToMagpieReport, mapping = mag2rem)

# Save the same elements that were loaded (they may have been updated in the meantime)
save(list = elementsLoaded, file = "config.Rdata")

message("\n", round(Sys.time()), " Continuing with REMIND Nash iteration")