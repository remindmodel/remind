*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/ACCREU/declarations.gms

scalars
s50_vsl 	"value of statistical life coefficient"	/117.59/;

parameters
p50_damageFuncCoef0(all_regi)			"damage function coefficient, constant"
p50_damageFuncCoef1(all_regi)			"damage function coefficient, linear in temperature"
p50_damageFuncCoef2(all_regi) 			"damage function coefficient, quadratic in temperture"
pm_damage(tall,all_regi)			"damage factor for general use"
pm_nonSLRdamageMarginal(tall,all_regi)		"marginal damage"
p50_nonSLRdamage(tall,all_regi)			"damage factor"

p50_SLRcoef0(all_regi)				"SLR damage function coefficient"
p50_SLRcoef1(all_regi)				"SLR damage function coefficient"
p50_SLRcoef2(all_regi)				"SLR damage function coefficient"
p50_SLRdamage(tall,all_regi)			"SLR damage factor"
pm_SLRdamageMarginal(tall,all_regi)		"SLR marginal damage"
pm_damageNonSLR(tall,all_regi)			"non-SLR damage"
pm_damageSLR(tall,all_regi)			"SLR damage"

p50_laborBenefitCoef0(all_regi)			"damage function coefficient, constant"
p50_laborBenefitCoef1(all_regi)			"damage function coefficient, linear in temperature"
p50_laborBenefitCoef2(all_regi) 			"damage function coefficient, quadratic in temperture"
p50_laborBenefit(tall,all_regi)			"beneficial impact of climate on labor"
pm_laborBenefit(tall,all_regi)			"beneficial impact of climate on labor, rebased"
pm_laborBenefitMarginal(tall,all_regi)		"marginal beneficial impact of climate on labor"

p50_mortalityHeatCoef0(all_regi)		"damage function coefficient, heat-related mortality, constant"
p50_mortalityHeatCoef1(all_regi)		"damage function coefficient, heat-related mortality, linear"
p50_mortalityHeatCoef2(all_regi)		"damage function coefficient, heat-related mortality, quadratic"
p50_mortalityColdCoef0(all_regi)		"damage function coefficient, cold-related mortality, constant"
p50_mortalityColdCoef1(all_regi)		"damage function coefficient, cold-related mortality, linear"
p50_mortalityColdCoef2(all_regi)		"damage function coefficient, cold-related mortality, quadratic"
p50_mortality(tall,all_regi)			"mortality in % of population"
pm_mortalityDamage(ttot,all_regi)		"mortality damage in $ to be applied to consumption"
p50_mortalityMarginal(tall,all_regi)		"mortality damage in $ to be applied to consumption"
pm_mortalityDamageMarginal(tall,all_regi)		"mortality damage in $ to be applied to consumption"
;

positive variable
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;


*** EOF ./modules/50_damages/ACCREU/declarations.gms
