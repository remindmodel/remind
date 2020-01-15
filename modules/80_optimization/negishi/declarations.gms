*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi/declarations.gms

parameter
p80_defic(iteration,all_regi)            "intertemporal trade balance deficit"
p80_defic_sum(iteration)                 "sum of intertemporal deficits"
p80_defic_sumLast                        "the sum of intertemporal deficits, only for the last iteration (needed for output analysis script)"
p80_nw(iteration,all_regi)               "negishi weights"
p80_alpha_nw(tall,all_regi)              "diagnostic parameter for new negishi routine"

p80_trade(ttot,all_regi,all_enty)        "trade surplusses"
p80_tradeVolumeAll(tall,all_regi)        "Trade volume of all traded goods"
p80_tradeVolume(tall,all_regi,all_enty)  "Trade volume"
p80_curracc(ttot,all_regi)               "current account"
p80_nfa(tall,all_regi)                   "net foreign assets"
p80_currentaccount_bau(tall,all_regi)    "baseline current account path"
pm_cumEff(tall,all_regi,all_in)          "parameter for spillover externality (aggregated productivity level)"
pm_fuExtrForeign(ttot,all_regi,all_enty,rlf) "foreign fuel extraction"
;

positive variable
*AJS* Adjustment costs for Nash trade algorithm.  Only non-zero in the Nash_test realization of 80_optimization module.
vm_costAdjNash(ttot,all_regi)               "Adjustment costs for deviation from the trade structure of the last iteration." 
;

equations
q80_balTrade(ttot,all_enty)              "trade balance equation"
q80_budget_helper(ttot,all_regi)         "Helper declaration for import from gdx"
;

scalars
s80_alpha_avg                            "average of p80_alpha_nw"
s80_cnptfile                             "parameter that indicates which optimality tolerance will be used"      /1/

;
*** EOF ./modules/80_optimization/negishi/declarations.gms
