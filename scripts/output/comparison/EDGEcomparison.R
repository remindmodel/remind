# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
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
require(mrremind)
require(edgeTrpLib)
require(gdx)
require(gdxdt)
require(stringr)
setConfig(forcecache = TRUE)
setConfig(regionmapping = "regionmappingH12.csv")
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
                 EJModeFuel_all = NULL,
                 ESmodecap_all = NULL,
                 emidem_all = NULL,
                 EJfuelsPass = NULL,
                 EJfuelsFrgt = NULL,
                 costs_all = NULL,
                 pref_FV_all = NULL,
                 demgdpcap_all = NULL)

scenNames <- getScenNames(outputdirs)
EDGEdata_path  <- path(outputdirs, paste("EDGE-T/"))
gdx_path  <- path(outputdirs,gdx_name)
scenNames <- getScenNames(outputdirs)

names(gdx_path) <- scenNames
names(EDGEdata_path) <- scenNames

SalesFun = function(shares_LDV, newcomp, sharesVS1){
  ## I need the total demand for each region to get the average composition in the region (sales are on a country level)
  ## First I calculate the total demand for new sales using the shares on FV level (in newcomp) and on VS1 level
  newcomp = merge(newcomp, sharesVS1[,.(shareVS1 = share, region, year, vehicle_type, subsector_L1)], all.x=TRUE, by = c("region", "year", "vehicle_type", "subsector_L1"))
  newcomp[, newdem := totdem*sharetech_new*shareVS1]
  newcomp = newcomp[,.(value = sum(newdem)), by = c("region", "year", "subsector_L1")]
  ## I have to interpolate in time the sales nto to loose the sales composition annual values
  newcomp=approx_dt(dt=newcomp, unique(shares_LDV$year),
                    xcol= "year",
                    ycol = "value",
                    idxcols=c("region","subsector_L1"),
                    extrapolate=T)

  setnames(newcomp, new = "newdem", old = "value")

  ## I calculate the sales composition (disrespective to the vehicle type)
  shares_LDV = unique(shares_LDV[,c("region","year", "technology", "shareFS1")])
  shares_LDV <- shares_LDV[,.(shareFS1=sum(shareFS1)),by=c("region","technology","year")]

  ## I calculate the weighted regional sales (depending on the total volume of sales per country in each region)
  shares_LDV = merge(shares_LDV, newcomp)
  shares_LDV[, demfuel := shareFS1*newdem, by = c("year", "region", "technology")]
  shares_LDV = shares_LDV[, .(demfuel = sum(demfuel)), by = c("year", "region", "technology")]
  shares_LDV[, shareFS1 := demfuel/sum(demfuel), by = c("year", "region")]

  ## plot features
  shares_LDV[, technology := factor(technology, levels = c("BEV", "Hybrid Electric", "FCEV", "Liquids", "NG"))]

  return(shares_LDV)
}


fleetFun = function(vintcomp, newcomp, sharesVS1, loadFactor){
  vintcomp = vintcomp[,.(totdem, region, subsector_L1, year, technology,vehicle_type, sector, sharetech_vint)]
  newcomp = newcomp[,.(region, subsector_L1, year, technology,vehicle_type, sector, sharetech_new)]

  allfleet = merge(newcomp, vintcomp, all =TRUE, by = c("region", "sector", "subsector_L1", "vehicle_type", "technology",  "year"))
  allfleet = merge(allfleet, sharesVS1[,.(shareVS1 = share, region, year, vehicle_type, subsector_L1)], all.x=TRUE, by = c("region", "year", "vehicle_type", "subsector_L1"))
  allfleet[,vintdem:=totdem*sharetech_vint*shareVS1]
  allfleet[,newdem:=totdem*sharetech_new*shareVS1]
  allfleet=melt(allfleet, id.vars = c("region", "sector", "subsector_L1", "vehicle_type", "technology",
                                      "year"), measure.vars = c("vintdem", "newdem"))
  allfleet[,alpha:=ifelse(variable == "vintdem", 0, 1)]

  allfleet = merge(allfleet, loadFactor, all.x = TRUE, by = c("region", "vehicle_type", "year"))
  annual_mileage = 13000
  allfleet = allfleet[,.(value = sum(value/1.5/annual_mileage)), by = c("region", "technology", "variable", "year")]

  allfleet = allfleet[,.(value = sum(value)), by = c("region", "technology", "variable", "year")]
  allfleet[,alphaval := ifelse(variable =="vintdem", 1,0)]
  allfleet[, technology := factor(technology, levels = c("BEV", "Hybrid Electric", "FCEV", "Liquids", "NG"))]

  return(allfleet)
}


