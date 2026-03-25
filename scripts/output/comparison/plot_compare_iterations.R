# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

############################# LOAD LIBRARIES #############################

library(magclass, quietly = TRUE, warn.conflicts = FALSE)
library(ggplot2,  quietly = TRUE, warn.conflicts = FALSE)
# Functions from other libraries are loaded using ::

############################# BASIC CONFIGURATION #############################

if (!exists("source_include") | !exists("runs") | !exists("folder")) {
  message("Script started from command line.")
  message("ls(): ", paste(ls(), collapse = ", "))
  runs <- if (exists("outputdirs")) unique(sub("-rem-[0-9]*", "", basename(outputdirs))) else NULL
  folder <- "./output"
  lucode2::readArgs("runs", "folder")
} else {
  message("Script was sourced.")
  message("runs  : ", paste(runs, collapse = ", "))
  message("folder: ", paste(folder, collapse = ", "))
}

############################# DEFINE FUNCTIONS ###########################

# Plot dimension specified for 'color' over dimension specified for 'xaxis' as line plot or bar plot
myplot <- function(data, type = "line", xaxis = "period", color = "iteration", scales = "free_y", ylab = NULL, title = NULL) {
  getNames(data) <- gsub(".*rem-","",getNames(data))
  getSets(data) <- c("region","year","iteration")
  dat <- quitte::as.quitte(data)
  dat[[color]] <- as.factor(dat[[color]]) # convert dimension that should be distinguished by color to factors (relevant if years are plotted over iterations)
  text_size <- 10
  scale_color <- as.character(mip::plotstyle(as.character(unique(dat[[color]])),out="color"))

  p <- ggplot()
  if (type == "line") {
    p <- p + geom_line( mapping = aes(x=!!sym((xaxis)), y=value, color=!!sym(color), group = !!sym(color)), data = dat, linewidth = 1)
    p <- p + geom_point(mapping = aes(x=!!sym((xaxis)), y=value, color=!!sym(color), group = !!sym(color)), data = dat, size = 1)
  } else if (type == "bar"){
    p <- p + geom_col(  mapping = aes(x=!!sym((xaxis)), y=value, fill=!!sym(color),  group = !!sym(color)), data = dat)
  }
    p <- p + facet_wrap(~region, scales=scales) +
    labs(x = NULL, y = ylab, title = title) +
    scale_color_manual(values=scale_color) +
    theme(
      plot.title   = element_text(size = text_size+4),
      strip.text.x = element_text(size = text_size),
      axis.text.y  = element_text(size = text_size),
      axis.title.x = element_text(size = text_size),
      axis.text.x  = element_text(size = text_size)) #+
    #theme_bw()
  return(p)
}

