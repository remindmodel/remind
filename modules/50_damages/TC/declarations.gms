*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/TC/declarations.gms

parameters
p50_damageFuncCoef1			"damage function coefficient"
p50_damageFuncCoef2			"damage function coefficient"
p50_damageFuncCoefTC0(isoTC)		"damage function coefficient for TC, constant"
p50_damageFuncCoefTC1(isoTC)			"damage function coefficient for TC, linear in temperature"
p50_damageFuncCoefTC2(isoTC) 			"damage function coefficient for TC, quadratic in temperture"
pm_damage(tall,all_regi)                             "damage factor (reduces GDP)"
pm_damageIso(tall,iso)                             "damage factor (reduces GDP)"
*p50_damageAllIso(tall,iso)                             "damage factor (reduces GDP)"
pm_damageGrowthRateIso(tall,iso)                   "damage function for growth rate of GDP"
pm_damageMarginal(tall,iso)                     "damage function derivative"
pm_GDPfrac(tall,iso)				"fraction of GDP of a country in its region"
pm_GDPGrossIso(tall,iso)	"gross GDP on country level"
p50_test(tall,iso)		"to check regional sum of GDP"
;

positive variable
vm_damageFactor(ttot,all_regi)      "damage factor reducing GDP"
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;

*** EOF ./modules/50_damages/TC/declarations.gms