EJroadFun <- function(demandEJ){
  demandEJ = demandEJ[subsector_L3 %in% c("trn_pass_road", "trn_freight_road"),]
  demandEJ <- demandEJ[, c("sector", "subsector_L3", "subsector_L2", "subsector_L1", "vehicle_type", "technology", "region", "year", "demand_EJ")]
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
  demandEJ_fuel = copy(demandEJ)
  demandEJ = demandEJ[,.(demand_EJ = sum(demand_EJ)), by = c("region", "year", "aggr_mode", "veh")]

  demandEJ[, vehicle_type_plot := factor(veh, levels = c("LDV","Freight Rail", "Truck","Domestic Shipping", "International Shipping",
                                                         "Motorbikes", "Small Cars", "Large Cars", "Van",
                                                         "Domestic Aviation", "International Aviation", "Bus", "Passenger Rail",
                                                         "Freight", "Freight (Inland)", "Pass non LDV", "Pass non LDV (Domestic)"))]


  return(list(demandEJ = demandEJ, demandEJ_fuel = demandEJ_fuel))
}


ESmodeFun = function(demandkm, POP){
  ## REMIND-EDGE results
  demandkm <- demandkm[,c("sector","subsector_L3","subsector_L2",
                          "subsector_L1","vehicle_type","technology", "region","year","demand_F")]

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
  demandkm = demandkm[,.(demand_F = sum(demand_F)), by = c("region", "year", "aggr_mode", "veh", "technology")]
  setnames(demandkm, old = "veh", new = "vehicle_type")


  demandkm[, vehicle_type_plot := factor(vehicle_type, levels = c("LDV","Freight Rail", "Truck", "Domestic Ship", "International Ship",
                                                                  "Motorbikes", "Small Cars", "Large Cars", "Van",
                                                                  "Domestic Aviation", "International Aviation","Bus", "Passenger Rail",
                                                                  "Freight", "Non motorized", "Shipping"))]

  ## attribute aggregate mode (passenger, freight)
  demandkm[, mode := ifelse(vehicle_type %in% c("Freight", "Freight Rail", "Truck", "Shipping") ,"freight", "pass")]

  ## aggregate to regions
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
             value]         ## in million km/million people=pkm/person

  demandkm = demandkm[year >= 2015 & year <= 2100]

  return(list(demandkm = demandkm, demandkm_abs = demandkm_abs))

}

FEliq_sourceFun = function(FEliq_source){
  FEliq_source = FEliq_source[variable %in% c("FE|Transport|Liquids|LDV|Fossil|New Reporting", "FE|Transport|Liquids|LDV|Biomass|New Reporting", "FE|Transport|Liquids|LDV|Synthetic|New Reporting")]
#print(FEliq_source)
  ## Attribute oil and biodiesel (TODO Coal2Liquids is accounted for as Oil!
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|LDV|Fossil|New Reporting", "FE|Transport|Pass|Road|LDV|Liquids"), "Oil", NA)]
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|LDV|Biomass|New Reporting"), "Biomass", technology)]
  FEliq_source[, technology := ifelse(variable %in% c("FE|Transport|Liquids|LDV|Synthetic|New Reporting"), "Synfuel", technology)]
  FEliq_source = FEliq_source[,.(value = sum(value)), by = c("model", "scenario", "region", "year", "unit", "technology")]
#print(FEliq_source)
  FEliq_sourceR = FEliq_source[, shareliq := value/sum(value),by=c("region", "year")]
#print(FEliq_sourceR)

  return(list(FEliq_sourceR = FEliq_sourceR))
}


