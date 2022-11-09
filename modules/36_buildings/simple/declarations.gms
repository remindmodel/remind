*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/declarations.gms

Parameters
  p36_CESMkup(ttot,all_regi,all_in)        "parameter for those CES markup cost accounted as investment cost in the budget [trUSD/CES input]"
  p36_floorspace(tall,all_regi)            "buildings floorspace, billion m2, in simple realization only used for reporting"
  p36_uedemand_build(tall,all_regi,all_in) "useful energy demand in buildings in TWh/a, in simple realization only used for reporting"
;

$ifThen.CESMkup not "%cm_CESMkup_build%" == "standard" 
Parameter
  p36_CESMkup_input(all_in)  "markup cost parameter read in from config for CES levels in buildings to influence demand-side cost and efficiencies in CES tree [trUSD/CES input]" / %cm_CESMkup_build% /
;
$endif.CESMkup 

Variables
  v36_costExponent(ttot,all_regi) "logistic function exponent for additional cost for H2 at low penetration"
;

Positive Variables
  v36_expSlack(ttot,all_regi)              "slack variable to avoid overflow on too high logistic function exponent"
  v36_H2share(ttot,all_regi)               "H2 share in gases"
  v36_costAddH2LowPen(ttot,all_regi)       "low penetration H2 mark up component"
  v36_costAddTeInvH2(ttot,all_regi,all_te) "Additional H2 phase-in cost at low H2 penetration levels [trUSD]"
;

Equations
  q36_demFeBuild(ttot,all_regi,all_enty,all_emiMkt) "buildings final energy demand"
  q36_H2Share(ttot,all_regi)                        "H2 share in gases"
  q36_auxCostAddTeInv(ttot,all_regi)                "logistic function exponent calculation for additional cost at low H2 penetration"  
  q36_costAddH2LowPen(ttot,all_regi)                "additional annual investment costs under low H2 penetration in buildings"
  q36_costAddH2PhaseIn(ttot,all_regi)               "additional industry H2 t&d cost at low H2 penetration in buildings" 
  q36_costCESmarkup(ttot,all_regi,all_in)           "calculation of additional CES markup cost that are accounted in the budget (GDP) to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps"
  q36_costAddTeInv(ttot,all_regi,all_te)            "summation of sector-specific demand-side cost"
;

*** EOF ./modules/36_buildings/simple/declarations.gms
