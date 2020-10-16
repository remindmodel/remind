*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/spillover/declarations.gms

Parameters
  p20_coef_EL(all_in)                      "coefficient of RD function"
  p20_coef_H(ttot, all_regi)               "human capital coefficient of RD function"
  p20_coeffInno                            "coefficient of Innovation RD investments"
  p20_coeffImi                             "coefficient of Innovation RD investments"
  p20_constRD                              "RD constant"
  p20_exponInno(ttot,all_regi,all_in)      "exponent of RD function"
  p20_exponImi(ttot,all_regi,all_in)       "exponent of RD function"
  p20_dataeffscal_avg(ttot,all_regi)       "average efficiency growth across FE types"
*** reporting parameter
  o20_ImiGDP_lab                           "share of imitation RD on GDP"
  o20_ImiGDP_E                             "share of imitation RD on GDP"
  o20_InnoGDP_lab                          "share of innovation RD on GDP"
  o20_InnoGDP_E                            "sahre of Innovation RD on GDP"
  ;

*mlb*  vm_invInno and  vm_invImi and pm_cumEff shifted to the core folder
Positive variables
 vm_effGr(ttot,all_regi,all_in)            "growth of factor efficiency"
 v20_effInno(ttot,all_regi,all_in)         "efficiency improvement by innovation"
 v20_effImi(ttot,all_regi,all_in)          "efficiency improvement by imitation"
;
 
equations
 q20_effGr(ttot,all_regi,all_in)           "R&D function"
 q20_effInno(ttot,all_regi,all_in)         "efficiency improvement by innovation"
 q20_effImi(ttot,all_regi,all_in)          "efficiency improvement by imitation"
;
*** EOF ./modules/20_growth/spillover/declarations.gms
