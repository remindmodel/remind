# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

require(rmarkdown)
require(lucode)
require(quitte)
require(data.table)
require(rmndt)
require(moinput)
require(edgeTrpLib)
require(gdx)
require(gdxdt)
require(stringr)
setConfig(forcecache = TRUE)

if(!exists("source_include")) {
  ## Define arguments that can be read from command line
  readArgs("outputdirs")
}

## Check if the output is EDGE based, otherwise remove the output directory from the list of compared output folders
for (outputdir in outputdirs) {
  load(file.path(outputdir, "config.Rdata"))
  if(cfg$gms$transport != "edge_esm"){
    print(paste0("The scenario ", outputdir, " is not EDGE-based and will be excluded from the reporting"))
    outputdirs = outputdirs[outputdirs != outputdir]
  }
}


gdx_name = "fulldata.gdx"


## create list to save
alltosave = list(fleet_all = NULL,
                 salescomp_all = NULL,
                 EJroad_all = NULL,
                 EJmode_all = NULL,
                 ESmodecap_all = NULL,
                 ESmodeabs_all = NULL,
                 CO2km_int_newsales_all = NULL,
                 emidem_all = NULL,
                 emiDemand_all = NULL,
                 emiSec_all = NULL,
                 EJfuelsPass_all = NULL,
                 EJfuelsFrgt_all = NULL,
                 EJfuelsMode_all = NULL,
                 emipSource_all = NULL,
                 elecdem_all = NULL,
                 costs_all = NULL,
                 pref_FV_all = NULL,
                 demgdpcap_all = NULL,
                 invest_all = NULL,
                 LDV_PEnew_all = NULL,
                 trsp_PEnew_all = NULL)

scenNames <- getScenNames(outputdirs)
EDGEdata_path  <- path(outputdirs, paste("EDGE-T/"))
gdx_path  <- path(outputdirs,gdx_name)
scenNames <- getScenNames(outputdirs)

names(gdx_path) <- scenNames
names(EDGEdata_path) <- scenNames

REMIND2ISO_MAPPING <- fread("config/regionmappingH12.csv")[, .(iso = CountryCode, region = RegionCode)]



SalesFun = function(shares_LDV, newcomp, sharesVS1){
  ## I need the total demand for each region to get the average composition in the region (sales are on a country level)
  ## First I calculate the total demand for new sales using the shares on FV level (in newcomp) and on VS1 level
  newcomp = merge(newcomp, sharesVS1[,.(shareVS1 = share, iso, year, vehicle_type, subsector_L1)], all.x=TRUE, by = c("iso", "year", "vehicle_type", "subsector_L1"))
  newcomp[, newdem := totdem*sharetech_new*shareVS1]
  newcomp = newcomp[,.(value = sum(newdem)), by = c("iso", "year", "subsector_L1")]
  ## I have to interpolate in time the sales nto to loose the sales composition annual values
  newcomp=approx_dt(dt=newcomp, unique(shares_LDV$year),
                    xcol= "year",
                    ycol = "value",
                    idxcols=c("iso","subsector_L1"),
                    extrapolate=T)

  setnames(newcomp, new = "newdem", old = "value")

  ## I calculate the sales composition (disrespective to the vehicle type)
  shares_LDV = unique(shares_LDV[,c("iso","year", "technology", "shareFS1")])
  shares_LDV <- shares_LDV[,.(shareFS1=sum(shareFS1)),by=c("iso","technology","year")]

  ## I calculate the weighted regional sales (depending on the total volume of sales per country in each region)
  shares_LDV = merge(shares_LDV, newcomp)
  shares_LDV = merge(shares_LDV, REMIND2ISO_MAPPING, by = "iso")
  shares_LDV[, demfuel := shareFS1*newdem, by = c("year", "iso", "technology")]
  shares_LDV = shares_LDV[, .(demfuel = sum(demfuel)), by = c("year", "region", "technology")]
  shares_LDV[, shareFS1 := demfuel/sum(demfuel), by = c("year", "region")]

  ## plot features
  shares_LDV[, technology := factor(technology, levels = c("BEV", "Hybrid Electric", "FCEV", "Hybrid Liquids", "Liquids", "NG"))]

  return(shares_LDV)
}


fleetFun = function(vintcomp, newcomp, sharesVS1, loadFactor){
  vintcomp = vintcomp[,.(totdem, iso, subsector_L1, year, technology,vehicle_type, sector, sharetech_vint)]
  newcomp = newcomp[,.(iso, subsector_L1, year, technology,vehicle_type, sector, sharetech_new)]

  allfleet = merge(newcomp, vintcomp, all =TRUE, by = c("iso", "sector", "subsector_L1", "vehicle_type", "technology",  "year"))
  allfleet = merge(allfleet, sharesVS1[,.(shareVS1 = share, iso, year, vehicle_type, subsector_L1)], all.x=TRUE, by = c("iso", "year", "vehicle_type", "subsector_L1"))
  allfleet[,vintdem:=totdem*sharetech_vint*shareVS1]
  allfleet[,newdem:=totdem*sharetech_new*shareVS1]
  allfleet=melt(allfleet, id.vars = c("iso", "sector", "subsector_L1", "vehicle_type", "technology",
                                      "year"), measure.vars = c("vintdem", "newdem"))
  allfleet[,alpha:=ifelse(variable == "vintdem", 0, 1)]

  allfleet = merge(allfleet, loadFactor, all.x = TRUE, by = c("iso", "vehicle_type", "year"))
  annual_mileage = 13000
  allfleet = allfleet[,.(value = sum(value/1.5/annual_mileage)), by = c("iso", "technology", "variable", "year")]

  allfleet = merge(allfleet, REMIND2ISO_MAPPING, by = "iso")
  allfleet = allfleet[,.(value = sum(value)), by = c("region", "technology", "variable", "year")]
  allfleet[,alphaval := ifelse(variable =="vintdem", 1,0)]
  allfleet[, technology := factor(technology, levels = c("BEV", "Hybrid Electric", "FCEV", "Hybrid Liquids", "Liquids", "NG"))]

  return(allfleet)
}


EJroadFun <- function(demandEJ){
  demandEJ = demandEJ[subsector_L3 %in% c("trn_pass_road", "trn_freight_road"),]
  demandEJ <- demandEJ[, c("sector", "subsector_L3", "subsector_L2", "subsector_L1", "vehicle_type", "technology", "iso", "year", "demand_EJ")]
  demandEJ = merge(demandEJ, REMIND2ISO_MAPPING, by = "iso")
  demandEJ[technology == "Hybrid Liquids", technology := "Liquids"]
  demandEJ[technology == "FCEV", technology := "Hydrogen"]
  demandEJ[technology %in% c("BEV", "Electric"), technology := "Electricity"]
  demandEJ[subsector_L1 %in% c("trn_pass_road_bus_tmp_subsector_L1", "Bus_tmp_subsector_L1"), subsector_L1 := "Bus_tmp_subsector_L1"]
  demandEJ = demandEJ[, .(demand_EJ = sum(demand_EJ)), by = c("region", "year", "technology", "subsector_L1")]
  return(demandEJ)

}


