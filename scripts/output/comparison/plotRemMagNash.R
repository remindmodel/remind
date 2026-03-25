# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

############################# LOAD LIBRARIES #############################

library(dplyr,    quietly = TRUE, warn.conflicts = FALSE)
library(ggplot2,  quietly = TRUE, warn.conflicts = FALSE)
# Functions from the following libraries are loaded using ::
# lucode2, tidyr, mip, quitte, lusweave, withr

############################# BASIC CONFIGURATION #############################

if (!exists("source_include")) lucode2::readArgs("outputdirs")

############################# DEFINE FUNCTIONS ###########################

# Plot dimension specified for 'color' over dimension specified for 'xaxis' as line plot or bar plot
myplot <- function(dat, parName, runName, type = "line", xaxis = "ttot", color = "iteration", scales = "free_y", ylab = NULL, title = "auto") {
  
  # Find last (continuous) iteration per outputDir
  if("outputdirs" %in% names(dat)) last <- dat |> group_by(outputdirs) |> summarise(iteration = max(iteration))
  
  # Zero values are not stored in the gdx and are thus missing in dat.
  # Add '0' for the missing combinations of iteration, ttot, all_regi.
  dat <- dat |> filter(ttot > 2000, par %in% parName) |> ungroup() |>
    tidyr::complete(iteration, ttot, all_regi, fill = list("value" = 0))
  
  # Generate auto title if wanted
  if(!is.null(title) && title == "auto") {
    title <- paste(paste(unique(runName$outputdirs), collapse = "\n"), 
                   dat |> first() |> pull(var), # obtain var name corresponding to par
                   parName,
                   sep = "\n")
  }
  
  # convert dimension that should be distinguished by color to factors (relevant if years are plotted over iterations)
  dat[[color]] <- as.factor(dat[[color]]) 
  
  text_size <- 10
  scale_color <- as.character(mip::plotstyle(as.character(unique(dat[[color]])), out = "color"))

  p <- ggplot()
  if (type == "line") {
    p <- p + geom_line( mapping = aes(x=!!sym((xaxis)), y=value, color=!!sym(color), group = !!sym(color)), data = dat, linewidth = 1)
    p <- p + geom_point(mapping = aes(x=!!sym((xaxis)), y=value, color=!!sym(color), group = !!sym(color)), data = dat, size = 1)
  } else if (type == "bar"){
    p <- p + geom_col(  mapping = aes(x=!!sym((xaxis)), y=value, fill=!!sym(color),  group = !!sym(color)), data = dat)
  }
    p <- p + facet_wrap(~all_regi, scales=scales) +
    labs(x = NULL, y = ylab, title = title) +
    scale_color_manual(values=scale_color) +
    theme(
      plot.title   = element_text(size = text_size+4),
      strip.text.x = element_text(size = text_size),
      axis.text.y  = element_text(size = text_size),
      axis.title.x = element_text(size = text_size),
      axis.text.x  = element_text(size = text_size)) #+
    #theme_bw()
  
  # If there is more than one run, plot vertical line to separate runs
    if("outputdirs" %in% names(dat) & xaxis == "iteration")  {
    p <- p + geom_vline(xintercept = last$iteration)  
  }
  return(p)
}

