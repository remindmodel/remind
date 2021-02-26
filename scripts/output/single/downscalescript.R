# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

#load libraries
library(mrremind)
library(luscale)
library(lusweave)
library(luplot)
library(lucode)
library(gdx)
library(ludata)
library(luplot)
library(raster)
library(ncdf)
library(rgdal)
library(fields)

#set working dir and get raster2magpie, edgar2magpie and downscale grid from 
#http://subversion.pik-potsdam.de/svn/spark_remind/tools/downscaling/
#setwd("C:/Users/rhennig/Desktop/REMIND/scripts/output/single")
source('C:/Users/rhennig/Desktop/DS/raster2magpie.R')
source('C:/Users/rhennig/Desktop/DS/edgar2magpie.R')
source("C:/Users/rhennig/Desktop/DS/downscale_grid.r")

#get mappings from /p/projects/rd3mod/inputdata/mappings
mapping <- "../../../../dumpfolder/regionmappingREMIND.csv"
mappingcell <- "../../../../dumpfolder/CountryToCellMapping.csv"
regionmatrix <- getAggregationMatrix(mapping)
cellmatrix <- getAggregationMatrix(mappingcell)

#OPTIONALLY prepare EDGAR data
# totals <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_TOT.0.1x0.1.nc")
# AgSoils <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_IPCC_4C_4D.0.1x0.1.nc")
# LSBB <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_IPCC_5A_C_D_F_4E.0.1x0.1.nc")
# INTA <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_IPCC_1A3a.0.1x0.1.nc")
# INTS <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_IPCC_1A3d.0.1x0.1.nc")
# edgar <- totals - AgSoils - LSBB - INTA - INTS
# SO2totals <- raster("../../../../Edgar/SO2/v42_SO2_2005_TOT.0.1x0.1.nc")
# SO2nonroadtr <- raster("../../../../Edgar/SO2/v42_SO2_2005_IPCC_1A3a_c_d_e.0.1x0.1.nc")
# SO2agwaste <- raster("../../../../Edgar/SO2/v42_SO2_2005_IPCC_4F.0.1x0.1.nc")
# SO2lsbb <- raster("../../../../Edgar/SO2/v42_SO2_2005_IPCC_5A_C_D_F_4E.0.1x0.1.nc")
# so2edgar <- SO2totals - SO2nonroadtr - SO2agwaste - SO2lsbb
#get reference file from http://subversion.pik-potsdam.de/svn/spark_remind/tools/downscaling/
# reference <- raster("../../../../DS/REFERENCE_EDGARv4.2_anthro_CO2_energy_production_and_distribution_2005_6270.nc")
# EDGAR_CO2 <- edgar2magpie(edgar,reference)
# EDGAR_SO2 <- edgar2magpie(so2edgar,reference)
# testmap <- magpie2map(log(EDGAR_SO2))
# image.plot(testmap)
# or simply read in the files from the input folder .../REMIND/core/input/grid
EDGAR_CO2 <- read.magpie("../../../core/input/grid/EDGAR_CO2_2010_excl_agr_and_intl_transport.mz")
EDGAR_SO2 <- read.magpie("../../../core/input/grid/EDGAR_SO2_2005_excl_agr_and_intl_transport.mz")

# Set gdx path
gdx_name <- "fulldata.gdx"
outputdir <- "../../../output/SSP1emscen6"               # path to the output folder
gdx_path <- path(outputdir,gdx_name)

