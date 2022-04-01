*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KWLike/declarations.gms

parameters
pm_regionalTemperatureImp(tall,tall,all_regi)
pm_damageGrowthRateImp(tall,tall,all_regi)
p50_seImp(tall,tall,all_regi)
pm_damageImp(tall,tall,all_regi)
pm_damageScc(tall,tall,all_regi)
pm_damage(tall,all_regi)                             "damage factor (reduces GDP)"
pm_damageGrowthRate(tall,all_regi)                   "damage function for growth rate of GDP"
pm_damageMarginalT(tall,all_regi)                    "damage function derivative for KW"
pm_damageMarginalTm1(tall,all_regi)                  "damage function derivative for KW"
pm_damageMarginalTm2(tall,all_regi)                  "damage function derivative for KW"
p50_damageFuncCoefa1     "coef1 of damamge function",
p50_damageFuncCoefa2     "coef2 of damamge function"
p50_damageFuncCoefb1     "coef1 of damamge function",
p50_damageFuncCoefb2     "coef2 of damamge function"
p50_se(tall,all_regi)
p50_var_a1
p50_var_a2
p50_var_b1
p50_var_b2
p50_cov_a1_a2
p50_cov_a1_b1
p50_cov_a1_b2
p50_cov_a2_b1
p50_cov_a2_b2
p50_cov_b1_b2

p50_delT(tall,all_regi)
p50_delT2(tall,all_regi)
p50_delTimp(tall,tall,all_regi)
p50_delTimp2(tall,tall,all_regi)
;

positive variable
vm_damageFactor(ttot,all_regi)      "damage factor reducing GDP"
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;
*** EOF ./modules/50_damages/KWLike/declarations.gms