# Compile all plots and produce pdf
plot_iterations <- function(dat, runname) {
  
  # ---- Plot: MAgPIE prices for purpose grown bioenergy ----
  
  p_price_mag    <- myplot(dat, "o_p30_pebiolc_pricemag", runname, ylab = "$/GJ")
  p_price_mag_it <- myplot(dat, "o_p30_pebiolc_pricemag", runname, xaxis = "iteration", color = "ttot", ylab = "$/GJ")

  # ---- Plot: MAgPIE co2luc ----
  
  p_emi_mag    <- myplot(dat, "o_vm_emiMacSector_co2luc", runname, ylab = "Mt CO2/yr")
  p_emi_mag_it <- myplot(dat, "o_vm_emiMacSector_co2luc", xaxis = "iteration", color = "ttot", runname, ylab = "Mt CO2/yr")
  
  
  # ---- Plot: REMIND Production of purpose grown bioenergy ----
  
  p_fuelex         <- myplot(dat, "o_vm_fuExtr_pebiolc", runname,                                      ylab = "EJ/yr")
  p_fuelex_it      <- myplot(dat, "o_vm_fuExtr_pebiolc", runname, xaxis = "iteration", color = "ttot", ylab = "EJ/yr")
  p_fuelex_it_fix  <- myplot(dat, "o_vm_fuExtr_pebiolc", runname, xaxis = "iteration", color = "ttot", ylab = "EJ/yr", scales = "fixed")
  p_fuelex_it_2060 <- myplot(dat |> filter(ttot == 2060),
                                  "o_vm_fuExtr_pebiolc", runname, type = "bar", 
                                                                  xaxis = "iteration", color = "ttot", ylab = "EJ/yr", scales = "fixed")
  
  # ---- Plot: REMIND Demand for purpose grown bioenergy ----
  
  p_demPE    <- myplot(dat, "o_PEDem_Bio_ECrops", runname,                                      ylab = "EJ/yr")
  p_demPE_it <- myplot(dat, "o_PEDem_Bio_ECrops", runname, xaxis = "iteration", color = "ttot", ylab = "EJ/yr")
  
  # ---- Plot: REMIND Price scaling factor ----
  
  p_mult    <- myplot(dat, "o_p30_pebiolc_pricmult", runname)
  p_mult_it <- myplot(dat, "o_p30_pebiolc_pricmult", runname, xaxis = "iteration", color = "ttot")
  
  # ---- Plot: REMIND co2 price ----
  
  p_price_carbon      <- myplot(dat, "pm_taxCO2eq_iter", runname, ylab = "$/tCO2")
  
  p_price_carbon_it_1 <- myplot(dat |> filter(ttot < 2025), "pm_taxCO2eq_iter", runname,
                                ylab = "$/tCO2", xaxis = "iteration", color = "ttot")
  p_price_carbon_it_2 <- myplot(dat |> filter(ttot > 2020, ttot <= 2100), "pm_taxCO2eq_iter", runname,
                                ylab = "$/tCO2", xaxis = "iteration", color = "ttot")
  
  # ---- Print to pdf ----
  
  out <- lusweave::swopen(template = "david")
  
  lusweave::swfigure(out, print, p_price_mag,         sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_price_mag_it,      sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_fuelex,            sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_fuelex_it,         sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_fuelex_it_fix,     sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_fuelex_it_2060,    sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_demPE_it,          sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_emi_mag,           sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_emi_mag_it,        sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_mult,              sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_mult_it,           sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_price_carbon,      sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_price_carbon_it_1, sw_option = "height=9,width=16")
  lusweave::swfigure(out, print, p_price_carbon_it_2, sw_option = "height=9,width=16")
  
  filename <- paste0("output/", tail(runname$outputdirs, n=1), ifelse(nrow(runname)>1, "-continued", ""))
  lusweave::swclose(out, outfile = filename, clean_output = TRUE, save_stream = FALSE)
  file.remove(paste0(filename,c(".log")))
  # out files have "." replaced with "-_-_-" in their names
  #file.remove(paste0(gsub("\\.","-_-_-",filename),".out"))
  
  return("Done\n")
}  

