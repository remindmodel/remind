# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(lusweave)
library(luplot)
library(lucode)
library(gdx)

############################# BASIC CONFIGURATION #############################
gdx_name <- "fulldata.gdx"        # name of the gdx   

if(!exists("source_include")) {
  #Define arguments that can be read from command line
   outputdir <- "."               # path to the output folder
   readArgs("outputdir","gdx_name")
} 

###############################################################################

##################### general plot settings ###################################
# time horizon for plots
y_plot <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
# regions for the plots
r_plot <- c("ROW","EUR","CHN","IND","JPN","RUS","USA","OAS","MEA","LAM","AFR")
###############################################################################

# Set gdx path
gdx_path <- path(outputdir,gdx_name)

############### Consumption ############################################
cons <- readGDX(gdx_path,"vm_cons", format="first_found")
p1 <- magpie2ggplot2(cons[r_plot,y_plot,"l"],geom='line',ylab='Consumption[trill.$US]',color='Region',show_grid=TRUE)
p2 <- magpie2ggplot2(cons[r_plot,y_plot,"l"],geom='line',facet_x=NULL,ylab='Consumption[trill.$US]',color='Region',show_grid=TRUE)
########################################################################

### vari - used for GDP,...
vari <- readGDX(gdx_path,"vm_cesIO", format="first_found")

############### GDP|MER ################################################   
gdp <- vari[,,"inco.l"]
p3 <- magpie2ggplot2(gdp[r_plot,y_plot,],geom='line',ylab='GDP[trill.$US]',color='Region',show_grid=TRUE)
p4 <- magpie2ggplot2(gdp[r_plot,y_plot,],geom='area',stack=TRUE,facet_x=NULL,ylab='GDP',color='Region',show_grid=TRUE)
########################################################################

### fuelex - used for pebiolc
fuelex <- readGDX(gdx_path,"vm_fuExtr", format="first_found")

############### biomass extraction #####################################
fuelex_bio <- fuelex[,,"pebiolc.1.l"]
fuelex_bio <- setNames(fuelex_bio,"level")
  # upper bound on biomass
fuelex_up <- readGDX(gdx_path,"p30_max_pebiolc_path", format="first_found")
fuelex_up <- setNames(fuelex_up,"up")
  # lower bound on biomass
fuelex_lo <- readGDX(gdx_path,"p30_min_pebiolc", format="first_found")
fuelex_lo <- setNames(fuelex_lo,"lo")
  # put all together for plotting
plot_fuelex_bio <- mbind2(fuelex_up[r_plot,y_plot,"up"],fuelex_bio[r_plot,y_plot,],fuelex_lo[r_plot,y_plot,"lo"])
p5 <- magpie2ggplot2(plot_fuelex_bio,geom='line',group=NULL,color='Data1',ylab='biomass extraction',scales='free_y',show_grid=TRUE)
########################################################################

############### quality of intertemporal convergence (defic) ###########
defic <- readGDX(gdx_path,"p80_defic", format="first_found") 
n_plot <- c()
for (n in getNames(defic)) {
 if(defic[,,n]!=0) n_plot = c(n_plot,n)
}
p6 <- magpie2ggplot2(defic[r_plot,,n_plot],geom='line',xaxis='Data1',xlab='iteration',ylab='defic',color='Region',facet_x=NULL,show_grid=TRUE)
########################################################################

### budget - used for price scaling,...
budget <- readGDX(gdx_path,"qm_budget", format="first_found")

############### prices of resources ####################################   
budget_m <- budget[,,"m"]
pebal <- readGDX(gdx_path,"q_balPe", format="first_found")
pebal_m <- as.magpie(pebal[,,"m"])
res_plot <- c("peoil","pegas","pecoal","peur","pebiolc")
pebal_m <- pebal_m[,,res_plot]
prices <- pebal_m/budget_m 
p7 <- magpie2ggplot2(prices[r_plot,y_plot,],geom='line',ylab='prices[trill.$US/TWa]',facet_x='Data1',color='Region',scales='free_y',show_grid=TRUE)
########################################################################

############### print figures ##########################################
print(p1)
print(p2)
print(p3)
print(p4)
print(p5)
print(p6)
print(p7)
########################################################################

############### write pdf of the plots #################################
library(lusweave)

sw <- swopen("gdx_example.pdf")
swfigure(sw,print,p1)
swfigure(sw,print,p2)
swfigure(sw,print,p3)
swfigure(sw,print,p4)
swfigure(sw,print,p5)
swfigure(sw,print,p6)
swfigure(sw,print,p7)
swclose(sw)
########################################################################
 
  
  

