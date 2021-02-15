# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(lusweave)
library(luplot)
library(lucode)
library(gdx)
library(magpie)
library(remind2)

############################# BASIC CONFIGURATION #############################
gdx_name <- "fulldata.gdx"        # name of the gdx   

if(!exists("source_include")) {
  #Define arguments that can be read from command line
  outputdirs <- c("C:/Documents and Settings/lavinia/My Documents/MEINS/MO/REMIND17/CO2-Kyoto_plot/output/rem4765_SSP1-37-SPA1-rem-8",
                  "C:/Documents and Settings/lavinia/My Documents/MEINS/MO/REMIND17/CO2-Kyoto_plot/output/rem4765_SSP1-ModTax-rem-6",
                  "C:/Documents and Settings/lavinia/My Documents/MEINS/MO/REMIND17/CO2-Kyoto_plot/output/rem4765_SSP2-37-SPA2-rem-8",
                  "C:/Documents and Settings/lavinia/My Documents/MEINS/MO/REMIND17/CO2-Kyoto_plot/output/rem4765_SSP2-ModTax-rem-8");
  # path to the output folder
   readArgs("outputdirs","gdx_name")
} 

###############################################################################

##################### general plot settings ###################################
# time horizon for plots
y_plot <- c("y2005","y2020","y2030","y2040","y2050")
y_table <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
# regions for the plots
r_plot <- c("ROW","EUR","CHN","IND","JPN","RUS","USA","OAS","MEA","LAM","AFR")
###############################################################################

# Set gdx path
gdx_path  <- path(outputdirs,gdx_name)
scenNames <- getScenNames(outputdirs)
#scenNames <- c("SSP1_ModPol","SSP2_ModPol","SSP5_ModPol");  # scenario names
names(gdx_path) <- scenNames

############### settings for the calculation ###########################
ref_year  <- 2005  # refenence year for comparision
########################################################################

############### read and calculate data ################################
emiCO2 <- read_all(gdx_path,readEmissions,emiengregi="co2",eminegregi="co2cement",as.list=FALSE)
emiCO2 <- emiCO2* (44/12*1000)
gdp    <- read_all(gdx_path,readGDPMER,as.list=FALSE) 
CI <- emiCO2[,y_table,]/(gdp[,y_table,]*1000)
CI_diff <- 100+((CI-setYears(CI[,ref_year,],NULL))/setYears(CI[,ref_year,],NULL)*100)

########################################################################

################## plot data ###########################################
p1 <- magpie2ggplot2(CI[r_plot,y_plot,],geom='line',facet_x='Data1', 
                     ylab='Carbon Intensity [Mt CO2/billion US$2005]',color='Region',
                     scales='free_y',show_grid=TRUE,ncol=2)
print(p1)
p2 <- magpie2ggplot2(CI_diff[r_plot,y_plot,],geom='line',facet_x='Data1', 
                     ylab='Carbon Intensity- Difference[%]',color='Region',
                     show_grid=TRUE,ncol=2)
print(p2)
y_plot <- c("y2005","y2010","y2015","y2020","y2025","y2030")
p3 <- magpie2ggplot2(CI_diff[r_plot,y_plot,],geom='line',facet_x='Data1', 
                     ylab='Carbon Intensity- Difference[%]',color='Region',
                     ylim=c(0,150),show_grid=TRUE,ncol=2)
print(p3)
########################################################################

############### generate table of data #################################
table <- CI_diff[r_plot,y_table,][,,scenNames]
########################################################################

############### write pdf of the plot #################################
library(lusweave)

sw <- swopen("CarbonintensityDiffT.pdf")
swfigure(sw,print,p1)
swfigure(sw,print,p2)
swfigure(sw,print,p3)
for(sn in scenNames){
  swtable(sw,table[,,sn],sn,digits=2,transpose=TRUE)
}
swclose(sw)
########################################################################
 
  
  

