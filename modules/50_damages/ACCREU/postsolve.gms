*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF .modules/50_damages/ACCREU/postsolve.gms

*** the ACCREU direct damages are with respect to preindustrial temperatures and 2020 SLR

p50_nonSLRdamage(tall,regi)$(tall.val ge 2010 and tall.val le 2300) = p50_damageFuncCoef0(regi)+p50_damageFuncCoef1(regi)*pm_globalMeanTemperature(tall)+p50_damageFuncCoef2(regi)*(pm_globalMeanTemperature(tall))**2;

*** derivative of damage function w.r.t. teperature (used in 51_internalizeDamages)
pm_nonSLRdamageMarginal(tall,regi)$(tall.val ge 2000 and tall.val le 2300) =     
  p50_damageFuncCoef1(regi)  + 2 * p50_damageFuncCoef2(regi) * pm_globalMeanTemperature(tall);

*** labor benefits are calculated separately
p50_laborBenefit(tall,regi)$(tall.val ge 2010 and tall.val le 2300) = p50_laborBenefitCoef0(regi)+p50_laborBenefitCoef1(regi)*pm_globalMeanTemperature(tall)+p50_laborBenefitCoef2(regi)*(pm_globalMeanTemperature(tall))**2;
pm_laborBenefitMarginal(tall,regi)$(tall.val ge 2000 and tall.val le 2300) =
  p50_laborBenefitCoef1(regi)+p50_laborBenefitCoef2(regi)*2*pm_globalMeanTemperature(tall);

display p50_nonSLRdamage,pm_nonSLRdamageMarginal,pm_laborBenefitMarginal;

*** SLR impacts
$ifthen.cm_SLR %cm_SLR% == "on"
*** SLR damage function is defined for SLR relative to 2020
p50_SLRdamage(tall,regi)$(tall.val ge 2030 and tall.val le 2300) = 
	p50_SLRcoef0(regi)+p50_SLRcoef1(regi)*(pm_globalMeanSLR(tall)-pm_globalMeanSLR("2020"))**p50_SLRcoef2(regi);

pm_SLRdamageMarginal(tall,regi)$(tall.val ge 2030 and tall.val le 2300) = 
	p50_SLRcoef1(regi)*p50_SLRcoef2(regi)*(pm_globalMeanSLR(tall)-pm_globalMeanSLR("2020"))**(p50_SLRcoef2(regi)-1);

display p50_SLRdamage,pm_SLRdamageMarginal;
$endif.cm_SLR  

*** mortality impacts - they are always calculated but only enter the welfare equation through the parameter pm_mortalityDamage (as well as the SCC) if the switch cm_mortality is "on"
p50_mortality(tall,regi)$(tall.val ge 2020 and tall.val le 2200) = 
	(p50_mortalityHeatCoef0(regi)+p50_mortalityColdCoef0(regi)) + (p50_mortalityHeatCoef1(regi)*(pm_globalMeanTemperature(tall)-1.1)**2+p50_mortalityColdCoef1(regi)*(pm_globalMeanTemperature(tall)-1.1));
p50_mortalityMarginal(tall,regi)$(tall.val ge 2020 and tall.val le 2300) = 
	(p50_mortalityHeatCoef1(regi)*2*(pm_globalMeanTemperature(tall)-1.1)+p50_mortalityColdCoef1(regi));

$ifthen.cm_mortality %cm_mortality% == "on"
pm_mortalityDamage(ttot,regi)$(ttot.val ge 2030) =
	s50_vsl*pm_GDPGross(ttot,regi)/pm_pop(ttot,regi)*pm_pop(ttot,regi)*(p50_mortality(ttot,regi)-p50_mortality("2025",regi));
pm_mortalityDamageMarginal(tall,regi)$(tall.val ge 2030 and tall.val le 2300) =
	s50_vsl*pm_GDPGross(tall,regi)*p50_mortalityMarginal(tall,regi);
display pm_mortalityDamage;

$endif.cm_mortality

pm_damageNonSLR(tall,regi)$(tall.val ge 2030 and tall.val le 2300) = 
  p50_nonSLRdamage(tall,regi)-p50_nonSLRdamage("2025",regi);

pm_damageSLR(tall,regi)$(tall.val ge 2030 and tall.val le 2300) = 
  p50_SLRdamage(tall,regi)-p50_SLRdamage("2025",regi);

pm_laborBenefit(tall,regi)$(tall.val ge 2030 and tall.val le 2300) = 
  p50_laborBenefit(tall,regi)-p50_laborBenefit("2025",regi);

pm_damage(tall,regi) = pm_damageNonSLR(tall,regi)+pm_damageSLR(tall,regi);

display pm_damage,pm_laborBenefit;

*** EOF .modules/50_damages/ACCREU/postsolve.gms
