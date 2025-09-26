*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF .modules/50_damages/COACCH/postsolve.gms

*** this damage function is derived for global mean temperature increase compared to 1986-2005 mean which is set to 0.6 degree Celsius:

p50_damage(tall,regi)$(tall.val ge 2010 and tall.val le 2300) = p50_damageFuncCoef0(regi)*(p50_damageFuncCoef1(regi)/100*(pm_globalMeanTemperature(tall)-0.6)+p50_damageFuncCoef2(regi)/100*(pm_globalMeanTemperature(tall)-0.6)**2);

*** derivative of damage function w.r.t. teperature (used in 51_internalizeDamages)
pm_damageMarginal(tall,regi)$(tall.val ge 2000 and tall.val le 2300) =     
  p50_damageFuncCoef0(regi)*( p50_damageFuncCoef1(regi)/100  + 2 * p50_damageFuncCoef2(regi)/100 * (pm_globalMeanTemperature(tall)-0.6));
*  ( p50_damageFuncCoef1(regi)/100  + 2 * p50_damageFuncCoef2(regi)/100 * (pm_globalMeanTemperatureZeroed1900(tall)-pm_globalMeanTemperatureZeroed1900("2005") ));

pm_damage(tall,regi)$(tall.val ge 2030 and tall.val le 2300) = 
  1-(p50_damage(tall,regi)-p50_damage("2020",regi));

display pm_damage,pm_damageMarginal;

*** EOF .modules/50_damages/COACCH/postsolve.gms
