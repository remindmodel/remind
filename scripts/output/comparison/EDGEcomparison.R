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


emi_all = NULL
salescomp_all = NULL
fleet_all = NULL
EJLDV_all = NULL
EJmode_all = NULL
ESmodecap_all = NULL
CO2km_int_newsales_all = NULL
EJfuels_all = NULL
emidem_all = NULL

scenNames <- getScenNames(outputdirs)
EDGEdata_path  <- path(outputdirs, paste("EDGE-T/"))
gdx_path  <- path(outputdirs,gdx_name)
scenNames <- getScenNames(outputdirs)

names(gdx_path) <- scenNames
names(EDGEdata_path) <- scenNames

REMIND2ISO_MAPPING <- fread("config/regionmappingH12.csv")[, .(iso = CountryCode, region = RegionCode)]



SalesFun = function(shares_LDV, newcomp, sharesVS1){
  ## I need the total demand for each region to get the average composition in Europe (sales are on a country level)
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


fleetFun = function(vintcomp, newcomp, sharesVS1){
  vintcomp = vintcomp[,.(totdem, iso, subsector_L1, year, technology,vehicle_type, sector, sharetech_vint)]
  newcomp = newcomp[,.(iso, subsector_L1, year, technology,vehicle_type, sector, sharetech_new)]
  
  allfleet = merge(newcomp, vintcomp, all =TRUE, by = c("iso", "sector", "subsector_L1", "vehicle_type", "technology",  "year"))
  allfleet = merge(allfleet, sharesVS1[,.(shareVS1 = share, iso, year, vehicle_type, subsector_L1)], all.x=TRUE, by = c("iso", "year", "vehicle_type", "subsector_L1"))
  allfleet[,vintdem:=totdem*sharetech_vint*shareVS1]
  allfleet[,newdem:=totdem*sharetech_new*shareVS1]
  allfleet=melt(allfleet, id.vars = c("iso", "sector", "subsector_L1", "vehicle_type", "technology",
                                      "year"), measure.vars = c("vintdem", "newdem"))
  allfleet[,alpha:=ifelse(variable == "vintdem", 0, 1)]
  
  load_factor = 1.5
  annual_mileage = 15000
  allfleet = allfleet[,.(value = sum(value/load_factor/annual_mileage)), by = c("iso", "technology", "variable", "year")]
  
  allfleet = merge(allfleet, REMIND2ISO_MAPPING, by = "iso")
  allfleet = allfleet[,.(value = sum(value)), by = c("region", "technology", "variable", "year")]
  allfleet[,alphaval := ifelse(variable =="vintdem", 1,0)]
  allfleet[, technology := factor(technology, levels = c("BEV", "Hybrid Electric", "FCEV", "Hybrid Liquids", "Liquids", "NG"))]
  
  return(allfleet)
}


EJLDVFun <- function(demandEJ){
  demandEJ = demandEJ[subsector_L1 == "trn_pass_road_LDV_4W",]
  demandEJ <- demandEJ[, c("sector", "subsector_L3", "subsector_L2", "subsector_L1", "vehicle_type", "technology", "iso", "year", "demand_EJ")]
  
  demandEJ = merge(demandEJ, REMIND2ISO_MAPPING, by = "iso")
  demandEJ[technology == "Hybrid Liquids", technology := "Liquids"]
  demandEJ[technology == "FCEV", technology := "Hydrogen"]
  demandEJ[technology == "BEV", technology := "Electricity"]
  demandEJ = demandEJ[, .(demand_EJ = sum(demand_EJ)), by = c("region", "year", "technology")]
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


ESmodecapFun = function(demandkm, POP){
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
  demandkm = demandkm[,.(demand_F = sum(demand_F)), by = c("iso", "year", "aggr_mode", "veh")]
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
  demandkm = demandkm[, .(demand_F = sum(demand_F)), by = c("region", "year", "vehicle_type_plot", "aggr_mode", "mode")]
  
  demandkm = merge(demandkm, POP, all.x = TRUE, by =c("year", "region"))
  
  ## calculate per capita values
  demandkm = demandkm[order(aggr_mode)]
  demandkm[, cap_dem := demand_F/    ## in million km
                         pop]         ## in million km/million people=pkm/person
  
  demandkm = demandkm[year >= 2015 & year <= 2100]
  
  return(demandkm)
  
}

FEliq_sourceFun = function(FEliq_source, gdp){
    ## Attribute oil and biodiesel (TODO Coal2Liquids is accounted for as Oil!
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Oil", "FE|Transport|Liquids|Coal"), "Oil", NA)]
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Biomass"), "Biodiesel", technology)]
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|Hydrogen"), "Synfuel", technology)]
  FEliq_source = FEliq_source[,.(value = sum(value)), by = c("model", "scenario", "region", "year", "unit", "technology")]
  
  FEliq_sourceR = FEliq_source[][, shareliq := value/sum(value),by=c("region", "year")]
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
  demandEJ = demandEJ[, .(demand_EJ = sum(demand_EJ)), by = c("region", "year","technology")]
  ## merge with liquids composition
  demandEJ = merge(demandEJ, FEliq_source, all = TRUE, by = c("region", "year", "technology"), allow.cartesian=TRUE)
  ## fuels that are not Liquids need a 1 as a share, otherwie would have an NA
  demandEJ[, shareliq := ifelse(is.na(shareliq), 1, shareliq)]
  demandEJ[, subtech := ifelse(is.na(subtech), technology, subtech)]
  ## calculate demand by fuel including oil types
  demandEJ = demandEJ[,.(demand_EJ = demand_EJ*shareliq), by = c("region", "year", "subtech")]
  ## filter out years
  demandEJ = demandEJ[year >= 2015 & year <= 2100]
  
  return(demandEJ)
}

emidemFun = function(emidem){
  emidem = emidem[region!="World" & year >= 2015 & year <= 2100]
  emidem[, variable := as.character(variable)]
  return(emidem)
}


for (outputdir in outputdirs) {
  ## load mif file
  name_mif = list.files(path = outputdir, pattern = "REMIND_generic", full.names = F)
  name_mif = name_mif[!grepl("withoutPlu", name_mif)]
  miffile <- as.data.table(read.quitte(paste0(outputdir, "/", name_mif)))
  miffile[, region:=as.character(region)]
  miffile[, year := period]
  miffile[, period:=NULL]
  miffile = miffile[region != "World"]

  ## load RDS files
  sharesVS1 = readRDS(paste0(outputdir, "/EDGE-T/", "shares.RDS"))[["VS1_shares"]]
  newcomp = readRDS(paste0(outputdir, "/EDGE-T/", "newcomp.RDS"))
  vintcomp = readRDS(paste0(outputdir, "/EDGE-T/", "vintcomp.RDS"))
  shares_LDV = readRDS(paste0(outputdir, "/EDGE-T/", "annual_sales.RDS"))
  demandEJ = readRDS(paste0(outputdir, "/EDGE-T/", "demandF_plot_EJ.RDS"))
  demandkm = readRDS(paste0(outputdir, "/EDGE-T/", "demandF_plot_pkm.RDS"))
  mj_km_data = readRDS(paste0(outputdir, "/EDGE-T/", "mj_km_data.RDS"))

  ## load population and GDP
  POP_country=calcOutput("Population", aggregate = F)[,, "pop_SSP2"]
  POP <- magpie2dt(POP_country, regioncol = "iso",
                     yearcol = "year", datacols = "POP")
  gdp <- getRMNDGDP(scenario = "gdp_SSP2", usecache = T)
  
  ## select useful entries from mif file
  FEliq_source = miffile[variable %in% c("FE|Transport|Liquids|Biomass", "FE|Transport|Liquids|Hydrogen", "FE|Transport|Liquids|Coal", "FE|Transport|Liquids|Oil"),]
  emidem = miffile[variable %in% c("Emi|CO2|Transport|Demand"),]
  ## modify mif file entries to be used in the functions
  FEliq_source = FEliq_sourceFun(FEliq_source, gdp)


  ## calculate sales
  salescomp = SalesFun(shares_LDV, newcomp, sharesVS1)
  ## calculate fleet compositons
  fleet = fleetFun(vintcomp, newcomp, sharesVS1)
  ## calculate EJ from LDVs by technology
  EJLDV = EJLDVFun(demandEJ)
  ## calculate FE demand by mode
  EJmode = EJmodeFun(demandEJ)
  ## calculate ES demand per capita
  ESmodecap = ESmodecapFun(demandkm, POP)
  ## calculate average emissions intensity from the LDVs fleet
  CO2km_int_newsales = CO2km_int_newsales_Fun(shares_LDV, mj_km_data, sharesVS1, FEliq_source$FEliq_sourceISO, gdp)
  ## calculate FE for all transport sectors by fuel, dividng Oil into Biofuels and Synfuels
  EJfuels = EJfuelsFun(demandEJ, FEliq_source$FEliq_sourceR)
  ## calculate demand emissions
  emidem = emidemFun(emidem)
  
  ## add scenario dimension to the results
  fleet[, scenario := as.character(unique(miffile$scenario))]
  salescomp[, scenario := unique(miffile$scenario)]
  EJLDV[, scenario := as.character(unique(miffile$scenario))]
  EJmode[, scenario := as.character(unique(miffile$scenario))]
  ESmodecap[, scenario := as.character(unique(miffile$scenario))]
  CO2km_int_newsales[, scenario := as.character(unique(miffile$scenario))]
  EJfuels[, scenario := as.character(unique(miffile$scenario))]
  emidem[, scenario := as.character(unique(miffile$scenario))]

  ## rbind scenarios
  salescomp_all = rbind(salescomp_all, salescomp)
  fleet_all = rbind(fleet_all, fleet)
  EJLDV_all = rbind(EJLDV_all, EJLDV)
  EJmode_all = rbind(EJmode_all, EJmode)
  ESmodecap_all = rbind(ESmodecap_all, ESmodecap)
  CO2km_int_newsales_all = rbind(CO2km_int_newsales_all, CO2km_int_newsales)
  EJfuels_all = rbind(EJfuels_all, EJfuels)
  emidem_all = rbind(emidem_all, emidem)
}

outdir = paste0("output/comparerunEDGE", gsub(" | ^([[:alpha:]]*).*","", Sys.time()))
dir.create(outdir)
md_template = "EDGETransportComparison.Rmd"
dash_template = "EDGEdashboard.Rmd"

saveRDS(EJmode_all, paste0(outdir, "/EJmode_all.RDS"))
saveRDS(salescomp_all, paste0(outdir, "/salescomp_all.RDS"))
saveRDS(fleet_all, paste0(outdir, "/fleet_all.RDS"))
saveRDS(EJLDV_all, paste0(outdir, "/EJLDV_all.RDS"))
saveRDS(ESmodecap_all, paste0(outdir, "/ESmodecap_all.RDS"))
saveRDS(CO2km_int_newsales_all, paste0(outdir, "/CO2km_int_newsales_all.RDS"))
saveRDS(EJfuels_all, paste0(outdir, "/EJfuels_all.RDS"))
saveRDS(emidem_all, paste0(outdir, "/emidem_all.RDS"))
file.copy(file.path("./scripts/output/comparison/notebook_templates", md_template), outdir)
rmarkdown::render(path(outdir, md_template), output_format="pdf_document")

## if it's a 4 scenarios comparison across ConvCase, SynSurge, ElecEra, and HydrHype. run the dashboard
if (length(outputdirs) == 4 &
    isTRUE(any(grepl("SynSurge", outputdirs))) &
    isTRUE(any(grepl("ConvCase", outputdirs))) &
    isTRUE(any(grepl("ElecEra", outputdirs))) &
    isTRUE(any(grepl("HydrHype", outputdirs))) ){
 file.copy(file.path("./scripts/output/comparison/notebook_templates/helper_dashboard.R"), outdir)
 file.copy(file.path("./scripts/output/comparison/notebook_templates", dash_template), outdir)
 rmarkdown::render(path(outdir, dash_template))
}

