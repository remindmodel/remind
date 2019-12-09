*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/26_agCosts/costs/datainput.gms
*FP* read agricultural costs (all except bioenergy) from MAgPIE

pm_NXagr(tall,all_regi) = 0;

*** Read total landuse cost (including bioenergy and MAC cost)
parameter p26_totLUcostLookup(tall,all_regi,all_LU_emi_scen,all_rcp_scen)  "regional total landuse cost"
/
$ondelim
$include "./modules/26_agCosts/costs/input/p26_totLUcostLookup.cs4r"
$offdelim
/
;

*DK* In coupled runs overwrite landuse costs from look-up table with actual MAgPIE values.
$if %cm_MAgPIE_coupling% == "on"  table p26_totLUcost_coupling(tall,all_regi)  "total landuse cost from MAgPIE"
$if %cm_MAgPIE_coupling% == "on"  $ondelim
$if %cm_MAgPIE_coupling% == "on"  $include "./modules/26_agCosts/costs/input/p26_totLUcost_coupling.csv";
$if %cm_MAgPIE_coupling% == "on"  $offdelim
$if %cm_MAgPIE_coupling% == "on"  ;

*** Total land use costs including MAC costs (either from look-up table for standalone runs or from MAgPIE in coupled runs)
$if %cm_MAgPIE_coupling% == "off" p26_totLUcosts_withMAC(ttot,regi) = p26_totLUcostLookup(ttot,regi,"%cm_LU_emi_scen%","%cm_rcp_scen%");
$if %cm_MAgPIE_coupling% == "on"  p26_totLUcosts_withMAC(ttot,regi) = p26_totLUcost_coupling(ttot,regi);

*** Land use emissions MAC cost from MAgPIE
*** In standalone runs LU MAC costs are calcualted endogenously in REMIND AND they already included in the exogenous total landuse costs (p26_totLUcostLookup). 
*** Therefore, substract the exact same LU MAC costs again that are already included in the exogenous total landuse costs.
parameter p26_macCostLuLookup(tall,all_regi,all_LU_emi_scen,all_rcp_scen)  "land use emissions MAC cost from MAgPIE"
/
$ondelim
$include "./modules/26_agCosts/costs/input/p26_macCostLuLookup.cs4r"
$offdelim
/
;

*** MAC costs (either from look-up table for standalone runs or zero in coupled runs because MAgPIE's total costs already include MAC costs)
$if %cm_MAgPIE_coupling% == "off" p26_macCostLu(ttot,regi) = p26_macCostLuLookup(ttot,regi,"%cm_LU_emi_scen%","%cm_rcp_scen%");
$if %cm_MAgPIE_coupling% == "on"  p26_macCostLu(ttot,regi) = 0;

*** EOF ./modules/26_agCosts/costs/datainput.gms
