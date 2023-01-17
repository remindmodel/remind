# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
############################# LOAD LIBRARIES #############################
library(magclass, quietly = TRUE,warn.conflicts =FALSE)
library(luplot, quietly = TRUE,warn.conflicts =FALSE)
library(lusweave, quietly = TRUE,warn.conflicts =FALSE)
library(gms, quietly = TRUE,warn.conflicts =FALSE)
library(lucode2, quietly = TRUE,warn.conflicts =FALSE)
library(gdx, quietly = TRUE,warn.conflicts =FALSE)
library(magpie4, quietly = TRUE,warn.conflicts =FALSE)
library(remind2, quietly = TRUE,warn.conflicts =FALSE)
library(gtools, quietly = TRUE,warn.conflicts =FALSE)

############################# BASIC CONFIGURATION #############################
if (!exists("source_include") | !exists("runs") | !exists("folder")) {
  message("Script started from command line.")
  message("ls(): ", paste(ls(), collapse = ", "))
  runs <- if (exists("outputdirs")) unique(sub("-rem-[0-9]*", "", basename(outputdirs))) else NULL
  folder <- "./output"
  readArgs("runs", "folder")
} else {
  message("Script was sourced.")
  message("runs  : ", paste(runs, collapse = ", "))
  message("folder: ", paste(folder, collapse = ", "))
}

###############################################################################

############################# DEFINE FUNCTIONS ###########################

readfuelex <- function(gdx,enty) {
  out <- readGDX(gdx,name="vm_fuExtr", format="first_found", field="l")[,,enty]
  out <- collapseNames(out)
  return(out)
}

readprodPE <- function(gdx,enty) {
  out <- readGDX(gdx,name="vm_prodPe", format="first_found", field="l")[,,enty]
  out <- collapseNames(out)
  return(out)
}


readshift <- function(gdx) {
  out <- readGDX(gdx,name="p30_pebiolc_pricshift", format="first_found")
  getNames(out) <- "pebiolc_priceshift"   # hab ich mir ausgedacht, kann natuerlich alles andere sein, wird durch collapseNames sowieso geloescht
  out <- collapseNames(out)
  return(out)
}

readbioprice <- function(gdx,name) {
  out <- readGDX(gdx, name, format="first_found")
  getNames(out) <- "pebiolc_pricemag"   # hab ich mir ausgedacht, kann natuerlich alles andere sein, wird durch collapseNames sowieso geloescht
  out <- collapseNames(out)
  return(out)
}

# function to read parameter from gdx file
readpar <- function(gdx,name) {
  out <- readGDX(gdx, name, format="first_found")
  #getNames(out) <- "dummy" # something has to be here, will be removed by collapseNames anyway
  #out <- collapseNames(out)
  return(out)
}

# function to read variable from gdx file
readvar <- function(gdx,name,enty=NULL) {
  if (is.null(enty)) {
    out <- readGDX(gdx,name, format="first_found", field="l")
    getNames(out) <- "dummy" # something has to be here, will be removed by collapseNames anyway
  } else {
    out <- readGDX(gdx,name=name, format="first_found", field="l")[,,enty]
  }
  out <- collapseNames(out)
  return(out)
}
# aufblasen auf alle jahre mit in die obige funktion, sodass man immer mult und shift mit vollen dimensionen zurueckbekommt.
# diese dann fuer jede region ueber der zeit fuer alle iterationen plotten

# If input (x) is not defined for years copy single value for all given years
fillyears <- function (x,years) {
  if (fulldim(x)[[1]][2]==1){
    a<-new.magpie(getRegions(x),years,getNames(x))
    for (i in years) {
      for (r in getRegions(a)) {
        a[r,i,]<-as.vector(x[r,1,])
      }
    }
    x<-a
  }
  return(x)
}


