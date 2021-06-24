# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# setwd("~/Documents/0_SVN/REMIND2.0")

library(lucode2)
library(gms)
library(lusweave)
library(luplot)
library(gdx)
library(ggplot2)
library(remind2)
library(mip)

#####################################################
################## CONFIGURATION ####################
#####################################################
 
if(!exists("source_include")) {
   outputdir <- "~/Transferfolder/coupling/"
}

scenario <- getScenNames(outputdir)

gdx <- path(outputdir,"fulldata.gdx")

filename<-paste0("REMIND_generic_",scenario,".mif")
if (file.exists(filename)) {
  csv <- read.report(filename,as.list = FALSE)
} else if (file.exists(path(outputdir,filename))) {
  csv <- read.report(path(outputdir,filename),as.list = FALSE)
} else {
  stop("No REMIND_generic_*.mif file found - please perform postprocessing first!")
}

years <- getYears(csv)

#####################################################
################## START PDF ########################
#####################################################

# MAgPIE EMULATOR results
# open pdf
emulator_file <- path(outputdir,paste0("EMULATOR_",scenario,".pdf"))
pdf<-swopen()
swlatex(pdf,c("\\title{MAgPIE EMULATOR results}","\\author{David Klein}","\\maketitle","\\tableofcontents"))
swlatex(pdf,"\\newpage")
swlatex(pdf,"\\mbox{} \\thispagestyle{empty}")
swlatex(pdf,"\\newpage")

swlatex(pdf,"\\section{Adapting the supply curves}")

#####################################################
##################### SHIFT #########################
#####################################################

swlatex(pdf,"\\subsection{Shift factors for intercept}")

out <- readGDX(gdx,name="v30_priceshift", format="first_found", field="l") * 1000 / 31.536
getNames(out) <- "dummy" # something has to be here, will be removed by collapseNames anyway
shift <- collapseNames(out)

dat <- as.ggplot(shift[,years,])
myplot <- ggplot(data=dat, aes(x=Year, y=Value)) + geom_line() + geom_point() +
     scale_color_manual(values=plotstyle(levels(dat$Region))) + labs(y="$/GJ") + facet_wrap(~Region)

swfigure(pdf,print,myplot,fig.width=1)

#####################################################
##################### MULT ##########################
#####################################################

swlatex(pdf,"\\subsection{Multiplication factors for slope}")

out <- readGDX(gdx,name="v30_pricemult", format="first_found", field="l")
getNames(out) <- "dummy" # something has to be here, will be removed by collapseNames anyway
mult <- collapseNames(out)

dat <- as.ggplot(mult[,years,])
myplot <- ggplot(data=dat, aes(x=Year, y=Value)) + geom_line() + geom_point(size=0.7) +
     scale_color_manual(values=plotstyle(levels(dat$Region))) + labs(y="") + facet_wrap(~Region,scales="free_y")

swfigure(pdf,print,myplot,fig.width=1)

#####################################################
################ SUPPLYCURVES #######################
#####################################################

swlatex(pdf,"\\subsection{Supplycurve}")
x <- readSupplycurveBio(outputdir)

regions <- sort(getRegions(x$supplycurve))

for (y in years) {

  title <- paste0(y) 
  dat <- gginput(x$supplycurve[regions,y,],scatter="type")
  dat$year<-factor(dat$year)

  p <- ggplot(dat, aes(x=.value.x,y=.value.y)) +
    geom_line(aes(colour=scenario, linetype=curve)) + #geom_line(size=0.5) + 
    geom_point(data=gginput(x$rem_point[regions,y,],scatter = "variable"),aes(x=.value.x,y=.value.y,colour=scenario)) +
    geom_point(data=gginput(x$mag_point[regions,y,],scatter = "variable"),aes(x=.value.x,y=.value.y,colour=scenario),shape=5) +
    facet_wrap(~region) +
    ggtitle(title) + ylab("$/GJ") + xlab("EJ") + coord_cartesian(xlim=c(0,80),ylim=c(0,30)) +
    theme(legend.position="top") + guides(linetype=guide_legend(nrow=2,byrow=TRUE, title.position = "top")) + 
    guides(color=guide_legend(nrow=1,byrow=TRUE, title.position = "top"))
  
  swfigure(pdf,print,p) #,sw_option="height=9,width=12")
}

