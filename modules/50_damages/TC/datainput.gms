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

parameter f50_TCconst(iso,all_TCpers,all_TCspec)	"damage parameter for TC, constant"
/
$ondelim
$include "./modules/50_damages/TC/input/f50_TC_df_const.cs4r"
$offdelim
/
;

parameter f50_TCtasK(iso,all_TCpers,all_TCspec)	"damage parameter for TC, linear with temperature"
/
$ondelim
$include "./modules/50_damages/TC/input/f50_TC_df_tasK.cs4r"
$offdelim
/
;

p50_damageFuncCoefTC0(iso) = f50_TCconst(iso,"%cm_TCpers%","%cm_TCspec%")/100;
p50_damageFuncCoefTC1(iso) = f50_TCtasK(iso,"%cm_TCpers%","%cm_TCspec%")/100;

display p50_damageFuncCoefTC0;

*initialize
pm_damage(tall,regi) = 1;

*read in GDP to calculate GDP fraction of countries in a region
table f50_countryGDP(tall,iso,all_GDPscen)	"ratio of country to regional GDP"
$ondelim
$include "./modules/50_damages/TC/input/f50_gdp.cs3r"
$offdelim
;

*calculate country GDP fraction of regional GDP for SSP2EU scenario
pm_GDPfrac(tall,iso)=f50_countryGDP(tall,iso,"gdp_SSP2EU")/sum(regi2iso(regi,iso),pm_gdp(tall,regi));

display pm_GDPfrac;

pm_GDPfrac(tall,iso)$(tall.val ge 2150) = pm_GDPfrac("2150",iso);


*** EOF ./modules/50_damages/TC/datainput.gms
