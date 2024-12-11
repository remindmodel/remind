# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# Calculate damage factor and marginal damages from Kotz et al. (2024) for the full distribution 
# FP
print("Calculating damages and marginal damages for SCC ")
require(dplyr)
require(gdxrrw)
require(quitte)
igdx(system("dirname $( which gams )", intern = TRUE))

beta1 <- read.csv("../../modules/50_damages/KotzWenz/input/f50_KLW_df_beta1.cs4r",skip=4,header=FALSE) %>% rename(iso=V1,realization=V2,value=V3)
beta2 <- read.csv("../../modules/50_damages/KotzWenz/input/f50_KLW_df_beta2.cs4r",skip=4,header=FALSE) %>% rename(iso=V1,realization=V2,value=V3)
maxtemp <- read.csv("../../modules/50_damages/KotzWenz/input/f50_KLW_df_maxGMT.cs4r",skip=4,header=FALSE) %>% rename(iso=V1,realization=V2,value=V3)

getTemperatureMagicc = function(file="./p15_magicc_temp.gdx"){
  x <- read.gdx("p15_magicc_temp.gdx","pm_globalMeanTemperature") %>% rename(period=tall)
  if(max(x$period) == 2100){
    x <- rbind(x,tibble(period= seq(2101,2300,1),value=subset(x,period == 2100)$value))
  }
  # Get relevant years
  return(subset(x,period >= 2005 & period <= 2300))	
}

temp <- getTemperatureMagicc() %>% subset(period >= 2020) %>% mutate(value=value-value[1])

#countries <- colnames(beta1)
countries <- unique(beta1$iso)

# calculate damage and marginal damage for mean, median, 5th and 95th percentile of damage distribution for each country
# if country temperature is above the robust range of the damages (indicated by maxtemp) the temperature is set to maxtemp

alldam <- tibble(tall=integer(),iso=character(),low=double(),med=double(),mean=double(),high=double())
alldam_marg <- tibble(tall=integer(),iso=character(),low_marg=double(),med_marg=double(),mean_marg=double(),high_marg=double())

for(i in countries){
#  df <- as.data.frame(cbind(beta1[,i],beta2[,i],maxtemp[,i])) %>%
#    rename(beta1=V1,beta2=V2,maxtemp=V3)
  df <- as.data.frame(cbind(subset(beta1,iso==i)$value,subset(beta2,iso==i)$value,subset(maxtemp,iso==i)$value)) %>%
    rename(beta1=V1,beta2=V2,maxtemp=V3)
  dam <- merge(temp,df) 
  dam[which(dam$maxtemp < dam$value),]$value <- 
    dam[which(dam$maxtemp < dam$value),]$maxtemp
  dam$dam <- dam$beta1/100*dam$value+dam$beta2/100*dam$value^2
  dam$marginal <- dam$beta1/100+2*dam$beta2/100*dam$value
  dam_q <- dam %>% group_by(period) %>% 
    summarize(low=quantile(dam,probs=0.05),med=quantile(dam,probs=0.5),mean=mean(dam),
              high=quantile(dam,probs=0.95),low_marg=quantile(marginal,probs=0.05),
	      med_marg=quantile(marginal,probs=0.5),mean_marg=mean(marginal),
	      high_marg=quantile(marginal,probs=0.95)) %>% ungroup()
  dam_q$iso = i
  alldam <- rbind(alldam,rename(select(dam_q,c("iso","period","low","med","mean","high")),tall=period))
  alldam_marg <- rbind(alldam_marg,rename(select(dam_q,c("iso","period","low_marg","med_marg","mean_marg","high_marg")),tall=period))
}

writeToGdx = function(file,df,name){
  df$tall = factor(df$tall)
  df$iso = factor(df$iso)
  df$percentile = factor(df$percentile)
  attr(df,which = 'symName') = name
  attr(df,which = 'domains') = c('tall','iso','percentile')
  attr(df,which = 'domInfo') = 'full'
  
  wgdx.lst(file,df,squeeze = F)
}

alldam <- reshape2::melt(alldam,id.vars=c("tall","iso")) %>% rename(percentile=variable)
alldam_marg <- reshape2::melt(rename(alldam_marg,low=low_marg,med=med_marg,mean=mean_marg,high=high_marg),id.vars=c("tall","iso")) %>% rename(percentile=variable)

# write to GDX:
writeToGdx('pm_KotzWenz_damageIso',alldam,'pm_damageIso')
writeToGdx('pm_KotzWenz_damageMarginalIso',alldam_marg,'pm_damageMarginalIso')
print("...done.")



