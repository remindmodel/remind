*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/50_damages/Labor/postsolve.gms

* damage function, match observed GDP in 2020, i.e. assume no climate change until then
* coefficients estimated as differences to baseline
pm_damage(tall,regi)$(tall.val gt 2020 and tall.val le 2300) = 
1 
+ p50_damageFuncCoef1(regi) * (pm_regionalTemperature(tall,regi)-pm_regionalTemperature("2005",regi)) 
+ p50_damageFuncCoef2(regi) * (pm_regionalTemperature(tall,regi)**2-pm_regionalTemperature("2005",regi)**2); 

* derivative of damage function w.r.t. teperature (used in 51_internalizeDamages)
pm_damageMarginal(tall,regi)$(tall.val ge 2000 and tall.val le 2300) =    
  ( p50_damageFuncCoef1(regi)  + 2 * p50_damageFuncCoef2(regi) * pm_regionalTemperature(tall,regi) );

display pm_regionalTemperature, pm_damage,pm_damageMarginal;

*** EOF ./modules/50_damages/Labor/postsolve.gms
