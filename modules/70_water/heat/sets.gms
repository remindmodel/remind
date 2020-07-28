*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/heat/sets.gms
***-------------------------------------------------------------------------------
*** *IM*2015-05-14* Sets definition
***-------------------------------------------------------------------------------

SETS
coolte70 "cooling technologies"  
/ 
  dry
  pond
  once
  tower
  hybrid
  default
  sea 
/

te_elcool70(all_te)   "electricity technologies that use cooling"
/
  ngcc
  ngccc
  ngt
  gaschp
  igcc
  igccc
  pc
  pcc
  pco
  coalchp
  dot  
  biochp
  bioigcc
  bioigccc
  geohdr
  hydro
  wind
  spv
  csp
  tnrs
*  fnrs
/    

te_coolren70(all_te) "renewable electricity technologies that use cooling"
/
hydro
geohdr
wind
spv
csp
/

te_coolnoren70(all_te) "non-renewable electricity technologies that use cooling"

te_stack70(all_te) "electricity technologies that have a smoke stack"

descr_water_ext    "additional quantities (all extensive) to be written out in water reporting"
/
  "Water Consumption|Electricity; km3/yr;"
  "Water Consumption|Electricity|wo/h; km3/yr;"
  "Water Consumption|Electricity|Fossil; km3/yr;"
  "Water Consumption|Electricity|Fossil|w/ CCS; km3/yr;"
  "Water Consumption|Electricity|Fossil|w/o CCS; km3/yr;"  
  "Water Consumption|Electricity|Coal; km3/yr;"
  "Water Consumption|Electricity|Coal|w/ CCS; km3/yr;"
  "Water Consumption|Electricity|Coal|w/o CCS; km3/yr;"
  "Water Consumption|Electricity|Oil; km3/yr;"
  "Water Consumption|Electricity|Oil|w/o CCS; km3/yr;"
  "Water Consumption|Electricity|Gas; km3/yr;"
  "Water Consumption|Electricity|Gas|w/ CCS; km3/yr;"
  "Water Consumption|Electricity|Gas|w/o CCS; km3/yr;"
  "Water Consumption|Electricity|Biomass; km3/yr;"
  "Water Consumption|Electricity|Biomass|w/ CCS; km3/yr;"
  "Water Consumption|Electricity|Biomass|w/o CCS; km3/yr;"
  "Water Consumption|Electricity|Nuclear; km3/yr;"
  "Water Consumption|Electricity|Non-Biomass Renewables; km3/yr;"  
  "Water Consumption|Electricity|Hydro; km3/yr;"
  "Water Consumption|Electricity|Solar; km3/yr;"  
  "Water Consumption|Electricity|Solar|PV; km3/yr;"  
  "Water Consumption|Electricity|Solar|CSP; km3/yr;"
  "Water Consumption|Electricity|Wind; km3/yr;"
  "Water Consumption|Electricity|Geothermal; km3/yr;"
  "Water Consumption|Electricity|Once Through; km3/yr;"  
  "Water Consumption|Electricity|Wet Tower; km3/yr;"
  "Water Consumption|Electricity|Cooling Pond; km3/yr;"
  "Water Consumption|Electricity|Dry Cooling; km3/yr;"  
  "Water Withdrawal|Electricity; km3/yr;"
  "Water Withdrawal|Electricity|Fossil; km3/yr;"
  "Water Withdrawal|Electricity|Fossil|w/ CCS; km3/yr;"
  "Water Withdrawal|Electricity|Fossil|w/o CCS; km3/yr;"  
  "Water Withdrawal|Electricity|Coal; km3/yr;"
  "Water Withdrawal|Electricity|Coal|w/ CCS; km3/yr;"
  "Water Withdrawal|Electricity|Coal|w/o CCS; km3/yr;"
  "Water Withdrawal|Electricity|Oil; km3/yr;"
  "Water Withdrawal|Electricity|Oil|w/o CCS; km3/yr;"
  "Water Withdrawal|Electricity|Gas; km3/yr;"
  "Water Withdrawal|Electricity|Gas|w/ CCS; km3/yr;"
  "Water Withdrawal|Electricity|Gas|w/o CCS; km3/yr;"
  "Water Withdrawal|Electricity|Biomass; km3/yr;"
  "Water Withdrawal|Electricity|Biomass|w/ CCS; km3/yr;"
  "Water Withdrawal|Electricity|Biomass|w/o CCS; km3/yr;"
  "Water Withdrawal|Electricity|Nuclear; km3/yr;"
  "Water Withdrawal|Electricity|Non-Biomass Renewables; km3/yr;"  
  "Water Withdrawal|Electricity|Hydro; km3/yr;"
  "Water Withdrawal|Electricity|Solar; km3/yr;"  
  "Water Withdrawal|Electricity|Solar|PV; km3/yr;"  
  "Water Withdrawal|Electricity|Solar|CSP; km3/yr;"
  "Water Withdrawal|Electricity|Wind; km3/yr;"
  "Water Withdrawal|Electricity|Geothermal; km3/yr;"  
  "Water Withdrawal|Electricity|Once Through; km3/yr;"  
  "Water Withdrawal|Electricity|Wet Tower; km3/yr;"
  "Water Withdrawal|Electricity|Cooling Pond; km3/yr;"
  "Water Withdrawal|Electricity|Dry Cooling; km3/yr;"  
  "Secondary Energy|Electricity|Full; EJ/yr;"
  "Secondary Energy|Electricity|Part; EJ/yr;"
  "Secondary Energy|Electricity|wo/h; EJ/yr;"  
  "Water Consumption Intensity|Electricity; m3/MWh;"
  "Water Consumption Intensity|Electricity|wo/h; m3/MWh;"  
  "Water Withdrawal Intensity|Electricity; m3/MWh;"
