# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(remind)
library(lusweave)
library(luplot)
library(ggplot2)

x <- readSupplycurveBio(outputdirs)

years <- getYears(x$supplycurve)
years <- years[years>="y2005" & years<="y2100"]

#years <- "y2080"
regions <- sort(getRegions(x$supplycurve))

out<-swopen(template="david")

for (year in years) {
  title <- paste0(year) 
  dat <- gginput(x$supplycurve[regions,year,],scatter="type")
  dat$year<-factor(dat$year)

  p <- ggplot(dat, aes(x=.value.x,y=.value.y)) +
    geom_line(aes(colour=scenario, linetype=curve)) + #geom_line(size=0.5) + 
    geom_point(data=gginput(x$rem_point[regions,year,],scatter = "variable"),aes(x=.value.x,y=.value.y,colour=scenario)) +
    geom_point(data=gginput(x$mag_point[regions,year,],scatter = "variable"),aes(x=.value.x,y=.value.y,colour=scenario),shape=5) +
    facet_wrap(~region) +
    ggtitle(title) + ylab("$/GJ") + xlab("EJ") + coord_cartesian(xlim=c(0,80),ylim=c(0,30))

  swfigure(out,print,p,sw_option="height=9,width=12")
}
swclose(out,outfile=paste0("supplycurves.pdf"),clean_output=TRUE,save_stream=FALSE)
