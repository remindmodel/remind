*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KW_SE/postsolve.gms

* Damage function based on Kalkuhl & Wenz (2020)
* time index mapping from supplement to code:  tall = t ; tall2 = t' ; tall3 = t''

display pm_regionalTemperature;

*calculate regional temperature based on emission pathway with an emission pulse
*tirf in K/GtCO2, pulse=1GtC
p50_regionalTemperatureImp(tall,tall2,regi) = pm_regionalTemperature(tall2,regi)+pm_temperatureImpulseResponseCO2(tall2,tall)*pm_tempScaleGlob2Reg(tall2,regi)*44/12;

* annual temperature differences for easier readibility below
p50_delT(tall,regi) = 0;
p50_delT2(tall,regi) = 0;
p50_delT(tall,regi)$(tall.val ge 2005 and tall.val le 2300)=pm_regionalTemperature(tall,regi)-pm_regionalTemperature(tall-1,regi);
p50_delT2(tall,regi)$(tall.val ge 2005 and tall.val le 2300)=pm_regionalTemperature(tall-1,regi)-pm_regionalTemperature(tall-2,regi);
p50_delT("2005",regi) = 0;
p50_delT2("2006",regi) = 0;

p50_delTimp(tall,tall2,regi) = 0;
p50_delTimp2(tall,tall2,regi) = 0;
p50_delTimp(tall,tall2,regi)$(tall.val ge 2005 and tall.val le 2300)=p50_regionalTemperatureImp(tall,tall2,regi)-p50_regionalTemperatureImp(tall,tall2-1,regi);
p50_delTimp2(tall,tall2,regi)$(tall.val ge 2005 and tall.val le 2300)=p50_regionalTemperatureImp(tall,tall2-1,regi)-p50_regionalTemperatureImp(tall,tall2-2,regi);
*p50_delTimp("2005",regi) = 0;
*p50_delTimp2("2006",regi) = 0;

* for high damages - standard error
p50_se(tall,regi)$(tall.val ge 2005 and tall.val le 2300) =
	(p50_var_a1*p50_delT(tall,regi)*p50_delT(tall,regi)+p50_var_a2*p50_delT2(tall,regi)*p50_delT2(tall,regi)
	+p50_var_b1*p50_delT(tall,regi)*p50_delT(tall,regi)*pm_regionalTemperature(tall-1,regi)**2
	+ p50_var_b2*p50_delT2(tall,regi)*p50_delT2(tall,regi)*pm_regionalTemperature(tall-1,regi)**2
	+ 2*(p50_cov_a1_a2*p50_delT(tall,regi)*p50_delT2(tall,regi)
	+ p50_cov_a1_b1*p50_delT(tall,regi)*p50_delT(tall,regi)*pm_regionalTemperature(tall-1,regi)
	+ p50_cov_a1_b2*p50_delT(tall,regi)*p50_delT2(tall,regi)*pm_regionalTemperature(tall-1,regi)
	+ p50_cov_a2_b1*p50_delT(tall,regi)*p50_delT2(tall,regi)*pm_regionalTemperature(tall-1,regi)
	+ p50_cov_a2_b2*p50_delT2(tall,regi)*p50_delT2(tall,regi)*pm_regionalTemperature(tall-1,regi)
	+ p50_cov_b1_b2*p50_delT(tall,regi)*p50_delT2(tall,regi)*pm_regionalTemperature(tall-1,regi)**2
	)
);
p50_seImp(tall,tall2,regi)$(tall.val ge 2005 and tall.val le 2300 and tall2.val ge 2005 and tall2.val le 2300) =
	(p50_var_a1*p50_delTimp(tall,tall2,regi)*p50_delTimp(tall,tall2,regi)+p50_var_a2*p50_delTimp2(tall,tall2,regi)*p50_delTimp2(tall,tall2,regi)
	+p50_var_b1*p50_delTimp(tall,tall2,regi)*p50_delTimp(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)**2
	+ p50_var_b2*p50_delTimp2(tall,tall2,regi)*p50_delTimp2(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)**2
	+ 2*(p50_cov_a1_a2*p50_delTimp(tall,tall2,regi)*p50_delTimp2(tall,tall2,regi)
	+ p50_cov_a1_b1*p50_delTimp(tall,tall2,regi)*p50_delTimp(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)
	+ p50_cov_a1_b2*p50_delTimp(tall,tall2,regi)*p50_delTimp2(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)
	+ p50_cov_a2_b1*p50_delTimp(tall,tall2,regi)*p50_delTimp2(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)
	+ p50_cov_a2_b2*p50_delTimp2(tall,tall2,regi)*p50_delTimp2(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)
	+ p50_cov_b1_b2*p50_delTimp(tall,tall2,regi)*p50_delTimp2(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)**2
	)
);

