*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/declarations.gms

Parameters
  pm_abatparam_Ind(ttot,all_regi,all_enty,steps)   "industry CCS MAC curves [ratio @ US$2005]"
  p37_energy_limit(all_in,all_in)                  "thermodynamic/technical limits of energy use [GJ/product]"
;

Positive Variables
  vm_macBaseInd(ttot,all_regi,all_enty,secInd37)   "industry CCS baseline emissions [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)             "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,alL_regi,all_enty)            "industry CCS cost"
;

Equations
  q37_energy_limits(ttot,all_regi,all_in,all_in)   "thermodynamic/technical limit of energy use"
  q37_limit_secondary_steel_share(ttot,all_regi)   "no more than 90% of steel from seconday production"
;

*** EOF ./modules/37_industry/subsectors/declarations.gms

