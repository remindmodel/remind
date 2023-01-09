# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#---------------------------------------------------------------------------
#----------------------------     PREPARATION     --------------------------
#---------------------------------------------------------------------------
library(tidyverse)
library(remind2)
library(gridExtra)
library(quitte)
require(lucode2)
require(gms)
require(colorspace)
require(gdx)
require(grid)

gdx_name     <- "fulldata.gdx"             # name of the gdx

if(!exists("source_include")) {
  #Define arguments that can be read from command line
   outputdir <- "output/R17IH_SSP2_postIIASA-26_2016-12-23_16.03.23"     # path to the output folder
   readArgs("outputdir","gdx_name")
}
gdx      <- file.path(outputdir,gdx_name)
scenario <- getScenNames(outputdir)

#---------------------------------------------------------------------------
#----------------------------     FUNCTIONS     ----------------------------
#---------------------------------------------------------------------------

quant_outliers = function(df, threshold){

  target_period_items = df %>% filter(iteration == "target") %>%
    select(t,pf) %>%
    unique()

  tmp  = left_join(target_period_items,df, by = c("pf","t")) %>%
    filter(variable == "quantity", iteration %in% c("target", iter.max),
           t <= 2100) %>%
    group_by( t, regi, variable, pf )  %>%
    filter(abs((value[iteration == "target"] - value[iteration == iter.max])/value[iteration == "target"]) > threshold) %>%
    ungroup() %>%
    filter(value > eps) %>%
    select(regi, pf, t) %>%
    unique() %>%
    group_by(regi, pf ) %>%
   # filter(length(t) > 1) %>%
    mutate(period = paste(t, collapse = ", ")) %>%
    select(-t) %>%
    unique() %>%
    ungroup() %>%
    arrange(regi, pf, period)

  return(tmp)
}

price_outliers <- function(df, threshold){
  tmp = df %>%
    filter(variable == "price",
           iteration %in% c(iter.max),
           pf != "inco",
           t        <= 2100,
           value < threshold) %>%
    select(regi, pf, t) %>%
    group_by(regi, pf ) %>%
    filter(length(t) > 1) %>%
    mutate(period = paste(t, collapse = ", ")) %>%
    select(-t) %>%
    unique() %>%
    ungroup() %>%
    arrange(regi, pf, period)
  return(tmp)
}

#---------------------------------------------------------------------------
#---------------------------- READ INPUT DATA    ---------------------------
#---------------------------------------------------------------------------

filename<-"CES_calibration.csv"
cat("Reading CES calibration output from ",filename,"\n")
if (file.exists(filename)) {
  CES.cal.report <- read.table(filename, header = TRUE, sep = ",", quote = "\"") %>%
    as.data.frame()
} else if (file.exists(file.path(outputdir,filename))) {

  CES.cal.report <- read.table(file.path(outputdir,filename), header = TRUE, sep = ",", quote = "\"") %>%
    as.data.frame()
} else {
  stop("No CES_calibration.csv file found. CES_calibration.csv is normally produced during calibration runs")
}


#---------------------------------------------------------------------------
#----------------------------   Parameters      ----------------------------
#---------------------------------------------------------------------------


in_set = readGDX(gdx, "in", "sets")

# normalize iteration numbers, which are characters because they contain "origin" and "target" as well
CES.cal.report$iteration <- coalesce(
  CES.cal.report$iteration %>% as.double() %>% as.character(),
  CES.cal.report$iteration)

itr <- getColValues(CES.cal.report,"iteration")
itr_num <- sort(as.double(setdiff(itr, c("origin","target"))))
itr <- c("origin", "target", itr_num)

col <- c("#fc0000", "#000000",
         rainbow_hcl(length(itr_num) - 1),
         "#bc80bd"#,
         #"#808080"
         )
names(col) <- c("origin", "target", itr_num)


lns <- c(rep("solid", 2), rep("longdash", length(itr_num)))
names(lns) <- c("origin", "target", itr_num)

.pf <- list("TE" = c("gastr", "refliq", "biotr", "coaltr","hydro", "ngcc","ngt","pc", "apCarDiT","apCarPeT","apCarElT","dot","gaschp","wind","tnrs"))



eps = 1e-2
threshold_quant = 0.15
threshold_price = 0.01




#---------------------------------------------------------------------------
#---------------------------- Process Data      ----------------------------
#---------------------------------------------------------------------------
CES.cal.report = CES.cal.report %>%
  order.levels(iteration = itr)

CES.cal.report <- unique(CES.cal.report)
CES.cal.report <- CES.cal.report %>% tbl_df()
CES.cal.report$scenario = as.character(CES.cal.report$scenario)

CES.cal.report$scenario = as.factor(CES.cal.report$scenario)
CES.cal.report$t <- as.numeric(as.character(CES.cal.report$t))
CES.cal.report$value <- as.numeric(as.character(CES.cal.report$value))


CES.cal.report = CES.cal.report %>% filter(iteration %in% c("target", "origin", itr_num))



iter.max = max(itr_num)

.pf$structure = sort(intersect(in_set,getColValues(CES.cal.report,"pf")))

#---------------------------------------------------------------------------
#------------------------      PLOTS     ----------------------------------
#---------------------------------------------------------------------------

pdf(file.path(outputdir,paste0("CES_calibration_report_",scenario,".pdf")),
    width = 42 / 2.54, height = 29.7 / 2.54, title = "CES calibration report")


# Include tables with quantities outliers
try(grid.table(quant_outliers(CES.cal.report, threshold_quant), rows = NULL))
grid.text(paste0("Quantities diverge by more than ",threshold_quant *100," %"),rot = 90,x = 0.05, y = 0.5,
          gp=gpar(fontsize=20, col="grey38"))