EJmodeFun = function(demandEJ){

  demandEJ[, aggr_mode := ifelse(subsector_L2 == "trn_pass_road_LDV", "LDV", NA)]
  demandEJ[, aggr_mode := ifelse(subsector_L3 %in% c("Passenger Rail", "HSR", "International Aviation", "Domestic Aviation"), "Pass non LDV", aggr_mode)]
  demandEJ[, aggr_mode := ifelse(subsector_L2 %in% c("trn_pass_road_bus", "Bus"), "Pass non LDV", aggr_mode)]
  demandEJ[, aggr_mode := ifelse(is.na(aggr_mode), "Freight", aggr_mode)]
  demandEJ[, veh := ifelse(grepl("Large|SUV|Midsize|Multipurpose Vehicle|Van|3W Rural", vehicle_type), "Large Cars", NA)]
  demandEJ[, veh := ifelse(grepl("Subcompact|Compact|Mini|Three-Wheeler", vehicle_type), "Small Cars", veh)]
  demandEJ[, veh := ifelse(grepl("Motorcycle|Moped|Scooter", vehicle_type), "Motorbikes", veh)]
  demandEJ[, veh := ifelse(grepl("bus|Bus", vehicle_type), "Bus", veh)]
  demandEJ[, veh := ifelse(grepl("Truck", vehicle_type) & vehicle_type != "Light Truck and SUV", "Truck", veh)]
  demandEJ[, veh := ifelse(grepl("Freight Rail_tmp_vehicletype", vehicle_type), "Freight Rail", veh)]
  demandEJ[, veh := ifelse(grepl("Passenger Rail|HSR", vehicle_type), "Passenger Rail", veh)]
  demandEJ[, veh := ifelse(subsector_L3 == "Domestic Ship", "Domestic Shipping", veh)]
  demandEJ[, veh := ifelse(subsector_L3 == "International Ship", "International Shipping", veh)]
  demandEJ[, veh := ifelse(subsector_L3 == "Domestic Aviation", subsector_L3, veh)]
  demandEJ[, veh := ifelse(subsector_L3 == "International Aviation", subsector_L3, veh)]
  demandEJ[, veh := ifelse(is.na(veh), vehicle_type, veh)]
  demandEJ = demandEJ[,.(demand_EJ = sum(demand_EJ)), by = c("iso", "year", "aggr_mode", "veh")]

  demandEJ[, vehicle_type_plot := factor(veh, levels = c("LDV","Freight Rail", "Truck","Domestic Shipping", "International Shipping",
                                                         "Motorbikes", "Small Cars", "Large Cars", "Van",
                                                         "Domestic Aviation", "International Aviation", "Bus", "Passenger Rail",
                                                         "Freight", "Freight (Inland)", "Pass non LDV", "Pass non LDV (Domestic)"))]

  demandEJ = merge(demandEJ, REMIND2ISO_MAPPING, by = "iso")
  demandEJ = demandEJ[,.(demand_EJ= sum(demand_EJ)), by = c("region", "year", "vehicle_type_plot", "aggr_mode")]


  return(demandEJ)
}


ESmodeFun = function(demandkm, POP){
  ## REMIND-EDGE results
  demandkm <- demandkm[,c("sector","subsector_L3","subsector_L2",
                          "subsector_L1","vehicle_type","technology", "iso","year","demand_F")]

  ## attribute aggregated mode and vehicle names for plotting purposes, and aggregate
  demandkm[, aggr_mode := ifelse(subsector_L1 %in% c("Three-Wheeler", "trn_pass_road_LDV_4W"), "LDV", NA)]
  demandkm[, aggr_mode := ifelse(sector %in% c("trn_freight", "trn_shipping_intl"), "Freight", aggr_mode)]
  demandkm[, aggr_mode := ifelse(sector %in% c("trn_aviation_intl"), "Pass. non LDV", aggr_mode)]
  demandkm[, aggr_mode := ifelse(subsector_L2 %in% c("trn_pass_road_bus", "HSR_tmp_subsector_L2", "Passenger Rail_tmp_subsector_L2", "Cycle_tmp_subsector_L2", "Walk_tmp_subsector_L2", "Domestic Aviation_tmp_subsector_L2", "Bus") | subsector_L1 %in% c("trn_pass_road_LDV_2W"), "Pass. non LDV", aggr_mode)]

  demandkm[, veh := ifelse(grepl("Truck", vehicle_type) & vehicle_type != "Light Truck and SUV" | vehicle_type == "3W Rural", "Truck", NA)]
  demandkm[, veh := ifelse(grepl("Large|SUV|Midsize|Multipurpose Vehicle|Van|Light Truck and SUV", vehicle_type), "Large Cars", veh)]
  demandkm[, veh := ifelse(grepl("Subcompact|Compact|Mini|Three-Wheeler_tmp_vehicletype", vehicle_type), "Small Cars", veh)]
  demandkm[, veh := ifelse(grepl("Motorcycle|Moped|Scooter", vehicle_type), "Motorbikes", veh)]
  demandkm[, veh := ifelse(grepl("bus|Bus", vehicle_type), "Bus", veh)]
  demandkm[, veh := ifelse(subsector_L3 == "Domestic Aviation", "Domestic Aviation", veh)]
  demandkm[, veh := ifelse(subsector_L3 == "International Aviation", "International Aviation", veh)]
  demandkm[, veh := ifelse(subsector_L3 == "Domestic Ship", "Domestic Shipping", veh)]
  demandkm[, veh := ifelse(subsector_L3 == "International Ship", "International Shipping", veh)]
  demandkm[, veh := ifelse(grepl("Freight Rail", vehicle_type), "Freight Rail", veh)]
  demandkm[, veh := ifelse(grepl("Passenger Rail|HSR", vehicle_type), "Passenger Rail", veh)]
  demandkm[, veh := ifelse(grepl("Ship", vehicle_type), "Shipping", veh)]
  demandkm[, veh := ifelse(grepl("Cycle|Walk", subsector_L3), "Non motorized", veh)]
  demandkm = demandkm[,.(demand_F = sum(demand_F)), by = c("iso", "year", "aggr_mode", "veh", "technology")]
  setnames(demandkm, old = "veh", new = "vehicle_type")


  demandkm[, vehicle_type_plot := factor(vehicle_type, levels = c("LDV","Freight Rail", "Truck", "Domestic Ship", "International Ship",
                                                                  "Motorbikes", "Small Cars", "Large Cars", "Van",
                                                                  "Domestic Aviation", "International Aviation","Bus", "Passenger Rail",
                                                                  "Freight", "Non motorized", "Shipping"))]

  ## attribute aggregate mode (passenger, freight)
  demandkm[, mode := ifelse(vehicle_type %in% c("Freight", "Freight Rail", "Truck", "Shipping") ,"freight", "pass")]

  ## aggregate to regions
  POP = merge(POP, REMIND2ISO_MAPPING, all.x = TRUE, by = c("iso"))
  POP = POP[, .(pop = sum(value)), by = c("region", "year")]
  demandkm = merge(demandkm, REMIND2ISO_MAPPING, by = "iso")
  demandkm = demandkm[, .(demand_F = sum(demand_F)), by = c("region", "year", "vehicle_type_plot", "aggr_mode", "mode", "technology")]

  ## save separately the total demand
  demandkm_abs = copy(demandkm)
  demandkm_abs = demandkm_abs[year >= 2015 & year <= 2100]
  demandkm_abs[, demand_F := demand_F/    ## in million km
                 1e6]         ## in trillion km
  ## calculate per capita demand
  demandkm = demandkm[, .(demand_F = sum(demand_F)), by = c("region", "year", "vehicle_type_plot", "aggr_mode", "mode")]
  demandkm = merge(demandkm, POP, all.x = TRUE, by =c("year", "region"))

  ## calculate per capita values
  demandkm = demandkm[order(aggr_mode)]
  demandkm[, cap_dem := demand_F/    ## in million km
             pop]         ## in million km/million people=pkm/person

  demandkm = demandkm[year >= 2015 & year <= 2100]

  return(list(demandkm = demandkm, demandkm_abs = demandkm_abs))

}

FEliq_sourceFun = function(FEliq_source, gdp){
  FEliq_source = FEliq_source[variable %in% c("FE|Transport|Liquids|LDV|Fossil|New Reporting", "FE|Transport|Liquids|LDV|Biomass|New Reporting", "FE|Transport|Liquids|LDV|Synthetic|New Reporting")]

  ## Attribute oil and biodiesel (TODO Coal2Liquids is accounted for as Oil!
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|LDV|Fossil|New Reporting", "FE|Transport|Pass|Road|LDV|Liquids"), "Oil", NA)]
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|LDV|Biomass|New Reporting"), "Biomass", technology)]
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|LDV|Synthetic|New Reporting"), "Synfuel", technology)]
  FEliq_source = FEliq_source[,.(value = sum(value)), by = c("model", "scenario", "region", "year", "unit", "technology")]
  FEliq_sourceR = FEliq_source[, shareliq := value/sum(value),by=c("region", "year")]

  ## to ISO level
  FEliq_sourceISO <- disaggregate_dt(FEliq_source, REMIND2ISO_MAPPING,
                                     valuecol="value",
                                     datacols=c("model","scenario", "unit","technology"),
                                     weights=gdp)
  ## calculate share
  FEliq_sourceISO[, shareliq := value/sum(value),by=c("iso", "year")]

  return(list(FEliq_sourceISO = FEliq_sourceISO, FEliq_sourceR = FEliq_sourceR))
}


