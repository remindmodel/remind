*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/TC/postsolve.gms

p50_damageGrowthRate(tall,iso) = 0;

*equation for a climate change only damage function - not applicable currently
*p50_damageGrowthRate(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) = p50_damageFuncCoefTC0(isoTC)+ p50_damageFuncCoefTC1(isoTC) * pm_globalMeanTemperatureZeroed1900(tall) + p50_damageFuncCoefTC2(isoTC) * pm_globalMeanTemperatureZeroed1900(tall)**2; 

*the current damage function is estimated for "baseline" TC effect plus climate change effect - need to subtract the baseline effect as in Burke by doing delta(T)-delta(T0)
p50_damageGrowthRate(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) = p50_damageFuncCoefTC1(isoTC) * (pm_globalMeanTemperatureZeroed1900(tall)-pm_globalMeanTemperatureZeroed1900("2000")) + p50_damageFuncCoefTC2(isoTC) * (pm_globalMeanTemperatureZeroed1900(tall)**2-pm_globalMeanTemperatureZeroed1900("2000")**2); 

* no damages before 2020 to match observed GDP
p50_damageGrowthRate(tall,iso)$(tall.val le 2020) = 0;
p50_damageGrowthRate(tall,iso)$(tall.val gt 2150) = 0;

display p50_damageGrowthRate;

*match observed 2020 GDP, i.e. assume no climate change until then
p50_damage(tall,iso) = 1;
p50_damage(tall,isoTC)$(tall.val ge 2020 and tall.val le 2300) = 
   prod(tall2$(tall2.val ge 2020 AND tall2.val le tall.val),
	(1+p50_damageGrowthRate(tall2,isoTC))
);


display pm_globalMeanTemperatureZeroed1900,p50_damage;

*regional damage
pm_damage(tall,regi)$(tall.val ge 2020 and tall.val le 2300) = 
	sum(regi2iso(regi,iso),p50_damage(tall,iso)*pm_GDPfrac(tall,iso));

*gross GDP on country level
pm_GDPGrossIso(tall,iso)=sum(regi2iso(regi,iso),pm_GDPGross(tall,regi))*pm_GDPfrac(tall,iso);

p50_test(tall,iso)$(tall.val ge 2005 and tall.val le 2100) = sum(regi2iso(regi,iso),pm_damage(tall,regi));

display pm_damage,pm_GDPfrac,p50_test;

* derivative of damage function w.r.t. temperature (used in 51_internalizeDamages)
pm_damageMarginal(tall,iso)=0;
pm_damageMarginal(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) =  p50_damageFuncCoefTC1(isoTC)+2*p50_damageFuncCoefTC2(isoTC)*(pm_globalMeanTemperatureZeroed1900(tall)-pm_globalMeanTemperatureZeroed1900("2000"));

display pm_damageMarginal;
*** EOF ./modules/50_damages/TC/postsolve.gms
