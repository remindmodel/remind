# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# Only output messages to the log if it is the first run of exoGAINS to avoid repetion in the log.txt file 
if(!any(grepl("ExoGAINS - log for first iteration...", readLines("log.txt")))){
  firstIteration = TRUE
  cat("\nExoGAINS - log for first iteration...\n\n")
} else {
  firstIteration = FALSE
}

# Downscaling of REMIND emissions to GAINS sectors using ECLIPSE emission and activity data
#rm(list=ls())

suppressMessages(library(dplyr, quietly = TRUE,warn.conflicts =FALSE))
suppressMessages(library(luscale, quietly = TRUE,warn.conflicts =FALSE)) # rename_dimnames
suppressMessages(library(remind2, quietly = TRUE,warn.conflicts =FALSE))
suppressMessages(library(gdx, quietly = TRUE,warn.conflicts =FALSE)) # writeGDX

# read SSP scenario
load("config.Rdata")
ssp_scenario <- cfg$gms$cm_APscen

# read in REMIND avtivities, use the fulldata_post.gdx and then the input.gdx if the fulldata.gdx is not available
if (file.exists("fulldata.gdx")){gdx <- "fulldata.gdx"} else {if (file.exists("fulldata_post.gdx")){gdx <- "fulldata_post.gdx"} else {gdx <- "input.gdx"}}


t <- c(seq(2005,2060,5),seq(2070,2110,10),2130,2150)
rem_in_mo <- NULL
rem_in_mo <- mbind(rem_in_mo,reportMacroEconomy(gdx)[,t,])
rem_in_mo <- mbind(rem_in_mo,reportPE(gdx)[,t,])
rem_in_mo <- mbind(rem_in_mo,reportSE(gdx)[,t,])
rem_in_mo <- mbind(rem_in_mo,reportFE(gdx)[,t,])

# delete "+" and "++" from variable names
rem_in_mo <- deletePlus(rem_in_mo)

# for easier debugging use rem_in in the remainder of the script
rem_in <- rem_in_mo

# load GAINS emissions and emission factors
ef_gains  <- read.magpie("ef_gains.cs4r")
emi_gains <- read.magpie("emi_gains.cs4r")

# ship_ef  <- read.magpie("../../modules/11_aerosols/exoGAINS/input/ef_ship.cs4r")
# ship_emi <- read.magpie("../../modules/11_aerosols/exoGAINS/input/emi_ship.cs4r")

# avi_ef  <- read.magpie("../../modules/11_aerosols/exoGAINS/input/ef_avi.cs4r")
# avi_emi <- read.magpie("../../modules/11_aerosols/exoGAINS/input/emi_avi.cs4r")


##############################################################
################### Load REMIND activities ###################
##############################################################

map_GAINS2REMIND <- read.csv("mappingGAINSmixedtoREMIND17activities.csv", stringsAsFactors=FALSE)

# End_Use_Services_Coal is mapped to an activity that is so far not existing in the REMIND reporting:
# FE|Solids without BioTrad (EJ/yr) = Final Energy|Solids (EJ/yr) -  Final Energy|Solids|Biomass|Traditional (EJ/yr)
# Thus, add this new activity
rem_in <- add_columns(rem_in,addnm = "FE|Solids without BioTrad (EJ/yr)",dim=3.1)
rem_in[,,"FE|Solids without BioTrad (EJ/yr)"] <- rem_in[,,"FE|Solids (EJ/yr)"] - rem_in[,,"FE|Solids|Biomass|Traditional (EJ/yr)"]

# select REMIND data according to order in mapping
RA <- collapseNames(rem_in[,,map_GAINS2REMIND$REMIND])
RA <- RA["GLO",,invert=TRUE]

# for sectors that have no GAINS emission factors use SSP2 data to create a dependence on SSPs
# Preliminary: ommit this step
# RA_SSP2 <- collapseNames(rem_in[,,map_GAINS2REMIND$REMIND][,,"SSP2-Ref-SPA0-V15"])
# RA_SSP2 <- RA_SSP2["GLO",,invert=TRUE]

##############################################################
###################   select GAINS data    ###################
##############################################################

# logging missing sectors
if(firstIteration){
  cat("List of sectors that are not in the GAINS2REMIND mapping because there is no emission and/or activity data.\nThese sectors will be omitted in the calculations!\n")
  missing_sectors <- setdiff(getNames(ef_gains,dim=1),map_GAINS2REMIND$GAINS)
  cat(missing_sectors,sep="\n")
}

# select GAINS data according to order in mapping and bring regions into same (alphabetically sorted) order as RA
ef_gains  <- ef_gains[getRegions(RA),,map_GAINS2REMIND$GAINS]
emi_gains <- emi_gains[getRegions(RA),,map_GAINS2REMIND$GAINS]

