# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(optparse)

opt_parser = OptionParser(
  description = "Coupled version of EDGE-T, to be run within a REMIND output folder.",
  option_list = list(
    make_option(
      "--reporting", action="store_true", default=FALSE,
      help="Store output files in subfolder EDGE-T")));
opt = parse_args(opt_parser);

library(data.table)
library(gdx)
library(gdxdt)
library(edgeTrpLib)
require(devtools)
library(rmndt)
library(moinput)

## use cached input data for speed purpose
setConfig(forcecache=T)

data_folder <- "EDGE-T"

datapath <- function(fname){
  file.path(data_folder, fname)
}

REMINDpath <- function(fname){
  file.path("../../", fname)
}

REMINDyears <- c(1990,
                 seq(2005, 2060, by = 5),
                 seq(2070, 2110, by = 10),
                 2130, 2150)

gdx <- "input.gdx"
if(file.exists("fulldata.gdx"))
  gdx <- "fulldata.gdx"

load("config.Rdata")
scenario <- cfg$gms$cm_GDPscen
EDGE_scenario <- cfg$gms$cm_EDGEtr_scen
setConfig(regionmapping = gsub('config/', '', cfg$regionmapping))
EDGEscenarios <- fread("EDGEscenario_description.csv")[scenario_name == EDGE_scenario]

inconvenience <- EDGEscenarios[options == "inconvenience", switch]

if (EDGE_scenario %in% c("ConvCase", "ConvCaseWise")) {
  techswitch <- "Liquids"
} else if (EDGE_scenario %in% c("ElecEra", "ElecEraWise")) {
  techswitch <- "BEV"
} else if (EDGE_scenario %in% c("HydrHype", "HydrHypeWise")) {
  techswitch <- "FCEV"
} else {
  print("You selected a not allowed scenario. Scenarios allowed are: ConvCase, ConvCaseWise, ElecEra, ElecEraWise, HydrHype, HydrHypeWise")
  quit()
}


REMIND2ISO_MAPPING <- fread(REMINDpath(cfg$regionmapping))[, .(iso = CountryCode, region = RegionCode)]
EDGE2teESmap <- fread("mapping_EDGE_REMIND_transport_categories.csv")


## input data loading
input_folder = paste0("../../modules/35_transport/edge_esm/input/")

if (length(list.files(path = data_folder, pattern = "RDS")) < 7) {
  createRDS(input_folder, data_folder,
            SSP_scenario = scenario,
            EDGE_scenario = EDGE_scenario)
}
inputdata <- loadInputData(data_folder)


vot_data = inputdata$vot_data
logit_params = inputdata$logit_params
int_dat = inputdata$int_dat
nonfuel_costs = inputdata$nonfuel_costs
capcost4W = inputdata$capcost4W
loadFactor = inputdata$loadFactor
price_nonmot = inputdata$price_nonmot
pref_data = inputdata$pref_data

## Moinput produces all combinations of iso-vehicle types and attributes a 0. These ghost entries have to be cleared.
int_dat = int_dat[EJ_Mpkm_final>0]
prefdata_nonmot = pref_data$FV_final_pref[subsector_L3 %in% c("Walk", "Cycle")]
pref_data$FV_final_pref = merge(pref_data$FV_final_pref, unique(int_dat[, c("region", "vehicle_type")]), by = c("region", "vehicle_type"), all.y = TRUE)
pref_data$FV_final_pref[, check := sum(value), by = c("vehicle_type", "region")]
pref_data$FV_final_pref = pref_data$FV_final_pref[check>0]
pref_data$FV_final_pref[, check := NULL]
pref_data$FV_final_pref = rbind(prefdata_nonmot, pref_data$FV_final_pref)

