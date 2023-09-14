*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
  p37_specMatDem(mat,all_te,opmoPrc)                                           "Specific materials demand of a production technology and operation mode [t_input/t_output]"
  p37_specFeDem(tall,all_regi,all_enty,all_te,opmoPrc)                         "Actual specific final-energy demand of a tech; blends between IEA data and Target [TWa/Gt_output]"
  p37_specFeDemTarget(all_enty,all_te,opmoPrc)                                 "Best available technology (will be reached in convergence year) [TWa/Gt_output]"
  p37_mat2ue(all_enty,all_in)                                                  "Contribution of process output to ue in CES tree [Gt/Gt]"
  p37_captureRate(all_te,opmoPrc)                                              "capture rate of CCS technology"
$endif.process_based_steel

*** output parameters only for reporting
  o37_emiInd(ttot,all_regi,all_enty,secInd37,all_enty)                   "industry CCS emissions [GtC/a]"
  o37_cementProcessEmissions(ttot,all_regi,all_enty)                     "cement process emissions [GtC/a]"
  o37_demFeIndTotEn(ttot,all_regi,all_enty,all_emiMkt)                   "total FE per energy carrier and emissions market in industry (sum over subsectors)"
  o37_shIndFE(ttot,all_regi,all_enty,secInd37,all_emiMkt)                "share of subsector in FE industry energy carriers and emissions markets"
  o37_demFeIndSub(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)   "FE demand per industry subsector"
$ifthen.process_based_steel "%cm_process_based_steel%" == "on"                 !! cm_process_based_steel
  o37_demFePrc(ttot,all_regi,all_enty,all_te,opmoPrc)               "Process-based FE demand per FE type and process"
$endif.process_based_steel

$ifThen.CESMkup not "%cm_CESMkup_ind%" == "standard"
  p37_CESMkup_input(all_in)  "markup cost parameter read in from config for CES levels in industry to influence demand-side cost and efficiencies in CES tree [trUSD/CES input]" / %cm_CESMkup_ind% /
$endIf.CESMkup

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
  v37_outflowPrc(tall,all_regi,all_te,opmoPrc)                             "Production volume of processes in material-flow model [Gt]"
  v37_prodMat(tall,all_regi,all_enty)                                      "Production of materials [Gt]"
  vm_emiPrc(ttot,all_regi,all_enty,secInd37)                               "industry baseline emissions [GtC/a]"
  v37_specEmiPrc(tall,all_regi,all_te,opmoPrc)		                   "specific emission from steel without CCS [GtCO2/GtSteel] [tCO2/tSteel]"	
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
  q37_cementCCS(ttot,all_regi)                            "link cement fuel and process abatement"
  q37_IndCCSCost                                          "Calculate industry CCS costs"
  q37_demFeIndst(ttot,all_regi,all_enty,all_emiMkt)       "industry final energy demand (per emission market)"
  q37_costCESmarkup(ttot,all_regi,all_in)                 "calculation of additional CES markup cost to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps etc."

$ifthen.process_based_steel "%cm_process_based_steel%" == "on"                 !! cm_process_based_steel
  q37_demMatPrc(tall,all_regi,mat)                      "Demand of process materials"
  q37_prodMat(tall,all_regi,mat)                        "Production volume of processes in material-flow model"
  q37_mat2ue(tall,all_regi,all_in)                      "Connect materials production to ue ces tree nodes"
  q37_limitCapMat(tall,all_regi,all_te)                 "Material-flow conversion is limited by capacities"
  q37_emiPrc(ttot,all_regi,all_enty,secInd37)           "industry baseline emissions [GtC/a]"

  q37_specEmiPrc(tall,all_regi,all_te,opmoPrc)      "specific emission from steel without CCS [GtCO2/GtSteel] [tCO2/tSteel]"
  q37_emiCCSPrc(tall,all_regi,emiInd37,secInd37)                 "captured emission from CCS"
$endif.process_based_steel
;

*** EOF ./modules/37_industry/subsectors/declarations.gms