# rename REMIND activities to GAINS sectors to make them compatible for calcualtion
# IMPORTANT: before renaming, order of REMIND sectors must be identical to order of GAINS sectors, otherwise data would be mixed up
# This was already taken care of by selecting both REMIND and GAINS data using the map_GAINS2REMIND (see above)
getNames(RA) <- getNames(ef_gains,dim=1)
getSets(RA)[3] <- "sector"

# Preliminary: ommit this step
# getNames(RA_SSP2) <- getNames(ef_gains,dim=1)
# getSets(RA_SSP2)[3] <- "sector"

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
          
E <- ( ef_gains[,,ssp_scenario] / (setYears(ef_gains[,2015,ssp_scenario])+1E-10) + noef ) * setYears(emi_gains[,2015,ssp_scenario])  * ( RA_limited) ^ela

# Calcualte emissions using different formula: for emisions that have no ef_gains
# take all timesteps of emi_gains and scale with relation of RA(SSP5) / RA(SSP2)
# Preliminary: set RA_SSP2 to RA
RA_SSP2 <- RA
E_noef <- emi_gains[,,ssp_scenario]  * ( RA / (RA_SSP2+1E-10) )^ela

# Replace only those emission in E that have no ef_gains
sec_noef <- map_GAINS2REMIND[map_GAINS2REMIND$noef==1,]$GAINS
E[,,sec_noef] <- E_noef[,,sec_noef]

# add global dimension
E <- mbind(E,dimSums(E,dim=1))

# Calibrate GAINS emissions to CEDS
# on GAINS sector level, or CEDS sector level or REMIND sector level?
# E_calibrated <- E * E(2015) / E_CEDS(2015)

# read mapping from GAINS sectors to REMIND sectors
#map_GAINSsec2REMINDsec <- read.csv(madrat:::toolMappingFile("sectoral", "mappingGAINStoREMINDsectors.csv"), stringsAsFactors=FALSE,na.strings = "")
map_GAINSsec2REMINDsec <- read.csv("mappingGAINStoREMINDsectors.csv", stringsAsFactors=FALSE,na.strings = "")
# keep mixed version of GAINS sectors (mix of aggregated and extended, currently only appending waste sectors from extended to aggreagted)
map_GAINSsec2REMINDsec <- subset(map_GAINSsec2REMINDsec, select = c("REMINDsectors","GAINS_mixed"))
# remove lines with empty GAINS sectors (land use etc.)
map_GAINSsec2REMINDsec <- na.omit(map_GAINSsec2REMINDsec)
# remove double entries that are due to the fact that the original file contains higher sectoral resolutions in some columns that have been removed here
# not necessary, since speed_aggregate seems to remove duplicates
#map_GAINSsec2REMINDsec <- map_GAINSsec2REMINDsec[-which(duplicated(map_GAINSsec2REMINDsec)),]

E_rem <- speed_aggregate(x=E,weight = NULL, dim=3.1, rel = map_GAINSsec2REMINDsec, from="GAINS_mixed",to="REMINDsectors")

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
gdxdata$name <- "pm_emiAPexsolve"
gdxdata$type <- "parameter"
gdxdata$form <- "sparse"
gdxdata$domains <- c("tall", "all_regi", "all_sectorEmi", "emiRCP")
#gdxdata$domInfo <- "full"

# add newly created attributes to existing ones
attributes(out) <- c(attributes(out),list(gdxdata =gdxdata))

# Write gdx with following dimensions: pm_emiAPexsolve(tall,all_regi,all_sectorEmi,emiRCP)
writeGDX(out,file="pm_emiAPexsolve.gdx",period_with_y = FALSE)

# Use this to produce file with start values for REMIND
#out_cs4r <- add_dimension(out,add = "ssp", nm = ssp_scenario,dim=3.3)
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
# E_rem["GLO",,getNames(tmp)] <- ship_E[,,gases][,,ssp_scenario]
# 
# # Add BC and NOx for missing Int. Aviation sector from extra file from Steve
# RA_avi <- collapseNames(time_interpolate(rem_in["GLO",,"Final Energy|Transportation|Liquids (EJ/yr)"][,,scenario], interpolated_year=getYears(ef_gains), integrate_interpolated_years=TRUE, extrapolation_type="constant"))
# # calculate aviation emission the same way as gains emissions
# avi_E <- (avi_ef/setYears(avi_ef[,2015,])) * setYears(avi_emi[,2015,]) * (RA_avi/setYears(RA_avi[,2015,]))
# CEDS16 <- add_columns(CEDS16,addnm = getNames(avi_E,dim=1)) # filled with NA
# CEDS16[,,getNames(avi_E,dim=1)] <- 0 # replace NA with zero
# CEDS16["GLO",,getNames(avi_E[,,ssp_scenario])] <- avi_E[,,ssp_scenario] # data only contains BC and NOx emissions from aircraft

if(firstIteration){
  cat("\nExoGAINS - end of first iteration.\n\n")
}

