# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# Extract temperature impulse response function (TIRF) from MAGICC. 
# needs ./magicc/addEmissionPulse.awk
# AJS 2016
print("Acquiring temperature impulse response from MAGICC.. ")
require(dplyr)
require(gdxrrw)
igdx(system("dirname $( which gams )", intern = TRUE))

#find MAGICC SCEN file:
load(file.path('config.Rdata'),envir = e <- new.env())
file_scen =  paste0('./magicc/','REMIND_',as.character(e$cfg$title),'.SCEN')

# define years and pulse size
scan_vals_pulse = c(0,1) # pulse size in GtC. Keep 0 in here as the baseline against which the pulse run is compared to
scan_vals_years = c(2010,2020,2030,2040,2050,2060,2070,2080,2090,2100,2110,2130)

# backup default scenario file
file.copy(file_scen,paste0(file_scen,'_backup'),overwrite = T)


getTemperatureMagicc = function(file = "./magicc/DAT_SURFACE_TEMP.OUT"){
  x = read.table(file, skip = 19,header = T)
  x = x[,c(1,2)]
  names(x) = c('period','value')
  x$period = as.integer(as.character(x$period))
  # Get relevant years
  years <- x[x$period >= 2005 & x$period <= 2300,1]
  return(x[x$period %in% years,])
}

#initialize
scan_params = list('year_pulse'=2020,"size_pulse"=1)


# loop over pulse experiments
tirf = 
  do.call(rbind,lapply(scan_vals_years, function(y){
    scan_params[['year_pulse']] = y  
    tirfYear = do.call(rbind,lapply(scan_vals_pulse, function(i) {
      # manipulate scenario file; add pulse
      scan_params[['size_pulse']] = i
      opts = paste0(paste0('-v ',paste0(names(scan_params),'=',scan_params)),collapse = ' ')
      cmd = paste0("awk -f ./magicc/addEmissionPulse.awk ",opts,' ',file_scen,' > ','tmp',' && ','mv tmp ',file_scen)
      system(cmd)
      #run MAGICC
      system('Rscript run_magicc.R')
      #reset scenario file
      file.copy(paste0(file_scen,'_backup'),file_scen,overwrite = T)
      #read results
      tirfYearPulsesize = getTemperatureMagicc()
      tirfYearPulsesize = merge(as.data.frame(scan_params),tirfYearPulsesize) 
      #return
      tirfYearPulsesize
    }))
    tirfYear
  }))

#calculate difference to baseline to get TIRF, normalize to 1 GtCO2eq emission.
tirf = tirf %>% 
  group_by(period,year_pulse) %>% 
  summarize(tirf = (value[size_pulse != 0] - value[size_pulse == 0])/size_pulse[size_pulse!=0]/(44/12)) %>% 
  ungroup()

#FIXME the result for 2150 is just zero, don't know why. work around by assuming the TIRF in 2150 is equal to the one in 2130. From 2150 to 2250, assume the same. 
tirf = rbind(tirf,
  tirf %>% 
  filter(year_pulse == 2130)  %>%
  mutate(year_pulse = 2250,
         period = period + 120)
)


## interpolate for the years we didn't explicitly run a pulse experiment:
# prepare data by shifting als pulses so that they start at period=0
tirfInterpolated = tirf %>%
  group_by(year_pulse) %>% 
  mutate(period = period - year_pulse) 

# only try to interpolate if there is at least two datapoints (not the case for the earliet pulse in the last couple of years:)
tirfInterpolated = tirfInterpolated %>% 
  group_by(period) %>% 
  filter(length(tirf) >1)

#interpolation:
oupt = do.call(rbind,lapply(as.integer(unique(tirfInterpolated$period)), function(p){
  dt = tirfInterpolated %>% filter(period==p) 
  out = approx(dt$year_pulse,dt$tirf,xout=seq(min(tirfInterpolated$year_pulse),max(tirfInterpolated$year_pulse),1),method = 'linear',yleft = 0,yright = 0,rule=2:1)
  out = data.frame(tall1=out$x,tirf=out$y)
  out$tall = p
  out
}))

# reverse shift and limit output to until 2250
oupt = oupt %>% 
  mutate(tall = tall + tall1) %>% 
  filter(tall<=2250,tall>=2005)  %>%
  select(tall,tall1,tirf)


writeToGdx = function(file="pm_magicc_temperatureImpulseResponse",df){
  df$tall = factor(df$tall)
  df$tall1 = factor(df$tall1)
  attr(df,which = 'symName') = 'pm_temperatureImpulseResponse'
  attr(df,which = 'domains') = c('tall','tall')
  attr(df,which = 'domInfo') = 'full'
  
  wgdx.lst(file,df,squeeze = F)
  
}

# write to GDX:
writeToGdx('pm_magicc_temperatureImpulseResponse',oupt)
print("...done.")



