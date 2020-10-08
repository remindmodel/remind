# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# Coupling summary

library(magclass)
library(mip)
library(ggplot2)
library(lusweave)

# ---- Settings ----

setwd("~/Documents/1_Projekte/Kopplung/2019_Validation-R2M4")

fileName  <- "coupling-summary.pdf"
y_bar     <- c(2010,2030,2050,2100)
y_bar_near_term <- c(2010,2030,2050)
hist      <- "historical.mif"
y_hist    <- c(seq(1960,2015,1))

scenarios <- c("C_Base","Base","C_NPi","NPi","C_NDC","NDC","C_Budg600","Budg600")

# /p/projects/remind/runs/r8375-C/output/all-r8375.mif
#data_all <- read.report("all-r8423-8438.mif",as.list = FALSE)

# Remove -mag-* and -rem-* from scenario names to make them the same
getNames(data_all,dim=1) <- gsub("-(rem|mag)-[0-9]{1,2}","",getNames(data_all,dim=1))

data <- data_all

getNames(data,dim=1) <- gsub("r8423-","",getNames(data,dim=1))
getNames(data,dim=1) <- gsub("r8438-","",getNames(data,dim=1))

# Pick scenarios in the order defined above (for a proper order in the plots)
data <- data[,getYears(data)<="y2100",scenarios]

data_near_term <- data[,getYears(data)<="y2050",]

# Read historical data
hist <- read.report(hist,as.list=FALSE)
if(all(getRegions(data) %in% getRegions(hist))) {
 hist = hist[getRegions(data),,]
 if ( any(grepl("EDGE_SSP2",getNames(hist)))){
   hist = hist[,,"EDGE_SSP2", invert = T]
 }
 hist <- hist[,y_hist,]
}

# ---- Open output-pdf ----

template <-  c("\\documentclass[a4paper,landscape,twocolumn]{article}",
               "\\setlength{\\oddsidemargin}{-0.8in}",                                                                              
               "\\setlength{\\evensidemargin}{-0.5in}",                                                                             
               "\\setlength{\\topmargin}{-0.8in}",                                                                                  
               "\\setlength{\\parindent}{0in}",                                                                                     
               "\\setlength{\\headheight}{0in}",                                                                                    
               "\\setlength{\\topskip}{0in}",                                                                                       
               "\\setlength{\\headsep}{0in}",                                                                                       
               "\\setlength{\\footskip}{0.2in}",                                                                                    
               "\\setlength\\textheight{0.95\\paperheight}",                                                                        
               "\\setlength\\textwidth{0.95\\paperwidth}",                                                                          
               "\\setlength{\\parindent}{0in}",
               "\\usepackage{float}",
               "\\usepackage[bookmarksopenlevel=section,colorlinks=true,linkbordercolor={0.9882353 0.8352941 0.7098039}]{hyperref}",
               "\\hypersetup{bookmarks=true,pdfauthor={GES group, PIK}}",
               "\\usepackage{graphicx}",
               "\\usepackage[strings]{underscore}",
               "\\usepackage{Sweave}",                                                                                              
               "\\begin{document}",
               "<<echo=false>>=",
               "options(width=110)",
               "@")

sw <- swopen(fileName,template = template)
swlatex(sw,"\\tableofcontents\\cleardoublepage")

# ---- ++++ EMISSIONS ++++ ----

swlatex(sw,"\\section{Emissions}")

# ---- CO2eq by source ----

swlatex(sw,"\\subsection{CO2eq by source}")
GWP <- c("CO2"=1,"CH4"=28,"N2O"=265)
var <- NULL
var <- mbind(var,data[,,"Emi|CO2|Land-Use Change (Mt CO2/yr)"]                   *GWP["CO2"])
var <- mbind(var,data[,,"Emi|CO2|Gross Fossil Fuels and Industry (Mt CO2/yr)"]   *GWP["CO2"])
var <- mbind(var,data[,,"Emi|CO2|Carbon Capture and Storage|Biomass (Mt CO2/yr)"]*-GWP["CO2"])
var <- mbind(var,data[,,"Emi|CH4|Energy Supply and Demand (Mt CH4/yr)"]          *GWP["CH4"])
var <- mbind(var,data[,,"Emi|CH4|Land Use (Mt CH4/yr)"]                          *GWP["CH4"])
var <- mbind(var,data[,,"Emi|CH4|Other (Mt CH4/yr)"]                             *GWP["CH4"])
var <- mbind(var,data[,,"Emi|CH4|Waste (Mt CH4/yr)"]                             *GWP["CH4"])
var <- mbind(var,data[,,"Emi|N2O|Land Use (kt N2O/yr)"]                          *GWP["N2O"]/1000)
var <- mbind(var,data[,,"Emi|N2O|Energy Supply and Demand (kt N2O/yr)"]          *GWP["N2O"]/1000)
var <- mbind(var,data[,,"Emi|N2O|Waste (kt N2O/yr)"]                             *GWP["N2O"]/1000)
var <- mbind(var,data[,,"Emi|N2O|Industry (kt N2O/yr)"]                          *GWP["N2O"]/1000)
var <- setNames(var,gsub(" \\(.*\\)"," (Mt CO2eq/yr)",getNames(var)))

