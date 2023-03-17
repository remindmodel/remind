*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KWTCint/postsolve.gms

* Damage function based on Kalkuhl & Wenz (2020)
* time index mapping from supplement to code:  tall = t ; tall2 = t' ; tall3 = t''

*calculate growth rate damages
pm_damageGrowthRate(tall,regi) = 0;

pm_damageGrowthRate(tall,regi)$(tall.val ge 2005 and tall.val le 2300) =
(    p50_damageFuncCoefa1 * ( pm_regionalTemperature(tall,regi) - pm_regionalTemperature(tall-1,regi) )
  + p50_damageFuncCoefa2 * ( pm_regionalTemperature(tall-1,regi) - pm_regionalTemperature(tall-2,regi) )
  + p50_damageFuncCoefb1 * ( pm_regionalTemperature(tall,regi) - pm_regionalTemperature(tall-1,regi))*pm_regionalTemperature(tall-1,regi)
  + p50_damageFuncCoefb2 * ( pm_regionalTemperature(tall-1,regi) - pm_regionalTemperature(tall-2,regi))*pm_regionalTemperature(tall-1,regi)
);


*no growth rate damages before 2020 to match observed GDP 
pm_damageGrowthRate(tall,regi)$(tall.val le 2020) = 0;

*no growth rate damages after 2150 to prevent extreme runaway damages
pm_damageGrowthRate(tall,regi)$(tall.val gt 2150) = 0;

*damage function. match observed 2020 GDP, that is, assume that no climate damages until then.
pm_damageProd(tall,regi)$(tall.val ge 2020 and tall.val le 2300) = 
    prod(tall2$(tall2.val ge 2020 AND tall2.val le tall.val),  
	(1 + pm_damageGrowthRate(tall2,regi)))    
;
display pm_damageProd;

*################## TC damages ##########################################
* see module TC

pm_damageGrowthRateTC(tall,iso) = 0;
pm_damageGrowthRateTC(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) = p50_damageFuncCoefTC1(isoTC) * (pm_globalMeanTemperatureZeroed1900(tall)-pm_globalMeanTemperatureZeroed1900("2000")); 

pm_damageGrowthRateTC(tall,iso)$(tall.val le 2020) = 0;
pm_damageGrowthRateTC(tall,iso)$(tall.val gt 2150) = 0;

pm_damageTC(tall,iso) = 1;
pm_damageTC(tall,isoTC)$(tall.val ge 2020 and tall.val le 2300) = 
   prod(tall2$(tall2.val ge 2020 AND tall2.val le tall.val),
	(1+pm_damageGrowthRateTC(tall2,isoTC))
);
display pm_damageTC;

*combined regional damage
pm_damage(tall,regi)$(tall.val ge 2005 and tall.val le 2300) = 
    pm_damageProd(tall,regi)*sum(regi2iso(regi,iso),pm_damageTC(tall,iso)*pm_GDPfrac(tall,iso))
;

*gross GDP on country level
pm_GDPGrossIso(tall,iso)=sum(regi2iso(regi,iso),pm_GDPGross(tall,regi))*pm_GDPfrac(tall,iso);

display pm_damage;

* ########### derivative of damage function w.r.t. temperature (used in 51_internalizeDamages)
* derivative of damage function w.r.t. teperature (used in 51_internalizeDamages)
pm_damageMarginalT(tall,regi)$(tall.val ge 2000 and tall.val le 2300) = 
  ( p50_damageFuncCoefa1 + p50_damageFuncCoefb1 * pm_regionalTemperature(tall-1,regi) );
pm_damageMarginalTm1(tall,regi)$(tall.val gt 2000 and tall.val le 2300) = 
  (p50_damageFuncCoefa2-p50_damageFuncCoefa1)+p50_damageFuncCoefb1*pm_regionalTemperature(tall,regi) + 2*(p50_damageFuncCoefb2-p50_damageFuncCoefb1)*pm_regionalTemperature(tall-1,regi) - p50_damageFuncCoefb2*pm_regionalTemperature(tall-2,regi);
pm_damageMarginalTm2(tall,regi)$(tall.val ge 2000 and tall.val le 2300) = 
 (-1)*p50_damageFuncCoefa2 - p50_damageFuncCoefb2 * pm_regionalTemperature(tall-1,regi) ;

pm_damageMarginalTC(tall,iso)=0;
pm_damageMarginalTC(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) =  p50_damageFuncCoefTC1(isoTC);

*** EOF ./modules/50_damages/KWTCint/postsolve.gms
