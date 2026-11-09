*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF .modules/50_damages/ACCREU/datainput.gms

p50_damageFuncCoef0(regi) = 0;
p50_damageFuncCoef1(regi) = 0;
p50_damageFuncCoef2(regi) = 0;

*non-SLR damage
parameter p50_damageCoefs(all_regi,dam_coef_50)	"coefficients for damage function, non-SLR" 
/
$ondelim
$include "./modules/50_damages/ACCREU/input/nonSLR_Kaj_REMIND_damage_coefs.inc"
$offdelim
/
;

p50_damageFuncCoef0(regi)=p50_damageCoefs(regi,"a");
p50_damageFuncCoef1(regi)=p50_damageCoefs(regi,"b1");
p50_damageFuncCoef2(regi)=p50_damageCoefs(regi,"b2");

*labor benefit
p50_laborBenefitCoef0(regi)=0;
p50_laborBenefitCoef1(regi)=0;
p50_laborBenefitCoef2(regi)=0;

parameter p50_laborBenefitCoefs(all_regi,dam_coef_50)	"coefficients for labor benefits in cold regions"
/
$ondelim
$include "./modules/50_damages/ACCREU/input/labor_Kaj_REMIND_benefits_coefs.inc"
$offdelim
/
;

p50_laborBenefitCoef0(regi)=p50_laborBenefitCoefs(regi,"a");
p50_laborBenefitCoef1(regi)=p50_laborBenefitCoefs(regi,"b1");

*SLR damage
parameter p50_damageCoefs_SLR(all_regi,dam_coef_50)	"coefficients for damage function, SLR" 
/
$ondelim
$include "./modules/50_damages/ACCREU/input/SLR_Kaj_REMIND_damage_coefs.inc"
$offdelim
/
;

p50_SLRcoef0(regi) = 1;
p50_SLRcoef1(regi) = 0;
p50_SLRcoef2(regi) = 0;

p50_SLRcoef0(regi)=p50_damageCoefs_SLR(regi,"a");
p50_SLRcoef1(regi)=p50_damageCoefs_SLR(regi,"b1");
p50_SLRcoef2(regi)=p50_damageCoefs_SLR(regi,"b2");

*mortality parameters
p50_mortalityHeatCoef0(regi) = 0;
p50_mortalityHeatCoef1(regi) = 0;
p50_mortalityHeatCoef2(regi) = 0;
p50_mortalityColdCoef0(regi) = 0;
p50_mortalityColdCoef1(regi) = 0;
p50_mortalityColdCoef2(regi) = 0;

parameter p50_mortalityColdCoefs(all_regi,dam_coef_50)	"coefficients for mortality damage function" 
/
$ondelim
$include "./modules/50_damages/ACCREU/input/Kaj_REMIND_mortality_cold_coefs_lin.inc"
$offdelim
/
;
parameter p50_mortalityHeatCoefs(all_regi,dam_coef_50)	"coefficients for mortality damage function" 
/
$ondelim
$include "./modules/50_damages/ACCREU/input/Kaj_REMIND_mortality_heat_coefs_quad.inc"
$offdelim
/
;

p50_mortalityColdCoef0(regi)=p50_mortalityColdCoefs(regi,"a");
p50_mortalityColdCoef1(regi)=p50_mortalityColdCoefs(regi,"b1");
p50_mortalityHeatCoef0(regi)=p50_mortalityHeatCoefs(regi,"a");
p50_mortalityHeatCoef1(regi)=p50_mortalityHeatCoefs(regi,"b1");

***
p50_SLRdamage(tall,regi) = 0;
pm_damageNonSLR(tall,regi) = 0;
pm_damageSLR(tall,regi) = 0;
pm_laborBenefit(tall,regi) = 0;

*initialize
pm_damage(tall,regi) = 1;
p50_nonSLRdamage(tall,regi) = 1;
pm_mortalityDamage(ttot,regi) = 0;
pm_mortalityDamageMarginal(ttot,regi) = 0;

*** EOF .modules/50_damages/ACCREU/datainput.gms
