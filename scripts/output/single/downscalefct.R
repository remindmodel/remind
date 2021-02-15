# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

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

setwd("C:/Users/rhennig/Desktop/REMIND/scripts/output/single")
source('C:/Users/rhennig/Desktop/DS/raster2magpie.R')
source('C:/Users/rhennig/Desktop/dumpfolder/getAggregationMatrixCell.R')
source('C:/Users/rhennig/Desktop/DS/edgar2magpie.R')

mapping <- "../../../../dumpfolder/regionmappingREMIND.csv"
map <- read.csv(mapping)
mappingcell <- "../../../../dumpfolder/CountryToCellMapping.csv"
mapcell <- read.csv(mappingcell, as.is = TRUE, sep = ";")
matrix <- getAggregationMatrix(mapping)
cellmatrix <- getAggregationMatrixCell(mappingcell,from="CountryCode",to="CellCode")

convyr <- 2100
baseyr <- 2010
pm_conv_TWa_EJ = 31.536
cellcountries <- unique(mapcell[,2])

totals <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_TOT.0.1x0.1.nc")
AgSoils <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_IPCC_4C_4D.0.1x0.1.nc")
LSBB <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_IPCC_5A_C_D_F_4E.0.1x0.1.nc")
INTA <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_IPCC_1A3a.0.1x0.1.nc")
INTS <- raster("../../../../Edgar/v42_FT2010_CO2_excl_short-cycle_org_C_2010_IPCC_1A3d.0.1x0.1.nc")
edgar <- totals - AgSoils - LSBB - INTA - INTS
SO2totals <- raster("../../../../Edgar/SO2/v42_SO2_2005_TOT.0.1x0.1.nc")
SO2nonroadtr <- raster("../../../../Edgar/SO2/v42_SO2_2005_IPCC_1A3a_c_d_e.0.1x0.1.nc")
SO2agwaste <- raster("../../../../Edgar/SO2/v42_SO2_2005_IPCC_4F.0.1x0.1.nc")
SO2lsbb <- raster("../../../../Edgar/SO2/v42_SO2_2005_IPCC_5A_C_D_F_4E.0.1x0.1.nc")
so2edgar <- SO2totals - SO2nonroadtr - SO2agwaste - SO2lsbb
reference <- raster("../../../../DS/REFERENCE_EDGARv4.2_anthro_CO2_energy_production_and_distribution_2005_6270.nc")
EDGAR_CO2 <- edgar2magpie(edgar,reference)
EDGAR_SO2 <- edgar2magpie(so2edgar,reference)


# Set gdx path
gdx_name <- "fulldata.gdx"
outputdir <- "../../../output/SSP1ref"               # path to the output folder
gdx_path <- path(outputdir,gdx_name)

