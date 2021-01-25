*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr/declarations.gms
***-------------------------------------------------------------------------------
***                                   PARAMETERS
***-------------------------------------------------------------------------------
parameters
pm_delta_kap(all_regi,all_in)                                   "Depreciation rate of capital."
pm_cumDeprecFactor_old(ttot,all_regi,all_in)                    "Investment depreciation within a period, applied to the investment of t -1."
pm_cumDeprecFactor_new(ttot,all_regi,all_in)                    "Investment depreciation within a period, applied to the investment of t."
pm_ppfen_ratios(ttot,all_regi,all_in,all_in)                    "Limit ratio of two primary production factors of energy (ppfEn)."
pm_ppfen_shares(ttot,all_regi,all_in,all_in)                    "Limit the share of one ppfEn in total CES nest inputs."
pm_consPC(tall,all_regi)                                        "Consumption per capita"
;   
***------------------------------------------------------------ -------------------
***                                   VARIABLES 
***------------------------------------------------------------ -------------------
positive variables  
vm_cons(ttot,all_regi)                                          "Consumption"  
vm_cesIO(tall,all_regi,all_in)                                  "Production factor" 
vm_invMacro(ttot,all_regi,all_in)                               "Investment for capital for ttot"
v01_invMacroAdj(ttot,all_regi,all_in)                           "Adjustment costs of macro economic investments"
vm_invRD(ttot,all_regi,all_in)                                  "R&D investments"
vm_invInno(ttot,all_regi,all_in)                                "Investment into innovation"
vm_invImi(ttot, all_regi,all_in)                                "Investment into imitation"     

*** putty-clay variables   
vm_cesIOdelta(tall,all_regi,all_in)                             "Putty-clay production factor"  
;   
***------------------------------------------------------------ -------------------
***                                   EQUATIONS 
***------------------------------------------------------------ -------------------
equations   
qm_budget(ttot,all_regi)                                        "Budget balance"
q01_balLab(ttot,all_regi)                                       "Labour balance"
q01_cesIO(ttot,all_regi,all_in)                                 "Production function"
q01_prodCompl(ttot,all_regi,all_in,all_in)                      "Constraints for perfect complements in the CES tree"
q01_kapMo(ttot,all_regi,all_in)                                 "Capital motion equation"
q01_kapMo0(t0,all_regi,all_in)                                  "Initial condition for capital"
q01_invMacroAdj(ttot,all_regi,all_in)                           "Adjustment costs for macro economic investments"
q01_limitShPpfen(ttot,all_regi,all_in,all_in)                   "Limit the share of one ppfEn in total CES nest inputs"
q01_limtRatioPpfen(ttot,all_regi,all_in,all_in)                 "Limit the ratio of two ppfEn"

*** putty-clay equations    
q01_cesIO_puttyclay(ttot,all_regi,all_in)                       "Putty-clay production function"
q01_puttyclay(ttot,all_regi,all_in)                             "Putty-clay Correspondance between variations in input and past stocks of input"
q01_prodCompl_putty(ttot,all_regi,all_in,all_in)                "Putty-Clay constraints for perfect complements in the CES tree"
q01_kapMo_putty(ttot,all_regi,all_in)                           "Putty-clay capital motion equation"
;
*** EOF ./modules/01_macro/singleSectorGr/declarations.gms
