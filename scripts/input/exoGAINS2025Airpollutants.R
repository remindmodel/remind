# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

##############################################################
######################## PREAMBLE ############################
##############################################################

# Only output messages to the log if it is the first run of exoGAINS2025 to avoid repetition in the log.txt file
firstIteration = FALSE
if (file.exists("log.txt")){
  if(!any(grepl("ExoGAINS2025 - log for first iteration...", readLines("log.txt")))){
    firstIteration = TRUE
    cat("\nExoGAINS2025 - log for first iteration...\n\n")
  }
}

# load required packages
for (pkg in c('madrat', 'dplyr', 'remind2', 'gdx')) {
  suppressPackageStartupMessages(require(pkg, character.only = TRUE))
}

# stop madrat reporting its default settings _every damn time_
invisible(getConfig(option = NULL, verbose = firstIteration))

##############################################################
######## READ AP SETTINGS FOR SCENARIO, SSP AND SOURCE #######
##############################################################

load("config.Rdata")
# AP scenario
ap_scenario <- cfg$gms$cm_APscen
# AP SSP
if (ap_scenario == "MTFR" | ap_scenario == "SMIPVLLO") {
  # MTFR and SMIPVLLO are not differentiated by SSP, so set to ap_scenario
  ap_ssp <- ap_scenario
} else if (ap_scenario == "CLE" | ap_scenario == "SLE" | ap_scenario == "SMIPbySSP") {
  # CLE, SLE and SMIPbySSP are differentiated by SSP, but SSP4 is not available for SMIPbySSP
  if (ap_scenario == "SMIPbySSP" & ((cfg$gms$cm_APssp == "SSP4") | (cfg$gms$cm_APssp == "FROMGDPSSP" & cfg$gms$cm_GDPpopScen == "SSP4"))) {
    stop(paste0("cm_APssp 'SSP4' is not available for SMIPbySSP. Please select another SSP."))
  }
  # Determine ap_ssp based on cm_APscen and cm_APssp setting
  if (cfg$gms$cm_APssp == "FROMGDPSSP"){
    ap_ssp <- cfg$gms$cm_GDPpopScen
  } else if (cfg$gms$cm_APssp %in% c("SSP1", "SSP2", "SSP3", "SSP4", "SSP5")) {
    ap_ssp <- cfg$gms$cm_APssp
  } else {
    stop(paste0("cm_APssp '", cfg$gms$cm_APssp,"' is not supported by exoGAINS2025. Please select one of the following: FROMGDPSSP, SSP1-5"))
  }
} else {
  stop(paste0("cm_APscen '",ap_scenario,"' is not supported by exoGAINS2025. Please select one of the following: CLE, SLE, MTFR, SMIPbySSP, SMIPVLLO"))
}
# AP source for baseyear emissions
ap_source <- cfg$gms$cm_APsource

##############################################################
################ READ IN GDX AND RUN REPORTING ###############
##############################################################

# Use input.gdx if the fulldata_exoGAINS2025.gdx is not available
if (file.exists("fulldata_exoGAINS2025.gdx")) {
  gdx <- "fulldata_exoGAINS2025.gdx"
  iterationInfo <- paste("iteration", as.numeric(readGDX(gdx = gdx, "o_iterationNumber", format = "simplest")))
} else {
  gdx <- "input.gdx"
  iterationInfo <- gdx
}

t <- c(seq(2005,2060,5),seq(2070,2110,10),2130,2150)
rem_in_mo <- NULL
message("With data from ", iterationInfo, ": exoGAINS2025Airpollutants.R calls remind2::reportMacroEconomy ", appendLF = FALSE)
rem_in_mo <- mbind(rem_in_mo,reportMacroEconomy(gdx)[,t,])
message("- reportPE ", appendLF = FALSE)
rem_in_mo <- mbind(rem_in_mo,reportPE(gdx)[,t,])
message("- reportSE ", appendLF = FALSE)
rem_in_mo <- mbind(rem_in_mo,reportSE(gdx)[,t,])
message("- reportFE")
rem_in_mo <- mbind(rem_in_mo,reportFE(gdx)[,t,])

# delete "+", "++" and "+++" from variable names
rem_in_mo <- piamutils::deletePlus(rem_in_mo)

# for easier debugging use rem_in in the remainder of the script
rem_in <- rem_in_mo

##############################################################
########### Load GAINS emissions and emission factors ########
##############################################################

if (ap_source == "CEDS") {
  emifacs <- read.magpie("emifacs_sectGAINS_sourceCEDS.cs4r")
  emis <- read.magpie("emi2020_sectGAINS_sourceCEDS.cs4r")
} else if (ap_source == "GAINS") {
  emifacs <- read.magpie("emifacs_sectGAINS_sourceGAINS.cs4r")
  emis <- read.magpie("emi2020_sectGAINS_sourceGAINS.cs4r")
} else {
  stop(paste0("cm_APsource '",ap_source,"' is not supported by exoGAINS2025. Please select one of the following: CEDS, GAINS"))
}

