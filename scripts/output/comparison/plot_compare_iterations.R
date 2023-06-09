# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
library(quitte, quietly = TRUE,warn.conflicts =FALSE)
library(mip, quietly = TRUE,warn.conflicts =FALSE)

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
  getNames(out) <- "pebiolc_priceshift"   # something has to be here, will be removed by collapseNames anyway
  out <- collapseNames(out)
  return(out)
}

readbioprice <- function(gdx,name) {
  out <- readGDX(gdx, name, format="first_found")
  getNames(out) <- "pebiolc_pricemag"   # something has to be here, will be removed by collapseNames anyway
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

# Plot dimension specified for 'color' over time
myplot <- function(data, xaxis = "period", color = "iteration", scales = "free_y", ylab = NULL, title = NULL) {
  getNames(data) <- gsub(".*rem-","",getNames(data))
  getSets(data) <- c("region","year","iteration")
  dat <- as.quitte(data)
  dat[[color]] <- as.factor(dat[[color]]) # convert dimension that should be distinguished by color to factors (relevant if years are plotted over iterations)
  text_size <- 10
  scale_color <- as.character(plotstyle(as.character(unique(dat[[color]])),out="color"))
  
  #browser()
  p <- ggplot() +
    geom_line( mapping = aes(x=!!sym((xaxis)), y=value, color=!!sym(color), group = !!sym(color)), data = dat, size=1) +
    geom_point(mapping = aes(x=!!sym((xaxis)), y=value, color=!!sym(color), group = !!sym(color)), data = dat, size=1) +
    facet_wrap(~region, scales=scales) + 
    labs(x = NULL, y = ylab, title = title) +
    scale_color_manual(values=scale_color) +
    theme(
      plot.title=element_text(size=text_size),
      strip.text.x=element_text(size=text_size),
      axis.text.y=element_text(size=text_size),
      axis.title.x=element_text(size=text_size),
      axis.text.x=element_text(size=text_size)) #+
    #theme_bw()
  return(p)
}

# The main function that compiles all plots
plot_iterations <- function(runname) {
  # ---- Find gdx files and scenario names ----
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

  # ---- Settings ----
  
  TWa2EJ <- 31.5576 # TWa to EJ (1 a = 365.25*24*3600 s = 31557600 s)
  txtsiz <- 10
  r   <- sort(c("SSA","CHA","EUR","NEU","IND","JPN","LAM","MEA","OAS","CAZ","REF","USA"))
  y   <- paste0("y",2000+10*(1:10))
  years <- c("y2005","y2010","y2015","y2020","y2025","y2030","y2035","y2040","y2045","y2050","y2055","y2060","y2070","y2080","y2090","y2100") # used for fillyears
  sm_tdptwyr2dpgj <- 31.71 # convert [TerraDollar per TWyear] to [Dollar per GJoule]
  
  # ---- PRICES (MAgPIE) OF PURPOSE GROWN BIOENERGY ----
  
  price <- readAll(gdx_path,readbioprice,name="p30_pebiolc_pricemag",asList=FALSE)
  price <- price / TWa2EJ * 1000

  p_price_mag <- myplot(price[r, years, ], ylab = "$/GJ", title = paste(runname,"Price|Biomass|MAgPIE (US$2005/GJ)",sep="\n"))
  
  # ---- CO2LUC (MAgPIE) ----
  
  emi <- readAll(gdx_path,readpar,name=c("pm_macBaseMagpie","p_macBaseMagpie"),asList=FALSE)[,,"co2luc"]*1000*44/12
  emi <- collapseDim(emi, dim = 3.2)  # remove 'co2luc'

  p_emi_mag <- myplot(emi[r, y, ], ylab = "Mt CO2/yr", title = paste(runname,"Emissions|CO2|Land Use (Mt CO2/yr)",sep="\n"))

  # ---- PRODUCTION OF PURPOSE GROWN BIOENERGY (REMIND) ----
  
  fuelex     <- readAll(gdx_path,readfuelex,enty="pebiolc",asList=FALSE)
  fuelex_bio <- collapseNames(fuelex[,,"1"]) * TWa2EJ
  fuelex_bio <- mbind(fuelex_bio,dimSums(fuelex_bio,dim=1))

  title <- paste(runname,"Primary Energy Production|Biomass|Energy Crops (EJ/yr)",sep="\n")

  p_fuelex        <- myplot(fuelex_bio[r, years, ],                                        ylab = "EJ/yr", title = title)
  p_it_fuelex     <- myplot(fuelex_bio[r, years, ], xaxis = "iteration", color = "period", ylab = "EJ/yr", title = title)
  p_it_fuelex_fix <- myplot(fuelex_bio[r, years, ], xaxis = "iteration", color = "period", ylab = "EJ/yr", title = title, scales = "fixed")

  getNames(fuelex_bio) <- gsub(".*rem-","",getNames(fuelex_bio))
  p_it_fuelex_2060 <- magpie2ggplot2(fuelex_bio[r,"y2060",],scenario=1,
                        geom="bar",fill="Data1",stack=T,facet_x="Region",xaxis="Scenario",ylab="EJ/yr",
                        title=paste0(title," in 2060"),xlab="Scenario",ncol=4)

  # ---- DEMAND FOR PURPOSE GROWN BIOENERGY (REMIND)  ----
  
  prodPE     <- readAll(gdx_path,readprodPE,enty="pebiolc",asList=FALSE)
  prodPE_bio <- collapseNames(prodPE) * TWa2EJ
  prodPE_bio <- mbind(prodPE_bio,dimSums(prodPE_bio,dim=1))

  title  <- paste(runname,"PE|Biomass|Modern (EJ/yr)",sep="\n")
  
  p_prodPE    <- myplot(prodPE_bio[r, years, ],                                        ylab = "EJ/yr", title = title)
  p_it_prodPE <- myplot(prodPE_bio[r, years, ], xaxis = "iteration", color = "period", ylab = "EJ/yr", title = title)

  # ---- PRICE SHIFT FACTOR IN 2060 ----
  
  shift <- readAll(gdx_path,readshift,asList=FALSE)* sm_tdptwyr2dpgj
  getNames(shift) <- gsub(".*rem-","",getNames(shift))

  title <- paste(runname,"Price|Biomass|Shiftfactor",sep="\n")
  
  p_shift_2060 <- magpie2ggplot2(shift[r,"y2060",],scenario=1,
                       geom="bar",fill="Data1",stack=T,facet_x="Region",xaxis="Scenario",ylab="[-]",
                       title=paste0(title," in 2060"),xlab="Scenario",ncol=4)

  # ---- Price shift over time ----

  v_shift <- readAll(gdx_path,readvar,name="v30_priceshift",asList=FALSE) * sm_tdptwyr2dpgj

  title <- paste(runname, "Price shift", sep = "\n")
  
  p_shift <- myplot(v_shift[r, years, ], ylab = "$/GJ", title = title)

  # ---- Price scaling factor over time ----
  
  v_mult <- readAll(gdx_path,readvar,name="v30_pricemult",asList=FALSE)

  title <- paste(runname, "Price multiplication factor", sep = "\n")
  
  p_mult <- myplot(v_mult[r, years, ], title = title)

  # ---- CO2 price ----
  
  report_path <- Sys.glob(paste0(runname,"-rem-*/REMIND_generic_*.mif"))
  report_path <- report_path[!grepl("with|adj",report_path)]

  tmp <- NULL
  for (rep in report_path) {
    tmp1 <- read.report(rep, as.list=FALSE)
    tmp <- mbind(tmp, tmp1[,,"Price|Carbon (US$2005/t CO2)"])
  }
  title <- paste(runname, "Price|Carbon (US$2005/t CO2)", sep = "\n")

  p_price_carbon <- myplot(tmp[r, years, ], ylab = "$/tCO2", title = title)

  p_it_price_carbon_1 <- myplot(tmp[, getYears(tmp)<"y2025", ],
                                ylab = "$/tCO2", xaxis = "iteration", color = "period", title = title)
  p_it_price_carbon_2 <- myplot(tmp[, getYears(tmp)>"y2020" & getYears(tmp)<="y2100", ], 
                                ylab = "$/tCO2", xaxis = "iteration", color = "period", title = title)

  # ---- Print to pdf ----
  
  out<-swopen(template="david")
  
  swfigure(out, print, p_price_mag,         sw_option = "height=9,width=16")
  swfigure(out, print, p_fuelex,            sw_option = "height=9,width=16")
  swfigure(out, print, p_it_fuelex,         sw_option = "height=9,width=16")
  swfigure(out, print, p_it_fuelex_fix,     sw_option = "height=9,width=16")
  swfigure(out, print, p_it_prodPE,         sw_option = "height=9,width=16")
  swfigure(out, print, p_it_fuelex_2060,    sw_option = "height=9,width=16")
  swfigure(out, print, p_emi_mag,           sw_option = "height=9,width=16")
  swfigure(out, print, p_shift,             sw_option = "height=9,width=16")
  swfigure(out, print, p_shift_2060,        sw_option = "height=9,width=16")
  swfigure(out, print, p_mult,              sw_option = "height=9,width=16")
  swfigure(out, print, p_it_price_carbon_1, sw_option = "height=9,width=16")
  swfigure(out, print, p_it_price_carbon_2, sw_option = "height=9,width=16")
  swfigure(out, print, p_price_carbon,      sw_option = "height=9,width=16")
  
  filename <- paste0(runname,"-",length(scenNames))
  swclose(out,outfile=filename,clean_output=TRUE,save_stream=FALSE)
  file.remove(paste0(filename,c(".log",".out")))
  return("Done\n")
}


withr::with_dir(folder, {

  # ---- Search for runs if not provided----
  if (is.null(runs)) {
    message("\nNo run specified by user. Searching for all runs available in this folder:")
    # Find fulldata.gdx files of all runs
    runs <- Sys.glob("*-rem-*/fulldata.gdx")
    # Remove everything but the scenario name from the folder names and remove duplicates
    runs <- unique(sub("-rem-[0-9]+/fulldata.gdx","",runs))
    message(paste(runs, collapse = ", "))
    message("")
  }
  
  # ---- Loop over runs ans plot ----
  for (runname in runs) {
    message("##################### ",runname," #################################")
    ret <- plot_iterations(runname)
    message(ret)
  }

})

