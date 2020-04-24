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
library(rmndt)
library(moinput)

## use cached input data for speed purpose
setConfig(forcecache=T)

data_folder <- "EDGE-T"

mapspath <- function(fname){
    file.path("../../modules/35_transport/edge_esm/input", fname)
}

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

EDGEscenarios <- fread("../../modules/35_transport/edge_esm/input/EDGEscenario_description.csv")[scenario_name == EDGE_scenario]

inconvenience <- EDGEscenarios[options == "inconvenience", switch]
selfmarket_policypush <- EDGEscenarios[options == "selfmarket_policypush", switch]
selfmarket_acceptancy <- EDGEscenarios[options == "selfmarket_acceptancy", switch]

if (EDGE_scenario == "Conservative_liquids") {
  techswitch <<- "Liquids"
} else if (EDGE_scenario %in% c("Electricity_push", "Smart_lifestyles_Electricity_push")) {
  techswitch <<- "BEV"
} else if (EDGE_scenario == "Hydrogen_push") {
  techswitch <<- "FCEV"
} else {
  print("You selected a not allowed scenario. Scenarios allowed are: Conservative_liquids, Hydrogen_push, Electricity_push, Smart_lifestyles_Electricity_push")
  exit()
}


REMIND2ISO_MAPPING <- fread(REMINDpath(cfg$regionmapping))[, .(iso = CountryCode, region = RegionCode)]
EDGE2teESmap <- fread(mapspath("mapping_EDGE_REMIND_transport_categories.csv"))


## input data loading
input_folder = paste0("../../modules/35_transport/edge_esm/input/")

if (length(list.files(path = data_folder, pattern = "RDS")) < 7) {
  createRDS(input_folder, data_folder,
            SSP_scenario = scenario,
            EDGE_scenario = EDGE_scenario)
}
inputdata <- loadInputData(data_folder)


vot_data = inputdata$vot_data
sw_data = inputdata$sw_data
inco_data = inputdata$inco_data
logit_params = inputdata$logit_params
int_dat = inputdata$int_dat
nonfuel_costs = inputdata$nonfuel_costs
price_nonmot = inputdata$price_nonmot

## optional average of prices
average_prices = FALSE


ES_demand_all = readREMINDdemand(gdx, REMIND2ISO_MAPPING, EDGE2teESmap, REMINDyears)
## select from total demand only the passenger sm
ES_demand = ES_demand_all[sector == "trn_pass",]



if (file.exists(datapath("demand_previousiter.RDS"))) {
  ## load previous iteration number of cars
  demand_BEVtmp = readRDS(datapath("demand_BEV.RDS"))
  ## load previous iteration demand
  ES_demandpr = readRDS(datapath("demand_previousiter.RDS"))
  ## calculate non fuel costs and
  nonfuel_costs = applylearning(gdx,REMINDmapping,EDGE2teESmap, demand_BEVtmp, ES_demandpr)
  saveRDS(nonfuel_costs, "nonfuel_costs_learning.RDS")
}

## load price
REMIND_prices <- merge_prices(
    gdx = gdx,
    REMINDmapping = REMIND2ISO_MAPPING,
    REMINDyears = REMINDyears,
    intensity_data = int_dat,
    nonfuel_costs = nonfuel_costs)


## save prices
## read last iteration count
keys <- c("iso", "year", "technology", "vehicle_type")
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
if (inconvenience) {
  years=copy(REMINDyears)

  logit_data <- calculate_logit_inconv_endog(
    prices= REMIND_prices[tot_price > 0],
    vot_data = vot_data,
    inco_data = inco_data,
    logit_params = logit_params,
    intensity_data = int_dat,
    price_nonmot = price_nonmot,
    selfmarket_policypush = selfmarket_policypush,
    selfmarket_acceptancy = selfmarket_acceptancy)

} else{

  logit_data <- calculate_logit(
    REMIND_prices[tot_price > 0],
    REMIND2ISO_MAPPING,
    vot_data = vot_data,
    sw_data = sw_data,
    logit_params = logit_params,
    intensity_data = int_dat,
    price_nonmot = price_nonmot)

}
shares <- logit_data[["share_list"]] ## shares of alternatives for each level of the logit function
## shares$VS1_shares=shares$VS1_shares[,-c("sector","subsector_L2","subsector_L3")]

