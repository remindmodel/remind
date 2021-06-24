# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(lusweave)
library(luplot)
library(lucode2)
library(gms)
library(gdx)
library(magpie)
library(remind2)

############################# BASIC CONFIGURATION #############################
gdx_name <- "fulldata.gdx"        # name of the gdx   


if(!exists("source_include")) {
  #Define arguments that can be read from command line
  outputdirs <- c("C:/Documents and Settings/lavinia/My Documents/MEINS/MO/REMIND17/codeCheck/output/rem5663_SSP5-OS-SPA5-rem-5");
  # path to the output folder
   readArgs("outputdirs","gdx_name")
} 

###############################################################################

##################### general plot settings ###################################
# time horizon for plots
y_plot <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050")
#y_plot <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
y_table <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
# regions for the plots
r_plot <- c("ROW","EUR","CHN","IND","JPN","RUS","USA","OAS","MEA","LAM","AFR")
###############################################################################

# Set gdx path
gdx_path  <- path(outputdirs,gdx_name)
scenNames <- getScenNames(outputdirs)
#scenNames <- c("SSP1_SPA1","SSP1_ModTax","SSP2_ModTax");  # scenario names
names(gdx_path) <- scenNames

############### read and calculate data ################################
prCO2 <- read_all(gdx_path,calcPrice,level="reg",enty="perm",type="present",as.list=FALSE)
prCO2 <- collapseNames(prCO2)* (1000*12/44)
########################################################################

################## plot data ###########################################
txtsiz <- 6
p1 <- magpie2ggplot2(prCO2[r_plot,y_plot,],geom='line',group=NULL,
                     ylab='CO2 Price[US$2005/t CO2]',color='Data1',
                     scales='free_y',show_grid=TRUE,ncol=3,text_size=txtsiz)
p1<-p1 + theme(legend.position="top")
p1<-p1 + guides(color = guide_legend(nrow = length(scenNames)))
print(p1)

y_plot <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070")
#y_plot <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")

p2 <- magpie2ggplot2(prCO2[r_plot,y_plot,],geom='line',facet_x='Data1', 
                     ylab='CO2 Price[US$2005/t CO2]',color='Region',
                     scales='free_y',show_grid=TRUE,ncol=2)
print(p2)
p3 <- magpie2ggplot2(prCO2[r_plot,y_plot,],geom='line',facet_x='Data1', 
                     ylab='CO2 Price[US$2005/t CO2]',color='Region',
                     show_grid=TRUE,ncol=2)
print(p3)
#y_plot <- c("y2005","y2010","y2015","y2020","y2025","y2030")
p4 <- magpie2ggplot2(prCO2[r_plot,y_plot,],geom='line',facet_x='Data1', 
                     ylab='CO2 Price[US$2005/t CO2]',color='Region',
                     scales='free_y',show_grid=TRUE,ncol=2)
print(p4)
########################################################################

############### generate table of data #################################
table <- prCO2[r_plot,y_table,][,,scenNames]
########################################################################

############### write pdf of the plot ##################################
library(lusweave)

sw <- swopen("CO2price.pdf")
swfigure(sw,print,p1)
swfigure(sw,print,p2)
swfigure(sw,print,p3)
swfigure(sw,print,p4)
for(sn in scenNames){
swtable(sw,table[,,sn],sn,digits=2,transpose=TRUE)
}
swclose(sw)
########################################################################
 
  
  

