*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/declarations.gms


scalars
  s37_costAddH2Inv   "additional h2 distribution costs for low diffusion levels. [$/kWh]"
  s37_costDecayStart "simplified logistic function end of full value   (ex. 5%  -> between 0 and 5% the simplified logistic function will have the value 1). [%]" 
  s37_costDecayEnd   "simplified logistic function start of null value (ex. 10% -> between 10% and 100% the simplified logistic function will have the value 0). [%]"
;

Parameters
  pm_abatparam_Ind(ttot,all_regi,all_enty,steps)         "industry CCS MAC curves [ratio @ US$2005]"


  pm_ue_eff_target(all_in)   "energy efficiency target trajectories [% p.a.]"
  /   /

  p37_CESMkup(ttot,all_regi,all_in)  "CES markup cost parameter [trUSD/CES input]"


  pm_IndstCO2Captured(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt) "Captured CO2 in industry by energy carrier, subsector and emissions market"

*** output parameters only for reporting
  o37_emiInd(ttot,all_regi,all_enty,secInd37,all_enty)   "industry CCS emissions [GtC/a]"
  o37_cementProcessEmissions(ttot,all_regi,all_enty)     "cement process emissions [GtC/a]"
  o37_CESderivatives(ttot,all_regi,all_in,all_in)        "derivatives of production CES function"
  o37_demFeIndSub(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)  "FE demand per industry subsector, FE carrier, SE carrier, emissions market"
  o37_demFeIndSub_SecCC(ttot,all_regi,secInd37)           "FE per subsector whose emissions can be captured, helper parameter for calculation of industry captured CO2"

  !! empty parameters from subsectors
  pm_energy_limit(all_in)    ""   / /
;


$ifThen.CESMkup not "%cm_CESMkup_ind%" == "standard" 
Parameter
	p37_CESMkup_input(all_in)  "markup cost parameter read in from config for CES levels in industry to influence demand-side cost and efficiencies in CES tree [trUSD/CES input]" / %cm_CESMkup_ind% /
;
$endIf.CESMkup

Variables
  v37_costExponent(ttot,all_regi)                  "logistic function exponent for additional hydrogen low penetration cost"
;

Positive Variables
  vm_macBaseInd(ttot,all_regi,all_enty,secInd37)   "industry CCS baseline emissions [GtC/a]"
  v37_emiIndCCSmax(ttot,all_regi,all_enty)         "max industry CCS emissions [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)             "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,all_regi,all_enty)            "industry CCS cost"
  v37_expSlack(ttot,all_regi)                      "slack variable to avoid overflow on too high logistic function exponent"
  v37_H2share(ttot,all_regi)                       "H2 share in gases"
  v37_costAddTeInvH2(ttot,all_regi,all_te)         "Additional hydrogen phase-in cost at low H2 penetration levels [trUSD]"
;

Equations
  q37_macBaseInd(ttot,all_regi,all_enty,secInd37)   "calculate industry CCS baseline emissions"
  q37_emiIndCCSmax(ttot,all_regi,all_enty)          "calculate max industry CCS emissions"
  q37_indCCS(ttot,all_regi,all_enty)                "calculate industry CCS emissions"
  q37_IndCCSCost(ttot,all_regi,all_enty)            "calculate cost for Industry CCS"
  q37_cementCCS(ttot,all_regi)                      "equal abatement levels for cement fuel and process emissions"
  q37_demFeIndst(ttot,all_regi,all_enty,all_emiMkt) "industry final energy demand (per emission market)"
  q37_H2Share(ttot,all_regi)                        "H2 share in gases"
  q37_auxCostAddTeInv(ttot,all_regi)                "auxiliar logistic function exponent calculation for additional hydrogen low penetration cost" 
  q37_costAddH2PhaseIn(ttot,all_regi)               "calculation of additional industry hydrogen t&d cost at low penetration levels of hydrogen in industry"  
  q37_costCESmarkup(ttot,all_regi,all_in)           "calculation of additional CES markup cost to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps etc."
  q37_costAddTeInv(ttot,all_regi,all_te)            "summation of sector-specific demand-side cost"
;

*** EOF ./modules/37_industry/fixed_shares/declarations.gms