y_plot <- c("y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
yrs <- c(2010,2015,2020,2025,2030,2035,2040,2045,2050,2055,2060,2070,2080,2090,2100)

# read 2010 baseline data for weights
x <- read.magpie("../../../core/input/country/convert_Data_A1_Country_total_population-SSPs.csv.mz")
x <- x[,y_plot,"Pop_ssp2"]
y <- read.magpie("../../../core/input/country/convert_OECD_v9_25-3-13-3.xlsx.mz")
y <- y[,y_plot,"GDP_ssp2"]
memis <- read.magpie("../../../../dumpfolder/memis.mz")
eminew <- read.magpie("../../../../dumpfolder/emi2010.mz")
emiC <- eminew[2:249,2010,"TOTAL.TOTOTHER"]+ eminew[2:249,2010,"TOTAL.CO2EMIS"]
emiag<- speed_aggregate(emiC,mapping)

#energy <- read.xlsx("energy2.xlsx")
#en <- as.magpie(energy)

pop <- readGDX(gdx_path,"pm_pop", format="first_found")
pop <- pop[1:11,y_plot,]
vari <- readGDX(gdx_path,"vm_cesIO", format="first_found")
gdp <- vari[1:11,y_plot,"inco.l"]
ratioppp <- readGDX(gdx_path,"pm_shPPPMER", format="first_found")
ratioppp <- ratioppp[1:11,,]
gdp <- gdp/ratioppp
vec <- c("fegas.l" , "fehos.l" , "fesos.l"  ,"feels.l" , "fehes.l",  "feh2s.l"  ,"ueLDVt.l" , "ueHDVt.l",  "fetf.l" 
         ,"feh2t.l" , "ueelTt.l" )
fe <- dimSums(vari[1:11,y_plot,vec],dims=3)*pm_conv_TWa_EJ

emi <- readGDX(gdx_path,"vm_emiTe", format="first_found")
emib <- readGDX(gdx_path,"vm_emiMacSector", format="first_found")
so2 <- emi[1:11,y_plot,"so2.l"]+emib[1:11,y_plot,"so2.l"]
emi <- emi[1:11,y_plot,"co2.l"]+emib[1:11,y_plot,"co2cement.l"]
getNames(emi) <- "co2"
a<-dimSums(vari[1:11,y_plot,vec],dims=3)*pm_conv_TWa_EJ
testpop <- speed_aggregate(x,mapping)

popCountry <- speed_aggregate(pop,mapping,weight=x)
gdpCountry <- speed_aggregate(gdp,mapping,weight=y)
emiCountry <- speed_aggregate(emi,mapping,weight=emiC)
so2Country <- speed_aggregate(so2,mapping,weight=emiC)
feCountry <- speed_aggregate(fe,mapping,weight=y)

# re-aggregation to have unified region labeling, check str(gdp) and str(gdp2) to see why
gdp2 <- speed_aggregate(gdpCountry,mapping)
pop2 <- speed_aggregate(popCountry,mapping)
emi2 <- speed_aggregate(emiCountry,mapping)
testemi <- speed_aggregate(emiC,mapping)
getNames(testemi) <- "co2"
#ei2 <- speed_aggregate(eiCountry,mapping)
fe2 <- speed_aggregate(feCountry,mapping)
nomiR <- gdp2
nomibaseC <- gdpCountry[,2010,]
denomC <- popCountry
eminormREMIND <- emi2[,2010,]/0.34723208
eminormIEA <- emiag[,2010,]/1331.5600
GDPpcC <- gdpCountry/popCountry
GDPpcR <- gdp2/pop2

gdplin <- downscale_intensity(gdp2,pop,gdpCountry[,2010,],popCountry,mapping,convmethod="lin",convrate=0.3)*popCountry
gdpexp <- downscale_intensity(gdp2,pop,gdpCountry[,2010,],popCountry,mapping,convrate=0.4,replacemissing=TRUE)*popCountry
gdppclin <- downscale_intensity(gdp2,pop,gdpCountry[,2010,],popCountry,mapping,convmethod="lin",convrate=0.5)
gdppcexp <- downscale_intensity(gdp2,pop,gdpCountry[,2010,],popCountry,mapping,replacemissing=TRUE)
emilin <- downscale_intensity(emi2,gdp2,emiC,gdpCountry,mapping,convmethod="lin",convrate=0.5)
emiexp <- downscale_intensity(emi2,gdp2,emiC,gdpCountry,mapping,convmethod="exp",convrate=0.5)
so2exp <- downscale_intensity(emi2,gdp2,emiC,gdpCountry,mapping,convmethod="exp",convrate=0.5)
emlin <- emilin*gdpCountry
emexp <- emiexp*gdpCountry
gdpds <- magpie_expand(gdpexp,gdplin)

emissionsC <- emlin




emgrid <- downscale_grid(emissionsC,test,mappingcell)
loggrid <- log(emgrid)
summary(loggrid)
loggrid[is.infinite(loggrid),,] <- NaN
loggrid[loggrid < (-60),,] <- NaN
testmap <- magpie2map(loggrid[,15,])
image.plot(testmap)

countrygrid <- testgrid
for(k in cellcountries) {
  countrygrid[!cellmatrix[,k]==0,,] <- as.numeric(emlin[k,2100,])
}
countrymap <- magpie2map(countrygrid)
image.plot(countrymap)

summary(test)
testgrid <- test
summary(emgrid)

testvec<-emissionsC[cellcountries,1,]
emgrid <- speed_aggregateCell(testvec,"CountryToCellMapping.csv",weight=testgrid)

getNames(gdpCountry) <- NULL
plotlistgdp <- list(gdplin["DEU",,],gdpexp["DEU",,],gdpCountry["DEU",,])
plotlistgdpppc <- list(gdppclin["DEU",,],gdppcexp["DEU",,],GDPpcR["EUR",,])

magpie2ggplot2(emexp["JPN",,])
magpie2ggplot2(GDPpcR["EUR",,])
temp <- gdppclin["DEU",,]
getRegions(temp) <- NULL
temp2 <- GDPpcR["EUR",,]
getRegions(temp2) <- NULL
getNames(gdpexp) <- "gdp"
getNames(gdplin) <- "gdp"
getNames(gdpCountry) <- "gdp"
getNames(GDPpcR) <- "gdp"

magpie2ggplot2(plotlistgdp,group=NULL)
magpie2ggplot2(gdplin["DEU",,])
magpie2ggplot2(gdpexp["DEU",,])
magpie2ggplot2(gdpCountry["DEU",,])
dummy <- mbind2(gdpexp["DEU",,],gdplin["DEU",,])
getNames(dummy) <- "gdp"
magpie2ggplot2(mbind2(gdpexp["DEU",,],gdpCountry["DEU",,]),color="Data2",group=NULL)
magpie2ggplot2(plist)

gdplin <- downscale_intensity(gdp2,pop,gdpCountry[,2010,],popCountry,mapping,convmethod="lin",convrate=0.7)*popCountry
gdpexp <- downscale_intensity(gdp2,pop,gdpCountry[,2010,],popCountry,mapping,convrate=0.35,replacemissing=FALSE,adjustshare="by nomiC")*popCountry
getNames(gdpexp) <- "gdp"
magpie2ggplot2(mbind2(gdpexp["DEU",,],gdpCountry["DEU",,]),color="Data2",group=NULL)
magpie2ggplot2(mbind2(gdpexp["FRA",,],gdpCountry["FRA",,]),color="Data2",group=NULL)
magpie2ggplot2(mbind2(gdpexp["ESP",,],gdpCountry["ESP",,]),color="Data2",group=NULL)

getNames(gdplin) <- "gdp"
magpie2ggplot2(mbind2(gdplin[1,,],gdpCountry[1,,]),color="Data2",group=NULL)
magpie2ggplot2(mbind2(gdppcexp[1,,],GDPpcR[1,,]),color="Data2",group=NULL)


testgdppc <- y/x
GDPpcC <- gdpCountry/popCountry
GDPpcR <- gdp2/pop2

gdplin["DEU",,]


denomR <- pop
dataR <- gdp2
nomibaseC <- gdpCountry[,2010,]
denomC <- popCountry
convmethod="lin"
convrate="standard"
replacemissing <- FALSE
adjustnomiR <- TRUE
adjustdenomR <- TRUE


