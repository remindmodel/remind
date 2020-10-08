*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de



pm_damage(tall,regi)$(tall.val ge 2010 and tall.val le 2300) = 
1 
- p50_damageFuncCoef1 * pm_globalMeanTemperatureZeroed1900(tall) 
- p50_damageFuncCoef2 * pm_globalMeanTemperatureZeroed1900(tall)**2; 

* derivative of damage function w.r.t. teperature (used in 51_internalizeDamages)
pm_damageMarginal(tall,"USA")$(tall.val ge 2000 and tall.val le 2300) =     !! USA stands in as a dummy for a gobal value here
  ( p50_damageFuncCoef1  + 2 * p50_damageFuncCoef2 * pm_globalMeanTemperatureZeroed1900(tall) );
