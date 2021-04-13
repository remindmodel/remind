# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#------------------------------------------------------------------------------
#----------------------------# PREPARATION ------------------------------------
#------------------------------------------------------------------------------

library(tidyverse)
library(quitte)
library(lucode2)
library(grid)
library(gridExtra)

options(digits = 2)

if(!exists("source_include")) {
  #Define arguments that can be read from command line
  output_folder <- "dummy"
  readArgs("output_folder")
  scenario<-"remind17_6013_SSP2-tax20-Noaff-CT-rem-5"
  output_folder <- "remind17_6013_SSP2-tax20-Noaff-CT-rem-5"
} else {
  output_folder <- outputdir
}
scenario <- getScenNames(outputdir)
#----------------------------------------------------------------------------
#---------------- FUNCTIONS ------------------------------------------------
#---------------------------------------------------------------------------
computeEnergyDemand = function(.df, discount){
  tmp_result = NULL
  for (per in getPeriods(.df)){
    .tmp = .df %>% filter(period == per)
    
    #take the efficiencies from the considered period
    eff_k = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "eff" , "value"]
    eff_fe = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "eff", "value"]
    effGr_k = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "effGr" , "value"]
    effGr_fe = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "effGr", "value"]
    xi_k = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "xi", "value"]
    xi_fe = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "xi", "value"]
    p_k = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "price_Noscale", "value"]
    p_fe = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "price_Noscale", "value"]
    V_en_in = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "quantity", "value"]
    V_kap_in = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "quantity", "value"]
    V_out =  .tmp[.tmp$index == "remind" & .tmp$variable == out & .tmp$parameter == "quantity", "value"]
    rho = .tmp[.tmp$index == "remind" & .tmp$variable == out & .tmp$parameter == "rho", "value"]
    
    alpha = xi_fe^(1/rho) * eff_fe * effGr_fe
    beta = xi_k^(1/rho) * eff_k * effGr_k
    
    disc = discount %>% filter(region == regi, period == per, variable == kap_in) %>% mutate(variable = "discount") %>% spread(variable,value)
     
    disc = disc %>% mutate(REM_en = V_en_in,
                           p_fe = p_fe, 
                           p_k = p_k,
                           p_EG = p_k -discount,
                           energyDemand = 1/alpha * V_out / (1 + (p_k/p_fe * alpha /beta)^(rho/(rho-1)))^(1/rho),
                           energyDemand_EG = 1/alpha * V_out / (1 + (p_EG/p_fe * alpha /beta)^(rho/(rho-1)))^(1/rho),
                           E_K = energyDemand / V_kap_in,
                           ChangeP_K = (p_EG / p_k -1) * 100,
                           changeED = (energyDemand_EG / energyDemand - 1) *100 )
    
    tmp_result = rbind(tmp_result,disc)
    
  }
  return(tmp_result)
}

computeISO = function(.df,includePrices=T){
  tmp_result = NULL
  for (per in getPeriods(.df)){
    .tmp = .df %>% filter(period == per)
    
    #take the efficiencies from the considered period
    eff_k = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "eff" , "value"]
    eff_fe = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "eff", "value"]
    effGr_k = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "effGr" , "value"]
    effGr_fe = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "effGr", "value"]
    xi_k = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "xi", "value"]
    xi_fe = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "xi", "value"]
    p_k = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "price", "value"]
    p_fe = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "price", "value"]
    V_en_in = .tmp[.tmp$index == "remind" & .tmp$variable == en_in & .tmp$parameter == "quantity", "value"]
    V_kap_in = .tmp[.tmp$index == "remind" & .tmp$variable == kap_in & .tmp$parameter == "quantity", "value"]
    
    #take the quantities of the 2015 period and compute the ISO going through the 2015 point
    # which correspond to the 2015, 2050 or 2100 efficiencies
    .tmp_2015 = .df %>% filter(period == 2015,
                               parameter == "quantity")
    .tmp_2015 = .tmp_2015 %>% spread(variable,value)
    
    #change the period to the period considered
    .tmp_per = .tmp_2015 %>% mutate(period = per)
    
    #In case the period is not the estimation period, adjust the output
    #to compute the isoquant that goes through the initial point
    if (per > 2015){
    V_en_in_2015 = .tmp_per[.tmp_per$index == "remind", en_in]
    V_kap_in_2015 = .tmp_per[.tmp_per$index == "remind", kap_in]
    
    
       V_out = (xi_fe*(eff_fe * effGr_fe * V_en_in_2015 )^rho
                         + xi_k*(eff_k * effGr_k * V_kap_in_2015)^rho)^(1/rho)
       .tmp_per[[out]] = V_out
      ratio_inputs = V_kap_in / V_en_in
      V_en_adj = V_out / (xi_fe * (eff_fe * effGr_fe)^rho
                          +xi_k * (eff_k * effGr_k * ratio_inputs)^rho) ^(1/rho)
      V_kap_adj = ratio_inputs * V_en_adj
      tmp_adj = head(.tmp_per, 1)
      tmp_adj["period"] = per
      tmp_adj["region"] = regi
      tmp_adj["parameter"] = "quantity"
      tmp_adj[out] = V_out
      tmp_adj[kap_in] = V_kap_adj
      tmp_adj[en_in] = V_en_adj
      tmp_adj["iso"] = V_en_adj
      tmp_adj["index"] = "remind_adjusted"
      tmp_adj$prices = NA
      tmp_result = rbind(tmp_result,tmp_adj)
    }
    
    .tmp_per = .tmp_per %>% mutate_(iso = lazyeval::interp(~ (1/(eff_fe*effGr_fe))
                                                           *((1/xi_fe) 
                                                             *(out^rho
                                                               - xi_k * (eff_k * effGr_k * kap_in)^rho)
                                                           )^(1/rho),
                                                           out = as.name(out), kap_in = as.name(kap_in)
    ))
    
    if(includePrices){
      .tmp_per = .tmp_per %>% mutate_(
        prices = lazyeval::interp(~ out/p_fe - p_k/p_fe*kap_in,
                                  out = as.name(out), kap_in = as.name(kap_in)
        ),
        prices = lazyeval::interp(~ ifelse (prices < 0 | prices > 1.05*max(en_in),
                                            NA,
                                            prices),
                                  prices = as.name("prices"),
                                  en_in = as.name(en_in))
      )
      if (per != 2015){
        .tmp_per$prices = NA
      }
    }
    
    tmp_result = rbind(tmp_result,.tmp_per)
  }
  return(tmp_result)
}



