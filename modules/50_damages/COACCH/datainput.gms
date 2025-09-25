*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF .modules/50_damages/COACCH/datainput.gms

p50_damageFuncCoef0(regi) = 1;
p50_damageFuncCoef1(regi) = 0;
p50_damageFuncCoef2(regi) = 0;

parameter p50_damageCoefs(dam_adapt50,all_regi,dam_coef50,dam_CI50)	"coefficients for damage function" 
/
$ondelim
$include "./modules/50_damages/COACCH/input/REMIND_coefs.inc"
$offdelim
/
;

p50_damageFuncCoef1(regi)=p50_damageCoefs("%cm_damage_COACCH_adaptSpec%",regi,"b1","%cm_damage_COACCH_CIspec%");
p50_damageFuncCoef2(regi)=p50_damageCoefs("%cm_damage_COACCH_adaptSpec%",regi,"b2","%cm_damage_COACCH_CIspec%");

*initialize
pm_damage(tall,regi) = 1;
p50_damage(tall,regi) = 1;

*** EOF .modules/50_damages/COACCH/datainput.gms