# nclude tables with price outliers
grid.newpage()
try(grid.table(price_outliers(CES.cal.report, threshold_price), rows = NULL))
grid.text(paste0("Prices below ",threshold_price),rot = 90,x = 0.05, y = 0.5,
          gp=gpar(fontsize=20, col="grey38"))



for (s in levels(CES.cal.report$scenario)) {
  for (r in unique(CES.cal.report[CES.cal.report$scenario == s,][["regi"]])) {

    # plot quantities
    CES.cal.report %>%
      filter(scenario == s,
             t        <= 2100,
             regi     == r,
             variable == "quantity") %>%
      order.levels(pf = getElement(.pf,"structure" )) %>%
      ggplot(aes(x = t, y = value, colour = iteration,
                 linetype = iteration)) +
      geom_line() +
      facet_wrap(~ pf, scales = "free", as.table = FALSE) +
      expand_limits(y = 0) +
      scale_colour_manual(values = col) +
      scale_linetype_manual(values = lns) +
      ggtitle(paste("quantities", r, s)) -> p

    plot(p)


    # plot prices
    CES.cal.report %>%
      filter(scenario == s,
             t        <= 2100,
             regi     == r,
             variable == "price") %>%
      order.levels(pf = getElement(.pf,"structure" )) %>%
      ggplot(aes(x = t, y = value, colour = iteration,
                 linetype = iteration)) +
      geom_line() +
      facet_wrap(~ pf, scales = "free", as.table = FALSE) +
      expand_limits(y = 0) +
      scale_colour_manual(values = col) +
      scale_linetype_manual(values = lns) +
      ggtitle(paste("prices", r, s)) -> p
    plot(p)

    # plot efficiencies
    CES.cal.report %>%
      filter(scenario == s,
             t        <= 2100,
             regi     == r,
             variable == "total efficiency",
             iteration != "origin") %>%
      group_by(scenario,t,regi,pf,variable) %>%
      mutate(value = value / value[as.character(iteration) == as.character(min(itr_num))]) %>%
      ungroup() %>%
      order.levels(pf = getElement(.pf,"structure" )) %>%
      ggplot(aes(x = t, y = value, colour = iteration,
                 linetype = iteration)) +
      geom_line() +
      facet_wrap(~ pf, scales = "free", as.table = FALSE) +
      scale_colour_manual(values = col) +
      scale_linetype_manual(values = lns) +
      ggtitle(paste("total efficiency (1 = iteration 1)", r, s)) -> p
    plot(p)


    # plot Putty quantities
    if ( dim(CES.cal.report %>% filter(variable == "quantity_putty"))[1] > 0){
    CES.cal.report %>%
      filter(scenario == s,
             t        <= 2100,
             regi     == r,
             variable == "quantity_putty") %>%
      order.levels(pf = getElement(.pf,"structure" )) %>%
      ggplot(aes(x = t, y = value, colour = iteration,
                 linetype = iteration)) +
      geom_line() +
      facet_wrap(~ pf, scales = "free", as.table = FALSE) +
      expand_limits(y = 0) +
      scale_colour_manual(values = col) +
      scale_linetype_manual(values = lns) +
      ggtitle(paste("Putty quantities", r, s)) -> p

    plot(p)

    # plot prices putty
    CES.cal.report %>%
      filter(scenario == s,
             t        <= 2100,
             regi     == r,
             variable == "price_putty") %>%
      order.levels(pf = getElement(.pf,"structure" )) %>%
      ggplot(aes(x = t, y = value, colour = iteration,
                 linetype = iteration)) +
      geom_line() +
      facet_wrap(~ pf, scales = "free", as.table = FALSE) +
      expand_limits(y = 0) +
      scale_colour_manual(values = col) +
      scale_linetype_manual(values = lns) +
      ggtitle(paste("prices", r, s)) -> p
    plot(p)

    # plot efficiencies
    CES.cal.report %>%
      filter(scenario == s,
             t        <= 2100,
             regi     == r,
             variable == "total efficiency putty",
             iteration != "origin") %>%
      group_by(scenario,t,regi,pf,variable) %>%
      mutate(value = value / value[as.character(iteration) == "1"]) %>%
      ungroup() %>%
      order.levels(pf = getElement(.pf,"structure" )) %>%
      ggplot(aes(x = t, y = value, colour = iteration,
                 linetype = iteration)) +
      geom_line() +
      facet_wrap(~ pf, scales = "free", as.table = FALSE) +
      expand_limits(y = 0) +
      scale_colour_manual(values = col) +
      scale_linetype_manual(values = lns) +
      ggtitle(paste("total efficiency (1 = iteration 1)", r, s)) -> p
    plot(p)

    }






    # plot delta_cap
    CES.cal.report %>%
      filter(scenario == s,
             t        <= 2100,
             t >= 1980,
             regi     == r,
             variable == "vm_deltaCap",
             pf%in% .pf$TE) %>%
      order.levels(pf = getElement(.pf, "TE")) %>%
      ggplot(aes(x = t, y = value, colour = iteration,
                 linetype = iteration)) +
      geom_line() +
      facet_wrap(~ pf, scales = "free", as.table = FALSE) +
      expand_limits(y = 0) +
      scale_colour_manual(values = col) +
      scale_linetype_manual(values = lns) +
      geom_vline(xintercept = 2005) +
      ggtitle(paste("vm_deltaCap", r, s)) -> p
    plot(p)

  }
}


dev.off()
