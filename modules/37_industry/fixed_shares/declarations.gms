*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/declarations.gms

Parameters
  p37_fctEmi(all_enty)                                   "emission factors of FE carriers [GtC/TWa]"
  pm_abatparam_Ind(ttot,all_regi,all_enty,steps)         "industry CCS MAC curves [ratio @ US$2005]"
  o37_emiInd(ttot,all_regi,all_enty,secInd37,all_enty)   "industry CCS emissions [GtC/a]"
  o37_cementProcessEmissions(ttot,all_regi,all_enty)     "cement process emissions [GtC/a]"
  o37_CESderivatives(ttot,all_regi,all_in,all_in)        "derivatives of production CES function"

  pm_ue_eff_target(all_in)   "energy efficiency target trajectories [% p.a.]"
  /   /
;

Positive Variables
  vm_macBaseInd(ttot,all_regi,all_enty,secInd37)   "industry CCS baseline emissions [GtC/a]"
  v37_emiIndCCSmax(ttot,all_regi,all_enty)         "max industry CCS emissions [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)             "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,all_regi,all_enty)            "industry CCS cost"
;

Equations
  q37_macBaseInd(ttot,all_regi,all_enty,secInd37)   "calculate industry CCS baseline emissions"
  q37_emiIndCCSmax(ttot,all_regi,all_enty)          "calculate max industry CCS emissions"
  q37_indCCS(ttot,all_regi,all_enty)                "calculate industry CCS emissions"
  q37_IndCCSCost(ttot,all_regi,all_enty)            "calculate cost for Industry CCS"
  q37_cementCCS(ttot,all_regi)                      "equal abatement levels for cement fuel and process emissions"
;

*** EOF ./modules/37_industry/fixed_shares/declarations.gms