CO2km_int_newsales_Fun = function(shares_LDV, mj_km_data, sharesVS1, FEliq_source, gdp){
  ## energy intensity https://en.wikipedia.org/wiki/Energy_density
  # emi_petrol = 45 ## MJ/gFUEL
  # emi_biodiesel = 42 ## MJ/gFUEL
  # emi_cng = 54 ## MJ/gFUEL
  #
  # ## CO2 content
  # CO2_petrol = 3.1 ## gCO2/gFUEL
  # CO2_biodiesel = 2.7 ## TODO this number is made up! gCO2/gFUEL
  # CO2_cng = 2.7 ## gCO2/gFUEL

  ## TODO of CO2 content of biodiesel is made up! gCO2/gFUEL Same for Synfuels! and for PHEVs!
  emi_fuel = data.table(technology = c("Oil", "Biodiesel", "NG", "Synfuel", "Hybrid Liquids", "Hybrid Electric"), ei_gF_MJ = c(20, 20, 20, 20, 20, 10), emi_cGO2_gF = c(3.1, 3.1, 2.7, 2.7, 3.1, 3.1))

  emi_liquids = merge(FEliq_source, emi_fuel, all.x = TRUE, by = "technology")
  emi_liquids = emi_liquids[, .(ei_gF_MJ = sum(shareliq*ei_gF_MJ), emi_cGO2_gF = sum(shareliq*emi_cGO2_gF)), by = c("iso", "year")][, technology := "Liquids"]
  emi_NG = cbind(emi_fuel[technology == "NG"], unique(FEliq_source[,c("year", "iso")]))

  emi_fuel = rbind(emi_NG, emi_liquids)
  emi_fuel[, gCO2_MJ := ei_gF_MJ*emi_cGO2_gF]
  ## merge emissions factor with energy intensity for LDVs
  emi_fuel = merge(mj_km_data[subsector_L1 == "trn_pass_road_LDV_4W" & year %in% unique(FEliq_source$year)], emi_fuel, all.x = TRUE, by = c("iso", "year", "technology"))
  emi_fuel[is.na(gCO2_MJ) & !technology %in% c("Liquids", "NG"), gCO2_MJ := 0]
  emi_fuel[, gCO2_km := MJ_km * gCO2_MJ]

  ## merge with sales composition
  intemi = merge(emi_fuel, shares_LDV, all.y = TRUE, by = c("iso", "year", "technology", "vehicle_type", "subsector_L1"), all.x = TRUE)
  intemi = intemi[!is.na(share) & !is.na(gCO2_km)]
  ## find average emission intensity
  intemi[, gCO2_km_ave := gCO2_km*share]
  intemi = intemi[,.(gCO2_km_ave = sum(gCO2_km_ave)), by = c("year", "iso", "vehicle_type")]
  ## find average emissions across fleet (all vehicle types)
  intemi = merge(intemi, sharesVS1, all.x = TRUE, by = c("iso", "year", "vehicle_type"))
  intemi = intemi[,.(gCO2_km_ave = sum(gCO2_km_ave*share)), by = c("iso", "year", "subsector_L1")]
  ## find regional values
  intemi = merge(intemi, REMIND2ISO_MAPPING, by="iso")
  intemi = merge(intemi, gdp, all.x=TRUE, by = c("iso", "year"))
  intemi[, share := weight/sum(weight), by = c("year", "region")]
  intemi = intemi[,.(gCO2_km_ave = sum(gCO2_km_ave*share)), by = c("year", "region")]
  intemi = intemi[year >= 2015 & year <= 2100]

  return(intemi)
}


EJfuelsFun = function(demandEJ, FEliq_source){
  ## find the composition of liquid fuels
  FEliq_source = FEliq_source[,.(value = sum(value)), by = c("region", "year", "technology")]
  ## renmae technology not to generate confusion with all technologies (non liquids)
  setnames(FEliq_source, old = "technology", new = "subtech")
  FEliq_source[, technology := "Liquids"]
  ## find shares
  FEliq_source[, shareliq := value/sum(value),by=c("region", "year")]
  ## merge with regional mapping
  demandEJ = merge(demandEJ, REMIND2ISO_MAPPING, by = "iso")
  ## attribute "liquids" to hybrid liquids
  demandEJ[, technology := ifelse(technology %in% c("Liquids", "Hybrid Liquids"), "Liquids", technology)]
  demandEJ[, technology := ifelse(technology %in% c("BEV", "LA-BEV", "Electric"), "Electricity", technology)]
  demandEJ[, technology := ifelse(technology %in% c("FCEV"), "Hydrogen", technology)]
  ## aggregate
  demandEJ = demandEJ[, .(demand_EJ = sum(demand_EJ)), by = c("region", "year","technology", "sector")]
  ## merge with liquids composition
  demandEJ = merge(demandEJ, FEliq_source, all = TRUE, by = c("region", "year", "technology"), allow.cartesian=TRUE)
  ## fuels that are not Liquids need a 1 as a share, otherwie would have an NA
  demandEJ[, shareliq := ifelse(is.na(shareliq), 1, shareliq)]
  demandEJ[, subtech := ifelse(is.na(subtech), technology, subtech)]
  ## calculate demand by fuel including oil types
  demandEJ = demandEJ[,.(demand_EJ = demand_EJ*shareliq), by = c("region", "year", "subtech", "sector")]
  ## filter out years
  demandEJ = demandEJ[year >= 2015 & year <= 2100]

  ## save separately passenger and freight
  demandEJpass = demandEJ[sector %in% c("trn_pass", "trn_aviation_intl")]
  demandEJfrgt = demandEJ[sector %in% c("trn_freight", "trn_shipping_intl")]

  demandEJ = list(demandEJpass = demandEJpass, demandEJfrgt = demandEJfrgt)
  return(demandEJ)
}


EJfuelsModeFun = function(demandEJ, FEliq_source){
  ## find the composition of liquid fuels
  FEliq_source = FEliq_source[,.(value = sum(value)), by = c("region", "year", "technology")]
  ## renmae technology not to generate confusion with all technologies (non liquids)
  setnames(FEliq_source, old = "technology", new = "subtech")
  FEliq_source[, technology := "Liquids"]
  ## find shares
  FEliq_source[, shareliq := value/sum(value),by=c("region", "year")]
  ## merge with regional mapping
  demandEJ = merge(demandEJ, REMIND2ISO_MAPPING, by = "iso")
  ## attribute "liquids" to hybrid liquids
  demandEJ[, technology := ifelse(technology %in% c("Liquids", "Hybrid Liquids"), "Liquids", technology)]
  demandEJ[, technology := ifelse(technology %in% c("BEV", "LA-BEV", "Electric"), "Electricity", technology)]
  demandEJ[, technology := ifelse(technology %in% c("FCEV"), "Hydrogen", technology)]
  ## attribute LDV, Freight and remove all other categories
  demandEJ[, subsec := "subsec"]
  demandEJ[subsector_L2 == "trn_pass_road_LDV", subsec := "LDV"]
  demandEJ[sector == "trn_freight", subsec := "Freight"]
  demandEJ[subsec=="subsec", subsec := "Other"]  ## aggregate
  demandEJ = demandEJ[, .(demand_EJ = sum(demand_EJ)), by = c("region", "year","technology", "subsec")]
  ## merge with liquids composition
  demandEJ = merge(demandEJ, FEliq_source, all = TRUE, by = c("region", "year", "technology"), allow.cartesian=TRUE)
  ## fuels that are not Liquids need a 1 as a share, otherwie would have an NA
  demandEJ[, shareliq := ifelse(is.na(shareliq), 1, shareliq)]
  demandEJ[, subtech := ifelse(is.na(subtech), technology, subtech)]
  ## calculate demand by fuel including oil types
  demandEJ = demandEJ[,.(demand_EJ = demand_EJ*shareliq), by = c("region", "year", "subtech", "subsec")]
  ## filter out years
  demandEJ = demandEJ[year >= 2015 & year <= 2100]

  return(demandEJ)
}