#####################################################
################## PRICE & DEMAND ###################
#####################################################

swlatex(pdf,"\\section{Bioenergy demand and prices}")

var_price_shapes = c("Price|Biomass|MAgPIE (US$2005/GJ)" = 0,
                     "Price|Biomass|Emulator presolve (US$2005/GJ)" = 1,
                     "Price|Biomass|Emulator presolve shifted (US$2005/GJ)" = 2,
                     "Price|Biomass|Emulator shifted (US$2005/GJ)" = 4)

# bring GLO to front
regions <- getRegions(csv)
if ("GLO" %in% regions) {
  regions <- c(regions[which(regions=="GLO")], regions[-which(regions=="GLO")])
}

for (r in regions){
  plot.title<-paste0("\\subsection{Bioenergy demand (",r,")}")
  swlatex(pdf,plot.title)
  var_dem = c("Primary Energy Production|Biomass|Energy Crops (EJ/yr)","Primary Energy Production|Biomass|Energy Crops MAgPIE (EJ/yr)")
  dat<-as.ggplot(csv[r,years,var_dem])
  p <- ggplot(data=dat, aes(x=Year, y=Value)) + geom_line(aes(colour=Data3),size=1) + labs(y="EJ/yr") +
        geom_point(aes(colour=Data3),size=2) +
        guides(color = guide_legend(nrow = length(var_dem))) +
        theme(legend.position="top", legend.title=element_blank()) +
        theme(legend.text = element_text(size = 8))
    swfigure(pdf,print,p)#,sw_option="height=6,width=10",fig.placement="!h")

  if(r!= "GLO") {
    plot.title<-paste0("\\subsection{Bioenergy prices (",r,")}")
    swlatex(pdf,plot.title)
    var_price = c("Price|Biomass|MAgPIE (US$2005/GJ)","Price|Biomass|Emulator presolve (US$2005/GJ)","Price|Biomass|Emulator presolve shifted (US$2005/GJ)","Price|Biomass|Emulator shifted (US$2005/GJ)")
    dat<-as.ggplot(csv[r,years,var_price])
    
    p <- ggplot(data=dat, aes(x=Year, y=Value,colour=Data3)) + geom_line(size=1) + labs(y="$/GJ") + 
          geom_point(aes(shape=Data3),size=4) +
          scale_shape_manual(values = var_price_shapes) +
          theme(legend.position="top",legend.title=element_blank()) +
          guides(shape = guide_legend(nrow = length(var_price))) +
          theme(legend.text = element_text(size = 8))
    
    swfigure(pdf,print,p)#,sw_option="height=6,width=10",fig.placement="!h")
  } else {
    # Add empty page so that for all following regions demand is printed on left pages and price on right
    # swlatex(pdf,"\\newpage")
    # swlatex(pdf,"\\mbox{} \\thispagestyle{empty}")
    # swlatex(pdf,"\\newpage")
  }
}

#####################################################
###################### COSTS ########################
#####################################################

swlatex(pdf,"\\section{Bioenergy costs}")

var_pe = c("Costs|Biomass|MAgPIE (billion US$2005/yr)",
           "Costs|Biomass|Price integral presolve (billion US$2005/yr)",
           "Costs|Biomass|Price integral (billion US$2005/yr)")
var_pe <- intersect(getNames(csv,dim="variable"),var_pe) # take only existing variables

if (!identical(var_pe, character(0))) {
    plot.title<-paste0("\\subsection{Bioenergy costs}")
    swlatex(pdf,plot.title)
    dat<-as.ggplot(csv[,years,var_pe]["GLO",,invert=TRUE])
    
    p <- ggplot(data=dat, aes(x=Year, y=Value)) + geom_line(aes(colour=Data3),size=1) + labs(y="billion US$2005") +
      geom_point(aes(colour=Data3),size=1) +
      guides(color = guide_legend(nrow = length(var_pe))) +
      theme(legend.position="top", legend.title=element_blank()) +
      theme(legend.text = element_text(size = 8)) +
      facet_wrap(~Region)

    swfigure(pdf,print,p,fig.width=1)
}
    
#close pdf and Change the name
swclose(pdf,outfile=emulator_file,clean_output=TRUE,save_stream=FALSE)
