*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KW_SE/declarations.gms

parameters
p50_regionalTemperatureImp(tall,tall,all_regi)	     "regional temperature with emission pulse"
p50_damageGrowthRateImp(tall,tall,all_regi)	     "growth rate damage with emission pulse"
p50_seImp(tall,tall,all_regi)			     "damage standard error with emission pulse"
pm_damageImp(tall,tall,all_regi)		     "damage with emission pulse"
pm_damageScc(tall,tall,all_regi)		     "damage without pulse"
pm_damage(tall,all_regi)                             "damage factor (reduces GDP)"
pm_damageGrowthRate(tall,all_regi)                   "damage function for growth rate of GDP"
pm_damageMarginalT(tall,all_regi)                    "damage function derivative for KW"
pm_damageMarginalTm1(tall,all_regi)                  "damage function derivative for KW"
pm_damageMarginalTm2(tall,all_regi)                  "damage function derivative for KW"
p50_damageFuncCoefa1     "coef1 of damamge function",
p50_damageFuncCoefa2     "coef2 of damamge function"
p50_damageFuncCoefb1     "coef1 of damamge function",
p50_damageFuncCoefb2     "coef2 of damamge function"
p50_se(tall,all_regi)    "standard error for damages"
p50_var_a1	         "variance of coef1"
p50_var_a2		 "variance of coef2"
p50_var_b1		 "variance of coefb1"
p50_var_b2		 "variance of coefb2"
p50_cov_a1_a2 		 "covariance of coefs a1, a2"
p50_cov_a1_b1		 "covariance of coefs a1, b1"
p50_cov_a1_b2		 "covariance of coefs a1, b2"
p50_cov_a2_b1		 "covariance of coefs a2, b1"
p50_cov_a2_b2		 "covariance of a2, b2"
p50_cov_b1_b2		 "covariance of b1, b2"

p50_delT(tall,all_regi)	 	"temperature difference between current and previous year"
p50_delT2(tall,all_regi)	"temperature difference between previuos year and year before that"
p50_delTimp(tall,tall,all_regi)	   "temperature difference for pathway with emission pulse"
p50_delTimp2(tall,tall,all_regi)    "temperature difference of lag years with emission pulse"
;

positive variable
vm_damageFactor(ttot,all_regi)      "damage factor reducing GDP"
vm_damageProdFactor(ttot,all_regi,all_in)      "damage factor reducing production factors"
;
*** EOF ./modules/50_damages/KW_SE/declarations.gms