# Read all parameters from gdx and return them all in one data frame
readDataFromGdx <- function(runfolder, allIter = TRUE) {

  # ---- Documentation of the items read from the gdx ----

  # "Internal|Price|Biomass|MAgPIE (US$2017/GJ)"
  # "o_p30_pebiolc_pricemag"
  # modules/30_biomass/magpie/presolve.gms
  # o_p30_pebiolc_pricemag(iteration,ttot,regi) = p30_pebiolc_pricemag(ttot,regi);
  
  # "Emi|CO2|+|Land-Use Change (Mt CO2/yr)"
  # vm_emiMacSector <- readGDX(gdx, "vm_emiMacSector", field = "l", restore_zeros = FALSE)
  # dimSums(vm_emiMacSector[, , "co2luc"]                 , dim = 3) * GtC_2_MtCO2
  # "o_vm_emiMacSector_co2luc"
  # core/postsolve.gms:
  # o_vm_emiMacSector_co2luc(iteration,ttot,regi) = vm_emiMacSector.l(ttot,regi,"co2luc");
  
  # "Primary Energy Production|Biomass|Energy Crops (EJ/yr)"
  # remind2::reportExtraction.R
  # fuelex     <- readGDX(gdx, name = c("vm_fuExtr", "vm_fuelex"),      field = "l", restore_zeros = FALSE, format = "first_found")
  # fuelex_bio <- fuelex[, t, c("pebiolc", "pebios", "pebioil")]
  # dimSums(fuelex_bio[, , "pebiolc.1"], dim = 3) * TWa_2_EJ
  #   -> "PE|Production|Biomass|+|Lignocellulosic (EJ/yr)"
  #   -> "Primary Energy Production|Biomass|Energy Crops (EJ/yr)" (used also in coupling interface in MAgPIE)
  # "o_vm_fuExtr_pebiolc"
  # core/postsolve.gms:
  # o_vm_fuExtr_pebiolc = vm_fuExtr.l(ttot,regi,"pebiolc","1");
  
  # "PE|Biomass|+++|Energy Crops (EJ/yr)"
  # remind2::reportPE.R
  # fuelex[,,"pebiolc.1"] + (1-p_costsPEtradeMp[,,"pebiolc"]) * Mport[,,"pebiolc"] - Xport[,,"pebiolc"] -> "PE|Biomass|+++|Energy Crops (EJ/yr)"
  # "o_PEDem_Bio_ECrops"
  # core/postsolve.gms:
  # o_PEDem_Bio_ECrops(iteration,ttot,regi) = vm_fuExtr.l(ttot,regi,"pebiolc","1") + (1 - pm_costsPEtradeMp(ttot,regi"pebiolc")) * vm_Mport.l(ttot,regi,"pebiolc") - vm_Xport.l(ttot,regi"pebiolc");
  
  # "Internal|Price|Biomass|Multfactor ()"
  # remind2::reportPrices.R
  # p30_pebiolc_pricmult -> "Internal|Price|Biomass|Multfactor ()"
  # "o_p30_pebiolc_pricmult"
  # modules/30_biomass/magpie/presolve.gms
  # o_p30_pebiolc_pricmult(iteration,ttot,regi) = p30_pebiolc_pricmult(ttot,regi);

  # "Price|Carbon (US$2017/t CO2)"
  # pm_taxCO2eqSum <- readGDX(gdx, name = "pm_taxCO2eqSum", format = "first_found")[, t, ]
  # pm_taxCO2eqSum * 1000 * 12 / 44
  # "pm_taxCO2eq_iter"  
  # Alternative, that is already being tracked:
  # pm_taxCO2eq_iter(iteration,ttot,all_regi)
  

  # ---- Settings ----
  gdxName         <- file.path(runfolder, "fulldata.gdx")
  TWa2EJ          <- 31.5576 # TWa to EJ (1 a = 365.25*24*3600 s = 31557600 s)
  sm_tdptwyr2dpgj <- 31.71 # convert [TerraDollar per TWyear] to [Dollar per GJoule]
  GtC_2_MtCO2     <- 44/12 * 1000

  items <- tribble(
    ~par                      , ~var                                                    , ~factor,
    "o_p30_pebiolc_pricemag"  , "Internal|Price|Biomass|MAgPIE (US$2017/GJ)"            ,  sm_tdptwyr2dpgj,
    "o_vm_emiMacSector_co2luc", "Emi|CO2|+|Land-Use Change (Mt CO2/yr)"                 ,  GtC_2_MtCO2,
    "o_vm_fuExtr_pebiolc"     , "Primary Energy Production|Biomass|Energy Crops (EJ/yr)",  TWa2EJ,
    "o_PEDem_Bio_ECrops"      , "PE|Biomass|+++|Energy Crops (EJ/yr)"                   ,  TWa2EJ,
    "o_p30_pebiolc_pricmult"  , "Internal|Price|Biomass|Multfactor ()"                  ,  1,
    "pm_taxCO2eq_iter"        , "Price|Carbon (US$2017/t CO2)"                          ,  1000 * 12 / 44,
  )
  
  data <- items |> pull(par)            |> # take only par from items
    sapply(quitte::read.gdx,               # read all par from gdx
           gdxName = gdxName,                     
           simplify = FALSE,               # store as list
           USE.NAMES = TRUE)            |> # use par as names for list elements
    bind_rows(.id = "par")              |> # bind individual lists rowwise together and identify by par
    left_join(items, by = join_by(par)) |> # add other columns from items
    mutate(value = value * factor)         # unit conversion from gdx units to report units
  
  # Keep magpieIter only and prepend 1
  
  if(!allIter) {
    magpieIter <- quitte::read.gdx(gdxName, "magpieIter")
    #magpieIter <- rbind(1,                                   # always plot the first iteration 
    magpieIter <- rbind(magpieIter,                        
                        data |> pull(iteration) |> max()) |> # and last iteration (to see what Nash does after last MAgPIE iteration)
                  distinct()                                 # remove duplicates (if last iteration is also last MAgPIE iteration)
    data <- data |> semi_join(magpieIter, by = join_by(iteration))
  }
  
  return(data)
}