prefdata_nonmotV = pref_data$VS1_final_pref[subsector_L3 %in% c("Walk", "Cycle")]
pref_data$VS1_final_pref = merge(pref_data$VS1_final_pref, unique(int_dat[, c("region", "vehicle_type")]), by = c("region", "vehicle_type"), all.y = TRUE)
pref_data$VS1_final_pref[, check := sum(sw), by = c("vehicle_type", "region")]
pref_data$VS1_final_pref = pref_data$VS1_final_pref[check>0]
pref_data$VS1_final_pref[, check := NULL]
pref_data$VS1_final_pref = rbind(prefdata_nonmotV, pref_data$VS1_final_pref)




## optional average of prices
average_prices = TRUE

ES_demand_all = readREMINDdemand(gdx, REMIND2ISO_MAPPING, EDGE2teESmap, REMINDyears, scenario)
## select from total demand only the passenger sm
ES_demand = ES_demand_all[sector == "trn_pass",]



if (file.exists(datapath("demand_previousiter.RDS"))) {
  ## load previous iteration number of cars
  demand_learntmp = readRDS(datapath("demand_learn.RDS"))
  ## load previous iteration demand
  ES_demandpr = readRDS(datapath("demand_previousiter.RDS"))
  ## load previus iteration number of stations
  stations = readRDS(datapath("stations.RDS"))
  ## calculate non fuel costs for technologies subjected to learning and merge the resulting values with the historical values
  nonfuel_costs = merge(nonfuel_costs, unique(int_dat[, c("region", "vehicle_type")]), by = c("region", "vehicle_type"), all.y = TRUE)
  if (techswitch == "BEV"){
    rebates_febatesBEV = EDGEscenarios[options== "rebates_febates", switch]
    rebates_febatesFCEV = FALSE
  } else if (techswitch == "FCEV") {
    rebates_febatesFCEV = EDGEscenarios[options== "rebates_febates", switch]
    rebates_febatesBEV = FALSE
  } else {
    rebates_febatesFCEV = FALSE
    rebates_febatesBEV = FALSE
  }

  nonfuel_costs_list = applylearning(
      non_fuel_costs = nonfuel_costs, capcost4W = capcost4W,
      gdx =  gdx, EDGE2teESmap = EDGE2teESmap, demand_learntmp = demand_learntmp,
      ES_demandpr =  ES_demandpr, ES_demand =  ES_demand,
      rebates_febatesBEV = rebates_febatesBEV, rebates_febatesFCEV = rebates_febatesFCEV)
      nonfuel_costs = nonfuel_costs_list$nonfuel_costs
      capcost4W = nonfuel_costs_list$capcost4W
      saveRDS(nonfuel_costs, "nonfuel_costs_learning.RDS")
      saveRDS(capcost4W, "capcost_learning.RDS")
   } else {
      stations = NULL
      totveh = NULL
   }
## load price
REMIND_prices <- merge_prices(
  gdx = gdx,
  REMINDmapping = REMIND2ISO_MAPPING,
  REMINDyears = REMINDyears,
  intensity_data = int_dat,
  nonfuel_costs = nonfuel_costs[type == "normal"][, type := NULL])


## save prices
## read last iteration count
keys <- c("region", "year", "technology", "vehicle_type")
setkeyv(REMIND_prices, keys)

pfile <- "EDGE_transport_prices.rds"
iter <- as.vector(gdxrrw::rgdx(gdx, list(name="o_iterationNumber"))$val)

REMIND_prices[, iternum := iter]

## save REMIND prices (before dampening)
saveRDS(REMIND_prices, datapath(paste0("REMINDprices", iter, ".RDS")))


if(average_prices){

  if(max(unique(REMIND_prices$iternum)) >= 20 & max(unique(REMIND_prices$iternum)) <= 30){
    old_prices <- readRDS(datapath(pfile))
    all_prices <- rbind(old_prices, REMIND_prices)
    setkeyv(all_prices, keys)
    ## apply moving avg
    REMIND_prices <- REMIND_prices[
      all_prices[iternum >= 20, mean(tot_price), by=keys], tot_price := V1]
    all_prices <- rbind(old_prices, REMIND_prices)
  }else{
    all_prices <- REMIND_prices
  }
  saveRDS(all_prices, datapath(pfile))

  ## save REMIND prices (after dampening)
  saveRDS(REMIND_prices, datapath(paste0("REMINDpricesDampened", iter, ".RDS")))

}

