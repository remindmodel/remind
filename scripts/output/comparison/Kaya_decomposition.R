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

############### read and calculate data ################################
Kaya <- read_all(gdx_path,calcKayaDecomp,as.list=FALSE)
########################################################################

################## plot data ###########################################
p1 <- magpie2ggplot2(Kaya[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Region', color='Data2',shape='Data1',
                     ylab='normalized to 2005',scales='free_y',show_grid=TRUE,ncol=3)
print(p1)
p2 <- magpie2ggplot2(Kaya[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Region', color='Data2',shape='Data1',ylim=c(0,2),
                     ylab='normalized to 2005',scales='free_y',show_grid=TRUE,ncol=3)
print(p2)
p3 <- magpie2ggplot2(Kaya[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Data1', color='Data2',linetype='Region',
                     ylab='normalized to 2005',scales='free_y',show_grid=TRUE,ncol=2)
print(p3)
p4 <- magpie2ggplot2(Kaya[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Data1', color='Data2',linetype='Region',ylim=c(0,2),
                     ylab='normalized to 2005',scales='free_y',show_grid=TRUE,ncol=2)
print(p4)
########################################################################

############### generate table of data #################################
table <- Kaya[r_plot,y_table,][,,scenNames]
########################################################################

############### write pdf of the plot #################################
library(lusweave)

sw <- swopen(template="/home/dklein/scripts/template.tex")
swfigure(sw,print,p1,sw_option="height=9,width=16")
swfigure(sw,print,p2,sw_option="height=9,width=16")
swfigure(sw,print,p3,sw_option="height=9,width=16")
swfigure(sw,print,p4,sw_option="height=9,width=16")
#for(sn in scenNames){
  #for(r in getRegions(Kaya)){
    #swtable(sw,collapseNames(table[r,,sn]),caption=paste(sn,r,sep=' '),digits=2,transpose=FALSE)
  #}
#}
swclose(sw,outfile="Kaya_decomposition.pdf",clean_output=TRUE)
########################################################################
 
  
  

