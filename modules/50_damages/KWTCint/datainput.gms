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
table f50_TCconst(isoTC,all_SSPscen,all_TCpers,all_TCspec)	"damage parameter constant"
$ondelim
$include "./modules/50_damages/KWTCint/input/TC_df_parameters_const.csv"
$offdelim
;

table f50_TCtasK(isoTC,all_SSPscen,all_TCpers,all_TCspec)	"damage parameter, linear with temperature"
$ondelim
$include "./modules/50_damages/KWTCint/input/TC_df_parameters_tasK.csv"
$offdelim
;

p50_damageFuncCoefTC0(isoTC) = f50_TCconst(isoTC,"%cm_TCssp%","%cm_TCpers%","%cm_TCspec%")/100;
p50_damageFuncCoefTC1(isoTC) = f50_TCtasK(isoTC,"%cm_TCssp%","%cm_TCpers%","%cm_TCspec%")/100;

* initialize
pm_damage(tall,regi) = 1;
pm_damageTC(tall,iso) = 1;
pm_damageProd(tall,regi) = 1;
pm_damageGrowthRate(tall,regi)         = 0;
pm_damageMarginalT(tall,regi)           = 0;
pm_damageMarginalTm1(tall,regi)           = 0;
pm_damageMarginalTm2(tall,regi)           = 0;

table f50_countryGDPfrac(tall,iso,all_GDPscen)	"ratio country to regional GDP"
$ondelim
$include "./modules/50_damages/KWTCint/input/gdp_countryFrac_ann.csv"
$offdelim
;
pm_GDPfrac(tall,iso) = f50_countryGDPfrac(tall,iso,"gdp_SSP2EU");
pm_GDPfrac(tall,iso)$(tall.val ge 2150) = pm_GDPfrac("2150",iso);

*** EOF ./modules/50_damages/KWTCint/datainput.gms
