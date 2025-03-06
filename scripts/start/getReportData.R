# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

getReportData <- function(path_to_report,inputpath_mag="magpie_40",inputpath_acc="costs",var_luc="smooth") {
  
  require(dplyr,    quietly = TRUE,warn.conflicts =FALSE)
  require(quitte,   quietly = TRUE,warn.conflicts =FALSE)
  require(readr,    quietly = TRUE,warn.conflicts =FALSE)
  
  .bioenergy_price <- function(mag, file, path_to_report) {
    
    mag2rem <- tribble(
      ~mag,              ~factorMag2Rem,
      "Prices|Bioenergy", 0.0315576 # US$2017/GJ to US$2017/Wa
    )

    rem <- mag |>
      inner_join(mag2rem, by = c("variable" = "mag"))    |> # combine tables keeping relevant variables only
      mutate(value = value * factorMag2Rem)              |> # apply unit conversion
      mutate(value = round(value, digits = 11))          |> # limit number of decimals
      relocate(period, .before = region)                 |> # put period in front of region for proper order for GAMS import
      filter(period >= 2005, region != "World")          |> # keep REMIND time horizon and remove World region
      select(period, region, value)                      |> # keep relevant columns only
      tidyr::pivot_wider(names_from = region, values_from = value) |> # make 2D-table
      readr::write_csv(file = file, col_names = TRUE)
    
    # in the old function NAs used to be filtered. Let's try without and re-introduce if occurring again.
    # out["JPN",is.na(out["JPN",,]),] <- 0
    
    write(paste0("*** EOF ", file ," ***"), file = file, append = TRUE)
    #tidyr::pivot_longer(rem, 2:14, names_to = "region")
    return(rem)
  }

  .bioenergy_production <- function(mag, file, path_to_report) {
    
    mag2rem <- tribble(
      ~mag,                                                ~factorMag2Rem,
      "Demand|Bioenergy|2nd generation|++|Bioenergy crops", 1/31.536 # EJ to TWa
    )
    
    rem <- mag |>
      inner_join(mag2rem, by = c("variable" = "mag"))    |> # combine tables keeping relevant variables only
      mutate(value = value * factorMag2Rem)              |> # apply unit conversion
      mutate(value = round(value, digits = 11))          |> # limit number of decimals
      relocate(period, .before = region)                 |> # put period in front of region for proper order for GAMS import
      filter(period >= 2005, region != "World")          |> # keep REMIND time horizon and remove World region
      select(period, region, value)                      |> # keep relevant columns only
      tidyr::pivot_wider(names_from = region, values_from = value) |> # make 2D-table
      readr::write_csv(file = file, col_names = TRUE)
    
    # in the old function NAs and negative values used to be filtered. Let's try without and re-introduce if occurring again.
    # out["JPN",is.na(out["JPN",,]),] <- 0
    # out[which(out<0)] <- 0 # set negative values to zero since they cause errors in GMAS power function
    
    write(paste0("*** EOF ", file ," ***"), file = file, append = TRUE)
    
    return(rem)
  }
  
  .emissions <- function(mag, file, var_luc, path_to_report) {

    # define three columns of dataframe:
    #   emimag (magpie emission names)
    #   emirem (remind emission names)
    #   factorMag2Rem (factor for converting magpie to remind emissions)
    #   1/1000*28/44, # kt N2O/yr -> Mt N2O/yr -> Mt N/yr
    #   28/44,        # Tg N2O/yr =  Mt N2O/yr -> Mt N/yr
    #   1/1000*12/44, # Mt CO2/yr -> Gt CO2/yr -> Gt C/yr

    mag2rem <- tribble(
      ~emimag,                                                                          ~emirem,                       ~factorMag2Rem,
      "Emissions|CO2|Land|+|Land-use Change                      "                      , "co2luc"                  ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|Regrowth|+|CO2-price AR"                      , "co2lucCDRintentByPrice"  ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|Regrowth|+|NPI_NDC AR"                        , "co2lucCDRintentByReg"    ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|Regrowth|+|Cropland Tree Cover"               , "co2lucCDRintentCropland" ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|Timber|+|Storage in HWP"                      , "co2lucCDRintentTimber"   ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|Regrowth|+|Other Land"                        , "co2lucCDRunintent"       ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|Regrowth|+|Secondary Forest"                  , "co2lucCDRunintent"       ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|Regrowth|+|Timber Plantations"                , "co2lucCDRunintent"       ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|SOM|+|Withdrawals"                            , "co2lucCDRunintent"       ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|+|Deforestation"                              , "co2lucPositive"          ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|+|Other land conversion"                      , "co2lucPositive"          ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|+|Peatland"                                   , "co2lucPositive"          ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|+|Wood Harvest"                               , "co2lucPositive"          ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|SOM|+|Emissions"                              , "co2lucPositive"          ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|Timber|+|Release from HWP"                    , "co2lucPositive"          ,   1/1000*12/44,
      "Emissions|CO2|Land|Land-use Change|+|Residual"                                   , "co2lucResidual"          ,   1/1000*12/44,
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

    if (var_luc == "smooth") {
      # do nothing and use variable names as defined above
    } else if (var_luc == "raw") {
      # add RAW to variable names
      mag2rem$emimag <- gsub("Emissions|CO2|Land","Emissions|CO2|Land RAW", mag2rem$emimag, fixed = TRUE)
    } else {
      stop(paste0("Unkown setting for 'var_luc': `", var_luc, "`. Only `smooth` or `raw` are allowed."))
    }

    rem <- mag |>
      inner_join(mag2rem, by = c("variable" = "emimag")) |> # combine tables keeping relevant variables only
      mutate(value = value * factorMag2Rem)              |> # apply unit conversion
      group_by(period, region, emirem)                   |> # define groups for summation
      summarise(value = sum(value))                      |> # sum MAgPIE emissions (emimag) that have the same enty in remind (emirem)
      relocate(period, .before = region)                 |> # put period in front of region for proper order for GAMS import
      filter(period >= 2005, region != "World")          |> # keep REMIND time horizon and remove World region
      readr::write_csv(file = file, col_names = FALSE)
    
    write(paste0("*** EOF ", file ," ***"), file = file, append = TRUE)
    
    return(rem)
  }
  
  .agriculture_costs <- function(mag, file, path_to_report) {
    
    mag2rem <- tribble(
      ~mag,                      ~factorMag2Rem,
      "Costs Without Incentives", 1/1000/1000 # 10E6 US$2017 to 10E12 US$2017
    )
    
    rem <- mag |>
      inner_join(mag2rem, by = c("variable" = "mag"))    |> # combine tables keeping relevant variables only
      mutate(value = value * factorMag2Rem)              |> # apply unit conversion
      mutate(value = round(value, digits = 11))          |> # limit number of decimals
      relocate(period, .before = region)                 |> # put period in front of region for proper order for GAMS import
      filter(period >= 2005, region != "World")          |> # keep REMIND time horizon and remove World region
      select(period, region, value)                      |> # keep relevant columns only
      tidyr::pivot_wider(names_from = region, values_from = value) |> # make 2D-table
      readr::write_csv(file = file, col_names = TRUE)
    
    # in the old function NAs used to be filtered. Let's try without and re-introduce if occurring again.
    # out["JPN",is.na(out["JPN",,]),] <- 0

    write(paste0("*** EOF ", file ," ***"), file = file, append = TRUE)
    
    return(rem)
  }  
    
  .agriculture_tradebal <- function(mag, file, path_to_report) {
    
    mag2rem <- tribble(
      ~mag,                      ~factorMag2Rem,
      "Costs Accounting|+|Trade", 1/1000/1000 # 10E6 US$2017 to 10E12 US$2017
    )
    
    rem <- mag |>
      inner_join(mag2rem, by = c("variable" = "mag"))    |> # combine tables keeping relevant variables only
      mutate(value = value * factorMag2Rem)              |> # apply unit conversion
      mutate(value = round(value, digits = 11))          |> # limit number of decimals
      relocate(period, .before = region)                 |> # put period in front of region for proper order for GAMS import
      filter(period >= 2005, region != "World")          |> # keep REMIND time horizon and remove World region
      select(period, region, value)                      |> # keep relevant columns only
      tidyr::pivot_wider(names_from = region, values_from = value) |> # make 2D-table
      readr::write_csv(file = file, col_names = TRUE)
    
    # in the old function NAs used to be filtered. Let's try without and re-introduce if occurring again.
    # out["JPN",is.na(out["JPN",,]),] <- 0
    
    write(paste0("*** EOF ", file ," ***"), file = file, append = TRUE)
    
    return(rem)
  }  

  magQuitte <- quitte::read.quitte(path_to_report, check.duplicates = FALSE)

  pricBio  <- .bioenergy_price(     magQuitte, file = paste0("./modules/30_biomass/",inputpath_mag,"/input/p30_pebiolc_pricemag_coupling_new.csv"), path_to_report)
  prodBio  <- .bioenergy_production(magQuitte, file = paste0("./modules/30_biomass/",inputpath_mag,"/input/pm_pebiolc_demandmag_coupling_new.csv"))
  cost     <- .agriculture_costs(   magQuitte, file = paste0("./modules/26_agCosts/",inputpath_acc,"/input/p26_totLUcost_coupling_new.csv"))
  emi      <- .emissions(           magQuitte, file = paste0("./core/input/f_macBaseMagpie_coupling_new.cs4r"), var_luc, path_to_report)
  # needs to be updated to MAgPIE 4 interface
  # trade <- .agriculture_tradebal(magQuitte, file = paste0("./modules/26_agCosts/",inputpath_acc,"/input/trade_bal_reg.rem.csv"), path_to_report)
  
  #tmp <- mbind(pricBio, prodBio, emi, cost)
  #return(invisible(tmp))
}
