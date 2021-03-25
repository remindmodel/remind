# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(lucode2)
library(gms)
library(tidyverse)
library(quitte)
library(reshape2)


#-------------------------- BASIC CONFIGURATION ----------------------------

if(!exists("source_include")) {
  #Define arguments that can be read from command line
  output_folder <- "dummy"
  readArgs("output_folder")

} else {
  output_folder <- outputdir
}

#---------------READ-IN DATA ----------------------------
filename = "Logit_buildings.csv"
if (file.exists(filename)) {
  df = read.csv(filename, stringsAsFactors = F)
}else if (file.exists(path(output_folder,filename))) {
  df = read.csv(path(output_folder,filename), stringsAsFactors = F)
  
} else {
  stop("No capital_unit.csv file found - please perform postprocessing first!")
}


#---------------PARAMETERS ----------------------------

iterations = as.numeric( setdiff(getColValues(df, "iteration"), "target"))
max_iter = max(iterations)
hist_period = 2015


#---------------PROCESS DATA ----------------------------
pdf(path(outputdir,paste0("reportLogit.pdf")), width = 10, height = 7)

for (regi in getRegs(df)){

  for (ces in getColValues(df,"ces_out")){



    tmp = df %>% filter(region == regi,
                        ces_out == ces,
                        iteration %in% c(max_iter, "target"),
                        period == hist_period,
                        !grepl("h2", tech),
                        !(variable == "shareFE" & iteration != "target"))
    
    tmp_totcosts = tmp %>% filter(variable == "cost")
    
    tmp_calib = tmp %>% filter(variable %in% c("calibfactor", "cost"))
    
    tmp_prices = tmp %>% filter(variable %in% c("CapCostsImplicit",
                                                "OM_FEpriceWtax",
                                                "OM_inconvenience"))
    tmp_shares = tmp %>% filter(variable == "shareUE")
    
    
    order_vec = getColValues(tmp_totcosts %>% arrange(desc(value)),"tech")
    
    tmp_prices = order.levels(tmp_prices,tech = order_vec)
    tmp_shares = order.levels(tmp_shares,tech = order_vec)
    tmp_calib = order.levels(tmp_calib,tech = order_vec)
    
    p1 = tmp_prices %>%
      ggplot(aes(tech,value, group = variable, fill = variable))+
      geom_bar(stat = "identity")+
      geom_point(data = tmp_shares, mapping = aes(tech,value)) +
      scale_y_continuous(sec.axis = sec_axis(trans = ~.*1, name = "Share UE")) +
      ggtitle(paste0(regi, " ", ces))
    print(p1)
    
     p2 = tmp_calib  %>%
       ggplot(aes(variable,value, fill = variable)) +
       geom_bar(stat = "identity") + 
       facet_grid(~tech) +
       ggtitle(paste0(regi, " ", ces))
     print(p2)
    
  }
}


dev.off()


