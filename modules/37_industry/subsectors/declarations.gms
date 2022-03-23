*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/declarations.gms

Scalar
  s37_clinker_process_CO2   "CO2 emissions per unit of clinker production"
;

Parameters
  pm_abatparam_Ind(ttot,all_regi,all_enty,steps)         "industry CCS MAC curves [ratio @ US$2005]"
  p37_energy_limit(all_in)                               "thermodynamic/technical limits of energy use [GJ/product]"

  p37_clinker_cement_ratio(ttot,all_regi)   "clinker content per unit cement used"

  pm_ue_eff_target(all_in)   "energy efficiency target trajectories [% p.a.]"
  pm_IndstCO2Captured(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt) "Captured CO2 in industry by energy carrier, subsector and emissions market"

  p37_CESMkup(ttot,all_regi,all_in)  "CES markup cost parameter [trUSD/CES input]"
  p37_chemicals_feedstock_share(ttot,all_regi)   "minimum share of feso/feli/fega in total chemicals FE input [0-1]"

*** output parameters only for reporting
  o37_emiInd(ttot,all_regi,all_enty,secInd37,all_enty)                    "industry CCS emissions [GtC/a]"
  o37_cementProcessEmissions(ttot,all_regi,all_enty)                      "cement process emissions [GtC/a]"
  o37_demFeIndTotEn(ttot,all_regi,all_enty,all_emiMkt)                               "total FE per energy carrier and emissions market in industry (sum over subsectors)"
  o37_shIndFE(ttot,all_regi,all_enty,secInd37,all_emiMkt)                            "share of subsector in FE industry energy carriers and emissions markets"
  o37_demFeIndSub(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)    "FE demand per industry subsector"
  o37_demFeIndSub_SecCC(ttot,all_regi,secInd37)           "FE per subsector whose emissions can be captured, helper parameter for calculation of industry captured CO2"

  p37_FeedstockCarbonContent(ttot,all_regi,all_enty)            "carbon content of feedstocks [GtC/TWa]"

  p37_FE_noNonEn(ttot,all_regi,all_enty,all_enty2,emiMkt) "testing parameter for FE without non-energy use" 
  p37_Emi_ChemProcess(ttot,all_regi,all_enty,emiMkt)           "testing parameter for process emissions from chemical feedstocks"
  p37_CarbonFeed_CDR(ttot,all_regi,all_emiMkt)         "testing parameter for carbon in feedstocks from biogenic and synthetic sources"
  p37_IndFeBal_FeedStock_LH(ttot,all_regi,all_enty,emiMkt) "testing parameter Ind FE Balance left-hand side feedstock term"
  p37_IndFeBal_FeedStock_RH(ttot,all_regi,all_enty,emiMkt)       "testing parameter Ind FE Balance right-hand side feedstock term"
  p37_EmiEnDemand_NonEnCorr(ttot,all_regi)                        "energy demand co2 emissions with non-energy correction"
  p37_EmiEnDemand(ttot,all_regi)                                  "energy demand co2 emissions without non-energy correction"
;

$ifThen.CESMkup not "%cm_CESMkup_ind%" == "standard" 
Parameter
	p37_CESMkup_input(all_in)  "markup cost parameter read in from config for CES levels in industry to influence demand-side cost and efficiencies in CES tree [trUSD/CES input]" / %cm_CESMkup_ind% /
;
$endIf.CESMkup

Positive Variables
  vm_macBaseInd(ttot,all_regi,all_enty,secInd37)                      "industry CCS baseline emissions [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)                                "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,alL_regi,all_enty)                               "industry CCS cost"
  v37_emIIndCCSmax(ttot,all_regi,emiInd37)                            "maximum abatable industry emissions"
;

Equations
  q37_energy_limits(ttot,all_regi,all_in)                           "thermodynamic/technical limit of energy use"
  q37_limit_secondary_steel_share(ttot,all_regi)                    "no more than 90% of steel from seconday production"
  q37_macBaseInd(ttot,all_regi,all_enty,secInd37)                   "gross industry emissions before CCS"
  q37_emiIndCCSmax(ttot,all_regi,emiInd37)                          "maximum abatable industry emissions at current CO2 price"
  q37_IndCCS(ttot,all_regi,emiInd37)                                "limit industry emissions abatement"
  q37_cementCCS(ttot,all_regi)                                      "link cement fuel and process abatement"
  q37_IndCCSCost                                                    "Calculate industry CCS costs"
  q37_demFeIndst(ttot,all_regi,all_enty,all_emiMkt)                 "industry final energy demand (per emission market)"
  q37_costCESmarkup(ttot,all_regi,all_in)                           "calculation of additional CES markup cost to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps etc."
  q37_chemicals_feedstocks_limit(ttot,all_regi)                     "lower bound on feso/feli/fega in chemicals FE input for feedstocks"
  q37_demFeFeedstockChemIndst(ttot,all_regi,all_enty,all_emiMkt)    "defines energy flow of non-energy feedstocks for the chemicals industry. It is used for emissions accounting"
  q37_FossilFeedstock_Base(ttot,all_regi,all_enty,all_emiMkt)       "in baseline runs feedstocks only come from fossil energy carriers"
  q37_FeedstocksCarbon(ttot,all_regi,all_enty,all_enty,all_emiMkt)  "calculate carbon contained in feedstocks [GtC]"
;

*** EOF ./modules/37_industry/subsectors/declarations.gms

