*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/globallyOptimal/declarations.gms
equations
    q22_costSubsidizeLearning(ttot,all_regi)    "Subsidy for learning spillover - total"
    q22_costSubsidizeLearningForeign(ttot,all_regi) "Subsidy for learning spillovers in foreign regions"
;

variables
    v22_costSubsidizeLearningForeign(ttot,all_regi) "Subsidy for learning spillover in foreign regions"

;    
parameters
    p22_subsidy_LI(ttot,all_regi,all_te)                           "p22_subsidy from last iteration"
    p22_deltacap0(ttot,all_regi,all_te,rlf)                        "deltacapt from later iteration"
    p22_subsidy(ttot,all_regi,all_te)                              "per unit subsidy - total value"
    p22_subsidyForeign(ttot,all_regi,all_te)                       "per unit subsidy for the foreign spillovers"
    p22_subsidyForeign_LI(ttot,all_regi,all_te)                    "per unit subsidy for the foreign spillovers from last iteration"
    p22_marginalCapcumBenefit(ttot,all_regi,all_te)                "marginal value of capacity addition"

    p22_debugInfoSubsidy(ttot,all_regi,all_te,iteration)           "debug display helper, not solution relevant"
    p22_debugInfoCapcum(ttot,all_regi,all_te,iteration)            "debug display helper, not solution relevant"
    p22_debugInfoCapcumForeign(ttot,all_regi,all_te,iteration)     "debug display helper, not solution relevant"
    p22_debugInfoSubsidyCost(ttot,all_regi,all_te,iteration)       "debug display helper, not solution relevant"
    p22_debugInfoMarginalBudget(ttot,all_regi,all_te,iteration)    "debug display helper, not solution relevant"
    p22_debugInfoMarginalCapcum(ttot,all_regi,all_te,iteration)    "debug display helper, not solution relevant"
    p22_debugInfoInvestcost(ttot,all_regi,all_te,iteration)        "debug display helper, not solution relevant"
    p22_infoCapcumGlob2050(all_te)                                 "info paramter: global capacities in 2050"

;
*** EOF ./modules/22_subsidizeLearning/globallyOptimal/declarations.gms
