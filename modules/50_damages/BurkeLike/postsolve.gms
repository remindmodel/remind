*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
* Damage function based on Burke et al. (2015), extended by finite persistence/adaptation parameterization
* For details refer to Schultes et al. (2018) supplementary material
* time index mapping from supplement to code:  tall = t ; tall2 = t' ; tall3 = t''


*calculate growth rate damages
* TODO for RCPs higher than 26:  Limit too extreme out-of-support extrapolation (No country hotter than X degrees in Burkes data). Not relevant for RCP26.
pm_damageGrowthRate(tall,regi) = 0;

pm_damageGrowthRate(tall,regi)$(tall.val ge 2000 and tall.val le 2300) =
(    p50_damageFuncCoef1 * ( pm_regionalTemperature(tall,regi) - pm_regionalTemperature("2005",regi) )
  + p50_damageFuncCoef2 * ( pm_regionalTemperature(tall,regi)**2 - pm_regionalTemperature("2005",regi)**2 )
);

*no growth rate damages after 2150 to prevent extreme runaway damages
pm_damageGrowthRate(tall,regi)$(tall.val gt 2150) = 0;

*damage function. match observed 2005 GDP, that is, assume that no climate damages unitl then.
pm_damage(tall,regi)$(tall.val ge 2000 and tall.val le 2300) = 
    prod(tall2$(tall2.val gt 2005 AND tall2.val le tall.val),  
	(1 + pm_damageGrowthRate(tall2,regi) * 2**(-(tall.val - tall2.val)/cm_damages_BurkeLike_persistenceTime) )    
    )
;

* derivative of damage function w.r.t. teperature (used in 51_internalizeDamages)
pm_damageMarginal(tall,regi)$(tall.val ge 2000 and tall.val le 2300) = 
  ( p50_damageFuncCoef1  + 2 * p50_damageFuncCoef2 * pm_regionalTemperature(tall,regi) );




display pm_damage;