# Subset the chosen scenario and SSP
emifacs <- mselect(emifacs, scenario = ap_scenario, ssp = ap_ssp)
emifacs <- collapseDim(emifacs, dim = c("ssp", "scenario"))

emis <- mselect(emis, scenario = ap_scenario, ssp = ap_ssp)
emis <- collapseDim(emis, dim = c("ssp", "scenario"))

##############################################################
################### Load REMIND activities ###################
##############################################################

map_GAINS2REMIND <- read.csv("mappingGAINS2025toREMINDactivities.csv", stringsAsFactors=FALSE)

# End_Use_Services_Coal is mapped to an activity that is so far not existing in the REMIND reporting:
# FE|Solids without BioTrad (EJ/yr) = Final Energy|Solids (EJ/yr) -  Final Energy|Solids|Biomass|Traditional (EJ/yr)
# Thus, add this new activity
rem_in <- add_columns(rem_in,addnm = "FE|Solids without BioTrad (EJ/yr)",dim=3.1)
rem_in[,,"FE|Solids without BioTrad (EJ/yr)"] <- rem_in[,,"FE|Solids (EJ/yr)"] - rem_in[,,"FE|Solids|Biomass|Traditional (EJ/yr)"]

# select REMIND activity (RA) data according to order in mapping
RA <- collapseNames(rem_in[,,map_GAINS2REMIND$REMIND])
RA <- RA["GLO",,invert=TRUE]

##############################################################
###################   Select GAINS data    ###################
##############################################################

# logging missing sectors
if(firstIteration){
  cat("List of sectors that are not in the GAINS2REMIND mapping because there is no emission and/or activity data.\nThese sectors will be omitted in the calculations!\n")
  missing_sectors <- setdiff(getNames(emifacs,dim=1),map_GAINS2REMIND$GAINS)
  cat(missing_sectors,sep="\n")
}

# Select GAINS data according to order in mapping and bring regions into same (alphabetically sorted) order as RA
emifacs  <- emifacs[getRegions(RA),,map_GAINS2REMIND$GAINS]
emis <- emis[getRegions(RA),,map_GAINS2REMIND$GAINS]

# Rename REMIND activities to GAINS sectors to make them compatible for calculation
# IMPORTANT: before renaming, order of REMIND sectors must be identical to order of GAINS sectors, otherwise data would be mixed up
# This was already taken care of by selecting both REMIND and GAINS data using the map_GAINS2REMIND (see above)
getNames(RA) <- getNames(emifacs,dim=1)
getSets(RA)[3] <- "sector"

# create magpie object of the structure of RA, fill with noef data from map_GAINS2REMIND
noef <- RA * 0
tmp <- as.magpie(map_GAINS2REMIND$noef)
getNames(tmp) <- getNames(RA)
noef[,,] <- tmp

# create magpie object of the structure of RA, fill with elasticity data from map_GAINS2REIND
ela <- RA * 0
tmp <- as.magpie(map_GAINS2REMIND$elasticity)
getNames(tmp) <- getNames(RA)
ela[,,] <- tmp

##############################################################
#################### Calculate emissions #####################
##############################################################
RA_limited <- RA / (setYears(RA[,2015,] +1E-10))
RA_limited[RA_limited>5] <- 5

E <- ( emifacs[,,ap_scenario] / (setYears(emifacs[,2015,ap_scenario])+1E-10) + noef ) * setYears(emis[,2015,ap_scenario])  * ( RA_limited) ^ela

# Calculate emissions using different formula: for emisions that have no emifacs
# take all timesteps of emis and scale with relation of RA(SSP5) / RA(SSP2)
# Preliminary: set RA_SSP2 to RA
# GA: Since RA/RA is 1, and 1^0.4 is 1, this is essentially taking the 
# exogenous emissions from the ap_scenario in emis unaltered
RA_SSP2 <- RA
E_noef <- emis[,,ap_scenario]  * ( RA / (RA_SSP2+1E-10) )^ela

# Replace only those emission in E that have no emifacs
sec_noef <- map_GAINS2REMIND[map_GAINS2REMIND$noef==1,]$GAINS
E[,,sec_noef] <- E_noef[,,sec_noef]

# add global dimension
E <- mbind(E,dimSums(E,dim=1))

# Calibrate GAINS emissions to CEDS
# on GAINS sector level, or CEDS sector level or REMIND sector level?
# E_calibrated <- E * E(2015) / E_CEDS(2015)

# read mapping from GAINS sectors to REMIND sectors
map_GAINSsec2REMINDsec <- read.csv(
  toolGetMapping(type = "sectoral", name = "mappingGAINS2025toREMINDsectors.csv", returnPathOnly = TRUE),
  stringsAsFactors = FALSE,
  na.strings = ""
)
# keep mixed version of GAINS sectors (mix of aggregated and extended, currently only appending waste sectors from extended to aggreagted)
map_GAINSsec2REMINDsec <- subset(map_GAINSsec2REMINDsec, select = c("REMINDsectors","GAINS_mixed"))
# remove lines with empty GAINS sectors (land use etc.)
map_GAINSsec2REMINDsec <- na.omit(map_GAINSsec2REMINDsec)
# remove double entries that are due to the fact that the original file contains higher sectoral resolutions in some columns that have been removed here
# not necessary, since speed_aggregate seems to remove duplicates
#map_GAINSsec2REMINDsec <- map_GAINSsec2REMINDsec[-which(duplicated(map_GAINSsec2REMINDsec)),]