p <- mipArea(var["GLO",,],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- CO2 by sector ----

swlatex(sw,"\\subsection{CO2 by sector}")

tot <-"Emi|CO2 (Mt CO2/yr)"
items <- c("Emi|CO2|Land-Use Change (Mt CO2/yr)",
           "Emi|CO2|Energy|Supply|Non-Elec (Mt CO2/yr)",
           "Emi|CO2|Energy|Supply|Electricity|Gross (Mt CO2/yr)",
           "Emi|CO2|Energy|Demand|Industry|Gross (Mt CO2/yr)",
           "Emi|CO2|FFaI|Industry|Process (Mt CO2/yr)",
           #          "Emi|CO2|Industrial Processes (Mt CO2/yr)",
           "Emi|CO2|Buildings|Direct (Mt CO2/yr)",
           "Emi|CO2|Transport|Demand (Mt CO2/yr)",
           "Emi|CO2|Carbon Capture and Storage|Biomass|Neg (Mt CO2/yr)",
           "Emi|CO2|CDR|DAC (Mt CO2/yr)",
           "Emi|CO2|CDR|EW (Mt CO2/yr)")
var <- data[,,intersect(items,getNames(data,dim=3))]

p <- mipArea(var["GLO",,],total=data["GLO",,tot],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],total=data[,,tot]["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- CO2 land-use ----

swlatex(sw,"\\subsection{CO2 land-use}")
p <- mipLineHistorical(data["GLO",,"Emi|CO2|Land-Use Change (Mt CO2/yr)"],#x_hist=hist["GLO",,"Emi|CO2|Land Use (Mt CO2/yr)"],
                       ylab='Emi|CO2|Land-Use Change [Mt CO2/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,"Emi|CO2|Land-Use Change (Mt CO2/yr)"]["GLO",,,invert=TRUE],#x_hist=hist[,,"Emi|CO2|Land Use (Mt CO2/yr)"]["GLO",,,invert=TRUE],
                       ylab='Emi|CO2|Land-Use Change [Mt CO2/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- CH4 land-use ----

swlatex(sw,"\\subsection{CH4 land-use}")
p <- mipLineHistorical(data["GLO",,"Emi|CH4|Land Use (Mt CH4/yr)"],#x_hist=hist["GLO",,"Emi|CH4|Land Use (Mt CH4/yr)"],
                       ylab='Emi|CH4|Land Use [Mt CH4/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,"Emi|CH4|Land Use (Mt CH4/yr)"]["GLO",,,invert=TRUE],#x_hist=hist[,,"Emi|CH4|Land Use (Mt CH4/yr)"]["GLO",,,invert=TRUE],
                       ylab='Emi|CH4|Land Use [Mt CH4/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- N2O land-use ----

swlatex(sw,"\\subsection{N2O}")
p <- mipLineHistorical(data["GLO",,"Emi|N2O|Land Use (kt N2O/yr)"],#x_hist=hist["GLO",,"Emi|N2O|Land Use (kt N2O/yr)"],
                       ylab='Emi|N2O|Land Use [kt N2O/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,"Emi|N2O|Land Use (kt N2O/yr)"]["GLO",,,invert=TRUE],#x_hist=hist[,,"Emi|N2O|Land Use (kt N2O/yr)"]["GLO",,,invert=TRUE],
                       ylab='Emi|N2O|Land Use [kt N2O/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- CDR by sector ----

swlatex(sw,"\\subsection{CDR by sector}")
tot <-"Emi|CO2 (Mt CO2/yr)"
items <- c("Emi|CO2|Gross Fossil Fuels and Industry (Mt CO2/yr)",
           "Emi|CO2|Carbon Capture and Storage|Fossil (Mt CO2/yr)",
           #"Emissions|CO2|Land|Land-use Change|+|Positive (Mt CO2/yr)",
           #"Emissions|CO2|Land|Land-use Change|+|Negative (Mt CO2/yr)",
           "Emi|CO2|Land-Use Change (Mt CO2/yr)",
           "Emi|CO2|CDR|BECCS (Mt CO2/yr)",
           "Emi|CO2|CDR|DAC (Mt CO2/yr)",
           "Emi|CO2|CDR|EW (Mt CO2/yr)")
var <- data[,,intersect(items,getNames(data,dim=3))]

# remove model dimension, because it has remind AND magpie, but mipBarYearData can't handle that
var <- collapseNames(var,collapsedim = 2)

p <- mipArea(var["GLO",,],total=data["GLO",,tot],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],total=data[,,tot]["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- ++++ EMISSIONS - near-term ++++ ----

swlatex(sw,"\\section{Emissions - near-term}")

# ---- CO2eq by source - near-term----

swlatex(sw,"\\subsection{CO2eq by source - near-term}")
GWP <- c("CO2"=1,"CH4"=28,"N2O"=265)
var <- NULL
var <- mbind(var,data_near_term[,,"Emi|CO2|Land-Use Change (Mt CO2/yr)"]                   *GWP["CO2"])
var <- mbind(var,data_near_term[,,"Emi|CO2|Gross Fossil Fuels and Industry (Mt CO2/yr)"]   *GWP["CO2"])
var <- mbind(var,data_near_term[,,"Emi|CO2|Carbon Capture and Storage|Biomass (Mt CO2/yr)"]*-GWP["CO2"])
var <- mbind(var,data_near_term[,,"Emi|CH4|Energy Supply and Demand (Mt CH4/yr)"]          *GWP["CH4"])
var <- mbind(var,data_near_term[,,"Emi|CH4|Land Use (Mt CH4/yr)"]                          *GWP["CH4"])
var <- mbind(var,data_near_term[,,"Emi|CH4|Other (Mt CH4/yr)"]                             *GWP["CH4"])
var <- mbind(var,data_near_term[,,"Emi|CH4|Waste (Mt CH4/yr)"]                             *GWP["CH4"])
var <- mbind(var,data_near_term[,,"Emi|N2O|Land Use (kt N2O/yr)"]                          *GWP["N2O"]/1000)
var <- mbind(var,data_near_term[,,"Emi|N2O|Energy Supply and Demand (kt N2O/yr)"]          *GWP["N2O"]/1000)
var <- mbind(var,data_near_term[,,"Emi|N2O|Waste (kt N2O/yr)"]                             *GWP["N2O"]/1000)
var <- mbind(var,data_near_term[,,"Emi|N2O|Industry (kt N2O/yr)"]                          *GWP["N2O"]/1000)
var <- setNames(var,gsub(" \\(.*\\)"," (Mt CO2eq/yr)",getNames(var)))

p <- mipArea(var["GLO",,],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar_near_term,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar_near_term,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- CO2 by sector - near-term ----

swlatex(sw,"\\subsection{CO2 by sector - near-term}")

tot <-"Emi|CO2 (Mt CO2/yr)"
items <- c("Emi|CO2|Land-Use Change (Mt CO2/yr)",
           "Emi|CO2|Energy|Supply|Non-Elec (Mt CO2/yr)",
           "Emi|CO2|Energy|Supply|Electricity|Gross (Mt CO2/yr)",
           "Emi|CO2|Energy|Demand|Industry|Gross (Mt CO2/yr)",
           "Emi|CO2|FFaI|Industry|Process (Mt CO2/yr)",
           #          "Emi|CO2|Industrial Processes (Mt CO2/yr)",
           "Emi|CO2|Buildings|Direct (Mt CO2/yr)",
           "Emi|CO2|Transport|Demand (Mt CO2/yr)",
           "Emi|CO2|Carbon Capture and Storage|Biomass|Neg (Mt CO2/yr)",
           "Emi|CO2|CDR|DAC (Mt CO2/yr)",
           "Emi|CO2|CDR|EW (Mt CO2/yr)")
var <- data_near_term[,,intersect(items,getNames(data_near_term,dim=3))]

p <- mipArea(var["GLO",,],total=data_near_term["GLO",,tot],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar_near_term,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar_near_term,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],total=data_near_term[,,tot]["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- CO2 land-use - near-term ----

swlatex(sw,"\\subsection{CO2 land-use - near-term}")
p <- mipLineHistorical(data_near_term["GLO",,"Emi|CO2|Land-Use Change (Mt CO2/yr)"],#x_hist=hist["GLO",,"Emi|CO2|Land Use (Mt CO2/yr)"],
                       ylab='Emi|CO2|Land-Use Change [Mt CO2/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data_near_term[,,"Emi|CO2|Land-Use Change (Mt CO2/yr)"]["GLO",,,invert=TRUE],#x_hist=hist[,,"Emi|CO2|Land Use (Mt CO2/yr)"]["GLO",,,invert=TRUE],
                       ylab='Emi|CO2|Land-Use Change [Mt CO2/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- CH4 land-use - near-term ----

swlatex(sw,"\\subsection{CH4 land-use - near-term}")
p <- mipLineHistorical(data_near_term["GLO",,"Emi|CH4|Land Use (Mt CH4/yr)"],#x_hist=hist["GLO",,"Emi|CH4|Land Use (Mt CH4/yr)"],
                       ylab='Emi|CH4|Land Use [Mt CH4/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data_near_term[,,"Emi|CH4|Land Use (Mt CH4/yr)"]["GLO",,,invert=TRUE],#x_hist=hist[,,"Emi|CH4|Land Use (Mt CH4/yr)"]["GLO",,,invert=TRUE],
                       ylab='Emi|CH4|Land Use [Mt CH4/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- N2O land-use - near-term ----

swlatex(sw,"\\subsection{N2O land-use - near-term}")
p <- mipLineHistorical(data_near_term["GLO",,"Emi|N2O|Land Use (kt N2O/yr)"],#x_hist=hist["GLO",,"Emi|N2O|Land Use (kt N2O/yr)"],
                       ylab='Emi|N2O|Land Use [kt N2O/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data_near_term[,,"Emi|N2O|Land Use (kt N2O/yr)"]["GLO",,,invert=TRUE],#x_hist=hist[,,"Emi|N2O|Land Use (kt N2O/yr)"]["GLO",,,invert=TRUE],
                       ylab='Emi|N2O|Land Use [kt N2O/yr]',scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- CDR by sector - near-term ----

swlatex(sw,"\\subsection{CDR by sector - near-term}")
tot <-"Emi|CO2 (Mt CO2/yr)"
items <- c("Emi|CO2|Gross Fossil Fuels and Industry (Mt CO2/yr)",
           "Emi|CO2|Carbon Capture and Storage|Fossil (Mt CO2/yr)",
           #"Emissions|CO2|Land|Land-use Change|+|Positive (Mt CO2/yr)",
           #"Emissions|CO2|Land|Land-use Change|+|Negative (Mt CO2/yr)",
           "Emi|CO2|Land-Use Change (Mt CO2/yr)",
           "Emi|CO2|CDR|BECCS (Mt CO2/yr)",
           "Emi|CO2|CDR|DAC (Mt CO2/yr)",
           "Emi|CO2|CDR|EW (Mt CO2/yr)")
var <- data_near_term[,,intersect(items,getNames(data_near_term,dim=3))]

# remove model dimension, because it has remind AND magpie, but mipBarYearData can't handle that
var <- collapseNames(var,collapsedim = 2)

p <- mipArea(var["GLO",,],total=data_near_term["GLO",,tot],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar_near_term,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar_near_term,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],total=data_near_term[,,tot]["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- ++++ ENERGY ++++ ----

swlatex(sw,"\\section{Energy}")

# ---- PE by carrier ----

swlatex(sw,"\\subsection{PE by carrier}")

items <-c("PE|+|Coal (EJ/yr)",
          "PE|+|Oil (EJ/yr)",
          "PE|+|Gas (EJ/yr)",
          "PE|+|Biomass (EJ/yr)",
          "PE|+|Nuclear (EJ/yr)",
          "PE|+|Solar (EJ/yr)",
          "PE|+|Wind (EJ/yr)",
          "PE|+|Hydro (EJ/yr)",
          "PE|+|Geothermal (EJ/yr)")
var <- data[,,intersect(items,getNames(data,dim=3))]

p <- mipArea(var["GLO",,],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- SE Electricity by carrier ----

swlatex(sw,"\\subsection{SE Electricity by carrier}")

items<- c ("SE|Electricity|Coal|w/ CCS (EJ/yr)",
           "SE|Electricity|Coal|w/o CCS (EJ/yr)",
           "SE|Electricity|Oil (EJ/yr)",
           "SE|Electricity|Gas|w/ CCS (EJ/yr)",
           "SE|Electricity|Gas|w/o CCS (EJ/yr)",
           "SE|Electricity|Geothermal (EJ/yr)",
           "SE|Electricity|Hydro (EJ/yr)",
           "SE|Electricity|Nuclear (EJ/yr)",
           "SE|Electricity|Biomass|w/ CCS (EJ/yr)",
           "SE|Electricity|Biomass|w/o CCS (EJ/yr)",
           "SE|Electricity|Solar|CSP (EJ/yr)",
           "SE|Electricity|Solar|PV (EJ/yr)",
           "SE|Electricity|Wind (EJ/yr)",
           "SE|Electricity|Hydrogen (EJ/yr)")
var <- data[,,intersect(items,getNames(data,dim=3))]

p <- mipArea(var["GLO",,],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- FE by sector ----

swlatex(sw,"\\subsection{FE by sector}")

items<- c("FE|CDR (EJ/yr)",
          "FE|Transport (EJ/yr)",
          "FE|Buildings (EJ/yr)",
          "FE|Industry (EJ/yr)")
var <- data[,,intersect(items,getNames(data,dim=3))]

p <- mipArea(var["GLO",,], scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- FE by carrier ----

swlatex(sw,"\\subsection{FE by carrier}")

items<- c("FE|+|Solids (EJ/yr)",
          "FE|+|Liquids (EJ/yr)",
          "FE|+|Gases (EJ/yr)",
          "FE|+|Heat (EJ/yr)",
          "FE|+|Hydrogen (EJ/yr)",
          "FE|+|Electricity (EJ/yr)")
var <- data[,,intersect(items,getNames(data,dim=3))]

p <- mipArea(var["GLO",,],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- PE Biomass by soure ----
swlatex(sw,"\\subsection{Biomass Production and Consumption}")

# Add inverted trade variable (export are negative and imports are positive)
tmp <- -data[,,"Trade|Biomass (EJ/yr)"]
getNames(tmp,dim=3) <- "Trade|Biomass inverted (EJ/yr)"
data <- mbind(data,tmp)

items <- c("Trade|Biomass inverted (EJ/yr)",
           "Primary Energy Production|Biomass|Energy Crops (EJ/yr)",
           "PE|Biomass|Residues (EJ/yr)",
           "PE|Biomass|1st Generation (EJ/yr)")
          # PE|Biomass|Modern
          # PE|Biomass|Traditional
          # PE|Biomass|Energy Crops

var <- data[,,intersect(items,getNames(data,dim=3))]

p <- mipArea(var["GLO",,],total=data["GLO",,"PE|+|Biomass (EJ/yr)"])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],total=data[,,"PE|+|Biomass (EJ/yr)"]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- PE Biomass by demand ----

swlatex(sw,"\\subsection{PE|Biomass Area}")

items<- c ("PE|Biomass|Solids (EJ/yr)",
           "PE|Biomass|Heat (EJ/yr)",
           "PE|Biomass|Liquids|w/ CCS (EJ/yr)",
           "PE|Biomass|Liquids|w/o CCS (EJ/yr)",
           "PE|Biomass|Gases (EJ/yr)",
           "PE|Biomass|Electricity|w/ CCS (EJ/yr)",
           "PE|Biomass|Electricity|w/o CCS (EJ/yr)",
           "PE|Biomass|Hydrogen|w/ CCS (EJ/yr)",
           "PE|Biomass|Hydrogen|w/o CCS (EJ/yr)")
var <- data[,,intersect(items,getNames(data,dim=3))]

p <- mipArea(var["GLO",,],scales="free_y")
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")

p <- mipBarYearData(var["GLO",y_bar,])
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=4.5,width=7")

p <- mipBarYearData(var[,y_bar,]["GLO",,,invert=TRUE])
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\onecolumn")
p <- mipArea(var["GLO",,,invert=TRUE],scales="free_y")
swfigure(sw,print,p,sw_option="height=8,width=16")
swlatex(sw,"\\twocolumn")

# ---- PE Biomass (line) ----

swlatex(sw,"\\subsection{PE|Biomass}")
var <- "PE|+|Biomass (EJ/yr)"
p <- mipLineHistorical(data["GLO",,var],x_hist=hist["GLO",,"PE|Biomass (EJ/yr)"],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],x_hist=hist[,,"PE|Biomass (EJ/yr)"]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- PE Biomass purpose grown (line) ----

swlatex(sw,"\\subsection{PE|Biomass purpose grown}")
var <- "Primary Energy Production|Biomass|Energy Crops (EJ/yr)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- Trade Biomass ----

swlatex(sw,"\\subsection{Trade Biomass}")
var <- "Trade|Biomass (EJ/yr)"
p <- mipArea(data[,,var])
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],x_hist=NULL,
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- ++++ LAND COVER ++++ ----

# ---- Yields ----

swlatex(sw,"\\subsection{Bioenerg yields}")
var <- "Productivity|Yield|+|Bioenergy crops (t DM/ha)"
#p <- mipLineHistorical(data["GLO",,var],
#                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
#swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\subsection{Cereal yields}")
var <- "Productivity|Yield|Crops|+|Cereals (t DM/ha)"
#p <- mipLineHistorical(data["GLO",,var],
#                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
#swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- TAU ----

swlatex(sw,"\\subsection{TAU}")
var <- "Productivity|Landuse Intensity Indicator Tau (Index)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- Land cover Stacked ----

swlatex(sw,"\\section{Land cover}")
# select the variables that have "+" at the 3rd and at the 4th slot
n <- c(grep("Resources\\|Land Cover\\|\\+.*",getNames(data,dim=3),value=TRUE),
       grep("Resources\\|Land Cover\\|[^\\|]*\\|\\+.*",getNames(data,dim=3),value=TRUE))

cat("There are the following land variables potentially relevant. Please manually choose the relevant ones!\n")
cat(sort(n),sep='",\n"')

var <-  c(#"Resources|Land Cover|+|Cropland (million ha)",
  #"Resources|Land Cover|+|Forest (million ha)",
  "Resources|Land Cover|+|Other Land (million ha)",
  "Resources|Land Cover|+|Pastures and Rangelands (million ha)",
  "Resources|Land Cover|Cropland|+|Bioenergy crops (million ha)",
  "Resources|Land Cover|Cropland|+|Crops (million ha)",
  "Resources|Land Cover|Cropland|+|Forage (million ha)",
  "Resources|Land Cover|Forest|+|Managed Forest (million ha)",
  "Resources|Land Cover|Forest|+|Natural Forest (million ha)",
  "Resources|Land Cover|+|Urban Area (million ha)")

tmp <- data[,,var]

getNames(tmp,dim=3) <- gsub("\\+\\|","",getNames(tmp,dim=3))
getNames(tmp,dim=3) <- gsub("Cropland\\|","",getNames(tmp,dim=3))
getNames(tmp,dim=3) <- gsub("Forest\\|","",getNames(tmp,dim=3))

# retrieve colors
land_colors <- plotstyle(shorten_legend(getNames(tmp,dim=3),identical=TRUE))

# correct missing colors
land_colors["Bioenergy crops"] <- "goldenrod4"
land_colors["Crops"]           <- "#8B4513"
land_colors["Forage"]          <- "purple"
land_colors["Managed Forest"]  <- "#006400"
land_colors["Natural Forest"]  <- "#66A61E"

p <- mipArea(tmp["GLO",,],total = FALSE)
p <- p + scale_fill_manual(values=land_colors)
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- mipArea(tmp["GLO",,invert=TRUE],total = FALSE)
p <- p + scale_fill_manual(values=land_colors)
swfigure(sw,print,p,sw_option="height=8,width=8")

# ---- Land cover Bioenergy cropland ----

swlatex(sw,"\\subsection{Land cover Bioenergy Cropland}")

var <- c("Resources|Land Cover|Cropland|+|Bioenergy crops (million ha)")

p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

# ---- Land cover change by scenario (line)----

var <- c("Resources|Land Cover Change|+|Cropland (million ha wrt 1995)",
         "Resources|Land Cover Change|+|Pastures and Rangelands (million ha wrt 1995)",
         "Resources|Land Cover Change|+|Forest (million ha wrt 1995)",
         "Resources|Land Cover Change|+|Other Land (million ha wrt 1995)")

for (scen in getNames(data[,,"MAgPIE"],dim=1)) {
  swlatex(sw,paste0("\\subsection{Land cover change ",scen,"}"))

  p <- mipLineHistorical(data["GLO",,var][,,scen],color.dim="variable",
                         ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
  swfigure(sw,print,p,sw_option="height=8,width=8")
  
  p <- mipLineHistorical(data[,,var][,,scen]["GLO",,,invert=TRUE],color.dim="variable",
                         ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
  swfigure(sw,print,p,sw_option="height=8,width=8")
}

# ---- Land cover change Cropland ----

swlatex(sw,"\\subsection{Land cover change Cropland}")

var <- c("Resources|Land Cover Change|+|Cropland (million ha wrt 1995)")

p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

# ---- Land cover change Other Land ----

swlatex(sw,"\\subsection{Land cover change Other Land}")

var <- c("Resources|Land Cover Change|+|Other Land (million ha wrt 1995)")

p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

# ---- Land cover change Pastures and Rangelands ----

swlatex(sw,"\\subsection{Land cover change Pastures and Rangelands}")

var <- c("Resources|Land Cover Change|+|Pastures and Rangelands (million ha wrt 1995)")

p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

# ---- Land cover change Managed Forest ----

swlatex(sw,"\\subsection{Land cover change Managed Forest}")

var <- c("Resources|Land Cover Change|Forest|+|Managed Forest (million ha wrt 1995)")

p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

# ---- Land cover change Natural Forest ----

swlatex(sw,"\\subsection{Land cover change Natural Forest}")

var <- c("Resources|Land Cover Change|Forest|+|Natural Forest (million ha wrt 1995)")

p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")

# ---- ++++ PRICES ++++ ----

swlatex(sw,"\\section{Prices}")

# ---- Food price index ----

swlatex(sw,"\\subsection{Food price index}")
var <- "Prices|Food Price Index (Index 2010=100)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- SE prices ----

swlatex(sw,"\\subsection{Prices Electricity}")
var <- "Price|Secondary Energy|Electricity (US$2005/GJ)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\subsection{Prices Liquids}")
var <- "Price|Secondary Energy|Liquids (US$2005/GJ)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- PE prices Bioenergy - MAgPIE ----

swlatex(sw,"\\subsection{Prices Bioenergy MAgPIE}")
var <- "Prices|Bioenergy (US$05/GJ)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- PE prices Bioenergy - REMIND ----

swlatex(sw,"\\subsection{Prices Bioenergy REMIND}")
var <- "Price|Biomass|Primary Level (US$2005/GJ)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- CO2 Prices ----

swlatex(sw,"\\subsection{CO2 Prices}")

p <- mipLineHistorical(data["GLO",,"Price|Carbon (US$2005/t CO2)"],x_hist=NULL,
                       ylab='Price|Carbon [US$2005/t CO2]',scales="free_y",plot.priority=c("x_hist","x","x_proj"))
p <- p + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=3.5,width=7")
p <- mipLineHistorical(data["GLO",,"Price|Carbon (US$2005/t CO2)"],x_hist=NULL,
                       ylab='Price|Carbon_log [US$2005/t CO2]',ybreaks=c(20,30,40,50,60,75,100,200,500,1000,2000,3000),
                       ylim=c(20,3000),ylog=TRUE)
swfigure(sw,print,p,sw_option="height=4.5,width=7")
p <- mipLineHistorical(data[,,"Price|Carbon (US$2005/t CO2)"]["GLO",,,invert=TRUE],x_hist=NULL,
                       ylab='Price|Carbon [US$2005/t CO2]',scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- CO2 prices comparison to MAgPIE ----

swlatex(sw,"\\subsection{GHG prices}")
var <- c("Price|Carbon (US$2005/t CO2)",
         "Prices|GHG Emission|CO2 (US$2005/tCO2)")

p <- ggplot(luplot::as.ggplot(data["GLO",,var]), aes_string(x="Year",y="Value")) + 
     geom_line(aes_string(colour="Data1",linetype="Data3"),size=1) +
     geom_point(aes_string(colour="Data1")) + labs(y ="US$2005 / tCO2")  + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- ggplot(luplot::as.ggplot(data[,,var]["GLO",,,invert=TRUE]), aes_string(x="Year",y="Value")) + 
  geom_line(aes_string(colour="Data1",linetype="Data3"),size=1) +
  geom_point(aes_string(colour="Data1")) + labs(y ="US$2005 / tCO2") +
  facet_wrap(~Region)  + theme(legend.position="bottom") +
  guides(colour = guide_legend(nrow = 5,title.position = "top"),linetype = guide_legend(nrow = 2,title.position = "top"))
 
swfigure(sw,print,p,sw_option="height=8,width=8")

# "Price|CH4 (US$2005/t CH4)"
# "Prices|GHG Emission|CH4 (US$2005/tCH4)"

# "Price|N2O (US$2005/t N2O)"
# "Prices|GHG Emission|N2O (US$2005/tN2O)"

# ---- ++++ COSTS ++++ ----

swlatex(sw,"\\section{Costs}")

# ---- Total ag costs ----
swlatex(sw,"\\subsection{Total Agricultural Costs}")
var <- "Costs|Land Use (billion US$2005/yr)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

swlatex(sw,"\\subsection{Total Agricultural Costs (look-up table or MAgPIE value)}")
var <- "Costs|Land Use with MAC-costs from MAgPIE (billion US$2005/yr)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- MAC costs ----

swlatex(sw,"\\subsection{Costs MAC (REMIND endogenous)}")
var <- "Costs|Land Use|MAC-costs (billion US$2005/yr)"
p <- mipLineHistorical(data["GLO",,var],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"))
swfigure(sw,print,p,sw_option="height=8,width=8")
p <- mipLineHistorical(data[,,var]["GLO",,,invert=TRUE],
                       ylab=var,scales="free_y",plot.priority=c("x_hist","x","x_proj"),facet.ncol=3)
swfigure(sw,print,p,sw_option="height=9,width=8")

# ---- COSTS MAC Line ----

swlatex(sw,"\\subsection{Costs MAC Line}")
# add REMIND's MAC costs for CH4 and N2O to make it comparable to MAgPIE's aggregate
var_rem <- c("Costs|Land Use|MAC-costs|N2O (billion US$2005/yr)",
             "Costs|Land Use|MAC-costs|CH4 (billion US$2005/yr)")
tmp <- dimSums(data[,,var_rem],dim = 3.3)*1000
tmp <- add_dimension(tmp,dim = 3.3,add = "variable",nm = "Costs|Land Use|MAC-costs|CH4 N2O (million US$2005/yr)")
data <- mbind(data,tmp)

# convert lookup values to million
var_rem <- "Costs|Land Use|Mac-costs Lookup (billion US$2005/yr)"
tmp <- data[,,var_rem]*1000
getNames(tmp,dim=3) <- gsub("bi","mi",getNames(tmp,dim=3))
data <- mbind(data,tmp)

var <- c("Costs|MainSolve|MACCS (million US$05/yr)",
         "Costs|Land Use|MAC-costs|CH4 N2O (million US$2005/yr)",
         "Costs|Land Use|Mac-costs Lookup (million US$2005/yr)")

p <- ggplot(luplot::as.ggplot(data["GLO",,var]), aes_string(x="Year",y="Value")) + 
  geom_line(aes_string(colour="Data1",linetype="Data3"),size=1) +
  geom_point(aes_string(colour="Data1")) + labs(y ="million US$2005 / tCO2")  + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- ggplot(luplot::as.ggplot(data[,,var]["GLO",,,invert=TRUE]), aes_string(x="Year",y="Value")) + 
  geom_line(aes_string(colour="Data1",linetype="Data3"),size=1) +
  geom_point(aes_string(colour="Data1")) + labs(y ="million US$2005 / tCO2") +
  facet_wrap(~Region)  + theme(legend.position="bottom") +
  guides(colour = guide_legend(nrow = 5,title.position = "top"),linetype = guide_legend(nrow = 3,title.position = "top"))
swfigure(sw,print,p,sw_option="height=8,width=8")

# ---- COSTS MAC Area ----

swlatex(sw,"\\subsection{Costs MAC Area}")

# Make mac costs from lookup table negative since they are substracted from the total costs in REMIND
data[,,"Costs|Land Use|Mac-costs Lookup (billion US$2005/yr)"] <- -data[,,"Costs|Land Use|Mac-costs Lookup (billion US$2005/yr)"]

var <- c("Costs|Land Use with MAC-costs from MAgPIE (billion US$2005/yr)",
         "Costs|Land Use|Mac-costs Lookup (billion US$2005/yr)",
         "Costs|Land Use|MAC-costs|CO2 (billion US$2005/yr)",
         "Costs|Land Use|MAC-costs|CH4 (billion US$2005/yr)",
         "Costs|Land Use|MAC-costs|N2O (billion US$2005/yr)")

p <- mipArea(data["GLO",,var],total = data["GLO",,"Costs|Land Use (billion US$2005/yr)"]) + theme(legend.position="none")
swfigure(sw,print,p,sw_option="height=8,width=8")

p <- mipArea(data[,,var]["GLO",,,invert=TRUE],total = data[,,"Costs|Land Use (billion US$2005/yr)"]["GLO",,,invert=TRUE]) +
  theme(legend.position="bottom") +
  guides(fill = guide_legend(nrow = 6,title.position = "top"))
swfigure(sw,print,p,sw_option="height=12,width=8")

# ---- END ----

swclose(sw)