/

descr_water_extn(descr_water_ext)   "additional quantities (extensive numerators) to be written out in water reporting"
/
  "Water Consumption|Electricity; km3/yr;"
  "Water Consumption|Electricity|wo/h; km3/yr;"
  "Water Consumption|Electricity|Fossil; km3/yr;"
  "Water Consumption|Electricity|Fossil|w/ CCS; km3/yr;"
  "Water Consumption|Electricity|Fossil|w/o CCS; km3/yr;"  
  "Water Consumption|Electricity|Coal; km3/yr;"
  "Water Consumption|Electricity|Coal|w/ CCS; km3/yr;"
  "Water Consumption|Electricity|Coal|w/o CCS; km3/yr;"
  "Water Consumption|Electricity|Oil; km3/yr;"
  "Water Consumption|Electricity|Oil|w/o CCS; km3/yr;"
  "Water Consumption|Electricity|Gas; km3/yr;"
  "Water Consumption|Electricity|Gas|w/ CCS; km3/yr;"
  "Water Consumption|Electricity|Gas|w/o CCS; km3/yr;"
  "Water Consumption|Electricity|Biomass; km3/yr;"
  "Water Consumption|Electricity|Biomass|w/ CCS; km3/yr;"
  "Water Consumption|Electricity|Biomass|w/o CCS; km3/yr;"
  "Water Consumption|Electricity|Nuclear; km3/yr;"
  "Water Consumption|Electricity|Non-Biomass Renewables; km3/yr;"  
  "Water Consumption|Electricity|Hydro; km3/yr;"
  "Water Consumption|Electricity|Solar; km3/yr;"  
  "Water Consumption|Electricity|Solar|PV; km3/yr;"  
  "Water Consumption|Electricity|Solar|CSP; km3/yr;"
  "Water Consumption|Electricity|Wind; km3/yr;"
  "Water Consumption|Electricity|Geothermal; km3/yr;"
  "Water Consumption|Electricity|Once Through; km3/yr;"  
  "Water Consumption|Electricity|Wet Tower; km3/yr;"
  "Water Consumption|Electricity|Cooling Pond; km3/yr;"
  "Water Consumption|Electricity|Dry Cooling; km3/yr;"  
  "Water Withdrawal|Electricity; km3/yr;"
  "Water Withdrawal|Electricity|Fossil; km3/yr;"
  "Water Withdrawal|Electricity|Fossil|w/ CCS; km3/yr;"
  "Water Withdrawal|Electricity|Fossil|w/o CCS; km3/yr;"  
  "Water Withdrawal|Electricity|Coal; km3/yr;"
  "Water Withdrawal|Electricity|Coal|w/ CCS; km3/yr;"
  "Water Withdrawal|Electricity|Coal|w/o CCS; km3/yr;"
  "Water Withdrawal|Electricity|Oil; km3/yr;"
  "Water Withdrawal|Electricity|Oil|w/o CCS; km3/yr;"
  "Water Withdrawal|Electricity|Gas; km3/yr;"
  "Water Withdrawal|Electricity|Gas|w/ CCS; km3/yr;"
  "Water Withdrawal|Electricity|Gas|w/o CCS; km3/yr;"
  "Water Withdrawal|Electricity|Biomass; km3/yr;"
  "Water Withdrawal|Electricity|Biomass|w/ CCS; km3/yr;"
  "Water Withdrawal|Electricity|Biomass|w/o CCS; km3/yr;"
  "Water Withdrawal|Electricity|Nuclear; km3/yr;"
  "Water Withdrawal|Electricity|Non-Biomass Renewables; km3/yr;"  
  "Water Withdrawal|Electricity|Hydro; km3/yr;"
  "Water Withdrawal|Electricity|Solar; km3/yr;"  
  "Water Withdrawal|Electricity|Solar|PV; km3/yr;"  
  "Water Withdrawal|Electricity|Solar|CSP; km3/yr;"
  "Water Withdrawal|Electricity|Wind; km3/yr;"
  "Water Withdrawal|Electricity|Geothermal; km3/yr;"  
  "Water Withdrawal|Electricity|Once Through; km3/yr;"  
  "Water Withdrawal|Electricity|Wet Tower; km3/yr;"
  "Water Withdrawal|Electricity|Cooling Pond; km3/yr;"
  "Water Withdrawal|Electricity|Dry Cooling; km3/yr;"  
