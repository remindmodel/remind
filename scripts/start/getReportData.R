# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

getReportData <- function(path_to_report,inputpath_mag="magpie_40",inputpath_acc="costs",var_luc="smooth") {
  
  require(magclass, quietly = TRUE,warn.conflicts =FALSE)
  
  .bioenergy_price <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    if("Demand|Bioenergy|++|2nd generation (EJ/yr)" %in% getNames(mag)) {
      # MAgPIE 4
      out <- mag[,,"Prices|Bioenergy (US$2017/GJ)"]*0.0315576 # with transformation factor from US$2017/GJ to US$2017/Wa
    } else {
      # MAgPIE 3
      out <- mag[,,"Price|Primary Energy|Biomass (US$2017/GJ)"]*0.0315576 # with transformation factor from US$2017/GJ to US$2017/Wa
    }
    out["JPN",is.na(out["JPN",,]),] <- 0
    tmp <- out
    dimnames(out)[[3]] <- NULL #Delete variable name to prevent it from being written into output file
    write.magpie(out[notGLO,,],paste0("./modules/30_biomass/",inputpath_mag,"/input/p30_pebiolc_pricemag_coupling.csv"),file_type="csvr")
    return(tmp[notGLO,,])
  }

  .bioenergy_production <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    if("Demand|Bioenergy|2nd generation|++|Bioenergy crops (EJ/yr)" %in% getNames(mag)) {
      # MAgPIE 4
      out <- mag[,,"Demand|Bioenergy|2nd generation|++|Bioenergy crops (EJ/yr)"]/31.536 # EJ to TWa
    } else {
      # MAgPIE 3
      out <- mag[,,"Primary Energy Production|Biomass|Energy Crops (EJ/yr)"]/31.536 # EJ to TWa
    }
    out[which(out<0)] <- 0 # set negative values to zero since they cause errors in GMAS power function
    out["JPN",is.na(out["JPN",,]),] <- 0
    tmp <- out
    dimnames(out)[[3]] <- NULL
    write.magpie(out[notGLO,,],paste0("./modules/30_biomass/",inputpath_mag,"/input/pm_pebiolc_demandmag_coupling.csv"),file_type="csvr")
    return(tmp[notGLO,,])
  }
  
  .emissions_mac <- function(mag) {
    # Select the LUC variable according to setting.
    if (var_luc == "smooth") {
      emi_co2_luc <- "Emissions|CO2|Land|+|Land-use Change (Mt CO2/yr)"
    } else if (var_luc == "raw") {
      emi_co2_luc <- "Emissions|CO2|Land RAW|+|Land-use Change (Mt CO2/yr)"
    } else {
      stop(paste0("Unkown setting for 'var_luc': `", var_luc, "`. Only `smooth` or `raw` are allowed."))
    }

    # define three columns of dataframe:
    #   emirem (remind emission names)
    #   emimag (magpie emission names)
    #   factor_mag2rem (factor for converting magpie to remind emissions)
    #   1/1000*28/44, # kt N2O/yr -> Mt N2O/yr -> Mt N/yr
    #   28/44,        # Tg N2O/yr =  Mt N2O/yr -> Mt N/yr
    #   1/1000*12/44, # Mt CO2/yr -> Gt CO2/yr -> Gt C/yr
    map <- data.frame(emirem=NULL,emimag=NULL,factor_mag2rem=NULL,stringsAsFactors=FALSE)
    if("Emissions|N2O|Land|Agriculture|+|Animal Waste Management (Mt N2O/yr)" %in% getNames(mag)) {
      # MAgPIE 4 (up to date)
      map <- rbind(map,data.frame(emimag=emi_co2_luc,                                                                                      emirem="co2luc",    factor_mag2rem=1/1000*12/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|+|Animal Waste Management (Mt N2O/yr)",                           emirem="n2oanwstm", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Inorganic Fertilizers (Mt N2O/yr)",          emirem="n2ofertin", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Manure applied to Croplands (Mt N2O/yr)",    emirem="n2oanwstc", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Decay of Crop Residues (Mt N2O/yr)",         emirem="n2ofertcr", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Soil Organic Matter Loss (Mt N2O/yr)",       emirem="n2ofertsom",factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|Agriculture|Agricultural Soils|+|Pasture (Mt N2O/yr)",                        emirem="n2oanwstp", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land|+|Peatland (Mt N2O/yr)",                                                      emirem="n2opeatland", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Rice (Mt CH4/yr)",                                              emirem="ch4rice",   factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Animal waste management (Mt CH4/yr)",                           emirem="ch4anmlwst",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Enteric fermentation (Mt CH4/yr)",                              emirem="ch4animals",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|+|Peatland (Mt CH4/yr)",                                                      emirem="ch4peatland",factor_mag2rem=1,stringsAsFactors=FALSE))
    } else if("Emissions|N2O-N|Land|Agriculture|+|Animal Waste Management (Mt N2O-N/yr)" %in% getNames(mag)) {
      # MAgPIE 4 (intermediate - wrong units)
      map <- rbind(map,data.frame(emimag="Emissions|CO2|Land|+|Land-use Change (Mt CO2/yr)",                                               emirem="co2luc",    factor_mag2rem=1/1000*12/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|+|Animal Waste Management (Mt N2O-N/yr)",                       emirem="n2oanwstm", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Inorganic Fertilizers (Mt N2O-N/yr)",      emirem="n2ofertin", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Manure applied to Croplands (Mt N2O-N/yr)",emirem="n2oanwstc", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Decay of Crop Residues (Mt N2O-N/yr)",     emirem="n2ofertcr", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Soil Organic Matter Loss (Mt N2O-N/yr)",   emirem="n2ofertsom",factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O-N|Land|Agriculture|Agricultural Soils|+|Pasture (Mt N2O-N/yr)",                    emirem="n2oanwstp", factor_mag2rem=28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Rice (Mt CH4/yr)",                                              emirem="ch4rice",   factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Animal waste management (Mt CH4/yr)",                           emirem="ch4anmlwst",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land|Agriculture|+|Enteric fermentation (Mt CH4/yr)",                              emirem="ch4animals",factor_mag2rem=1,stringsAsFactors=FALSE))
    } else if("Emissions|CO2|Land Use (Mt CO2/yr)" %in% getNames(mag)) {
      # MAgPIE 3
      map <- rbind(map,data.frame(emimag="Emissions|CO2|Land Use (Mt CO2/yr)",                                                        emirem="co2luc",    factor_mag2rem=1/1000*12/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|AWM (kt N2O/yr)",                                        emirem="n2oanwstm", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Inorganic Fertilizers (kt N2O/yr)",       emirem="n2ofertin", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Manure applied to Croplands (kt N2O/yr)", emirem="n2oanwstc", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Decay of crop residues (kt N2O/yr)",      emirem="n2ofertcr", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Soil organic matter loss (kt N2O/yr)",    emirem="n2ofertsom",factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Cropland Soils|Lower N2O emissions of rice (kt N2O/yr)", emirem="n2ofertrb", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Agriculture|Pasture (kt N2O/yr)",                                    emirem="n2oanwstp", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Biomass Burning|Forest Burning (kt N2O/yr)",                         emirem="n2oforest", factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Biomass Burning|Savannah Burning (kt N2O/yr)",                       emirem="n2osavan",  factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|N2O|Land Use|Biomass Burning|Agricultural Waste Burning (kt N2O/yr)",             emirem="n2oagwaste",factor_mag2rem=1/1000*28/44,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Agriculture|Rice (Mt CH4/yr)",                                       emirem="ch4rice",   factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Agriculture|AWM (Mt CH4/yr)",                                        emirem="ch4anmlwst",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Agriculture|Enteric Fermentation (Mt CH4/yr)",                       emirem="ch4animals",factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Biomass Burning|Forest Burning (Mt CH4/yr)",                         emirem="ch4forest", factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Biomass Burning|Savannah Burning (Mt CH4/yr)",                       emirem="ch4savan",  factor_mag2rem=1,stringsAsFactors=FALSE))
      map <- rbind(map,data.frame(emimag="Emissions|CH4|Land Use|Biomass Burning|Agricultural Waste Burning (Mt CH4/yr)",             emirem="ch4agwaste",factor_mag2rem=1,stringsAsFactors=FALSE))
    } else {
      stop("Emission data not found in MAgPIE report. Check MAgPIE reporting file.")
    }

    # Read data from MAgPIE report and convert to REMIND data, collect in 'out' object
    out<-NULL
    for (i in 1:nrow(map)) {
        tmp<-setNames(mag[,,map[i,]$emimag],map[i,]$emirem)
        tmp<-tmp*map[i,]$factor_mag2rem
        # Add emission variable to full dataframe
        out<-mbind(out,tmp)
    }

    # Write REMIND input file
    notGLO   <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    filename <- paste0("./core/input/f_macBaseMagpie_coupling.cs4r")
    write.magpie(out[notGLO,,],filename)
    write(paste0("*** EOF ",filename," ***"),file=filename,append=TRUE)
    return(out[notGLO,,])
  }
  
  .agriculture_costs <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    out <- mag[,,"Costs Without Incentives (million US$2017/yr)"]/1000/1000 # with transformation factor from 10E6 US$2017 to 10E12 US$2017
    out["JPN",is.na(out["JPN",,]),] <- 0
    tmp <- out
    dimnames(out)[[3]] <- NULL #Delete variable name to prevent it from being written into output file
    write.magpie(out[notGLO,,],paste0("./modules/26_agCosts/",inputpath_acc,"/input/p26_totLUcost_coupling.csv"),file_type="csvr")
    return(tmp[notGLO,,])
  }
  
  .agriculture_tradebal <- function(mag){
    notGLO <- getRegions(mag)[!(getRegions(mag)=="GLO")]
    out <- mag[,,"Trade|Agriculture|Trade Balance (billion US$2017/yr)"]/1000 # with transformation factor from 10E9 US$2017 to 10E12 US$2017
    out["JPN",is.na(out["JPN",,]),] <- 0
    dimnames(out)[[3]] <- NULL
    write.magpie(out[notGLO,,],paste0("./modules/26_agCosts/",inputpath_acc,"/input/trade_bal_reg.rem.csv"),file_type="csvr")
  }
 
  rep <- read.report(path_to_report,as.list=FALSE)
  if (length(getNames(rep,dim="scenario"))!=1) stop("getReportData: MAgPIE data contains more or less than 1 scenario.")
  rep <- collapseNames(rep) # get rid of scenario and model dimension if they exist
  years <- 2000+5*(1:30)
  mag <- time_interpolate(rep,years)
  pricBio <- .bioenergy_price(mag)
  prodBio <- .bioenergy_production(mag)
  emi     <- .emissions_mac(mag)
  cost    <- .agriculture_costs(mag)
  tmp <- mbind(pricBio, prodBio, emi, cost)
  # needs to be updated to MAgPIE 4 interface
  #.agriculture_tradebal(mag)
  return(invisible(tmp))
}
