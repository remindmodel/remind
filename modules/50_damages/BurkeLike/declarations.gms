*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/BurkeLike/declarations.gms
parameters
pm_damage(tall,all_regi)                             "damage factor (reduces GDP)"
pm_damageGrowthRate(tall,all_regi)                   "damage function for growth rate of GDP"
pm_damageMarginal(tall,all_regi)                     "damage function derivative"
p50_damageFuncCoef1     "coef1 of damamge function",
p50_damageFuncCoef2     "coef2 of damamge function"
;

positive variable
vm_damageFactor(ttot,all_regi)      "damage factor reducing GDP"
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;
*** EOF ./modules/50_damages/BurkeLike/declarations.gms
