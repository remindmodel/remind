*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/declarations.gms

Scalar
  s37_clinker_process_CO2   "CO2 emissions per unit of clinker production"
  s37_plasticsShare         "share of carbon cointained in feedstocks for the chemicals subsector that goes to plastics"
;

Parameters
  pm_abatparam_Ind(ttot,all_regi,all_enty,steps)                               "industry CCS MAC curves [ratio @ US$2005]"
  pm_energy_limit(all_in)                                                      "thermodynamic/technical limits of subsector energy use [GJ/t product]"
  p37_energy_limit_slope(tall,all_regi,all_in)                                 "limit for subsector specific energy demand that converges towards the thermodynamic/technical limit [GJ/t product]"
  p37_clinker_cement_ratio(ttot,all_regi)                                      "clinker content per unit cement used"
  pm_ue_eff_target(all_in)                                                     "energy efficiency target trajectories [% p.a.]"
  pm_IndstCO2Captured(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)     "Captured CO2 in industry by energy carrier, subsector and emissions market [GtC/a]"
  p37_CESMkup(ttot,all_regi,all_in)                                            "parameter for those CES markup cost accounted as investment cost in the budget [trUSD/CES input]"
  p37_cesIO_up_steel_secondary(tall,all_regi,all_GDPscen)                      "upper limit to secondary steel production based on scrap availability"
  p37_steel_secondary_max_share(tall,all_regi)                                 "maximum share of secondary steel production"
  p37_BAU_industry_ETS_solids(tall,all_regi)                                   "industry solids demand in baseline scenario"
  p37_cesIO_baseline(tall,all_regi,all_in)                                     "vm_cesIO from the baseline scenario"
$ifthen.process_based_steel "%cm_process_based_steel%" == "on"                 !! cm_process_based_steel
**p37_specMatsDem(mats,all_te,opModes)                                         "Specific materials demand of a production technology and operation mode [t_input/t_output]"
**p37_specFeDem(all_enty,all_te,opModes)                                       "Specific final-energy demand of a production technology and operation mode [MWh/t_output]"
$endif.process_based_steel

  p37_chemicals_feedstock_share(ttot,all_regi)               "minimum share of feso/feli/fega in total chemicals FE input [0-1]"
  p37_FeedstockCarbonContent(ttot,all_regi,all_enty)         "carbon content of feedstocks [GtC/TWa]"
  p37_FE_noNonEn(ttot,all_regi,all_enty,all_enty2,emiMkt)    "testing parameter for FE without non-energy use" 
  p37_Emi_ChemProcess(ttot,all_regi,all_enty,emiMkt)         "testing parameter for process emissions from chemical feedstocks"
  p37_CarbonFeed_CDR(ttot,all_regi,all_emiMkt)               "testing parameter for carbon in feedstocks from biogenic and synthetic sources"
  p37_IndFeBal_FeedStock_LH(ttot,all_regi,all_enty,emiMkt)   "testing parameter Ind FE Balance left-hand side feedstock term"
  p37_IndFeBal_FeedStock_RH(ttot,all_regi,all_enty,emiMkt)   "testing parameter Ind FE Balance right-hand side feedstock term"
  p37_EmiEnDemand_NonEnCorr(ttot,all_regi)                   "energy demand co2 emissions with non-energy correction"
  p37_EmiEnDemand(ttot,all_regi)                             "energy demand co2 emissions without non-energy correction"

*** output parameters only for reporting
  o37_emiInd(ttot,all_regi,all_enty,secInd37,all_enty)                   "industry CCS emissions [GtC/a]"
  o37_cementProcessEmissions(ttot,all_regi,all_enty)                     "cement process emissions [GtC/a]"
  o37_demFeIndTotEn(ttot,all_regi,all_enty,all_emiMkt)                   "total FE per energy carrier and emissions market in industry (sum over subsectors)"
  o37_shIndFE(ttot,all_regi,all_enty,secInd37,all_emiMkt)                "share of subsector in FE industry energy carriers and emissions markets"
  o37_demFeIndSub(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)   "FE demand per industry subsector"

  p37_CESMkup_input(all_in)  "markup cost parameter read in from config for CES levels in industry to influence demand-side cost and efficiencies in CES tree [trUSD/CES input]"
  /
$ifthen.CESMkup "%cm_CESMkup_ind%" == "manual" 
    %cm_CESMkup_ind_data%
$endif.CESMkup
  /

$ifthen.sec_steel_scen NOT "%cm_steel_secondary_max_share_scenario%" == "off"   !! cm_steel_secondary_max_share_scenario
  p37_steel_secondary_max_share_scenario(tall,all_regi)   "scenario limits on share of secondary steel production"
  / %cm_steel_secondary_max_share_scenario% /
