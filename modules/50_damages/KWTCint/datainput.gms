*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KWTCint/datainput.gms

* satisfy dependencies
$ifi not %downscaleTemperature% == 'CMIP5' abort "module damages=KWTCint requires downscaleTemperature=CMIP5";

** damage specification
    

*default specification from Kalkuhl & Wenz 2020:
p50_damageFuncCoefa1 =  0.00641;
p50_damageFuncCoefa2 =  0.00345;
p50_damageFuncCoefb1 = -0.00109;
p50_damageFuncCoefb2 = -0.000718;

* TC damage coefficients from Krichene et al. 2022 
 
p50_damageFuncCoefTC0(isoTC) = 0;
p50_damageFuncCoefTC1(isoTC) = 0;

*** load TC damage parameter data
parameter f50_TCconst(iso,all_TCpers,all_TCspec)	"damage parameter constant"
/
$ondelim
$include "./modules/50_damages/KWTCint/input/f50_TC_df_const.cs4r"
$offdelim
/
;

parameter f50_TCtasK(iso,all_TCpers,all_TCspec)	"damage parameter, linear with temperature"
/
$ondelim
$include "./modules/50_damages/KWTCint/input/f50_TC_df_tasK.cs4r"
$offdelim
/
;

p50_damageFuncCoefTC0(iso) = f50_TCconst(iso,"%cm_TCpers%","%cm_TCspec%")/100;
p50_damageFuncCoefTC1(iso) = f50_TCtasK(iso,"%cm_TCpers%","%cm_TCspec%")/100;

* initialize
pm_damage(tall,regi) = 1;
pm_damageTC(tall,iso) = 1;
pm_damageProd(tall,regi) = 1;
pm_damageGrowthRate(tall,regi)         = 0;
pm_damageMarginalT(tall,regi)           = 0;
pm_damageMarginalTm1(tall,regi)           = 0;
pm_damageMarginalTm2(tall,regi)           = 0;

*read in GDP to calculate fraction of countries in a region
table f50_countryGDP(tall,iso,all_GDPscen)	"ratio country to regional GDP"
$ondelim
$include "./modules/50_damages/KWTCint/input/f50_gdp.cs3r"
$offdelim
;
pm_GDPfrac(ttot,iso)$(ttot.val ge 2005) = f50_countryGDP(ttot,iso,"gdp_SSP2EU")/1000000/sum(regi2iso(regi,iso),pm_gdp(ttot,regi)/pm_shPPPMER(regi));
loop(ttot$(ttot.val ge 2005),
	loop(tall$(pm_tall_2_ttot(tall,ttot)),
		pm_GDPfrac(tall,iso) = 
			(1-pm_interpolWeight_ttot_tall(tall))*pm_GDPfrac(ttot,iso)
			+ pm_interpolWeight_ttot_tall(tall)*pm_GDPfrac(ttot+1,iso);
));
display pm_GDPfrac;
pm_GDPfrac(tall,iso)$(tall.val ge 2150) = pm_GDPfrac("2150",iso);

*** EOF ./modules/50_damages/KWTCint/datainput.gms