REMIND_prices[, "iternum" := NULL]

## calculates logit
years=copy(REMINDyears)
if (file.exists(datapath("demand_totalLDV.RDS"))) {
  ## load previous iteration number of cars
  totveh = readRDS(datapath("demand_totalLDV.RDS"))
}
logit_data <- calculate_logit_inconv_endog(
  prices= REMIND_prices[tot_price > 0],
  vot_data = vot_data,
  pref_data = pref_data,
  logit_params = logit_params,
  intensity_data = int_dat,
  price_nonmot = price_nonmot,
  stations = if (!is.null(stations)) stations,
  totveh = if (!is.null(totveh)) totveh,
  techswitch = techswitch)

shares <- logit_data[["share_list"]] ## shares of alternatives for each level of the logit function
## shares$VS1_shares=shares$VS1_shares[,-c("sector","subsector_L2","subsector_L3")]

mj_km_data <- logit_data[["mj_km_data"]] ## energy intensity at a technology level
prices <- logit_data[["prices_list"]] ## prices at each level of the logit function, 1990USD/pkm


## calculate vintages (new shares, prices, intensity)
vintages = calcVint(shares = shares,
                    totdem_regr = ES_demand_all,
                    prices = prices,
                    mj_km_data = mj_km_data,
                    years = REMINDyears)

shares$FV_shares = vintages[["shares"]]$FV_shares
prices = vintages[["prices"]]
mj_km_data = vintages[["mj_km_data"]]


## use logit to calculate shares and intensities (on tech level)
EDGE2CESmap <- fread("mapping_CESnodes_EDGE.csv")


shares_int_dem <- shares_intensity_and_demand(
  logit_shares=shares,
  MJ_km_base=mj_km_data,
  EDGE2CESmap=EDGE2CESmap,
  REMINDyears=REMINDyears,
  scenario=scenario,
  demand_input = if (opt$reporting) ES_demand_all)

demByTech <- shares_int_dem[["demand"]] ##in [-]
intensity <- shares_int_dem[["demandI"]] ##in million pkm/EJ
norm_demand <- shares_int_dem[["demandF_plot_pkm"]] ## total demand is 1, required for costs

if (opt$reporting) {
  saveRDS(vintages[["vintcomp"]], file = datapath("vintcomp.RDS"))
  saveRDS(vintages[["newcomp"]], file = datapath("newcomp.RDS"))
  saveRDS(shares, file = datapath("shares.RDS"))
  saveRDS(logit_data$EF_shares, file = datapath("EF_shares.RDS"))
  saveRDS(logit_data$mj_km_data, file = datapath("mj_km_data.RDS"))
  saveRDS(shares_int_dem$demandF_plot_EJ,
          file=datapath("demandF_plot_EJ.RDS"))
  saveRDS(shares_int_dem$demandF_plot_pkm,
          datapath("demandF_plot_pkm.RDS"))
  saveRDS(logit_data$annual_sales, file = datapath("annual_sales.RDS"))
  saveRDS(logit_data$pref_data, file = datapath("pref_output.RDS"))

  vint <- vintages[["vintcomp_startyear"]]
  dem <- shares_int_dem$demandF_plot_pkm
  vint <- dem[vint, on=c("iso", "subsector_L1", "vehicle_type", "technology", "year", "sector")]
  vint <- vint[!is.na(demand_F)][
  , c("sector", "subsector_L3", "subsector_L2", "subsector_L1", "vint", "value") := NULL]
  vint[, demand_F := demand_F * 1e6] # million pkm -> pkm

  vint <- loadFactor[vint, on=c("year", "iso", "vehicle_type")]
  vint[, full_demand_vkm := demand_F/loadFactor]
  vint[, vintage_demand_vkm := demVintEachYear/loadFactor]
  vint[, c("demand_F", "demVintEachYear", "loadFactor") := NULL]

  fwrite(vint, "vintcomp.csv")

  quit()
}

