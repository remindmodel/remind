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
  outputdirs <- c("C:/Documents and Settings/dklein/My Documents/0_SVN/0_B_remind_modular/output/SSP2-26/",
                  "C:/Documents and Settings/dklein/My Documents/0_SVN/0_B_remind_modular/output/SSP2-37/")
  # path to the output folder
   readArgs("outputdirs","gdx_name")
} 


##################### general plot settings ###################################
TWa2EJ <- 31.5576      # TWa to EJ (1 a = 365.25*24*3600 s = 31557600 s)
txtsiz <- 20

# time horizon for plots
y_plot <- c("y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100")
# regions for the plots
r_plot <- c("ROW","EUR","CHN","IND","JPN","RUS","USA","OAS","MEA","LAM","AFR")
r_plot <- c("GLO")

# Set gdx path
gdx_path       <- path(outputdirs,gdx_name)
scenNames_path <- path(outputdirs,"config.Rdata")
scenNames <- c()
for (i in scenNames_path) {
  load(i)
  scenNames[i] <- cfg$title
  }

names(gdx_path) <- scenNames

readfuelex <- function(gdx,enty) {
  out <- readGDX(gdx, "vm_fuExtr", format="first_found", field="l")[,,enty]
  out <- collapseNames(out)
  return(out)
}

############### read and calculate data ################################
fuelex <- read_all(gdx_path,readfuelex,enty="pebiolc",as.list=FALSE)

fuelex_bio <- dimSums(fuelex,dims=4) * TWa2EJ # grades are in fourth dimension

fuelex_bio[12,,] <- colSums(fuelex_bio[-12,,])

################## plot data ###########################################
p1 <- magpie2ggplot2(fuelex_bio[r_plot,y_plot,],geom='line',group=NULL,
                     ylab='EJ/yr',color='Data1',
                     scales='fixed',show_grid=TRUE,ncol=4,text_size=txtsiz,ylim=c(0,max(fuelex_bio)),
                     title=paste0("Purpose grown bio: production"))

print(p1)

############### write pdf of the plot #################################
library(lusweave)

out<-swopen(outfile=paste0("bioenergy_glob_comp.pdf"),template="/home/dklein/scripts/template.tex")
swfigure(out,print,p1,sw_option="height=9,width=16")
swclose(out,clean_output=TRUE)
return("Done\n")
