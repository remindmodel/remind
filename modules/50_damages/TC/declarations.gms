*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/TC/declarations.gms

parameters
p50_damageFuncCoef1
p50_damageFuncCoef2
p50_damageFuncCoefTC0(isoTC)
p50_damageFuncCoefTC1(isoTC)			"damage function coefficient, linear in temperature"
p50_damageFuncCoefTC2(isoTC) 			"damage function coefficient, quadratic in temperture"
pm_damage(tall,all_regi)                             "damage factor (reduces GDP)"
p50_damage(tall,iso)                             "damage factor (reduces GDP)"
*p50_damageAllIso(tall,iso)                             "damage factor (reduces GDP)"
p50_damageGrowthRate(tall,iso)                   "damage function for growth rate of GDP"
pm_damageMarginal(tall,iso)                     "damage function derivative"
p50_GDPfrac(tall,iso)				"fraction of GDP of a country in its region"
pm_GDPGrossIso(tall,iso)
p50_test(tall,iso)
;

positive variable
vm_damageFactor(ttot,all_regi)      "damage factor reducing GDP"
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;

*** EOF ./modules/50_damages/TC/declarations.gms
