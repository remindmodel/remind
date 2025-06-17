# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

getReportData <- function(path_to_report,inputpath_mag="magpie_40",inputpath_acc="costs",var_luc="smooth") {
  
  require(dplyr,  quietly = TRUE, warn.conflicts = FALSE)
  require(quitte, quietly = TRUE, warn.conflicts = FALSE)
  require(readr,  quietly = TRUE, warn.conflicts = FALSE)
  
  magData <- quitte::read.quitte(path_to_report, check.duplicates = FALSE)
  
  .emissions <- function(mag, mapping, file, var_luc, path_to_report) {

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
      stop("The following variables could not be found in the MAgPIE report: ", mapping$mag[variablesMissing])
    }
    
    write(paste0("*** ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " Data transferred from ", path_to_report), file = file)
    
    rem <- mag |>
      inner_join(mapping, by = c("variable" = "mag"),       # combine tables keeping relevant variables only
                 relationship = "many-to-one",              # each row in x (mag) matches at most 1 row in y (mapping)
                 unmatched = c("drop", "error"))         |> # drop rows from x that are not in y, error: all rows in y must be in x
      mutate(value = value * factorMag2Rem)              |> # apply unit conversion
      group_by(period, region, rem)                      |> # define groups for summation
      summarise(value = sum(value))                      |> # sum MAgPIE emissions (mag) that have the same enty in remind (rem)
      relocate(period, .before = region)                 |> # put period in front of region for proper order for GAMS import
      filter(period >= 2005, region != "World")          |> # keep REMIND time horizon and remove World region
      readr::write_csv(file = file, col_names = FALSE, append = TRUE)
    
    write(paste0("*** EOF ", file ," ***"), file = file, append = TRUE)
    
    return(rem)
  }

  .convertAndWrite <- function(mag, mapping, file, path_to_report) {
    
    # Stop if variables are missing
    variablesMissing <- ! mapping$mag %in% mag$variable
    if (any(variablesMissing)) {
      stop("The following variables could not be found in the MAgPIE report: ", mapping$mag[variablesMissing])
    }

    write(paste0("*** ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " Data transferred from ", path_to_report), file = file)

    mag <- mag |>
      inner_join(mapping, by = c("variable" = "mag"),       # combine tables keeping relevant variables only
                 relationship = "many-to-one",              # each row in x (mag) matches at most 1 row in y (mapping)
                 unmatched = c("drop", "error"))         |> # drop rows from x that are not in y, error: all rows in y must be in x
      mutate(value = value * factorMag2Rem)              |> # apply unit conversion
      mutate(value = round(value, digits = 11))          |> # limit number of decimals
      relocate(period, .before = region)                 |> # put period in front of region for proper order for GAMS import
      filter(period >= 2005, region != "World")          |> # keep REMIND time horizon and remove World region
      select(period, region, value)                      |> # keep relevant columns only
      tidyr::pivot_wider(names_from = region, values_from = value) |> # make 2D-table
      readr::write_csv(file = file, col_names = TRUE, append = TRUE)

    write(paste0("*** EOF ", file ," ***"), file = file, append = TRUE)

    return(mag)
  }
  
  ### ---- Emissions ----
  
  # define three columns of dataframe:
  #   mag (magpie emission names)
  #   rem (remind emission names)
  #   factorMag2Rem (factor for converting magpie units into remind units)
  #   nitrogen: 28/44,        # Tg N2O/yr =  Mt N2O/yr -> Mt N/yr
  #   carbon:   1/1000*12/44, # Mt CO2/yr -> Gt CO2/yr -> Gt C/yr
  
  mag2rem <- tribble(
    ~mag,                                                                             ~rem,                       ~factorMag2Rem,
    "Emissions|CO2|Land|+|Land-use Change"                                            , "co2luc"                  ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|+|Deforestation"                              , "co2lucPos"               ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|+|Forest degradation"                         , "co2lucPos"               ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|+|Other land conversion"                      , "co2lucPos"               ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|+|Wood Harvest"                               , "co2lucPos"               ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Peatland|+|Positive"                          , "co2lucPos"               ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Peatland|+|Negative"                          , "co2lucNegIntentPeat"     ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Regrowth|+|CO2-price AR"                      , "co2lucNegIntentAR"       ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Regrowth|+|NPI_NDC AR"                        , "co2lucNegIntentAR"       ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Regrowth|+|Cropland Tree Cover"               , "co2lucNegIntentAgroforestry",1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Regrowth|+|Other Land"                        , "co2lucNegUnintent"       ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Regrowth|+|Secondary Forest"                  , "co2lucNegUnintent"       ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Regrowth|+|Timber Plantations"                , "co2lucNegUnintent"       ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Residual|+|Positive"                          , "co2lucPos"               ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Residual|+|Negative"                          , "co2lucNegUnintent"       ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Soil|++|Emissions"                            , "co2lucPos"               ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Soil|Cropland management|+|Withdrawals"       , "co2lucNegUnintent"       ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Soil|Land Conversion|+|Withdrawals"           , "co2lucNegUnintent"       ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Soil|Soil Carbon Management|+|Withdrawals"    , "co2lucNegIntentSCM"      ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Timber|+|Storage in HWP"                      , "co2lucNegIntentTimber"   ,   1/1000*12/44,
    "Emissions|CO2|Land|Land-use Change|Timber|+|Release from HWP"                    , "co2lucPos"               ,   1/1000*12/44,
    "Emissions|N2O|Land|Agriculture|+|Animal Waste Management"                        , "n2oanwstm"               ,   28/44,
    "Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Inorganic Fertilizers"       , "n2ofertin"               ,   28/44,
    "Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Manure applied to Croplands" , "n2oanwstc"               ,   28/44,
    "Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Decay of Crop Residues"      , "n2ofertcr"               ,   28/44,
    "Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Soil Organic Matter Loss"    , "n2ofertsom"              ,   28/44,
    "Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Pasture"                     , "n2oanwstp"               ,   28/44,
    "Emissions|N2O|Land|+|Peatland"                                                   , "n2opeatland"             ,   28/44,
    "Emissions|CH4|Land|Agriculture|+|Rice"                                           , "ch4rice"                 ,   1,
    "Emissions|CH4|Land|Agriculture|+|Animal waste management"                        , "ch4anmlwst"              ,   1,
    "Emissions|CH4|Land|Agriculture|+|Enteric fermentation"                           , "ch4animals"              ,   1,
    "Emissions|CH4|Land|+|Peatland"                                                   , "ch4peatland"             ,   1
  )
  
  emi <- .emissions(magData, mag2rem, file = paste0("./core/input/f_macBaseMagpie_coupling.cs4r"), var_luc, path_to_report)
  
  ### ---- Bioenergy prices ----
  
  mag2rem <- tribble(
    ~mag,              ~factorMag2Rem,
    "Prices|Bioenergy", 0.0315576) # US$2017/GJ to US$2017/Wa

  pricBio <- .convertAndWrite(magData, mag2rem, file = paste0("./modules/30_biomass/",inputpath_mag,"/input/p30_pebiolc_pricemag_coupling.csv"), path_to_report)
  
  ### ---- Bioenergy production ----
  
  mag2rem <- tribble(
    ~mag,                                                ~factorMag2Rem,
    "Demand|Bioenergy|2nd generation|++|Bioenergy crops", 1/31.536) # EJ to TWa
    
  prodBio <- .convertAndWrite(magData, mag2rem, file = paste0("./modules/30_biomass/",inputpath_mag,"/input/pm_pebiolc_demandmag_coupling.csv"), path_to_report)

  ### ---- Agricultural costs ----

  mag2rem <- tribble(
    ~mag,                      ~factorMag2Rem,
    "Costs Without Incentives", 1/1000/1000) # 10E6 US$2017 to 10E12 US$2017

  cost <- .convertAndWrite(magData, mag2rem, file = paste0("./modules/26_agCosts/",inputpath_acc,"/input/p26_totLUcost_coupling.csv"), path_to_report)
  
  ### ---- Agricultural trade ----
  
  mag2rem <- tribble(
    ~mag,                      ~factorMag2Rem,
    "Costs Accounting|+|Trade", 1/1000/1000) # 10E6 US$2017 to 10E12 US$2017
  
  # needs to be updated to MAgPIE 4 interface
  # trade <- .convertAndWrite(magData, mag2rem, file = paste0("./modules/26_agCosts/",inputpath_acc,"/input/trade_bal_reg.rem.csv"), path_to_report)
  
  ### ---- return ----

  #tmp <- rbind(emi, pricBio, prodBio, cost)
  #return(invisible(tmp))
}