# The main function that compiles all plots
plot_iterations <- function(runname) {

  # ---- Read REMIND reportings for all scenarios ----

  message("Searching for REMIND_generic_*.mif files for ", runname)
  report_path <- Sys.glob(paste0(runname,"-rem-*/REMIND_generic_", runname, "-rem-*.mif"))
  report_path <- grep(paste0(runname, "-rem-[0-9]+\\.mif$"), report_path, value = TRUE)

  message("Reading ", length(report_path), " REMIND reports.")
  reports <- NULL
  for (rep in report_path) {
    reports <- mbind(reports, read.report(rep, as.list=FALSE)) #[,,"Price|Carbon (US$2017/t CO2)"])
  }

  # ---- Settings ----

  TWa2EJ <- 31.5576 # TWa to EJ (1 a = 365.25*24*3600 s = 31557600 s)
  txtsiz <- 10
  r      <- sort(c("SSA","CHA","EUR","NEU","IND","JPN","LAM","MEA","OAS","CAZ","REF","USA"))
  years  <- paste0("y",c(seq(2005,2060,5),seq(2070,2100,10), c(2110,2130,2150)))
  sm_tdptwyr2dpgj <- 31.71 # convert [TerraDollar per TWyear] to [Dollar per GJoule]


  # ---- Plot: MAgPIE prices for purpose grown bioenergy ----

  var <- "Internal|Price|Biomass|MAgPIE (US$2017/GJ)"

  p_price_mag <- myplot(reports[r, years, var], ylab = "$/GJ", title = paste(runname, var, sep = "\n"))


  # ---- Plot: MAgPIE co2luc ----

  var <- "Emi|CO2|+|Land-Use Change (Mt CO2/yr)"

  p_emi_mag <- myplot(reports[r, years, var], ylab = "Mt CO2/yr", title = paste(runname, var, sep = "\n"))


  # ---- Plot: REMIND Production of purpose grown bioenergy ----

  # remind2::reportExtraction.R
  # vm_fuExtr[, , "pebiolc.1"] -> "PE|Production|Biomass|+|Lignocellulosic (EJ/yr)"
  # vm_fuExtr[, , "pebiolc.1"] -> "Primary Energy Production|Biomass|Energy Crops (EJ/yr)" (used also in coupling interface in MAgPIE)

  var <- "Primary Energy Production|Biomass|Energy Crops (EJ/yr)"
  title <- paste(runname, var , sep = "\n")

  p_fuelex         <- myplot(reports[r, years,   var],                                                      ylab = "EJ/yr", title = title)
  p_fuelex_it      <- myplot(reports[r, years,   var],               xaxis = "iteration", color = "period", ylab = "EJ/yr", title = title)
  p_fuelex_it_fix  <- myplot(reports[r, years,   var],               xaxis = "iteration", color = "period", ylab = "EJ/yr", title = title, scales = "fixed")
  p_fuelex_it_2060 <- myplot(reports[r, "y2060", var], type = "bar", xaxis = "iteration", color = "period", ylab = "EJ/yr", title = title, scales = "fixed")


  # ---- Plot: REMIND Demand for purpose grown bioenergy ----

  # remind2::reportPE.R
  # fuelex[,,"pebiolc.1"] + (1-p_costsPEtradeMp[,,"pebiolc"]) * Mport[,,"pebiolc"] - Xport[,,"pebiolc"] -> "PE|Biomass|Energy Crops (EJ/yr)"

  var <- "PE|Biomass|+++|Energy Crops (EJ/yr)"
  title  <- paste(runname, var, sep = "\n")

  p_prodPE    <- myplot(reports[r, years, var],                                        ylab = "EJ/yr", title = title)
  p_prodPE_it <- myplot(reports[r, years, var], xaxis = "iteration", color = "period", ylab = "EJ/yr", title = title)


  # ---- Plot: REMIND Price shift factor ----

  # remind2::reportPrices.R
  # p30_pebiolc_pricshift -> "Internal|Price|Biomass|Shiftfactor ()"

  var <- "Internal|Price|Biomass|Shiftfactor ()"

  p_shift <- myplot(reports[r, years, var], ylab = "$/GJ", title = paste(runname, var, sep="\n"))


  # ---- Plot: REMIND Price scaling factor ----

  # remind2::reportPrices.R
  # p30_pebiolc_pricmult -> "Internal|Price|Biomass|Multfactor ()"

  var <- "Internal|Price|Biomass|Multfactor ()"

  p_mult <- myplot(reports[r, years, var], title = paste(runname, var, sep = "\n"))


  # ---- Plot: REMIND co2 price ----

  var <- "Price|Carbon (US$2017/t CO2)"
  title <- paste(runname, var, sep = "\n")

  p_price_carbon      <- myplot(reports[r, years, var], ylab = "$/tCO2", title = title)

  p_price_carbon_it_1 <- myplot(reports[r, getYears(reports)<"y2025", var],
                                ylab = "$/tCO2", xaxis = "iteration", color = "period", title = title)
  p_price_carbon_it_2 <- myplot(reports[r, getYears(reports)>"y2020" & getYears(reports)<="y2100", var],
                                ylab = "$/tCO2", xaxis = "iteration", color = "period", title = title)


  # ---- Print to pdf ----

  out <- lusweave::swopen(template = "david")

  lusweave::swfigure(out, print, p_price_mag,         sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_fuelex,            sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_fuelex_it,         sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_fuelex_it_fix,     sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_fuelex_it_2060,    sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_prodPE_it,         sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_emi_mag,           sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_mult,              sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_shift,             sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_price_carbon,      sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_price_carbon_it_1, sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_price_carbon_it_2, sw_option = "height=9,width=16")

  filename <- paste0(runname, "-", length(getItems(reports, dim = 3.1)))
  lusweave::swclose(out, outfile = filename, clean_output = TRUE, save_stream = FALSE)
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