$endif.sec_steel_scen
;

Positive Variables
  vm_macBaseInd(ttot,all_regi,all_enty,secInd37)                            "industry CCS baseline emissions [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)                                      "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,alL_regi,all_enty)                                     "industry CCS cost"
  v37_emIIndCCSmax(ttot,all_regi,emiInd37)                                  "maximum abatable industry emissions"

$ifthen.process_based_steel "%cm_process_based_steel%" == "on"                 !! cm_process_based_steel
  v37_demMatsEcon(tall,all_regi,all_enty)                                   "External demand of materials from economy"
  v37_demMatsProc(tall,all_regi,all_enty)                                   "Internal demand of materials from processes"
  v37_prodMats(tall,all_regi,all_enty,all_te,opModes)                       "Production of materials"
  v37_demFEMats(tall,all_regi,all_enty,all_emiMkt)                          "Final-energy demand of material-flow model"
$endif.process_based_steel
;

Equations
$ifthen.no_calibration "%CES_parameters%" == "load"   !! CES_parameters
  q37_energy_limits(ttot,all_regi,all_in)                 "thermodynamic/technical limit of energy use"
$endif.no_calibration
  q37_limit_secondary_steel_share(ttot,all_regi)          "no more than 90% of steel from seconday production"
  q37_macBaseInd(ttot,all_regi,all_enty,secInd37)         "gross industry emissions before CCS"
  q37_emiIndCCSmax(ttot,all_regi,emiInd37)                "maximum abatable industry emissions at current CO2 price"
  q37_IndCCS(ttot,all_regi,emiInd37)                      "limit industry emissions abatement"
  q37_limit_IndCCS_growth(ttot,all_regi,emiInd37)	  "limit industry CCS scale-up"
  q37_cementCCS(ttot,all_regi)                            "link cement fuel and process abatement"
  q37_IndCCSCost                                          "Calculate industry CCS costs"
  q37_demFeIndst(ttot,all_regi,all_enty,all_emiMkt)       "industry final energy demand (per emission market)"
  q37_costCESmarkup(ttot,all_regi,all_in)                 "calculation of additional CES markup cost to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps etc."
  q37_chemicals_feedstocks_limit(ttot,all_regi)                     "lower bound on feso/feli/fega in chemicals FE input for feedstocks"
  q37_demFeFeedstockChemIndst(ttot,all_regi,all_enty,all_emiMkt)    "defines energy flow of non-energy feedstocks for the chemicals industry. It is used for emissions accounting"
  q37_FossilFeedstock_Base(ttot,all_regi,all_enty,all_emiMkt)       "in baseline runs feedstocks only come from fossil energy carriers"
  q37_FeedstocksCarbon(ttot,all_regi,all_enty,all_enty,all_emiMkt)  "calculate carbon contained in feedstocks [GtC]"
  q37_plasticsCarbon(ttot,all_regi,all_enty,all_enty,all_emiMkt)            "calculate carbon contained in plastics [GtC]"
  q37_plasticWaste(ttot,all_regi,all_enty,all_enty,all_emiMkt)  "calculate carbon contained in plastic waste [GtC]"
  q37_incinerationEmi(ttot,all_regi,all_enty,all_enty,all_emiMkt)           "calculate carbon contained in plastics that are incinerated [GtC]"
  q37_nonIncineratedPlastics(ttot,all_regi,all_enty,all_enty,all_emiMkt)    "calculate carbon contained in plastics that are not incinerated [GtC]"
  q37_feedstockEmiUnknownFate(ttot,all_regi,all_enty,all_enty,all_emiMkt)   "calculate carbon contained in chemical feedstock with unknown fate [GtC]"
  q37_feedstocksLimit(ttot,all_regi,all_enty,all_enty,all_emiMkt)           "restrict feedstocks flow to total energy flows into industry"

$ifthen.process_based_steel "%cm_process_based_steel%" == "on"                 !! cm_process_based_steel
  q37_balMats(tall,all_regi,all_enty)                     "Balance of materials in material-flow model"
  q37_limitCapMat(tall,all_regi,all_enty,all_te)          "Material-flow conversion is limited by capacities"
  q37_demMatsProc(tall,all_regi,all_enty)                 "Demand of process materials"
  q37_demFEMats(tall,all_regi,all_enty,all_emiMkt)        "Final-energy demand of materail-flow model"
$endif.process_based_steel
;

*** EOF ./modules/37_industry/subsectors/declarations.gms
