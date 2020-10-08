*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/off/declarations.gms

Parameters
  pm_abatparam_Ind(ttot,all_regi,all_enty,steps)         "industry CCS MAC curves [ratio @ US$2005]"
  o37_cementProcessEmissions(ttot,all_regi,all_enty)     "cement process emissions [GtC/a]"
  o37_emiInd(ttot,all_regi,all_enty,secInd37,all_enty)   "industry CCS emissions [GtC/a]"
;

Variables
  vm_macBaseInd(ttot,all_regi,all_enty,secInd37)   "industry CCS baseline emissions [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)             "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,all_regi,all_enty)            "industry CCS cost"
;

*** EOF ./modules/37_industry/off/declarations.gms

