*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC2018/datainput.gms
*** CO2 tax level is calculated at a 5% exponential increase from the 2020 tax level exogenously defined until 2030, then a linear tax, plus regional convergence
pm_taxCO2eq("2020",regi) = 5;

*** convert tax value from $/t CO2eq to T$/GtC
pm_taxCO2eq("2020",regi)= pm_taxCO2eq("2020",regi) * sm_DptCO2_2_TDpGtC;

*** set ETS price in 2015 for EUR
pm_taxCO2eq("2015",regi)= 0;
pm_taxCO2eq("2015",regi)$regi_group("EUR_regi",regi)= 5 * sm_DptCO2_2_TDpGtC;

Parameter p45_factor_targetyear(ttot,all_regi,all_GDPscen) "Multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region"
  /
$ondelim
$include "./modules/45_carbonprice/NDC2018/input/p45_factor_targetyear.cs4r"
$offdelim
  /             ;

Parameter p45_2005share_target(ttot,all_regi,all_GDPscen) "2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years"
  /
$ondelim
$include "./modules/45_carbonprice/NDC2018/input/p45_2005share_target.cs4r"
$offdelim
  /             ;


Parameter p45_hist_share(tall,all_regi) "GHG emissions share of countries with quantifyable 2030 target, time dimension specifies historic record"
  /
$ondelim
$include "./modules/45_carbonprice/NDC2018/input/p45_hist_share.cs4r"
$offdelim
  /             ;
  

Parameter p45_BAU_reg_emi_wo_LU_bunkers(ttot,all_regi) "regional GHG emissions (without LU and bunkers) in BAU scenario"
  /
$ondelim
$include "./modules/45_carbonprice/NDC2018/input/p45_BAU_reg_emi_wo_LU_bunkers.cs4r"
$offdelim
  /             ;
  
Set regi_2025target(all_regi) "set of regions with predominantly 2025 GHG target"
  /
$ondelim
$include "./modules/45_carbonprice/NDC2018/input/set_regi2025.cs4r"
$offdelim
  /             ;

Set regi_2030target(all_regi) "set of regions with predominantly 2030 GHG target"
  /
$ondelim
$include "./modules/45_carbonprice/NDC2018/input/set_regi2030.cs4r"
$offdelim
  /             ;
  

*** EOF ./modules/45_carbonprice/NDC2018/datainput.gms