display p50_se;

*calculate growth rate damages
pm_damageGrowthRate(tall,regi) = 0;
p50_damageGrowthRateImp(tall,tall2,regi) = 0;

pm_damageGrowthRate(tall,regi)$(tall.val ge 2005 and tall.val le 2300) =
(    p50_damageFuncCoefa1 * p50_delT(tall,regi)
  + p50_damageFuncCoefa2 * p50_delT2(tall,regi)
  + p50_damageFuncCoefb1 * p50_delT(tall,regi)*pm_regionalTemperature(tall-1,regi)
  + p50_damageFuncCoefb2 * p50_delT2(tall,regi)*pm_regionalTemperature(tall-1,regi)
  - p50_se(tall,regi)**0.5*cm_damage_KWSE
);

p50_damageGrowthRateImp(tall,tall2,regi)$(tall.val ge 2005 and tall.val le 2300 and tall2.val ge tall.val and tall2.val le 2300) =
(   p50_damageFuncCoefa1 * p50_delTimp(tall,tall2,regi)
  + p50_damageFuncCoefa2 * p50_delTimp2(tall,tall2,regi)
  + p50_damageFuncCoefb1 * p50_delTimp(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)
  + p50_damageFuncCoefb2 * p50_delTimp2(tall,tall2,regi)*p50_regionalTemperatureImp(tall,tall2-1,regi)
  - p50_seImp(tall,tall2,regi)**0.5*cm_damage_KWSE
);

*no damages before 2020
pm_damageGrowthRate(tall,regi)$(tall.val le 2020) = 0;
p50_damageGrowthRateImp(tall,tall2,regi)$(tall.val le 2020) = 0;

*no growth rate damages after 2150 to prevent extreme runaway damages
pm_damageGrowthRate(tall,regi)$(tall.val gt 2150) = 0;
p50_damageGrowthRateImp(tall,tall2,regi)$(tall.val gt 2150) = 0;

*damage function. match observed 2020 GDP, that is, assume that no climate damages unitl then.
*damage factor for budget equation
pm_damage(tall,regi)$(tall.val ge 2020 and tall.val le 2300) =
    prod(tall2$(tall2.val ge 2020 AND tall2.val le tall.val),
    (1 + pm_damageGrowthRate(tall2,regi))
    )
;
*damage used in SCC calculation
pm_damageScc(tall,tall2,regi)$(tall.val ge 2020 and tall.val le 2300 and tall2.val ge 2020 and tall2.val le 2300) =
    prod(tall3$(tall3.val gt tall.val AND tall3.val le tall2.val),
    (1 + pm_damageGrowthRate(tall3,regi))
    )
;
*damage with emission pulse for SCC calculation
pm_damageImp(tall,tall2,regi)$(tall.val ge 2020 and tall.val le 2300 and tall2.val ge 2020 and tall2.val le 2300) =
    prod(tall3$(tall3.val gt tall.val AND tall3.val le tall2.val),
    (1 + p50_damageGrowthRateImp(tall,tall3,regi))
    )
;


display pm_damage;

*** EOF ./modules/50_damages/KW_SE/postsolve.gms