/

descr_water_extd(descr_water_ext)   "additional quantities (extensive denominators) to be written out in water reporting"
/
	"Secondary Energy|Electricity|Full; EJ/yr;"
	"Secondary Energy|Electricity|Part; EJ/yr;"
	"Secondary Energy|Electricity|wo/h; EJ/yr;"  
/

descr_water_int(descr_water_ext)   "additional quantities (intensive) to be written out in water reporting"
/
	"Water Consumption Intensity|Electricity; m3/MWh;"
	"Water Consumption Intensity|Electricity|wo/h; m3/MWh;"  
	"Water Withdrawal Intensity|Electricity; m3/MWh;"
/

descr_water_int2ext(descr_water_int,descr_water_extn,descr_water_extd)   "???"
/
  "Water Consumption Intensity|Electricity; m3/MWh;" . "Water Consumption|Electricity; km3/yr;" . "Secondary Energy|Electricity|Part; EJ/yr;"
  "Water Consumption Intensity|Electricity|wo/h; m3/MWh;" . "Water Consumption|Electricity|wo/h; km3/yr;" . "Secondary Energy|Electricity|wo/h; EJ/yr;"
  "Water Withdrawal Intensity|Electricity; m3/MWh;" . "Water Withdrawal|Electricity; km3/yr;" . "Secondary Energy|Electricity|Part; EJ/yr;"
/
;

te_coolnoren70(te) = not te_coolren70(te);
te_stack70(te) = te_elcool70(te) - te_coolren70(te) - te_elcool70(te)$(sameas (te,"tnrs"));



display te_stack70;

*** EOF ./modules/70_water/heat/sets.gms