E_rem <- madrat::toolAggregate(x = E, weight = NULL, dim = 3.1, rel = map_GAINSsec2REMINDsec, from = "GAINS_mixed", to = "REMINDsectors")

getNames(E_rem,dim=2) <- gsub("VOC","NMVOC",getNames(E_rem,dim=2)) # rename emissions to names defined in emiRCP

# Preliminary: export only all_sectorEmi (sectors that are in all_exogEmi (ag,waste,avi,ship) will be added later)
# we leave out Waste that is not part of all_sectorEmi
all_sectorEmi <- c("solvents","indprocess", "indst", "res", "trans", "extraction", "power")
getNames(E_rem) <- gsub("SO2","SOx",getNames(E_rem))

# get rid of SSPx in the name
E_rem <- collapseNames(E_rem)

# for test purpose: limit high values (indst AFR,CHN,LAM,OAS,IND)
#E_rem[E_rem>100] <- 100

# rename dimension to the ones we need in GAMS (gdx will use these)
getSets(E_rem) <- c("all_regi","tall","all_sectorEmi","emiRCP")
#write.report(E_rem,file=paste0("exoGAINS_AP",format(Sys.time(), "_%Y-%m-%d_%H.%M.%S"),".mif"))

##############################################################
###################### Export to gdx  ########################
##############################################################

# selcet data that will be exported to GDX
out <- E_rem[,,all_sectorEmi]["GLO",,invert=TRUE]

# construct attributes that are required by writeGDX
gdxdata <- list()
gdxdata$name <- "p11_emiAPexsolve"
gdxdata$type <- "parameter"
gdxdata$form <- "sparse"
gdxdata$domains <- c("tall", "all_regi", "all_sectorEmi", "emiRCP")
#gdxdata$domInfo <- "full"

# add newly created attributes to existing ones
attributes(out) <- c(attributes(out),list(gdxdata =gdxdata))

# Write gdx with following dimensions: p11_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP)
writeGDX(out,file="p11_emiAPexsolve",period_with_y = FALSE)

# Use this to produce file with start values for REMIND
#out_cs4r <- add_dimension(out,add = "ssp", nm = ap_scenario,dim=3.3)
#write.magpie(out_cs4r,file_name = "f11_emiAPexsolve.cs4r")

# library(luplot)
# for (sec in getNames(E_rem,dim=1)) {
#   dat <- as.ggplot(E_rem[,,sec])
#   dat <- na.omit(dat)
#   p<-ggplot(data=dat, aes(x=Year, y=Value)) +  geom_line(aes(colour=Data2)) + facet_wrap(~Region,scales = "free_y")
#   ggsave(filename=paste0("Regions_",sec,".png"),p,scale=1.5,width=32,height=18,unit="cm",dpi=150)
# }
#
# stop()
#
# # Add missing Int. Shipping sector from extra ECLIPSE file
# RA_ship <- setNames(rem_in["GLO",,"FE|Transport|Liquids (EJ/yr)"],NULL)
# # calculate shippin emission the same way as gains emissions
# ship_E <- (ship_ef/setYears(ship_ef[,2015,])) * setYears(ship_emi[,2015,]) * (RA_ship/setYears(RA_ship[,2015,]))
# E_rem <- add_columns(E_rem,addnm = getNames(ship_E,dim=1)) # filled with NA
# gases <- getNames(E_rem,dim=2)
# E_rem["GLO",,getNames(tmp)] <- ship_E[,,gases][,,ap_scenario]
#
# # Add BC and NOx for missing Int. Aviation sector from extra file from Steve
# RA_avi <- collapseNames(time_interpolate(rem_in["GLO",,"Final Energy|Transportation|Liquids (EJ/yr)"][,,scenario], interpolated_year=getYears(emifacs), integrate_interpolated_years=TRUE, extrapolation_type="constant"))
# # calculate aviation emission the same way as gains emissions
# avi_E <- (avi_ef/setYears(avi_ef[,2015,])) * setYears(avi_emi[,2015,]) * (RA_avi/setYears(RA_avi[,2015,]))
# CEDS16 <- add_columns(CEDS16,addnm = getNames(avi_E,dim=1)) # filled with NA
# CEDS16[,,getNames(avi_E,dim=1)] <- 0 # replace NA with zero
# CEDS16["GLO",,getNames(avi_E[,,ap_scenario])] <- avi_E[,,ap_scenario] # data only contains BC and NOx emissions from aircraft

if(firstIteration){
  cat("\nExoGAINS2025 - end of first iteration.\n\n")
}
