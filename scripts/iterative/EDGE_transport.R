require(data.table)
require(gdx)
require(gdxdt)
require(edgeTrpLib)
require(rmndt)
## use cached input data for speed purpose
require(moinput)
setConfig(forcecache=T)


mapspath <- function(fname){
    file.path("../../modules/35_transport/edge_esm/input", fname)
}

datapath <- function(fname){
    file.path("input_EDGE", fname)
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

merge_traccs <<- EDGEscenarios[options == "merge_traccs", switch]
addvintages <<- EDGEscenarios[options == "addvintages", switch]
inconvenience <<- EDGEscenarios[options == "inconvenience", switch]
selfmarket_taxes <<- EDGEscenarios[options == "selfmarket_taxes", switch]
selfmarket_policypush <<- EDGEscenarios[options == "selfmarket_policypush", switch]
selfmarket_acceptancy <<- EDGEscenarios[options == "selfmarket_acceptancy", switch]

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

endogeff <<- EDGEscenarios[options== "endogeff", switch]
enhancedtech <<- EDGEscenarios[options== "enhancedtech", switch]
rebates_febates <<- EDGEscenarios[options== "rebates_febates", switch] ##NB THEY ARE ONLY IN PSI! ONLY WORKING IN EUROPE
savetmpinput <<- FALSE
smartlifestyle <<- EDGEscenarios[options== "smartlifestyle", switch]



REMIND2ISO_MAPPING <- fread(REMINDpath(cfg$regionmapping))[, .(iso = CountryCode, region = RegionCode)]
EDGE2teESmap <- fread(mapspath("mapping_EDGE_REMIND_transport_categories.csv"))


## input data loading
input_path = paste0("../../modules/35_transport/edge_esm/input/")

inputdata = createRDS(input_path, SSP_scenario = scenario, EDGE_scenario = EDGE_scenario)
vot_data = inputdata$vot_data
sw_data = inputdata$sw_data
inco_data = inputdata$inco_data
logit_params = inputdata$logit_params
int_dat = inputdata$int_dat
nonfuel_costs = inputdata$nonfuel_costs
price_nonmot = inputdata$price_nonmot

## add learning optional
setlearning = TRUE
## add optional vintages
addvintages = TRUE
## optional average of prices
average_prices = FALSE
## inconvenience costs instead of preference factors
inconvenience = TRUE

if (setlearning | addvintages){
  ES_demand = readREMINDdemand(gdx, REMIND2ISO_MAPPING, EDGE2teESmap, REMINDyears)
  ## select from total demand only the passenger sm
  ES_demand = ES_demand[sector == "trn_pass",]
}


if (setlearning & file.exists("demand_previousiter.RDS")) {
  ## load previous iteration number of cars
  demand_BEVtmp = readRDS("demand_BEV.RDS")
  ## load previous iteration demand
  ES_demandpr = readRDS("demand_previousiter.RDS")
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
saveRDS(REMIND_prices, paste0("REMINDprices", iter, ".RDS"))


if(average_prices){

  if(max(unique(REMIND_prices$iternum)) >= 20 & max(unique(REMIND_prices$iternum)) <= 30){
    old_prices <- readRDS(pfile)
    all_prices <- rbind(old_prices, REMIND_prices)
    setkeyv(all_prices, keys)
    ## apply moving avg
    REMIND_prices <- REMIND_prices[
      all_prices[iternum >= 20, mean(tot_price), by=keys], tot_price := V1]
    all_prices <- rbind(old_prices, REMIND_prices)
  }else{
    all_prices <- REMIND_prices
  }
  saveRDS(all_prices, pfile)

  ## save REMIND prices (after dampening)
  saveRDS(REMIND_prices,paste0("REMINDpricesDampened", iter, ".RDS"))

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
    price_nonmot = price_nonmot)

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

if(addvintages){
  ## calculate vintages (new shares, prices, intensity)
  vintages = calcVint(shares = shares,
                      totdem_regr = ES_demand,
                      prices = prices,
                      mj_km_data = mj_km_data,
                      years = REMINDyears)

  shares$FV_shares = vintages[["shares"]]$FV_shares
  prices = vintages[["prices"]]
  mj_km_data = vintages[["mj_km_data"]]
}

## use logit to calculate shares and intensities (on tech level)
EDGE2CESmap <- fread(mapspath("mapping_CESnodes_EDGE.csv"))

shares_intensity_demand <- shares_intensity_and_demand(
    logit_shares=shares,
    MJ_km_base=mj_km_data,
    EDGE2CESmap=EDGE2CESmap,
    REMINDyears=REMINDyears,
    scenario=scenario,
    REMIND2ISO_MAPPING=REMIND2ISO_MAPPING)

demByTech <- shares_intensity_demand[["demand"]] ##in [-]
intensity <- shares_intensity_demand[["demandI"]] ##in million pkm/EJ
norm_demand <- shares_intensity_demand$demandF_plot_pkm ## total demand is 1, required for costs

if (setlearning) {
  demand_BEV=calc_num_vehicles( norm_dem_BEV = norm_demand[technology == "BEV" & ## battery vehicles
                                                           subsector_L1 == "trn_pass_road_LDV_4W", ## only 4wheelers
                                                           c("iso", "year", "sector", "vehicle_type", "demand_F") ],
                                ES_demand = ES_demand)

  ## save number of vehicles for next iteration
  saveRDS(demand_BEV, "demand_BEV.RDS")
  ## save the demand for next iteration renaming the column
  setnames(ES_demand, old ="demand", new = "demandpr")
  saveRDS(ES_demand, "demand_previousiter.RDS")
}


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