LDV_PEnewFun =function(demEJ, gdx, miffile, FEliq_source, REMIND2ISO_MAPPING) {
  ## Collect all the FEs
  FE_noliq = miffile[variable %in% c("FE|Transport|Pass|Road|LDV|Electricity", "FE|Transport|Pass|Road|LDV|Gases", "FE|Transport|Pass|Road|LDV|Hydrogen")]

  ## give short names to the FEs
  FE_noliq[variable %in% c("FE|Transport|Pass|Road|LDV|Electricity"), technology := "Electricity"]
  FE_noliq[variable %in% c("FE|Transport|Pass|Road|LDV|Gases"), technology := "Gases"]
  FE_noliq[variable %in% c("FE|Transport|Pass|Road|LDV|Hydrogen"), technology := "Hydrogen"]
  FE_noliq[, variable := NULL]
  FE_all = rbind(FE_noliq, FEliq_source[, shareliq:=NULL])

  ## collect the effciencies from the gdx
  refliq = 0.9 ## refinery oil to SE liquids
  elh2 = 0.8    ## convert electricity to H2
  MeOH = 0.7    ## methanol production
  biodiesel = 0.98  ## oil biomass to biodiesel

  ## calculate the shares of 4W and 2W in LDVs for each energy source(liquids->synfuels,biofuels,fossil,electricity,hydrogen)
  demand_EJ = merge(demEJ, REMIND2ISO_MAPPING, by = "iso")
  demand_EJ = demand_EJ[subsector_L2 == "trn_pass_road_LDV"]
  demand_EJ[technology %in% c("BEV", "LA-BEV", "Electricity"), technology := "Electricity"]
  demand_EJ[technology %in% c("Liquids", "Hybrid Liquids"), technology := "Oil"]
  demand_EJ[technology %in% c("FCEV"), technology := "Hydrogen"]
  demand_EJ = demand_EJ[,.(demand_EJ = sum(demand_EJ)), by = .(region, year, technology, subsector_L1)]
  demand_EJ[, share_LDV := demand_EJ/sum(demand_EJ), by = .(region, year, technology)]
  defos = demand_EJ[technology == "Oil"]
  ## duplicate values for synfuels and biofuels
  demand_EJ = rbind(demand_EJ, defos[, technology := "Synfuel"])
  demand_EJ = rbind(demand_EJ, defos[, technology := "Biomass"])
  ## reduce the FEs according to the shares of 2W and 4W
  FE_all = merge(FE_all, demand_EJ[subsector_L1 == "trn_pass_road_LDV_4W"][, subsector_L1 := NULL], by = c("region", "year", "technology"))
  FE_all[, value := value*share_LDV]
  FE_all[, share_LDV := NULL]
  ## calculate SE units
  FE_all[technology == "Oil", value := value/refliq]
  FE_all[technology == "Hydrogen", value := value/elh2]
  FE_all[technology == "Synfuel", value := value/elh2/MeOH]
  FE_all[technology == "Biomass", value := value/biodiesel]
  ## attribute electricity tag to h2 and syn
  FE_all[technology %in% c("Hydrogen", "Synfuel"), technology := "Electricity"]
  ## sum up on technology
  FE_all = FE_all[,.(value = sum(value)), by = c("region", "year", "technology")]
  ## collect efficiencies of fossil plants
  eff = data.table(variable = c("SE|Electricity|Gas|CC|w/o CCS", "SE|Electricity|Gas|CCC|w/ CCS", "SE|Electricity|Gas|GT", "SE|Electricity|Gas|CHP|w/o CCS", "SE|Electricity|Coal|PC|w/o CCS", "SE|Electricity|Coal|PCC|w/ CCS", "SE|Electricity|Coal|IGCC|w/o CCS", "SE|Electricity|Coal|IGCCC|w/ CCS", "SE|Electricity|Oil|DOT", "SE|Electricity|Geothermal"), eff = c(0.57, 0.49, 0.38, 0.47, 0.41, 0.36, 0.42, 0.33, 0.3, 0.4))

  ## collect the shares of the different sources in the electricity production
  SEcomp = miffile[variable %in% c("SE|Electricity|Gas|CC|w/o CCS", "SE|Electricity|Gas|CCC|w/ CCS", "SE|Electricity|Gas|GT", "SE|Electricity|Gas|CHP|w/o CCS", "SE|Electricity|Coal|PC|w/o CCS", "SE|Electricity|Coal|PCC|w/ CCS", "SE|Electricity|Coal|IGCC|w/o CCS", "SE|Electricity|Coal|IGCCC|w/ CCS", "SE|Electricity|Oil|DOT", "SE|Electricity|Nuclear", "SE|Electricity|Geothermal", "SE|Electricity|Hydro",  "SE|Electricity|Solar|CSP", "SE|Electricity|Solar|PV", "SE|Electricity|Wind")]
  SEcomp = merge(SEcomp, eff, by = "variable", all.x =TRUE)
  SEcomp[, share := value/sum(value), by = .(region, year)]
  SEcomp[, value:= NULL]
  ## calculate the PE by sources
  PE_elec = merge(FE_all[technology == "Electricity"], SEcomp, by = c("region", "year"))
  ## attribute efficiency 1 to RES
  PE_elec[is.na(eff), eff := 1]
  PE_elec[, value := value*share/eff]
  PE_elec[, c("share", "eff"):= NULL]
  PE_elec[variable == "SE|Electricity|Wind", technology := "Wind"]
  PE_elec[variable %in% c("SE|Electricity|Solar|PV", "SE|Electricity|Solar|CSP"), technology := "Solar"]
  PE_elec[variable %in% c("SE|Electricity|Gas|CC|w/o CCS", "SE|Electricity|Gas|CCC|w/ CCS", "SE|Electricity|Gas|GT", "SE|Electricity|Gas|CHP|w/o CCS"), technology := "Gas"]
  PE_elec[variable %in% c("SE|Electricity|Coal|PC|w/o CCS", "SE|Electricity|Coal|PCC|w/ CCS", "SE|Electricity|Coal|IGCC|w/o CCS", "SE|Electricity|Coal|IGCCC|w/ CCS"), technology := "Coal"]
  PE_elec[variable %in% c("SE|Electricity|Oil|DOT"), technology := "Oil"]
  PE_elec[variable %in% c("SE|Electricity|Nuclear"), technology := "Uranium"]
  PE_elec[variable %in% c("SE|Electricity|Hydro"), technology := "Hydro"]
  PE_elec[variable %in% c("SE|Electricity|Geothermal"), technology := "Geothermal"]
  PE_elec = PE_elec[,.(value =sum(value)), by = .(region, year, technology)]
  ## merge all PE
  PE_all = rbind(PE_elec, FE_all[technology != "Electricity"])
  ## summarise the technologies (e.g. fossil electricity production and fossil used directly)
  PE_all = PE_all[,.(value = sum(value)), by = .(region, year, technology)]

  return(PE_all)

}


