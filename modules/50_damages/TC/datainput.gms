*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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

parameter f50_TCconst(iso,all_TCspec)	"damage parameter for TC, constant"
/
$ondelim
$include "./modules/50_damages/TC/input/f50_TC_df_const.cs4r"
$offdelim
/
;

parameter f50_TCtasK(iso,all_TCspec)	"damage parameter for TC, linear with temperature"
/
$ondelim
$include "./modules/50_damages/TC/input/f50_TC_df_tasK.cs4r"
$offdelim
/
;

p50_damageFuncCoefTC0(iso) = f50_TCconst(iso,"%cm_TCspec%");
p50_damageFuncCoefTC1(iso) = f50_TCtasK(iso,"%cm_TCspec%");

display p50_damageFuncCoefTC0;

*** initialize
pm_damage(tall,regi) = 1;

*** read in GDP to calculate GDP fraction of countries in a region and convert to MER
table f50_countryGDP(tall,iso,all_GDPscen)	"ratio of country to regional GDP"
$ondelim
$include "./modules/50_damages/TC/input/f50_gdp.cs3r"
$offdelim
;

*** calculate and interpolate country GDP fraction of regional GDP for SSP2 scenario, country GDP is in PPP, regional GDP in trl MER!
pm_GDPfrac(tall,iso)=f50_countryGDP(tall,iso,"gdp_SSP2")/1000000/sum(regi2iso(regi,iso),pm_gdp(tall,regi)/pm_shPPPMER(regi));

loop(ttot$(ttot.val ge 2005),
	loop(tall$(pm_tall_2_ttot(tall,ttot)),
		pm_GDPfrac(tall,iso) = 
			(1-pm_interpolWeight_ttot_tall(tall))*pm_GDPfrac(ttot,iso)
			+ pm_interpolWeight_ttot_tall(tall)*pm_GDPfrac(ttot+1,iso);
));

display pm_GDPfrac;

pm_GDPfrac(tall,iso)$(tall.val ge 2150) = pm_GDPfrac("2150",iso);


*** EOF ./modules/50_damages/TC/datainput.gms