num_veh_stations = calc_num_vehicles_stations(
  norm_dem = norm_demand[
    subsector_L1 == "trn_pass_road_LDV_4W", ## only 4wheelers
    c("region", "year", "sector", "vehicle_type", "technology", "demand_F") ],
  ES_demand_all = ES_demand_all,
  techswitch = techswitch,
  loadFactor = loadFactor)

## save number of vehicles for next iteration
saveRDS(num_veh_stations$learntechdem, datapath("demand_learn.RDS"))
saveRDS(num_veh_stations$stations, datapath("stations.RDS"))
saveRDS(num_veh_stations$alltechdem, datapath("demand_totalLDV.RDS"))
## save the demand for next iteration renaming the column
setnames(ES_demand, old ="demand", new = "demandpr")
saveRDS(ES_demand, datapath("demand_previousiter.RDS"))


## use logit to calculate costs
budget <- calculate_capCosts(
  base_price=prices$base,
  Fdemand_ES = shares_int_dem[["demandF_plot_pkm"]],
  EDGE2CESmap = EDGE2CESmap,
  EDGE2teESmap = EDGE2teESmap,
  REMINDyears = REMINDyears,
  scenario = scenario)

## full REMIND time range for inputs
REMINDtall <- c(seq(1900,1985,5),
                seq(1990, 2060, by = 5),
                seq(2070, 2110, by = 10),
                2130, 2150)

## prepare the entries to be saved in the gdx files: intensity, shares, non_fuel_price. Final entries: intensity in [trillionkm/Twa], capcost in [2005USD/trillionpkm], shares in [-]
finalInputs <- prepare4REMIND(
  demByTech = demByTech,
  intensity = intensity,
  capCost = budget,
  EDGE2teESmap = EDGE2teESmap,
  REMINDtall = REMINDtall)



## add the columns of SSP scenario and EDGE scenario to the output parameters
for (i in names(finalInputs)) {
  finalInputs[[i]]$SSP_scenario <- scenario
  finalInputs[[i]]$EDGE_scenario <- EDGE_scenario
}


## calculate shares
finalInputs$shFeCes = finalInputs$demByTech[, value := value/sum(value), by = c("tall", "all_regi", "all_in")]
## 7 decimals the lowest accepted value
finalInputs$shFeCes[, value := round(value, digits = 7)]
finalInputs$shFeCes[, value := ifelse(value == 0, 1e-7, value)]
finalInputs$shFeCes[, sumvalue := sum(value), by = c("tall", "all_regi", "all_in")]
finalInputs$shFeCes[, maxtech := ifelse(value == max(value), TRUE, FALSE), by =c("tall", "all_regi", "all_in")]

## attribute the variation to the maximum share value
finalInputs$shFeCes[sumvalue!=1 & maxtech==TRUE, value := value + (1-sumvalue), by = c("tall", "all_regi")]
## remove temporary columns
finalInputs$shFeCes[, c("sumvalue", "maxtech") := NULL]

## CapCosts
writegdx.parameter("p35_esCapCost.gdx", finalInputs$capCost, "p35_esCapCost",
                   valcol="value", uelcols=c("tall", "all_regi", "SSP_scenario", "EDGE_scenario", "all_teEs"))

## Intensities
writegdx.parameter("p35_fe2es.gdx", finalInputs$intensity, "p35_fe2es",
                   valcol="value", uelcols = c("tall", "all_regi", "SSP_scenario", "EDGE_scenario", "all_teEs"))

## Shares: demand can represent the shares since it is normalized
writegdx.parameter("p35_shFeCes.gdx", finalInputs$shFeCes, "p35_shFeCes",
                   valcol="value",
                   uelcols = c("tall", "all_regi", "SSP_scenario", "EDGE_scenario", "all_enty", "all_in", "all_teEs"))