trsp_PEnewFun =function(demEJ, gdx, miffile, feliq, REMIND2ISO_MAPPING) {
  ## Collect all the FEs
  FE_noliq = miffile[variable %in% c("FE|Transport|Electricity", "FE|Transport|Gases", "FE|Transport|Hydrogen")]

  ## give short names to the FEs
  FE_noliq[variable %in% c("FE|Transport|Electricity"), technology := "Electricity"]
  FE_noliq[variable %in% c("FE|Transport|Gases"), technology := "Gases"]
  FE_noliq[variable %in% c("FE|Transport|Hydrogen"), technology := "Hydrogen"]
  FE_noliq[, variable := NULL]
  FE_all = rbind(FE_noliq, feliq)


  ## collect the effciencies from the gdx
  
  refliq = 0.9 ## refinery oil to SE liquids
  elh2 = 0.8    ## convert electricity to H2
  MeOH = 0.7    ## methanol production
  biodiesel = 0.98  ## oil biomass to biodiesel

  ## calculate the shares of 4W and 2W in LDVs for each energy source(liquids->synfuels,biofuels,fossil,electricity,hydrogen)
  demand_EJ = merge(demEJ, REMIND2ISO_MAPPING, by = "iso")
  demand_EJ[technology %in% c("BEV", "LA-BEV", "Electricity"), technology := "Electricity"]
  demand_EJ[technology %in% c("Liquids", "Hybrid Liquids"), technology := "Oil"]
  demand_EJ[technology %in% c("FCEV"), technology := "Hydrogen"]
  demand_EJ = demand_EJ[,.(demand_EJ = sum(demand_EJ)), by = .(region, year, technology)]
  defos = demand_EJ[technology == "Oil"]
  ## duplicate values for synfuels and biofuels
  demand_EJ = rbind(demand_EJ, defos[, technology := "Synfuel"])
  demand_EJ = rbind(demand_EJ, defos[, technology := "Biomass"])
  ## reduce the FEs according to the shares of 2W and 4W
  FE_all = merge(FE_all, demand_EJ, by = c("region", "year", "technology"))
  ## calculate SE units
  FE_all[technology == "Oil", value := value/refliq]
  FE_all[technology == "Hydrogen", value := value/elh2]
  FE_all[technology == "Synfuel", value := value/elh2/MeOH]
  FE_all[technology == "Biomass", value := value/biodiesel]
  ## attribute electricity tag to h2 and syn
  FE_all[technology %in% c("Hydrogen", "Synfuel"), technology := "Electricity"]
  ## sum up on technology
  FE_all = FE_all[,.(value = sum(value)), by = c("region", "year", "technology")]
  ## collect efficiencies of fossil plants
  eff = data.table(variable = c("SE|Electricity|Gas|CC|w/o CCS", "SE|Electricity|Gas|CCC|w/ CCS", "SE|Electricity|Gas|GT", "SE|Electricity|Gas|CHP|w/o CCS", "SE|Electricity|Coal|PC|w/o CCS", "SE|Electricity|Coal|PCC|w/ CCS", "SE|Electricity|Coal|IGCC|w/o CCS", "SE|Electricity|Coal|IGCCC|w/ CCS", "SE|Electricity|Oil|DOT", "SE|Electricity|Geothermal"), eff = c(0.57, 0.49, 0.38, 0.47, 0.41, 0.36, 0.42, 0.33, 0.3, 0.4))

  ## collect the shares of the different sources in the electricity production
  SEcomp = miffile[variable %in% c("SE|Electricity|Gas|CC|w/o CCS", "SE|Electricity|Gas|CCC|w/ CCS", "SE|Electricity|Gas|GT", "SE|Electricity|Gas|CHP|w/o CCS", "SE|Electricity|Coal|PC|w/o CCS", "SE|Electricity|Coal|PCC|w/ CCS", "SE|Electricity|Coal|IGCC|w/o CCS", "SE|Electricity|Coal|IGCCC|w/ CCS", "SE|Electricity|Oil|DOT", "SE|Electricity|Nuclear", "SE|Electricity|Geothermal", "SE|Electricity|Hydro",  "SE|Electricity|Solar|CSP", "SE|Electricity|Solar|PV", "SE|Electricity|Wind")]
  SEcomp = merge(SEcomp, eff, by = "variable", all.x =TRUE)
  SEcomp[, share := value/sum(value), by = .(region, year)]
  SEcomp[, value:= NULL]
  ## calculate the PE by sources
  PE_elec = merge(FE_all[technology == "Electricity"], SEcomp, by = c("region", "year"))
  ## attribute efficiency 1 to RES
  PE_elec[is.na(eff), eff := 1]
  PE_elec[, value := value*share/eff]
  PE_elec[, c("share", "eff"):= NULL]
  PE_elec[variable == "SE|Electricity|Wind", technology := "Wind"]
  PE_elec[variable %in% c("SE|Electricity|Solar|PV", "SE|Electricity|Solar|CSP"), technology := "Solar"]
  PE_elec[variable %in% c("SE|Electricity|Gas|CC|w/o CCS", "SE|Electricity|Gas|CCC|w/ CCS", "SE|Electricity|Gas|GT", "SE|Electricity|Gas|CHP|w/o CCS"), technology := "Gas"]
  PE_elec[variable %in% c("SE|Electricity|Coal|PC|w/o CCS", "SE|Electricity|Coal|PCC|w/ CCS", "SE|Electricity|Coal|IGCC|w/o CCS", "SE|Electricity|Coal|IGCCC|w/ CCS"), technology := "Coal"]
  PE_elec[variable %in% c("SE|Electricity|Oil|DOT"), technology := "Oil"]
  PE_elec[variable %in% c("SE|Electricity|Nuclear"), technology := "Uranium"]
  PE_elec[variable %in% c("SE|Electricity|Hydro"), technology := "Hydro"]
  PE_elec[variable %in% c("SE|Electricity|Geothermal"), technology := "Geothermal"]
  PE_elec = PE_elec[,.(value =sum(value)), by = .(region, year, technology)]
  ## merge all PE
  PE_all = rbind(PE_elec, FE_all[technology != "Electricity"])
  ## summarise the technologies (e.g. fossil electricity production and fossil used directly)
  PE_all = PE_all[,.(value = sum(value)), by = .(region, year, technology)]

  return(PE_all)

}


emidemFun = function(miffile){
  emidem = miffile[variable %in% c("Emi|CO2|Transport|Pass|Short-Medium Distance|Demand", "Emi|CO2|Transport|Pass|Long Distance|Demand","Emi|CO2|Transport|Freight|Short-Medium Distance|Demand", "Emi|CO2|Transport|Freight|Long Distance|Demand"),]
  return(emidem)
}


emiDemandFun = function(miffile){
  emitail = miffile[grepl("Demand", variable)]
  return(emitail)
}



elecdemFun = function(miffile){
  elecdem = miffile[variable == "SE|Electricity"]
  return(elecdem)

}


investFun = function(miffile){
  invest = miffile[variable %in% c("Energy Investments|Hydrogen", "Energy Investments|Electricity", "Energy Investments|Liquids", "Energy Investments|Gases", "Energy system costs")]
  return(invest)
}

emiSecFun = function(miffile){
   emiSec = miffile[variable %in% c("Emi|CO2|Fossil Fuels and Industry|Energy Supply",
                                      "Emi|CO2|Carbon Capture and Storage|Biomass|Supply|w/ couple prod",
                                      "Emi|CO2|Industry|Direct",
                                      "Emi|CO2|Carbon Capture and Storage|Biomass|Energy|Demand|Industry",
                                      "Emi|CO2|FFaI|Industry|Process",
                                      "Emi|CO2|Transport|Demand",
                                      "Emi|CO2|Buildings|Direct",
                                      "Emi|CO2|Land-Use Change",
                                      "Emi|CO2|Carbon Capture and Storage|Biomass"),]

   emiSec[, variable := as.character(variable)]
   emiSec[, varplot := ifelse(variable == "Emi|CO2|Carbon Capture and Storage|Biomass", "Emi|CO2|CDR|BECCS", NA)]
   emiSec[varplot == "Emi|CO2|CDR|BECCS", value := -value]
   emiSec[, varplot := ifelse(variable %in% c("Emi|CO2|Fossil Fuels and Industry|Energy Supply", "Emi|CO2|Carbon Capture and Storage|Biomass|Supply|w/ couple prod"), "Emi|CO2|Energy|Supply|Gross", varplot)]
   emiSec[, varplot := ifelse(variable %in% c("Emi|CO2|Industry|Direct", "Emi|CO2|Carbon Capture and Storage|Biomass|Energy|Demand|Industry", "Emi|CO2|FFaI|Industry|Process"), "Emi|CO2|Industry|Gross", varplot)]
   emiSec[is.na(varplot), varplot := variable]
   emiSec = emiSec[,.(value = sum(value)), by = c("region", "year", "varplot")]
   return(emiSec)
}

