# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(remind2)
library(magpie)
library(luplot)

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
r_plot <- c("EUR")
###############################################################################

# Set gdx path
gdx_path  <- path(outputdirs,gdx_name)
scenNames <- getScenNames(outputdirs)
#scenNames <- c("SSP1_ModPol","SSP2_ModPol","SSP5_ModPol");  # scenario names
names(gdx_path) <- scenNames

############### Consumption ################################
cons <- read_all(gdx_path,readConsumption,as.list=FALSE)
p1 <- magpie2ggplot2(cons[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Region', color='Data2',shape='Data1',
                     scales='free_y',show_grid=TRUE,ncol=3)
print(p1)
table <- cons[r_plot,y_table,][,,scenNames]
########################################################################

############### Change in Consumption ################################
consCh <- abs((cons[r_plot,,names(gdx_path)[1]]-cons[r_plot,,names(gdx_path)[2]])
            /cons[r_plot,,names(gdx_path)[1]])*100
getNames(consCh)<-"relChange (%)"
p2 <- magpie2ggplot2(consCh[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Region',shape='Data1',
                     scales='free_y',show_grid=TRUE,ncol=3)
print(p2)
tableCh <- consCh[r_plot,y_table,]
########################################################################

############### Cumulative Consumption ################################
names(dimnames(cons))[[3]]<-"scenario.variable"
cons<-as.quitte(cons)
cons$variable<-"Consumption"
consAgg<-as.magpie(calcCumulatedDiscount(as.quitte(cons)))
p3 <- magpie2ggplot2(consAgg[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Region', color='Data2',shape='Data1',
                     scales='free_y',show_grid=TRUE,ncol=3)
print(p3)
tableAgg <- consAgg[r_plot,y_table,]
########################################################################

############### Prices ###############################################
p80_subset   <- c("good","peur","peoil","pegas","pecoal","pebiolc") #--> read in from gdx as sets trade and trade_? - types="set"
pm_pvp_def        <- readGDX(gdx_path[scenNames[[1]]],name=c("pm_pvp","p80_pvp"),format="first_found")[,,p80_subset]
getNames(pm_pvp_def)<-paste0(scenNames[[1]],".",getNames(pm_pvp_def))
pm_pvp_ref        <- readGDX(gdx_path[scenNames[[2]]],name=c("pm_pvp","p80_pvp"),format="first_found")[,,p80_subset]
getNames(pm_pvp_ref)<-paste0(scenNames[[2]],".",getNames(pm_pvp_ref))
pm_pvp <- mbind(pm_pvp_def,pm_pvp_ref)
p4 <- magpie2ggplot2(pm_pvp[,y_table,],geom='line',group=NULL,
                     facet_x='Region', color='Data2',shape='Data1',
                     scales='free_y',show_grid=TRUE,ncol=3)
print(p4)
tablePr <- pm_pvp[,y_table,][,,scenNames]

############### Trade ################################
trade <- read_all(gdx_path,reportTrade,as.list=FALSE)
trade <- trade[,,c("Trade|Coal (EJ/yr)","Trade|Gas (EJ/yr)","Trade|Oil (EJ/yr)","Trade|Biomass (EJ/yr)","Trade|Goods (billion US$2005/yr)")]
p5 <- magpie2ggplot2(trade[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Data2', color='Data1',shape='Data1',
                     scales='free_y',show_grid=TRUE,ncol=3)
print(p5)
tableTr <- trade[r_plot,y_table,][,,scenNames]

trade2 <- read_all(gdx_path,reportTrade,as.list=FALSE)
trade2 <- trade2[,,c("Trade|Imports|Coal (EJ/yr)","Trade|Imports|Gas (EJ/yr)","Trade|Imports|Oil (EJ/yr)","Trade|Imports|Biomass (EJ/yr)","Trade|Imports|Goods (billion US$2005/yr)")]
p6 <- magpie2ggplot2(trade2[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Data2', color='Data1',shape='Data1',
                     scales='free_y',show_grid=TRUE,ncol=3)
print(p6)
tableTr2 <- trade2[r_plot,y_table,][,,scenNames]
########################################################################

############### PE ################################
pe <- read_all(gdx_path,reportPE,as.list=FALSE)
pe <- pe[,,c("PE|Coal (EJ/yr)","PE|Gas (EJ/yr)","PE|Oil (EJ/yr)","PE|Biomass (EJ/yr)","PE|Solar (EJ/yr)","PE|Wind (EJ/yr)","PE|Nuclear (EJ/yr)")]
p7 <- magpie2ggplot2(pe[r_plot,y_table,],geom='line',group=NULL,
                     facet_x='Data2', color='Data1',shape='Data1',
                     ylab='normalized to 2005',scales='free_y',show_grid=TRUE,ncol=3)
print(p7)
tablePE <- pe[r_plot,y_table,][,,scenNames]



############### write pdf of the plot #################################

library(lusweave)

sw <- swopen()
swfigure(sw,print,p1,sw_option="height=9,width=16")
  for(r in r_plot){
    swtable(sw,collapseNames(table[r,,]),caption=paste("Consumption",sep=' '),digits=2,transpose=FALSE)
  }

swfigure(sw,print,p2,sw_option="height=9,width=16")
  for(r in r_plot){
    swtable(sw,collapseNames(tableCh[r,,]),caption=paste("Relative Change in Consumption",sep=' '),digits=4,transpose=TRUE)
  }

swfigure(sw,print,p3,sw_option="height=9,width=16")
for(r in r_plot){
  swtable(sw,collapseNames(tableAgg[r,,]),caption=paste("Consumption, Aggregated",sep=' '),digits=2,transpose=FALSE)
}

swfigure(sw,print,p4,sw_option="height=9,width=16")
swtable(sw,collapseNames(tablePr[,,"good"]),caption=paste("Price, Good",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePr[,,"peoil"]),caption=paste("Price, Oil",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePr[,,"pegas"]),caption=paste("Price, Gas",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePr[,,"pecoal"]),caption=paste("Price, Coal",sep=' '),digits=5,transpose=FALSE)

swfigure(sw,print,p5,sw_option="height=9,width=16")
swtable(sw,collapseNames(tableTr[,,"Trade|Coal (EJ/yr)"]),caption=paste("Trade, Coal",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tableTr[,,"Trade|Gas (EJ/yr)"]),caption=paste("Trade, Gas",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tableTr[,,"Trade|Oil (EJ/yr)"]),caption=paste("Trade, Oil",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tableTr[,,"Trade|Biomass (EJ/yr)"]),caption=paste("Trade, Biomass",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tableTr[,,"Trade|Goods (billion US$2005/yr)"]),caption=paste("Trade, Good",sep=' '),digits=5,transpose=FALSE)

swfigure(sw,print,p6,sw_option="height=9,width=16")
swtable(sw,collapseNames(tableTr2[,,"Trade|Imports|Coal (EJ/yr)"]),caption=paste("Trade|Imports, Coal",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tableTr2[,,"Trade|Imports|Gas (EJ/yr)"]),caption=paste("Trade|Imports, Gas",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tableTr2[,,"Trade|Imports|Oil (EJ/yr)"]),caption=paste("Trade|Imports, Oil",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tableTr2[,,"Trade|Imports|Biomass (EJ/yr)"]),caption=paste("Trade|Imports, Biomass",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tableTr2[,,"Trade|Imports|Goods (billion US$2005/yr)"]),caption=paste("Trade|Imports, Good",sep=' '),digits=5,transpose=FALSE)

swfigure(sw,print,p7,sw_option="height=9,width=16")
swtable(sw,collapseNames(tablePE[,,"PE|Coal (EJ/yr)"]),caption=paste("PE, Coal",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePE[,,"PE|Gas (EJ/yr)"]),caption=paste("PE, Gas",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePE[,,"PE|Oil (EJ/yr)"]),caption=paste("PE, Oil",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePE[,,"PE|Biomass (EJ/yr)"]),caption=paste("PE, Biomass",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePE[,,"PE|Solar (EJ/yr)"]),caption=paste("PE, Solar",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePE[,,"PE|Wind (EJ/yr)"]),caption=paste("PE, Wind",sep=' '),digits=5,transpose=FALSE)
swtable(sw,collapseNames(tablePE[,,"PE|Nuclear (EJ/yr)"]),caption=paste("PE, Nuclear",sep=' '),digits=5,transpose=FALSE)

swclose(sw,outfile="oneRegComp.pdf",clean_output=TRUE)
########################################################################
 
  
  