# The main plot function
plot_iterations <- function(runname) {
  ############################ FIND GDX FILES #################################
  message("Searching for reportings for ", runname)
  gdx_path <- Sys.glob(paste0(runname,"-rem-*/fulldata.gdx"))
  gdx_path <- rev(mixedsort(gdx_path)) # sort runs from 1,10,2,20 to 1,2,10,20i
  message("The following reportings were found:")
  message(paste(gdx_path, collapse = ", "))

  # Read runnames and use them to name the rows of gdx_path
  outputdirs <- sub("/fulldata.gdx","",gdx_path)
  if(length(outputdirs) == 0) {
    return("No gdx files found\n\n")
  }

  scenNames_path <- file.path(outputdirs, "config.Rdata")
  scenNames <- c()
  for (i in scenNames_path) {
    load(i)
    scenNames[i] <- cfg$title
  }
  names(gdx_path) <- scenNames

  ######################### COMMON SETTINGS ############################
  TWa2EJ <- 31.5576      # TWa to EJ (1 a = 365.25*24*3600 s = 31557600 s)
  txtsiz <- 10
  r   <- sort(c("SSA","CHA","EUR","NEU","IND","JPN","LAM","MEA","OAS","CAZ","REF","USA"))
  y   <- paste0("y",2000+10*(1:10))
  years <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100") # used for fillyears
  sm_tdptwyr2dpgj <- 31.71 # multipl. factor to convert (TerraDollar per TWyear) to (Dollar per GJoule)
  ######################### IMPORT AND PLOT DATA #######################

  ### PRICES (MAgPIE) OF PURPOSE GROWN BIOENERGY ###
  price <- readAll(gdx_path,readbioprice,name="p30_pebiolc_pricemag",asList=FALSE)
  price <- price / TWa2EJ * 1000
  #price <- mbind(price,new.magpie("GLO",getYears(price),getNames(price),fill=c(0)))
  getNames(price) <- gsub(".*rem-","",getNames(price))

  v  <- paste(runname,"Price|Biomass|MAgPIE (US$2005/GJ)",sep="\n")

  p_price_mag <- magpie2ggplot2(price[r,years,],scenario=1,
                   group=NULL,ylab="$/GJ",color="Scenario",facet_x="Region",show_grid=TRUE,title=v,
                   scales="free_y",text_size=10,ncol=4,pointwidth=1,linewidth=1,
                   legend_position="right")

  ### LUC EMISSIONS (MAgPIE) ###
  emi <- readAll(gdx_path,readpar,name=c("pm_macBaseMagpie","p_macBaseMagpie"),asList=FALSE)[,,"co2luc"]*1000*44/12
  emi <- mbind(emi,dimSums(emi,dim=1))
  getNames(emi) <- gsub(".*rem-","",getNames(emi))

  v  <- paste(runname,"Emissions|CO2|Land Use (Mt CO2/yr)",sep="\n")
  p_emi_mag <- magpie2ggplot2(emi[r,y,],scenario=1,
                   group=NULL,ylab="Mt CO2/yr",color="Scenario",facet_x="Region",show_grid=TRUE,title=v,
                   scales="free_y",text_size=10,ncol=4,pointwidth=1,linewidth=1,
                   legend_position="right")

  ### DEMAND FOR PURPOSE GROWN BIOENERGY ###
  fuelex           <- readAll(gdx_path,readfuelex,enty="pebiolc",asList=FALSE)
  fuelex_bio       <- collapseNames(fuelex[,,"1"]) * TWa2EJ
  fuelex_bio       <- mbind(fuelex_bio,dimSums(fuelex_bio,dim=1))
  getNames(fuelex_bio) <- gsub(".*rem-","",getNames(fuelex_bio))

  v  <- paste(runname,"Primary Energy Production|Biomass|Energy Crops (EJ/yr)",sep="\n")

  p_fuelex <- magpie2ggplot2(fuelex_bio[r,years,],scenario=1,
                   group=NULL,ylab="EJ/yr",color="Scenario",facet_x="Region",show_grid=TRUE,title=v,
                   scales="free_y",text_size=10,ncol=4,pointwidth=1,linewidth=1,
                   legend_position="right")

  p_it_fuelex <- magpie2ggplot2(fuelex_bio[r,years,],scenario=1,group="Year",ylab="EJ/yr",color="Year",xaxis="Scenario",facet_x="Region",show_grid=TRUE,title=v,
                   scales="free_y",text_size=10,ncol=4,pointwidth=1,linewidth=1,asDate=FALSE,legend_position="right")

  p_it_fuelex_fix <- magpie2ggplot2(fuelex_bio[r,years,],scenario=1,group="Year",ylab="EJ/yr",color="Year",xaxis="Scenario",facet_x="Region",show_grid=TRUE,title=v,
                       scales="fixed",text_size=10,ncol=4,pointwidth=1,linewidth=1,asDate=FALSE,legend_position="right")

  p_it_fuelex_2060 <- magpie2ggplot2(fuelex_bio[r,"y2060",],scenario=1,
                        geom="bar",fill="Data1",stack=T,facet_x="Region",xaxis="Scenario",ylab="EJ/yr",
                        title=paste0(v," in 2060"),xlab="Scenario",ncol=4)

  ### DEMAND
  fuelex           <- readAll(gdx_path,readprodPE,enty="pebiolc",asList=FALSE)
  fuelex_bio       <- collapseNames(fuelex) * TWa2EJ
  fuelex_bio       <- mbind(fuelex_bio,dimSums(fuelex_bio,dim=1))
  getNames(fuelex_bio) <- gsub(".*rem-","",getNames(fuelex_bio))

  v  <- paste(runname,"PE|Biomass|Modern (EJ/yr)",sep="\n")
  p_demPE <- magpie2ggplot2(fuelex_bio[r,y,],scenario=1,
               group=NULL,ylab="EJ/yr",color="Scenario",facet_x="Region",show_grid=TRUE,title=v,
               scales="free_y",text_size=10,ncol=4,pointwidth=1,linewidth=1,
               legend_position="right")

  p_it_demPE <- magpie2ggplot2(fuelex_bio[r,y,],scenario=1,group="Year",ylab="EJ/yr",color="Year",xaxis="Scenario",facet_x="Region",show_grid=TRUE,title=v,
                       scales="free_y",text_size=10,ncol=4,pointwidth=1,linewidth=1,asDate=FALSE,legend_position="right")

  ### PRICE SHIFT FACTOR IN 2060 ###
  shift <- readAll(gdx_path,readshift,asList=FALSE)* sm_tdptwyr2dpgj
  #shift <- mbind(shift,new.magpie("GLO",getYears(shift),getNames(shift),fill=c(0)))
  shift <- fillyears(shift,years)
  getNames(shift) <- gsub(".*rem-","",getNames(shift))
  
  v  <- paste(runname,"Price|Biomass|Shiftfactor",sep="\n")
  p_shift_2060 <- magpie2ggplot2(shift[r,"y2060",],scenario=1,
                       geom="bar",fill="Data1",stack=T,facet_x="Region",xaxis="Scenario",ylab="[-]",
                       title=paste0(v," in 2060"),xlab="Scenario",ncol=4)

  ### Price shift and mult factor over time ###

  v_shift    <- readAll(gdx_path,readvar,name="v30_priceshift",asList=FALSE) * sm_tdptwyr2dpgj
  v_shift    <- fillyears(v_shift,years) # If there is no year dimension add it
  getNames(v_shift) <- gsub(".*rem-","",getNames(v_shift))

  p_shift <- magpie2ggplot2(v_shift[r,years,],geom='line',group=NULL,
                        ylab='$/GJ',color='Data1',#linetype="Data2",
                        scales='free',show_grid=TRUE,ncol=3,text_size=txtsiz,#ylim=y_limreg,
                        title=paste(runname,"Price shift",sep="\n"))

  v_mult    <- readAll(gdx_path,readvar,name="v30_pricemult",asList=FALSE)
  v_mult    <- fillyears(v_mult,years) # If there is no year dimension add it
  #y_limreg  <- c(0,max(v_mult[,years,]))
  getNames(v_mult) <- gsub(".*rem-","",getNames(v_mult))

  p_mult <- magpie2ggplot2(v_mult[r,years,],geom='line',group=NULL,
                        ylab='',color='Data1',#linetype="Data2",
                        scales='free_y',show_grid=TRUE,ncol=3,text_size=txtsiz,#ylim=y_limreg,
                        title=paste(runname,"Price mult factor",sep="\n"))

  ### CO2 price ###
  report_path <- Sys.glob(paste0(runname,"-rem-*/REMIND_generic_*.mif"))
  report_path <- report_path[!grepl("with|adj",report_path)]

  tmp <- NULL
  for (r in report_path) {
    tmp1 <- read.report(r, as.list=FALSE)
    tmp <- mbind(tmp, tmp1[,,"Price|Carbon (US$2005/t CO2)"])
  }
  getNames(tmp) <- gsub(".*rem-","",getNames(tmp))

  v  <- paste(runname,"Price|Carbon (US$2005/t CO2)",sep="\n")

  #p_price_carbon <- magpie2ggplot2(tmp,geom='line',group=NULL,
  #               ylab='US$2005/t CO2',color='Data1',#linetype="Data2",
  #               scales='free',show_grid=TRUE,ncol=3,text_size=txtsiz+4,#ylim=y_limreg,
  #               title=paste(runname,"Carbon price",sep="\n"))

  p_it_price_carbon_1 <- magpie2ggplot2(tmp[,getYears(tmp)<"y2025",],scenario=1,group="Year",ylab="EJ/yr",color="Year",xaxis="Scenario",facet_x="Region",show_grid=TRUE,title=v,
                              scales="free_y",text_size=10,ncol=4,pointwidth=1,linewidth=1,asDate=FALSE,legend_position="right")
  p_it_price_carbon_2 <- magpie2ggplot2(tmp[,getYears(tmp)>"y2020" & getYears(tmp)<="y2100",],scenario=1,group="Year",ylab="EJ/yr",color="Year",xaxis="Scenario",facet_x="Region",show_grid=TRUE,title=v,
                              scales="free_y",text_size=10,ncol=4,pointwidth=1,linewidth=1,asDate=FALSE,legend_position="right")

  ######################### PRINT TO PDF ################################
  out<-swopen(template="david")
  swfigure(out,print,p_price_mag,sw_option="height=9,width=16")
  swfigure(out,print,p_fuelex,sw_option="height=9,width=16")
  swfigure(out,print,p_it_fuelex,sw_option="height=9,width=16")
  swfigure(out,print,p_it_fuelex_fix,sw_option="height=9,width=16")
  swfigure(out,print,p_it_demPE,sw_option="height=9,width=16")
  swfigure(out,print,p_it_fuelex_2060,sw_option="height=9,width=16")
  swfigure(out,print,p_emi_mag,sw_option="height=9,width=16")
  swfigure(out,print,p_shift,sw_option="height=9,width=16")
  swfigure(out,print,p_shift_2060,sw_option="height=9,width=16")
  swfigure(out,print,p_mult,sw_option="height=9,width=16")
  swfigure(out,print,p_it_price_carbon_1,sw_option="height=9,width=16")
  swfigure(out,print,p_it_price_carbon_2,sw_option="height=9,width=16")
  filename <- paste0(runname,"-",length(scenNames))
  swclose(out,outfile=filename,clean_output=TRUE,save_stream=FALSE)
  file.remove(paste0(filename,c(".log",".out")))
  return("Done\n")
}

wdnow <- getwd()
setwd(folder)

# Searching for runs to plot iterations for
if (is.null(runs)) {
  message("\nNo run specified by user. Searching for all runs available in this folder:")
  # Find which runs were performed by searching for all files that contain "-rem-"
  runs <- Sys.glob("*-rem-*/fulldata.gdx")
  # keep directories only (filter out files)
  #runs <- runs[file.info(runs)[,"isdir"]]
  # Remove "-rem-*" from the folder names and remove remaining double elements to yield the pure runname
  runs <- unique(sub("-rem-[0-9]+/fulldata.gdx","",runs))
  message(paste(runs, collapse = ", "))
  message("")
}

# Plot iterations
for (runname in runs) {
  message("##################### ",runname," #################################")
  ret <- plot_iterations(runname)
  message(ret)
}

setwd(wdnow)