# Read data for all runs and put into on data frame
allRuns <- 
  outputdirs                     |> 
  sapply(readDataFromGdx,           # read gdx files for all outputdirs
     allIter = FALSE,               # decide whether to plot all Nash iterations or only Nash iterations in which MAgPIE runs
     simplify = FALSE,              # store as list
     USE.NAMES = TRUE)           |> # use outputdirs as names for list elements
  bind_rows(.id = "outputdirs")  |> # bind outputDir lists elements together and identify by outputDir
  mutate(outputdirs = basename(outputdirs)) |> # remove 'output/' from scenario names
  group_by(outputdirs)           #|> 
  #group_walk(~ plot_iterations(     # apply plot_iterations to all rows in a group
  #   .x,                            # .x refers to the subset of all rows in a group
  #   .y))                           # .y refers to their key (here: outputdirs)


# If a run continues a previous coupled REMIND-MAgPIE runs, produce a pdf that
# concatenates the iterations of all runs and plots all iterations on one axis

# Continue iteration count for runs that continue other runs

# Define order of runs in the order they are listed in outputdirs
allRuns$outputdirs <- factor(allRuns$outputdirs, levels = basename(outputdirs))

# Find last iteration per outputDir
last <- allRuns |> group_by(outputdirs) |> summarise(iteration = max(iteration))

# # A tibble: 2 × 2
#   outputdirs         last
#    <fct>             <dbl>
# 1 randomFolderName1    37
# 2 randomFolderName2    34

# Create data frame that maps single iterations to continuous iterations
mapIterations <- last |> group_by(outputdirs) |> 
  group_modify( ~ add_row(.x, iteration = 1:max(.x))) |> # per group add iterations 1:last
  arrange(outputdirs, iteration) |> 
  distinct() |> # remove duplicated last iteration
  ungroup() |> 
  mutate(continuous = 1:n()) # add column that continues iteration count across runs

# A tibble: 71 × 3
#    outputdirs     iteration continuous
#    <fct>              <dbl>      <int>
#  1 randomFolderName1      1          1
#  2 randomFolderName1      2          2
# ...
# 36 randomFolderName1     36         36
# 37 randomFolderName1     37         37
# 38 randomFolderName2      1         38
# 39 randomFolderName2      2         39
# ...
# 69 randomFolderName2     32         69
# 70 randomFolderName2     33         70
# 71 randomFolderName2     34         71

# Add column with continuous iteration numbers to allRuns
allRunsContinued <- allRuns |> 
  left_join(mapIterations, by = join_by(outputdirs, iteration)) |> 
  rename(single = iteration) |> 
  rename(iteration = continuous)

# Plot all runs into one plot
allRunsContinued |> 
  ungroup() |> 
  plot_iterations(runname = select(allRunsContinued, outputdirs) |> distinct() )

