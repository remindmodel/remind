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
  p37_fctEmi(all_enty)                                   "FE emission factors"
  o37_emiInd(ttot,all_regi,all_enty,secInd37,all_enty)   "industry CCS emissions [GtC/a]"
  o37_cementProcessEmissions(ttot,all_regi,all_enty)     "cement process emissions [GtC/a]"

  p37_clinker_cement_ratio(ttot,all_regi)   "clinker content per unit cement used"

  pm_ue_eff_target(all_in)   "energy efficiency target trajectories [% p.a.]"
;

Positive Variables
  vm_macBaseInd(ttot,all_regi,all_enty,secInd37)   "industry CCS baseline emissions [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)             "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,alL_regi,all_enty)            "industry CCS cost"
  v37_emIIndCCSmax(ttot,all_regi,emiInd37)         "maximum abatable industry emissions"
;

Equations
  q37_energy_limits(ttot,all_regi,all_in)                 "thermodynamic/technical limit of energy use"
  q37_limit_secondary_steel_share(ttot,all_regi)          "no more than 90% of steel from seconday production"
  q37_macBaseInd(ttot,all_regi,all_enty,secInd37)         "gross industry emissions before CCS"
  q37_emiIndCCSmax(ttot,all_regi,emiInd37)                "maximum abatable industry emissions at current CO2 price"
  q37_IndCCS(ttot,all_regi,emiInd37)                      "limit industry emissions abatement"
  q37_cementCCS(ttot,all_regi)                            "link cement fuel and process abatement"
  q37_IndCCSCost                                          "Calculate industry CCS costs"
  q37_demFeIndst(ttot,all_regi,all_enty,all_emiMkt)       "industry final energy demand (per emission market)"
;

*** EOF ./modules/37_industry/subsectors/declarations.gms

