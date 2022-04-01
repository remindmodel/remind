*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/TC/postsolve.gms

p50_damageGrowthRate(tall,iso) = 0;
*p50_damageGrowthRate(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) = p50_damageFuncCoefTC0(isoTC)+ p50_damageFuncCoefTC1(isoTC) * pm_globalMeanTemperatureZeroed1900(tall) + p50_damageFuncCoefTC2(isoTC) * pm_globalMeanTemperatureZeroed1900(tall)**2; 
p50_damageGrowthRate(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) = p50_damageFuncCoefTC1(isoTC) * (pm_globalMeanTemperatureZeroed1900(tall)-pm_globalMeanTemperatureZeroed1900("2000")) + p50_damageFuncCoefTC2(isoTC) * (pm_globalMeanTemperatureZeroed1900(tall)**2-pm_globalMeanTemperatureZeroed1900("2000")**2); 

p50_damageGrowthRate(tall,iso)$(tall.val gt 2150) = 0;

display p50_damageGrowthRate;

p50_damage(tall,iso) = 1;
p50_damage(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) = 
   prod(tall2$(tall2.val gt 2005 AND tall2.val le tall.val),
	(1+p50_damageGrowthRate(tall2,isoTC))
);


display pm_globalMeanTemperatureZeroed1900,p50_damage;

*p50_damageAllIso(tall,isoTC) = p50_damage(tall,isoTC);

*regional damage
pm_damage(tall,regi)$(tall.val ge 2000 and tall.val le 2300) = 
	sum(regi2iso(regi,iso),p50_damage(tall,iso)*p50_GDPfrac(tall,iso));

*gross GDP on country level
pm_GDPGrossIso(tall,iso)=sum(regi2iso(regi,iso),pm_GDPGross(tall,regi))*p50_GDPfrac(tall,iso);

* update the country fraction
*p50_GDPfracTC(tall,isoTC)$regi2isoTC(regi,isoTC) = p50_damage(tall,isoTC)*p50_GDPfracTC(tall,isoTC)/pm_damage(tall,regi);
*p50_GDPfrac(tall,iso)$(tall.val ge 2000 and tall.val le 2300) = p50_damage(tall,iso)*p50_GDPfrac(tall,iso)/sum(regi2iso(regi,iso),pm_damage(tall,regi));
p50_test(tall,iso)$(tall.val ge 2005 and tall.val le 2100) = sum(regi2iso(regi,iso),pm_damage(tall,regi));

display pm_damage,p50_GDPfrac,p50_test;

* derivative of damage function w.r.t. temperature (used in 51_internalizeDamages)
pm_damageMarginal(tall,iso)=0;
pm_damageMarginal(tall,isoTC)$(tall.val ge 2000 and tall.val le 2300) =  p50_damageFuncCoefTC1(isoTC)+2*p50_damageFuncCoefTC2(isoTC)*(pm_globalMeanTemperatureZeroed1900(tall)-pm_globalMeanTemperatureZeroed1900("2000"));

display pm_damageMarginal;
*** EOF ./modules/50_damages/TC/postsolve.gms