emipSourceFun = function(miffile){

  minyr <- 2015
  maxyr <- 2100

  ## fe hydrogen used for liquids consumption in passenger transport
  h2liqp = miffile[
    variable == "FE|Transport|Pass|Liquids|Hydrogen" &
      year >= minyr & year <= maxyr][
        , .(year, region, fes="feh2l", fe=value)]

  ## fe hydrogen used in passenger transport
  h2p = miffile[
    variable == "FE|Transport|Pass|Hydrogen" &
      year >= minyr & year <= maxyr][
        , .(year, region, fes="feh2", fe=value)]

  ## elec used in passenger transport
  elp = miffile[
    variable == "FE|Transport|Pass|Electricity" &
      year >= minyr & year <= maxyr][
        , .(year, region, fes="el", fe=value)]

  ## final energy electricity
  el = miffile[
    variable == "FE|+|Electricity" &
      year >= minyr & year <= maxyr][
        , .(year, region, fes="el", fe=value)]

  ## emission supply side from electricity
  emiel = miffile[
    variable == "Emi|CO2|Energy|Supply|Electricity|Gross" &
      year >= minyr & year <= maxyr][
        , .(year, region, emis="el", emi=value)]

  ## emissions from transport passenger
  emip = miffile[
    variable == "Emi|CO2|Transport|Pass|Short-Medium Distance|Liquids" &
      year >= minyr & year <= maxyr][
        , .(year, region, source="liq", emi=value)]

  ## calculate fossil electricity carbon intensity
  elint = merge(el, emiel, by = c("year", "region"))
  elint[, int := emi/fe]
  elint = elint[,.(year, region, int)]

  ## calculate emissions from electricity of electrified transport
  emielp = merge(elint, elp, by = c("year", "region"))
  emielp[, emi := int*fe]
  emielp = emielp[,.(year, region, emi, source = "elp")]
  ## estimate the secondary energy from electricity based synfuels in passenger transport
  sesynp = h2liqp[][, se := fe/0.55][, fe := NULL]

  ## estimate the secondary energy from hydrogen in passenger transport
  seh2np = h2p[][, se := fe/0.7][, fe := NULL]

  ## emissions CO2 derived from synfuels in passenger transport
  emisynp = merge(sesynp, elint, by = c("year", "region"))
  emisynp[, emi := se*int]
  emisynp = emisynp[,.(year, region, emi, source = "synf")]
  ## emissions CO2 derived from hydrogen
  emih2p = merge(seh2np, elint, by = c("year", "region"))
  emih2p[, emi := se*int]
  emih2p = emih2p[,.(year, region, emi, source = "h2")]
  ## summarize emissions
  emi_all = rbindlist(list(emih2p, emisynp, emielp, emip), use.names=TRUE)

  return(emi_all)
}

costscompFun = function(newcomp, sharesVS1,  pref_FV, capcost4Wall, capcost4W_BEVFCEV, nonf, totp, REMIND2ISO_MAPPING){

  ## weight of each ISO within region

  ## First I calculate the total demand for new sales using the shares on FV level (in newcomp) and on VS1 level
  newcomp = merge(newcomp, sharesVS1[,.(shareVS1 = share, iso, year, vehicle_type, subsector_L1)], all.x=TRUE, by = c("iso", "year", "vehicle_type", "subsector_L1"))
  newcomp[, newdem := totdem*sharetech_new*shareVS1]
  newcomp = newcomp[,.(value = sum(newdem)), by = c("iso", "year", "subsector_L1")]

  ## merge with region mapping
  newcomp = merge(newcomp, REMIND2ISO_MAPPING, by = "iso")
  ## weight of each country within the region
  newcomp[, weightiso := value/sum(value), by = c("year", "region")]

  ## inconvenience components

  ## I calculate the inconvenience cost value (disrespective to the vehicle type)
  inc = sharesVS1[subsector_L1 == "trn_pass_road_LDV_4W",.(shareVS1 = share, iso, year, vehicle_type, subsector_L1)]
  inc = merge(inc, pref_FV, by = c("iso", "year", "vehicle_type"))
  ## average car (lost small, large dimension) in each ISO
  inc = inc[,.(cost = sum(value*shareVS1)), by = c("iso", "technology", "year", "logit_type")]
  ## I calculate the weighted regional values
  inc = merge(inc, newcomp, allow.cartesian = TRUE,by = c("iso", "year"))
  ## average cost is given by the costs weighted for the ISO importance in the region
  inc[, costave := cost*weightiso]
  inc = inc[,.(cost=sum(costave)), by = c("year", "technology", "region", "logit_type")]

  ##  fuel prices

  ## fuel prices are only available in the total price dt
  fp = totp[subsector_L1 == "trn_pass_road_LDV_4W", c("iso", "year", "technology","vehicle_type", "fuel_price_pkm")]
  ## I calculate the fuel price value (disrespective to the vehicle type)
  fp = merge(fp, sharesVS1[subsector_L1 == "trn_pass_road_LDV_4W",.(shareVS1 = share, iso, year, vehicle_type, subsector_L1)], all.y = TRUE, by = c("iso", "year", "vehicle_type"))

  ## average car (lost small, large dimension) in each ISO
  fp = fp[,.(fp = sum(fuel_price_pkm*shareVS1)), by = c("iso", "technology", "year")]
  fp[, variable := "fuel_price"]
  ## average cost is given by the costs weighted for the ISO importance in the region
  fp = merge(fp, newcomp, allow.cartesian = TRUE,by = c("iso", "year"))
  fp[, fp_priceave := fp*weightiso]
  fp=fp[,.(cost = sum(fp_priceave)), by = c("year", "technology", "region", "variable")]
  setnames(fp, old = "variable", new = "logit_type")

  nonf = nonf[, .(non_fuel_price = sum(non_fuel_price)), by = c("iso", "year", "technology", "vehicle_type")]

  ## merge capital cost for BEVs and FCEVs with technologies without learning
  capc = rbind(capcost4Wall, capcost4W_BEVFCEV[, c("iso", "year", "technology", "type", "price_component", "vehicle_type", "non_fuel_price")])
  capc = capc[, .(purchase = sum(non_fuel_price)), by = c("iso", "year", "technology", "vehicle_type")]

  ## find non-capital component as a difference between total and purchase
  nonf = merge(nonf, capc, by = c("iso", "year", "vehicle_type", "technology"))
  nonf[, other := non_fuel_price-purchase]
  nonf[, non_fuel_price := NULL]
  nonf= melt(nonf, id.vars = c("iso", "year", "technology", "vehicle_type"))

  ## I calculate the non fuel costs value (disrespective to the vehicle type)
  nonf = merge(nonf, sharesVS1[subsector_L1 == "trn_pass_road_LDV_4W",.(shareVS1 = share, iso, year, vehicle_type, subsector_L1)], by = c("iso", "year", "vehicle_type"))

  ## average car in ISO
  nonf = nonf[,.(nonf = sum(value*shareVS1)), by = c("iso", "technology", "year", "variable")]
  ## average cost is given by the costs weighted for the ISO importance in the region
  nonf = merge(nonf, newcomp, allow.cartesian = TRUE,by = c("iso", "year"))
  nonf[, non_fuel_priceave := nonf*weightiso]
  nonf=nonf[,.(cost = sum(non_fuel_priceave)), by = c("year", "technology", "region", "variable")]
  setnames(nonf, old = "variable", new = "logit_type")

  ## dt containing all cost components
  tmp = rbindlist(list(nonf, inc, fp))

  ## attribute factors
  tmp[, technology := factor(technology, levels = c("BEV", "Hybrid Electric", "FCEV", "Hybrid Liquids", "Liquids", "NG"))]

  return(tmp)
}