y_plot <- c("y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
yrs <- c(2010,2015,2020,2025,2030,2035,2040,2045,2050,2055,2060,2070,2080,2090,2100)

# read 2010 baseline data from .../REMIND/core/input/country/ for weights
x <- read.magpie("../../../core/input/country/convert_Data_A1_Country_total_population-SSPs.csv.mz")
x <- x[,y_plot,"Pop_ssp2"]
y <- read.magpie("../../../core/input/country/convert_OECD_v9_25-3-13-3.xlsx.mz")
y <- y[,y_plot,"GDP_ssp2"]
# IEA emissions from Anastasis
memis <- read.magpie("../../../../dumpfolder/memis.mz")
eminew <- read.magpie("../../../../dumpfolder/emi2010.mz")
emiC <- eminew[2:249,2010,"TOTAL.TOTOTHER"]+ eminew[2:249,2010,"TOTAL.CO2EMIS"]
emiag<- speed_aggregate(emiC,mapping)

#get regional data from REMIND output
pop <- readGDX(gdx_path,"pm_pop", format="first_found")
pop <- pop[1:11,y_plot,]
vari <- readGDX(gdx_path,"vm_cesIO", format="first_found")
gdp <- vari[1:11,y_plot,"inco.l"]
vec <- c("fegas.l" , "fehos.l" , "fesos.l"  ,"feels.l" , "fehes.l",  "feh2s.l"  ,"ueLDVt.l" , "ueHDVt.l",  "fetf.l" 
         ,"feh2t.l" , "ueelTt.l" )
fe <- dimSums(vari[1:11,y_plot,vec],dims=3)*pm_conv_TWa_EJ
emi <- readGDX(gdx_path,"vm_emiTe", format="first_found")
emib <- readGDX(gdx_path,"vm_emiMacSector",format="first_found")
so2 <- emi[1:11,y_plot,"so2.l"]+emib[1:11,y_plot,"so2.l"]
emi <- emi[1:11,y_plot,"co2.l"]+emib[1:11,y_plot,"co2cement.l"]
getNames(emi) <- "co2"
#adjust GDP tp PPP
ratioppp <- readGDX(gdx_path,"pm_shPPPMER", format="first_found")
ratioppp <- ratioppp[1:11,,]
gdp <- gdp/ratioppp
#disaggregate ReMind data, using external input data as weights
popCountry <- speed_aggregate(pop,mapping,weight=x)
gdpCountry <- speed_aggregate(gdp,mapping,weight=y)
emiCountry <- speed_aggregate(emi,mapping,weight=emiC)
so2Country <- speed_aggregate(so2,mapping,weight=emiC)  #this has to be updated! the weight for SO2 should be SO2 data from EDGAR
feCountry <- speed_aggregate(fe,mapping,weight=y)       #this too. if energy is used as intermediate step, external energy data on country level needs to be supplied here.

# re-aggregation to have unified region labeling, check str(gdp), str(gdp2) and str(regionmatrix) to see why
# the region labeling of the Remind data has to match that of the mapping matrix
gdp2 <- speed_aggregate(gdpCountry,mapping)
pop2 <- speed_aggregate(popCountry,mapping)
emi2 <- speed_aggregate(emiCountry,mapping)
so2 <- speed_aggregate(so2Country,mapping)
fe2 <- speed_aggregate(feCountry,mapping)

#the following lines are to compare emissions from IEA and Remind. both are normalized to the emissions from japan.
#if the two data sets would comlpetely agree, all the numbers should be the same.
#USA has the biggest absolute disagreement between the data sets (35% of the emissions of Japan)
eminormREMIND <- emi2[,2010,]/0.34571122
eminormIEA <- emiag[,2010,]/1331.5600

#the following lines can be used to benchmark the downscaling, using GDP per capita from OECD projections and the downscaled version.
# GDPpcC <- gdpCountry/popCountry
# GDPpcR <- gdp2/pop2
# gdppcds <- luscale:::downscale_intensity(gdp2,pop,gdpCountry[,2010,],popCountry,mapping,convrate=0.4)
# gdpds <- gdppcds*popCountry
# getNames(gdpCountry) <- "gdp"
# getNames(gdpds) <- "gdp"
# magpie2ggplot2(mbind2(gdpds["DEU",,],gdpCountry["DEU",,]),color="Data2",group=NULL)

#downscaling of emissions
emiintds <- downscale_intensity(emi2,gdp2,emiC,gdpCountry,mapping,convrate=0.5)
getNames(emiintds) <- "gdp"
emids <- emiintds*gdpCountry
so2intds <- downscale_intensity(so2,gdp2,emiC,gdpCountry,mapping,convrate=0.5)
getNames(so2intds) <- "gdp"
so2ds <- so2intds*gdpCountry

# grid downscaling
so2grid <- downscale_grid(so2ds,EDGAR_SO2,mappingcell)
co2grid <- downscale_grid(emids,EDGAR_CO2,mappingcell)

loggrid <- log(co2grid)
#loggrid[is.infinite(loggrid[,2010,]),,] <- NaN
#loggrid[loggrid < (-60),,] <- NaN
testmap <- magpie2map(loggrid[,2040,])
image.plot(testmap)