EJfuelsFun = function(demandEJ, FEliq_source_val){
  ## find the composition of liquid fuels
  FEliq_source = FEliq_source_val[,.(value = sum(value)), by = c("region", "year", "technology")]
  ## renmae technology not to generate confusion with all technologies (non liquids)
  setnames(FEliq_source_val, old = "technology", new = "subtech")
  FEliq_source_val[, technology := "Liquids"]
  ## find shares
  FEliq_source_val[, shareliq := value/sum(value),by=c("region", "year")]
  ## attribute technology name
  demandEJ[, technology := ifelse(technology %in% c("BEV", "Electric"), "Electricity", technology)]
  demandEJ[, technology := ifelse(technology %in% c("FCEV"), "Hydrogen", technology)]

  demandEJ = demandEJ[, .(demand_EJ = sum(demand_EJ)), by = c("region", "year","technology", "sector")]
  ## merge with liquids composition
  demandEJ = merge(demandEJ, FEliq_source_val, all = TRUE, by = c("region", "year", "technology"), allow.cartesian=TRUE)
  ## fuels that are not Liquids need a 1 as a share, otherwie would have an NA
  demandEJ[, shareliq := ifelse(is.na(shareliq), 1, shareliq)]
  demandEJ[, subtech := ifelse(is.na(subtech), technology, subtech)]
  demandEJModeFuel = copy(demandEJ)
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

emidemFun = function(miffile){
  emidem = miffile[variable %in% c("Emi|CO2|Transport|Pass|Short-Medium Distance|Demand", "Emi|CO2|Transport|Pass|Long Distance|Demand","Emi|CO2|Transport|Freight|Short-Medium Distance|Demand", "Emi|CO2|Transport|Freight|Long Distance|Demand"),]
  return(emidem)
}

costscompFun = function(newcomp, sharesVS1,  pref_FV, capcost4Wall, capcost4W_BEVFCEV, nonf, totp){

  ## First I calculate the total demand for new sales using the shares on FV level (in newcomp) and on VS1 level
  newcomp = merge(newcomp, sharesVS1[,.(shareVS1 = share, region, year, vehicle_type, subsector_L1)], all.x=TRUE, by = c("region", "year", "vehicle_type", "subsector_L1"))
  newcomp[, newdem := totdem*sharetech_new*shareVS1]
  newcomp = newcomp[,.(value = sum(newdem)), by = c("region", "year", "subsector_L1")]

  ## inconvenience components

  ## I calculate the inconvenience cost value (disrespective to the vehicle type)
  inc = sharesVS1[subsector_L1 == "trn_pass_road_LDV_4W",.(shareVS1 = share, region, year, vehicle_type, subsector_L1)]
  inc = merge(inc, pref_FV, by = c("region", "year", "vehicle_type"))
  ## average car (lost small, large dimension) in each region
  inc = inc[,.(cost = sum(value*shareVS1)), by = c("region", "technology", "year", "logit_type")]
  inc = inc[,.(cost, year, technology, region, logit_type)]

  ##  fuel prices

  ## fuel prices are only available in the total price dt
  fp = totp[subsector_L1 == "trn_pass_road_LDV_4W", c("region", "year", "technology","vehicle_type", "fuel_price_pkm")]
  ## I calculate the fuel price value (disrespective to the vehicle type)
  fp = merge(fp, sharesVS1[subsector_L1 == "trn_pass_road_LDV_4W",.(shareVS1 = share, region, year, vehicle_type, subsector_L1)], all.y = TRUE, by = c("region", "year", "vehicle_type"))

  ## average car (lost small, large dimension) in each region
  fp = fp[,.(fp = sum(fuel_price_pkm*shareVS1)), by = c("region", "technology", "year")]
  fp[, variable := "fuel_price"]
  fp=fp[,.(cost = sum(fp)), by = c("year", "technology", "region", "variable")]
  setnames(fp, old = "variable", new = "logit_type")

  nonf = nonf[, .(non_fuel_price = sum(non_fuel_price)), by = c("region", "year", "technology", "vehicle_type")]

  ## merge capital cost for BEVs and FCEVs with technologies without learning
  capc = rbind(capcost4Wall, capcost4W_BEVFCEV[, c("region", "year", "technology", "type", "price_component", "vehicle_type", "non_fuel_price")])
  capc = capc[, .(purchase = sum(non_fuel_price)), by = c("region", "year", "technology", "vehicle_type")]

  ## find non-capital component as a difference between total and purchase
  nonf = merge(nonf, capc, by = c("region", "year", "vehicle_type", "technology"))
  nonf[, other := non_fuel_price-purchase]
  nonf[, non_fuel_price := NULL]
  nonf= melt(nonf, id.vars = c("region", "year", "technology", "vehicle_type"))

  ## I calculate the non fuel costs value (disrespective to the vehicle type)
  nonf = merge(nonf, sharesVS1[subsector_L1 == "trn_pass_road_LDV_4W",.(shareVS1 = share, region, year, vehicle_type, subsector_L1)], by = c("region", "year", "vehicle_type"))

  ## average car in region
  nonf = nonf[,.(nonf = sum(value*shareVS1)), by = c("region", "technology", "year", "variable")]
  nonf=nonf[,.(cost = sum(nonf)), by = c("year", "technology", "region", "variable")]
  setnames(nonf, old = "variable", new = "logit_type")

  ## dt containing all cost components
  tmp = rbindlist(list(nonf, inc, fp), use.names=TRUE)

  ## attribute factors
  tmp[, technology := factor(technology, levels = c("BEV", "Hybrid Electric", "FCEV", "Liquids", "NG"))]

  return(tmp)
}


demgdpcap_Fun = function(demkm, GDPcap) {
  demkm = demkm[,.(demand_F = sum(demand_F)), by = c("region", "year", "sector", "subsector_L3", "subsector_L2", "subsector_L1")]
  demcap_gdp = merge(demkm, GDPcap, by = c("region", "year"))

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
               POP_val]                 ## in million km/million people=pkm/person

  demcap_gdp[, demappl := demappl/  ## in million km
               POP_val]                 ## in million km/million people=pkm/person

  demcap_gdp[, demtype := demtype/  ## in million km
               POP_val]    ## in million km/million people=pkm/person

  demcap_gdp = unique(demcap_gdp[, c("region", "year", "demsec", "demappl", "demtype", "appl", "type", "sector", "GDP_cap")])

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
  POP=calcOutput("Population", aggregate = T)[,, "pop_SSP2"]
  POP <- magpie2dt(POP, regioncol = "region",
                   yearcol = "year", datacols = "POP")
  gdp <- getRMNDGDP(scenario = "gdp_SSP2", to_aggregate = T, isocol = "region", usecache = T, gdpfile = "GDPcache.RDS")
  GDPcap <- getRMNDGDPcap(scenario = "gdp_SSP2", usecache = TRUE, isocol = "region", to_aggregate = T, gdpCapfile = "GDPcapCache.RDS")
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
  FEliq_source = FEliq_sourceFun(FEliq_source)
  ## calculate sales
  salescomp = SalesFun(shares_LDV, newcomp[subsector_L1 == "trn_pass_road_LDV_4W"], sharesVS1)
  ## calculate fleet compositons
  fleet = fleetFun(vintcomp, newcomp[subsector_L1 == "trn_pass_road_LDV_4W"], sharesVS1, loadFactor)
  ## calculate EJ from LDVs by technology
  EJroad = EJroadFun(demandEJ)
  ## calculate FE demand by mode
  EJmode = EJmodeFun(demandEJ)[["demandEJ"]]
  EJModeFuel = EJmodeFun(demandEJ)[["demandEJ_fuel"]]
  ## calculate ES demand per capita
  ESmode = ESmodeFun(demandkm, POP)
  ESmodecap = ESmode[["demandkm"]]
  ## calculate FE for all transport sectors by fuel, dividng Oil into Biofuels and Synfuels
  EJfuels = EJfuelsFun(demandEJ, FEliq_source$FEliq_sourceR)
  EJfuelsPass = EJfuels[["demandEJpass"]]
  EJfuelsFrgt = EJfuels[["demandEJfrgt"]]
  ## calculate demand emissions
  emidem = emidemFun(miffile)
  ## calculate costs by component
  costs = costscompFun(newcomp = newcomp[subsector_L1 == "trn_pass_road_LDV_4W"], sharesVS1 = sharesVS1, pref_FV = pref_FV, capcost4Wall = capcost4Wall, capcost4W_BEVFCEV = capcost4W_BEVFCEV, nonf = nonf, totp = totp)
  ## per capita demand-gdp per capita
  demgdpcap = demgdpcap_Fun(demkm = demandkm, GDPcap)
  ## add scenario dimension to the results
  allentries = list(fleet = fleet,
                    salescomp = salescomp,
                    EJroad = EJroad,
                    EJmode = EJmode,
                    EJModeFuel = EJModeFuel,
                    ESmodecap = ESmodecap,
                    emidem = emidem,
                    EJfuelsPass = EJfuelsPass,
                    EJfuelsFrgt = EJfuelsFrgt,
                    costs = costs,
                    pref_FV = pref_FV,
                    demgdpcap = demgdpcap)

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



