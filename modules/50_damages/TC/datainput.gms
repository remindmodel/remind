*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/TC/datainput.gms

p50_damageFuncCoefTC0(isoTC) = 0;
p50_damageFuncCoefTC1(isoTC) = 0;
p50_damageFuncCoefTC2(isoTC) = 0;

*** load TC damage parameter data

table f50_TCconst(isoTC,all_SSPscen,all_TCpers,all_TCspec)
$ondelim
$include "./modules/50_damages/TC/input/TC_df_parameters_const.csv"
$offdelim
;

table f50_TCtasK(isoTC,all_SSPscen,all_TCpers,all_TCspec)
$ondelim
$include "./modules/50_damages/TC/input/TC_df_parameters_tasK.csv"
$offdelim
;

p50_damageFuncCoefTC0(isoTC) = f50_TCconst(isoTC,"%cm_TCssp%","%cm_TCpers%","%cm_TCspec%")/100;
p50_damageFuncCoefTC1(isoTC) = f50_TCtasK(isoTC,"%cm_TCssp%","%cm_TCpers%","%cm_TCspec%")/100;
*p50_damageFuncCoefTC0(isoTC) = f50_TCconst(isoTC,"SSP2","0","estimates_mean")/100;
*p50_damageFuncCoefTC1(isoTC) = f50_TCtasK(isoTC,"SSP2","0","estimates_mean")/100;
*p50_damageFuncCoefTC0(isoTC) = f50_TCconst(isoTC,"SSP2","8","estimates_mean")/100;
*p50_damageFuncCoefTC1(isoTC) = f50_TCtasK(isoTC,"SSP2","8","estimates_mean")/100;
*p50_damageFuncCoefTC0(isoTC) = f50_TCconst(isoTC,"SSP2","8","estimates_95")/100;
*p50_damageFuncCoefTC1(isoTC) = f50_TCtasK(isoTC,"SSP2","8","estimates_95")/100;
*p50_damageFuncCoefTC0(isoTC) = f50_TCconst(isoTC,"SSP2","8","estimates_05")/100;
*p50_damageFuncCoefTC1(isoTC) = f50_TCtasK(isoTC,"SSP2","8","estimates_05")/100;

display p50_damageFuncCoefTC0;

*initialize
pm_damage(tall,regi) = 1;
*p50_damage(tall,isoTC) = 1;
*p50_damageAllIso(tall,iso) = 1;

* calculate initial GDP ratio for countries in region --> actually just read this in!
* load PPP-MER conversion factor data for countries
*parameter pm_shPPPMERcountry(iso)
*/
*$ondelim
*$include "./modules/50_damages/TC/input/..."
*$offdelim
*/
*;

* load country GDP data
*table f50_countryGDP(tall,iso,all_GDPscen)
*$ondelim
*$include "./modules/50_damages/TC/input/gdp_Inga.cs3r"
*$offdelim
*;

*p50_countryGDP(tall,iso) = f_countryGDP(tall,iso,"%cm_GDPscen%"); 
* pm_shPPPMER(iso) / 1000000; 

table f50_countryGDPfrac(tall,iso,all_GDPscen)
$ondelim
$include "./modules/50_damages/TC/input/gdp_countryFrac_ann.csv"
$offdelim
;
*p50_GDPfracTC(tall,isoTC,all_regi) = f50_countryGDPfrac(tall,iso,all_regi,"%cm_GDPscen%");
p50_GDPfrac(tall,iso) = f50_countryGDPfrac(tall,iso,"gdp_SSP2EU");
p50_GDPfrac(tall,iso)$(tall.val ge 2150) = p50_GDPfrac("2150",iso);


*** EOF ./modules/50_damages/TC/datainput.gms