demgdpcap_Fun = function(demkm, REMIND2ISO_MAPPING) {
  GDP_POP = getRMNDGDPcap()
  GDP_POP = merge(GDP_POP, REMIND2ISO_MAPPING, by = "iso")
  ## regional GDP cap
  GDP_POP = GDP_POP[,.(GDP = sum(weight), POP = sum(POP_val)), by = c("region", "year")]
  GDP_POP[, gdpcap := GDP/POP]


  demkm = merge(demkm, REMIND2ISO_MAPPING, by = "iso")
  demkm = demkm[,.(demand_F = sum(demand_F)), by = c("region", "year", "sector", "subsector_L3", "subsector_L2", "subsector_L1")]
  demcap_gdp = merge(demkm, GDP_POP, by = c("region", "year"))

  ## define if land, water or air application
  demcap_gdp[, appl := ifelse(subsector_L3 %in% c("Domestic Aviation", "International Aviation"), "Air", NA)]
  demcap_gdp[, appl := ifelse(subsector_L3 %in% c("Domestic Ship", "International Ship"), "Marine", appl)]
  demcap_gdp[, appl := ifelse(is.na(appl) & sector %in% c("trn_pass", "trn_aviation_intl"), "Land-Pass", appl)]
  demcap_gdp[, appl := ifelse(is.na(appl) & sector %in% c("trn_freight", "trn_shipping_intl"), "Land-Freight", appl)]

  ## define most disaggregated values to plot
  demcap_gdp[, type := ifelse(subsector_L2 %in% c("Bus"), subsector_L2, NA)]
  demcap_gdp[, type := ifelse(subsector_L2 %in% c("Domestic Aviation_tmp_subsector_L2", "International Aviation_tmp_subsector_L2"), "Aviation (international+domestic)", type)]
  demcap_gdp[, type := ifelse(subsector_L2 %in% c("Domestic Ship_tmp_subsector_L2", "International Ship_tmp_subsector_L2"), "Shipping (international+domestic)", type)]
  demcap_gdp[, type := ifelse(subsector_L2 %in% c("Passenger Rail_tmp_subsector_L2", "HSR_tmp_subsector_L2"), "Passenger Rail (normal+HSR)", type)]
  demcap_gdp[, type := ifelse(subsector_L2 %in% c("trn_pass_road_bus"), "Bus", type)]
  demcap_gdp[, type := ifelse(subsector_L2 %in% c("Freight Rail_tmp_subsector_L2", "Walk_tmp_subsector_L2", "Cycle_tmp_subsector_L2"), gsub("_tmp_subsector_L2","", subsector_L2), type)]
  demcap_gdp[, type := ifelse(subsector_L2 == "trn_pass_road_LDV", "LDV", type)]
  demcap_gdp[, type := ifelse(subsector_L2 == "trn_freight_road_tmp_subsector_L2", "Road freight", type)]

  ## partial sums
  demcap_gdp = demcap_gdp[, demsec := sum(demand_F), by = .(region, sector, year)]
  demcap_gdp = demcap_gdp[, demappl := sum(demand_F), by = .(region, appl, year)]
  demcap_gdp = demcap_gdp[, demtype := sum(demand_F), by = .(region, type, year)]

  ## per capita values
  demcap_gdp[, demsec := demsec/    ## in million km
               POP]                 ## in million km/million people=pkm/person

  demcap_gdp[, demappl := demappl/  ## in million km
               POP]                 ## in million km/million people=pkm/person

  demcap_gdp[, demtype := demtype/  ## in million km
               POP]    ## in million km/million people=pkm/person

  demcap_gdp = unique(demcap_gdp[, c("region", "year", "demsec", "demappl", "demtype", "appl", "type", "sector", "gdpcap")])

  return(demcap_gdp)
}





