
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
              filter(parameter == "f_macBaseMagpie") |>
              select(enty) |>
              unique(),
    description = "emission types coming from MAgPIE"
  )
  
  # ---- Define PARAMETERS ----
  
  f_macBaseMagpie <- m$addParameter(
    "f_macBaseMagpie",
    domain = c(ttot, regi, emiMacMagpie),
    records = rem |>
              filter(parameter == "f_macBaseMagpie") |>
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
  
  p26_totLUcost <- m$addParameter(
    "p26_totLUcost",
    domain = c(ttot, regi),
    records = rem |> 
              filter(parameter == "p26_totLUcost") %>% 
              select(ttot, regi, value),
    description = "total production costs from MAgPIE without costs for GHG"
  )
  
  # ---- Write to gdx file ----
  
  m$write("magpieData.gdx")
}

# Coupling REMIND-MAgPIE

# run REMIND reporting and give path to mif to MAgPIE
# - remind2::convGDX2MIF_REMIND2MAgPIE(gdx = "fulldata.gdx", file = "REMIND_rem2mag.mif")

#load("config.Rdata")

cfg <- list()
cfg$pathToMagpieReport <- "/p/projects/remind/runs/REMIND-MAgPIE-2025-04-24/magpie/output/C_SSP2-NPi2025-mag-4/report.mif"
cfg$pathToMagpieReport <- "~/Transferfolder/report.mif"
cfg$var_luc <- "raw"

# - load from REMIND config in the REMIND run folder:
#   - path_to_magpie
#   - MAgPIE settings
#   - run name used for MAgPIE run
# - start MAgPIE
    # outfolder_mag <- start_run(cfg_mag, codeCheck=FALSE)
# - obtain path to individual MAgPIE report
    # report_mag <- file.path(path_magpie, outfolder_mag, "report.mif")
    
# runMAgPIE(cfg)

getMagpieData(
  path_to_report = cfg$pathToMagpieReport, 
  mapping        = "config/mappingMAgPIE2REMIND.csv",
  var_luc        = cfg$var_luc)