mj_km_data <- logit_data[["mj_km_data"]] ## energy intensity at a technology level
prices <- logit_data[["prices_list"]] ## prices at each level of the logit function, 1990USD/pkm


## calculate vintages (new shares, prices, intensity)
vintages = calcVint(shares = shares,
                    totdem_regr = ES_demand,
                    prices = prices,
                    mj_km_data = mj_km_data,
                    years = REMINDyears)

shares$FV_shares = vintages[["shares"]]$FV_shares
prices = vintages[["prices"]]
mj_km_data = vintages[["mj_km_data"]]


## use logit to calculate shares and intensities (on tech level)
EDGE2CESmap <- fread(mapspath("mapping_CESnodes_EDGE.csv"))


shares_int_dem <- shares_intensity_and_demand(
  logit_shares=shares,
  MJ_km_base=mj_km_data,
  EDGE2CESmap=EDGE2CESmap,
  REMINDyears=REMINDyears,
  scenario=scenario,
  REMIND2ISO_MAPPING=REMIND2ISO_MAPPING,
  demand_input = if (opt$reporting) ES_demand_all)

demByTech <- shares_int_dem[["demand"]] ##in [-]
intensity <- shares_int_dem[["demandI"]] ##in million pkm/EJ
norm_demand <- shares_int_dem[["demandF_plot_EJ"]] ## total demand is 1, required for costs


if (opt$reporting) {
  saveRDS(vintages[["vintcomp"]], file = datapath("vintcomp.RDS"))
  saveRDS(vintages[["newcomp"]], file = datapath("newcomp.RDS"))
  saveRDS(shares, file = datapath("shares.RDS"))
  saveRDS(logit_data$EF_shares, file = datapath("EF_shares.RDS"))
  saveRDS(logit_data$mj_km_data, file = datapath("mj_km_data.RDS"))
  saveRDS(logit_data$inconv_cost, file=datapath("inco_costs.RDS"))
  saveRDS(shares_int_dem$demandF_plot_EJ,
          file=datapath("demandF_plot_EJ.RDS"))
  saveRDS(shares_int_dem$demandF_plot_pkm,
          datapath("demandF_plot_pkm.RDS"))
  saveRDS(logit_data$annual_sales, file = datapath("annual_sales.RDS"))
  quit()
}

demand_BEV=calc_num_vehicles(
  norm_dem_BEV = norm_demand[
    technology == "BEV" & ## battery vehicles
    subsector_L1 == "trn_pass_road_LDV_4W", ## only 4wheelers
    c("iso", "year", "sector", "vehicle_type", "demand_F") ],
  ES_demand = ES_demand)

## save number of vehicles for next iteration
saveRDS(demand_BEV, datapath("demand_BEV.RDS"))
## save the demand for next iteration renaming the column
setnames(ES_demand, old ="demand", new = "demandpr")
saveRDS(ES_demand, datapath("demand_previousiter.RDS"))


## use logit to calculate costs
budget <- calculate_capCosts(
    base_price=prices$base,
    Fdemand_ES = norm_demand,
    EDGE2CESmap = EDGE2CESmap,
    EDGE2teESmap = EDGE2teESmap,
    REMINDyears = REMINDyears,
    scenario = scenario,
    REMIND2ISO_MAPPING=REMIND2ISO_MAPPING)

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
    REMINDtall = REMINDtall,
    REMIND2ISO_MAPPING=REMIND2ISO_MAPPING)



## add the columns of SSP scenario and EDGE scenario to the output parameters
for (i in names(finalInputs)) {
             finalInputs[[i]]$SSP_scenario <- scenario
             finalInputs[[i]]$EDGE_scenario <- EDGE_scenario
           }


## calculate shares
finalInputs$shFeCes = finalInputs$demByTech[, value := value/sum(value), by = c("tall", "all_regi", "all_in")]


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