#------------------------------------------------------------------------------
#----------------------------# READ INPUT DATA --------------------------------
#------------------------------------------------------------------------------



filename<-"capital_unit.csv"

if (file.exists(filename)) {
  df = read.csv(filename)
}else if (file.exists(path(output_folder,filename))) {
  df = read.csv(path(output_folder,filename))
  
} else {
  stop("No capital_unit.csv file found - please perform postprocessing first!")
}


#------------------------------------------------------------------------------
#----------------------------# Parameters  ------------------------------------
#------------------------------------------------------------------------------
cesOut2cesIn = inline.data.frame(
  "out;kap_in;en_in",
  "uescb;kapsc;fescelb",
  "esswb;kaphc;ueswb",
  "uealb;kapal;fealelb"
)

fileDisc = "fulldata.gdx"
if (file.exists(fileDisc)) {
  discRateImpl = read.gdx(fileDisc, "p21_implicitDiscRateMarg")
}else if (file.exists(path(output_folder,fileDisc))) {
  discRateImpl = read.gdx(path(output_folder,fileDisc), "p21_implicitDiscRateMarg")
  
} else { stop("Could not find fulldata.gdx")}

colnames(discRateImpl) = c("period","region","variable","value")
TWa_2_kWh = 8.76e+12
Trillion_2_non = 1e+12
#------------------------------------------------------------------------------
#----------------------------# Process Data    --------------------------------
#------------------------------------------------------------------------------
max_iter = max(df$iteration)
df = df %>% filter(iteration == max_iter) %>% select(-iteration)



#----------------------------------------------------------------------------------------------------------

 pdf(path(outputdir,paste0("Esubs calibration report.pdf")),
     width = 42 / 2.54, height = 29.7 / 2.54, title = "Esubs calibration report")

for (i in 1:nrow(cesOut2cesIn)){
  for (regi in getRegs(df)){
   
    out = getElement(cesOut2cesIn[i,], "out")
    kap_in = getElement(cesOut2cesIn[i,], "kap_in")
    en_in = getElement(cesOut2cesIn[i,], "en_in")
    
    tmp = df %>% filter(region == regi, variable %in% c(out, kap_in, en_in))
    
    demand_2015 = tmp[tmp$index == "remind" & tmp$variable == out & tmp$parameter == "quantity" & tmp$period == 2015, "value"]
    
    
    #rescale the output to the level considered in the estimation
    output_scale =  tmp[tmp$index == "remind" & tmp$variable == out & tmp$parameter == "output_scale", "value"] 
    scale = output_scale / demand_2015
    
    tmp = tmp %>% mutate(value = ifelse(index == "remind" & parameter == "quantity", value *scale,value))
    tmp = tmp %>% mutate(value = ifelse(variable == out & index != "remind" & parameter == "quantity", output_scale, value))
    
    
    rho = tmp[tmp$index == "remind" & tmp$variable == out & tmp$parameter == "rho" & tmp$period == 2015, "value"]
    sigma = 1/(1-rho)
    EnerDemand = computeEnergyDemand(tmp, discRateImpl)
    tmp = computeISO(tmp,includePrices = T)
    
    tmp$period = as.factor(tmp$period)
    
    # Change units from Trillion$/TWa to $/kWh
    tmp[kap_in] = tmp[kap_in] / (TWa_2_kWh / Trillion_2_non)
    
    p = ggplot()+
      geom_point(data = tmp %>% filter(index != "remind", period == 2015), aes_string(kap_in,en_in))+
      geom_point(data = tmp %>% filter(index == "remind", period == 2015), aes_string(kap_in,en_in), size = 4) +
      geom_point(data = tmp %>% filter(index == "0"), aes_string(kap_in,en_in), colour = "green", size = 4) +
      geom_point(data = tmp %>% filter(index == "remind_adjusted"), aes_string(kap_in,en_in, colour = "period"), size = 5, shape = 15)+
      geom_line(data = tmp %>% filter(!is.na(iso)), aes_string(kap_in,"iso", colour = "period"), size = 1.5)+
      geom_line(data = tmp %>% filter(!is.na(prices)), aes_string(kap_in,"prices", colour = "period"), size = 0.5)+
      ggtitle(paste0(regi, ". Sigma = ",sigma,"\n Demand = ", demand_2015))+
      expand_limits(x = 0, y =0) +
      theme(text = element_text(size = 18))
    print(p)
    
    grid.newpage()
    grid.table((EnerDemand), rows = NULL)
  
    
  }}


dev.off()