for (outputdir in outputdirs) {
  ## load mif file
  name_mif = list.files(path = outputdir, pattern = "REMIND_generic", full.names = F)
  name_mif = name_mif[!grepl("withoutPlu", name_mif)]
  miffile <- as.data.table(read.quitte(paste0(outputdir, "/", name_mif)))
  miffile[, region := as.character(region)]
  miffile[, year := period]
  miffile[, period := NULL]
  miffile = miffile[region != "World" & year >= 2015 & year <= 2100]
  miffile[, variable := as.character(variable)]
  ## load gdx file
  gdx = paste0(outputdir, "/fulldata.gdx")

  ## load RDS files
  sharesVS1 = readRDS(paste0(outputdir, "/EDGE-T/shares.RDS"))[["VS1_shares"]]
  newcomp = readRDS(paste0(outputdir, "/EDGE-T/newcomp.RDS"))
  vintcomp = readRDS(paste0(outputdir, "/EDGE-T/vintcomp.RDS"))
  shares_LDV = readRDS(paste0(outputdir, "/EDGE-T/annual_sales.RDS"))
  demandEJ = readRDS(paste0(outputdir, "/EDGE-T/demandF_plot_EJ.RDS"))
  demandkm = readRDS(paste0(outputdir, "/EDGE-T/demandF_plot_pkm.RDS"))
  mj_km_data = readRDS(paste0(outputdir, "/EDGE-T/mj_km_data.RDS"))
  loadFactor = readRDS(paste0(outputdir, "/EDGE-T/loadFactor.RDS"))
  pref_FV = readRDS(paste0(outputdir, "/EDGE-T/pref_output.RDS"))[["FV_final_pref"]]
  nonf = readRDS(paste0(outputdir, "/nonfuel_costs_learning.RDS"))
  capcost4Wall = readRDS(paste0(outputdir, "/EDGE-T/UCD_NEC_iso.RDS"))[(price_component == "Capital_costs_purchase") & ((!technology %in% c("BEV", "FCEV"))|(technology %in% c("BEV", "FCEV") & year < 2020))]
  capcost4W_BEVFCEV = readRDS(paste0(outputdir, "/capcost_learning.RDS")) ## starts at 2020

  ## read in fuel prices
  files<- list.files(path = paste0(outputdir, "/EDGE-T"), pattern = "REMINDprices")
  ## only the last iteration is to be used
  file = files[grepl(max(as.numeric(gsub("\\D", "", files))), files)]
  if (length(file)>1){
    file = file[grepl("Dampened", file)]
  }
  totp = readRDS(paste0(outputdir, "/EDGE-T/", file))

  ## load population and GDP
  POP_country=calcOutput("Population", aggregate = F)[,, "pop_SSP2"]
  POP <- magpie2dt(POP_country, regioncol = "iso",
                   yearcol = "year", datacols = "POP")
  gdp <- getRMNDGDP(scenario = "gdp_SSP2", usecache = T)
  #browser()
  if (nrow(miffile[variable %in% c("FE|Transport|Liquids|LDV|Biomass|New Reporting")])==0) {
    TWa_2_EJ     <- 31.536
    prodFE  <- readGDX(gdx,name=c("vm_prodFe"),field="l",restore_zeros=FALSE,format="first_found")*TWa_2_EJ
    tmp1=mbind(setNames(collapseNames(prodFE[,,"seliqbio.fepet.tdbiopet"]),
                        "FE|Transport|Liquids|LDV|Biomass|New Reporting"),
               setNames(collapseNames(prodFE[,,"seliqfos.fepet.tdfospet"]),
                        "FE|Transport|Liquids|LDV|Fossil|New Reporting"),
               setNames(collapseNames(prodFE[,,"seliqbio.fedie.tdbiodie"]),
                        "FE|Transport|Liquids|HDV|Biomass|New Reporting"),
               setNames(collapseNames(prodFE[,,"seliqfos.fedie.tdfosdie"]),
                        "FE|Transport|Liquids|HDV|Fossil|New Reporting"))



    tmp1=magpie2dt(tmp1)
    setnames(tmp1, old = c("all_regi", "ttot", "data"), new = c("region", "year", "variable"))
    tmp1[, model := unique(miffile$model)]
    tmp1[, scenario := unique(miffile$scenario)]
    tmp1[, unit := "EJ/yr"]
    feliqsyn = tmp1[variable %in% c("FE|Transport|Liquids|LDV|Fossil|New Reporting", "FE|Transport|Liquids|HDV|Fossil|New Reporting")]
    feliqsyn[, c("value", "variable") := list(0, gsub("Fossil", "Synfuel", variable ))]
    FEliq_source=rbind(tmp1, feliqsyn)
    ## add the totals
    FEliq_source_tot = copy(FEliq_source)
    FEliq_source_tot[, tech := str_extract(variable, "Biomass|Fossil|Synfuel")]
    FEliq_source_tot = FEliq_source_tot[,.(value = sum(value)), by = .(region, year,model,scenario, unit, tech)]
    FEliq_source_tot[, variable:= paste0("FE|Transport|Liquids|", tech, "|New Reporting")][, tech := NULL]
    FEliq_source = rbind(FEliq_source, FEliq_source_tot)
    FEliq_source_tot=FEliq_source[variable %in% c("FE|Transport|Liquids|Biomass|New Reporting",
                                                  "FE|Transport|Liquids|Synthetic|New Reporting",
                                                  "FE|Transport|Liquids|Fossil|New Reporting")]

    FEliq_source_tot[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Fossil|New Reporting", "FE|Transport|Pass|Road|LDV|Liquids"), "Oil", NA)]
    FEliq_source_tot[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Biomass|New Reporting"), "Biomass", technology)]
    FEliq_source_tot[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Synthetic|New Reporting"), "Synfuel", technology)]


  } else {
    ## select useful entries from mif file
    FEliq_source = miffile[variable %in% c("FE|Transport|Pass|Road|LDV|Liquids",
                                           "FE|Transport|Liquids|LDV|Biomass|New Reporting",
                                           "FE|Transport|Liquids|LDV|Synthetic|New Reporting",
                                           "FE|Transport|Liquids|LDV|Fossil|New Reporting",
                                           "FE|Transport|Liquids",
                                           "FE|Transport|Liquids|Biomass|New Reporting",
                                           "FE|Transport|Liquids|Synthetic|New Reporting",
                                           "FE|Transport|Liquids|Fossil|New Reporting",
                                           "FE|Transport|Pass|Road|HDV|Liquids",
                                           "FE|Transport|Liquids|HDV|Biomass|New Reporting",
                                           "FE|Transport|Liquids|HDV|Synthetic|New Reporting",
                                           "FE|Transport|Liquids|HDV|Fossil|New Reporting"),]

    FEliq_source[year <= 2020 , value := ifelse(variable == "FE|Transport|Liquids|LDV|Fossil|New Reporting", value[variable == "FE|Transport|Pass|Road|LDV|Liquids"],value), by = c("region", "year")]
    FEliq_source[year <= 2020 & variable %in% c("FE|Transport|Liquids|LDV|Biomass|New Reporting", "FE|Transport|Liquids|LDV|Synthetic|New Reporting"), value := 0]

    FEliq_source[year <= 2020 , value := ifelse(variable == "FE|Transport|Liquids|HDV|Fossil|New Reporting", value[variable == "FE|Transport|Pass|Road|HDV|Liquids"],value), by = c("region", "year")]
    FEliq_source[year <= 2020 & variable %in% c("FE|Transport|Liquids|HDV|Biomass|New Reporting", "FE|Transport|Liquids|HDV|Synthetic|New Reporting"), value := 0]

    FEliq_source[year <= 2020 , value := ifelse(variable == "FE|Transport|Liquids|Fossil|New Reporting", value[variable == "FE|Transport|Liquids"],value), by = c("region", "year")]
    FEliq_source[year <= 2020 & variable %in% c("FE|Transport|Liquids|Biomass|New Reporting", "FE|Transport|Liquids|Synthetic|New Reporting"), value := 0]



    ## remove the value that was used to repair the NAs
    FEliq_source = FEliq_source[!variable %in% c("FE|Transport|Pass|Road|LDV|Liquids", "FE|Transport|Pass|Road|HDV|Liquids", "FE|Transport|Liquids")]
    FEliq_source_tot=FEliq_source[variable %in% c("FE|Transport|Liquids|Biomass|New Reporting",
                                                  "FE|Transport|Liquids|Synthetic|New Reporting",
                                                  "FE|Transport|Liquids|Fossil|New Reporting")]

    FEliq_source_tot[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Fossil|New Reporting", "FE|Transport|Pass|Road|LDV|Liquids"), "Oil", NA)]
    FEliq_source_tot[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Biomass|New Reporting"), "Biomass", technology)]
    FEliq_source_tot[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Synthetic|New Reporting"), "Synfuel", technology)]

  }

  ## modify mif file entries to be used in the functions
  FEliq_source = FEliq_sourceFun(FEliq_source, gdp)

  newcompLDVs = newcomp[subsector_L1 == "trn_pass_road_LDV_4W"]
  ## calculate sales
  salescomp = SalesFun(shares_LDV, newcompLDVs, sharesVS1)
  ## calculate fleet compositons
  fleet = fleetFun(vintcomp, newcompLDVs, sharesVS1, loadFactor)
  ## calculate EJ from LDVs by technology
  EJroad = EJroadFun(demandEJ)
  ## calculate FE demand by mode
  EJmode = EJmodeFun(demandEJ)
  ## calculate ES demand per capita
  ESmode = ESmodeFun(demandkm, POP)
  ESmodecap = ESmode[["demandkm"]]
  ESmodeabs = ESmode[["demandkm_abs"]]
  ## calculate average emissions intensity from the LDVs fleet
  CO2km_int_newsales = CO2km_int_newsales_Fun(shares_LDV, mj_km_data, sharesVS1, FEliq_source$FEliq_sourceISO, gdp)
  ## calculate FE for all transport sectors by fuel, dividng Oil into Biofuels and Synfuels
  EJfuels = EJfuelsFun(demandEJ, FEliq_source$FEliq_sourceR)
  EJfuelsPass = EJfuels[["demandEJpass"]]
  EJfuelsFrgt = EJfuels[["demandEJfrgt"]]
  ## calculate FE for selected modes by fuel, dividing Oil into Biofuels and Synfuels
  EJfuelsMode = EJfuelsModeFun(demandEJ, FEliq_source$FEliq_sourceR)
  ## calculate demand emissions
  emidem = emidemFun(miffile)
  ## tailpipe emissions
  emiDemand = emiDemandFun(miffile)
  ## sectoral emissions
  emiSec = emiSecFun(miffile)
  ## calculate emissions from passenger SM fossil fuels (liquids)
  emipSource =  emipSourceFun(miffile)
  ## secondary energy electricity demand
  elecdem = elecdemFun(miffile)
  ## calculate costs by component
  costs = costscompFun(newcomp = newcompLDVs, sharesVS1 = sharesVS1, pref_FV = pref_FV, capcost4Wall = capcost4Wall, capcost4W_BEVFCEV = capcost4W_BEVFCEV, nonf = nonf, totp = totp, REMIND2ISO_MAPPING)
  ## per capita demand-gdp per capita
  demgdpcap = demgdpcap_Fun(demkm = demandkm, REMIND2ISO_MAPPING)
  ## investments in different energy carriers
  invest = investFun(miffile)
  ## primary energy
  LDV_PEnew = LDV_PEnewFun(demEJ = demandEJ, gdx, miffile, FEliq_source = FEliq_source$FEliq_sourceR, REMIND2ISO_MAPPING)
  trsp_PEnew = trsp_PEnewFun(demEJ = demandEJ, gdx, miffile, feliq = FEliq_source_tot[, variable := NULL], REMIND2ISO_MAPPING)
  ## add scenario dimension to the results
  allentries = list(fleet = fleet,
                    salescomp = salescomp,
                    EJroad = EJroad,
                    EJmode = EJmode,
                    ESmodecap = ESmodecap,
                    ESmodeabs = ESmodeabs,
                    CO2km_int_newsales =CO2km_int_newsales,
                    emidem = emidem,
                    emiDemand = emiDemand,
                    emiSec = emiSec,
                    EJfuelsPass = EJfuelsPass,
                    EJfuelsFrgt = EJfuelsFrgt,
                    EJfuelsMode = EJfuelsMode,
                    emipSource = emipSource,
                    elecdem = elecdem,
                    costs = costs,
                    pref_FV = pref_FV,
                    demgdpcap = demgdpcap,
                    invest = invest,
                    LDV_PEnew = LDV_PEnew,
                    trsp_PEnew = trsp_PEnew)

  allentries = lapply(allentries, function(x) x[,scenario := as.character(unique(miffile$scenario))])

  ## rbind scenarios

for (i in names(allentries)) {
  j = paste0(i, "_all")
  alltosave[[j]] = rbind(alltosave[[j]], allentries[[i]])
}

}

## create string with date and time
time = gsub(":",".",gsub(" ","_",Sys.time()))
## create output folder
outdir = paste0("output/comparerunEDGE", time)
dir.create(outdir)
## names of the output files
md_template = "EDGETransportComparison.Rmd"
## save RDS files
lapply(names(alltosave), function(nm)
  saveRDS(alltosave[[nm]], paste0(outdir, "/",nm,".RDS")))

## create a txt file containing the run names
write.table(outputdirs, paste0(outdir, "/run_names.txt"), append = FALSE, sep = " ", quote = FALSE,
            row.names = FALSE, col.names = FALSE)


file.copy(file.path("./scripts/output/comparison/notebook_templates", md_template), outdir)
rmarkdown::render(path(outdir, md_template), output_format="pdf_document")



