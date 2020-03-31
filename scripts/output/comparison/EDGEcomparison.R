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


for (outputdir in outputdirs) {
  ## load mif file
  name_mif = list.files(path = outputdir, pattern = "REMIND_generic", full.names = F)
  name_mif = name_mif[!grepl("withoutPlu", name_mif)]
  miffile <- as.data.table(read.quitte(paste0(outputdir, "/", name_mif)))
  
  ## load RDS files
  sharesVS1 = readRDS(paste0(outputdir, "/EDGE-T/" ,"shares.RDS"))[["VS1_shares"]]
  newcomp = readRDS(paste0(outputdir, "/EDGE-T/" ,"newcomp.RDS"))
  vintcomp = readRDS(paste0(outputdir, "/EDGE-T/" ,"vintcomp.RDS"))
  shares_LDV = readRDS(paste0(outputdir, "/EDGE-T/" ,"annual_sales.RDS"))
  demandEJ = readRDS(paste0(outputdir, "/EDGE-T/" , "demandF_plot_EJ.RDS"))
  
  ## calculate sales
  salescomp = SalesFun(shares_LDV, newcomp, sharesVS1)
  ## calculate fleet compositons
  fleet = fleetFun(vintcomp, newcomp, sharesVS1)
  ## calculate EJ from LDVs by technology
  EJLDV = EJLDVFun(demandEJ)
  ## calculate FE demand by mode
  EJmode = EJmodeFun(demandEJ)
  
  ## add scenario dimension to the results
  fleet[, scenario := as.character(unique(miffile$scenario))]
  salescomp[, scenario := unique(miffile$scenario)]
  EJLDV[, scenario := as.character(unique(miffile$scenario))]
  EJmode[, scenario := as.character(unique(miffile$scenario))]
  
  ## rbind scenarios
  salescomp_all = rbind(salescomp_all, salescomp)
  fleet_all = rbind(fleet_all, fleet)
  EJLDV_all = rbind(EJLDV_all, EJLDV)
  EJmode_all = rbind(EJmode_all, EJmode)

}

dir.create("output/comparerunEDGE", showWarnings = FALSE)

outdir = "output/comparerunEDGE/"
md_template = "EDGETransportComparison.Rmd"

saveRDS(EJmode_all, "output/comparerunEDGE/EJmode_all.RDS")
saveRDS(salescomp_all, "output/comparerunEDGE/salescomp_all.RDS")
saveRDS(fleet_all, "output/comparerunEDGE/fleet_all.RDS")
saveRDS(EJLDV_all, "output/comparerunEDGE/EJLDV_all.RDS")

file.copy(file.path("./scripts/output/comparison/notebook_templates", md_template), outdir)
rmarkdown::render(path(outdir, md_template), output_format="pdf_document")

