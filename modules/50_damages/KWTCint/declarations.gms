*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KWTCint/declarations.gms

parameters
pm_damage(tall,all_regi)                             "damage factor (reduces GDP)"
pm_damageGrowthRate(tall,all_regi)                   "damage function for growth rate of GDP"
pm_damageMarginalT(tall,all_regi)                    "damage function derivative for KW"
pm_damageMarginalTm1(tall,all_regi)                  "damage function derivative for KW"
pm_damageMarginalTm2(tall,all_regi)                  "damage function derivative for KW"
p50_damageFuncCoefa1     "coef1 of damamge function",
p50_damageFuncCoefa2     "coef2 of damamge function"
p50_damageFuncCoefb1     "coef1 of damamge function",
p50_damageFuncCoefb2     "coef2 of damamge function"
p50_damageFuncCoefTC0(isoTC)	"coef0 for tropical cyclone damage function"
p50_damageFuncCoefTC1(isoTC)	"coef1 for tropical cyclone damage function"
pm_damageProd(tall,all_regi)	"damage from aggregate damage function"
pm_damageTC(tall,iso)		"tropical cyclone damages"
pm_damageGrowthRateTC(tall,iso)	"growth rate damage from tropical cyclones"
pm_GDPfrac(tall,iso)			"ratio of country to region GDP"
pm_damageMarginalTC(tall,iso)		"marginal damage of tropical cyclones"
pm_GDPGrossIso(tall,iso)		"gross GDP on country level"
;

positive variable
vm_damageFactor(ttot,all_regi)      "damage factor reducing GDP"
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;
*** EOF ./modules/50_damages/KWTCint/declarations.gms
