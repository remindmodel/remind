*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/declarations.gms

scalars
  s36_costAddH2Inv   "additional h2 distribution costs for low diffusion levels [$/kWh]"
  s36_costDecayStart "simplified logistic function end of full value (ex. 5%  -> between 0 and 5% the function will have the value 1). [%]"
  s36_costDecayEnd   "simplified logistic function start of null value (ex. 10% -> after 10% the function will have the value 0). [%]"
;

Parameters
  p36_CESMkup(ttot,all_regi,all_in)               "CES markup cost parameter [trUSD/CES input]"
  p36_floorspace(tall,all_regi)                   "buildings floorspace, billion m2, in simple realization only used for reporting"
  p36_uedemand_build(tall,all_regi,all_in)        "useful energy demand in buildings in TWh/a, in simple realization only used for reporting"
  ;

$ifThen.CESMkup not "%cm_CESMkup_build%" == "standard" 
Parameter
	p36_CESMkup_input(all_in)  "markup cost parameter read in from config for CES levels in buildings to influence demand-side cost and efficiencies in CES tree [trUSD/CES input]" / %cm_CESMkup_build% /
;
$endIf.CESMkup

Variables
  v36_costExponent(ttot,all_regi) "logistic function exponent for additional hydrogen low penetration cost"
;

Positive Variables
  v36_expSlack(ttot,all_regi)     "slack variable to avoid overflow on too high logistic function exponent"
  v36_H2share(ttot,all_regi)      "H2 share in gases"
  v36_costAddH2LowPen(ttot,all_regi) "low penetration H2 mark up component"
  v36_costAddTeInvH2(ttot,all_regi,all_te)         "Additional hydrogen phase-in cost at low H2 penetration levels [trUSD]"
;

Equations
  q36_demFeBuild(ttot,all_regi,all_enty,all_emiMkt) "buildings final energy demand"
  q36_H2Share(ttot,all_regi)         "H2 share in gases"
  q36_costAddH2LowPen(ttot,all_regi) "additional buildings hydrogen annual investment costs under low technology diffusion"
  q36_auxCostAddTeInv(ttot,all_regi) "auxiliar logistic function exponent calculation for additional hydrogen low penetration cost"  
  q36_costAddH2PhaseIn(ttot,all_regi) "calculation of additional industry hydrogen t&d cost at low penetration levels of hydrogen in buildings" 
  q36_costCESmarkup(ttot,all_regi,all_in) "calculation of additional CES markup cost to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps etc."
  q36_costAddTeInv(ttot,all_regi,all_te)  "summation of sector-specific demand-side cost"
;

*** EOF ./modules/36_buildings/simple/declarations.gms
