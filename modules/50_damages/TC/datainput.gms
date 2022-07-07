*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/TC/datainput.gms

p50_damageFuncCoefTC0(isoTC) = 0;
p50_damageFuncCoefTC1(isoTC) = 0;
p50_damageFuncCoefTC2(isoTC) = 0;

*** load TC damage parameter data (Krichene et al. 2022)

table f50_TCconst(isoTC,all_SSPscen,all_TCpers,all_TCspec)	"damage parameter for TC, constant"
$ondelim
$include "./modules/50_damages/TC/input/TC_df_parameters_const.csv"
$offdelim
;

table f50_TCtasK(isoTC,all_SSPscen,all_TCpers,all_TCspec)	"damage parameter for TC, linear with temperature"
$ondelim
$include "./modules/50_damages/TC/input/TC_df_parameters_tasK.csv"
$offdelim
;

p50_damageFuncCoefTC0(isoTC) = f50_TCconst(isoTC,"%cm_TCssp%","%cm_TCpers%","%cm_TCspec%")/100;
p50_damageFuncCoefTC1(isoTC) = f50_TCtasK(isoTC,"%cm_TCssp%","%cm_TCpers%","%cm_TCspec%")/100;

display p50_damageFuncCoefTC0;

*initialize
pm_damage(tall,regi) = 1;

* read in GDP fraction of countries in region 

table f50_countryGDPfrac(tall,iso,all_GDPscen)	"ratio of country to regional GDP"
$ondelim
$include "./modules/50_damages/TC/input/gdp_countryFrac_ann.csv"
$offdelim
;

pm_GDPfrac(tall,iso) = f50_countryGDPfrac(tall,iso,"gdp_SSP2EU");
pm_GDPfrac(tall,iso)$(tall.val ge 2150) = pm_GDPfrac("2150",iso);


*** EOF ./modules/50_damages/TC/datainput.gms
