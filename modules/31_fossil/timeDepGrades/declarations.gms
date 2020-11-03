*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/timeDepGrades/declarations.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: timeDepGrades
* FILE.......: declarations.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for 
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example. 
*===========================================
* Authors...: JH, NB, TAC
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil   
* History...:
*   - 2015-12-03 : Cleaning up
*   - 2015-02-06 : Add possibility for user-defined fuel extraction in 2005 
*                  (skip automatic allocation)
*   - 2013-10-01 : Cleaning up
*   - 2012-05-04 : Creation
*===========================================


*-------------------------------------------
*** SCALARS
*-------------------------------------------
scalars
*** Debug
s31_debug                                            "debugging option to display more output"        /0/
s31_max_disp_peur                                    "maximum amount of cumulative uranium production in Megatonnes of metal uranium (U3O8, the stuff that is traded at 40-60US$/lb)."
;


*-------------------------------------------
*** PARAMETERS
*-------------------------------------------
parameter
$IFTHEN.mofex %cm_MOFEX% == "on"
*** MOFEX
p31_MOFEX_peprod_ref(tall,all_regi,all_enty)         "Load PE production level values from reference GDX"
p31_MOFEX_Xport_ref(tall,all_regi,all_enty)          "Load exports values from reference GDX"
p31_MOFEX_Mport_ref(tall,all_regi,all_enty)          "Load imports values from reference GDX"
p31_MOFEX_fuelex_costMin(tall,all_regi,all_enty,rlf) "Result of MOFEX calculation: fuelex"
p31_MOFEX_cumfex_costMin(tall,all_regi,all_enty,rlf) "Result of MOFEX calculation: cumulative fuelex"
p31_MOFEX_Mport_costMin(tall,all_regi,all_enty)      "Result of MOFEX calculation: imports"
p31_MOFEX_Xport_costMin(tall,all_regi,all_enty)      "Result of MOFEX calculation: exports"
$ENDIF.mofex
*** Input ------------------------------------
p31_costExPoly(all_regi,xirog,all_enty)              "(Input) information about exhaustibles according to Rogner's polynomial approach. Unit: "
p31_grades(tall,all_regi,xirog,all_enty,rlf)         "(Input) information about exhaustibles according to the grade structure concept. Unit: TWa"
p31_datafosdyn(all_regi,all_enty,rlf,gradePar31)     "(Input) information about exhaustibles according to the grade structure concept. Unit: "
p31_fosadjco_xi5xi6(all_regi,xirog,all_enty)         "(Input) data and parameters that describe the adjustment cost function of the fossil fuel extraction. Unit:"
* Bounds -----------------------------------
p31_fuelexIni(all_regi, all_enty, rlf)               "(Bounds) user-defined fossil fuel extraction values in 2005. Unit: TWa"
*** Preloop ----------------------------------
pm_prodIni(all_regi,all_enty)                       "(Preloop) regional amount of primary energy that has to be produced according to 1.1*initial demand. Unit: "
p31_prodShare(all_regi,all_enty,rlf)                 "(Preloop) minimum amount of primary energy that can be produced given the decline rate. Unit: "
*** Output -----------------------------------
pm_fuelex_cum(tall,all_regi,all_enty,rlf)           "(Output) cumulated extraction. Unit: "
p31_costfu_detail(tall,all_regi,all_enty)            "(Output) absolute fuel costs for each element of peExPol. Unit: "
*LB* reporting parameters 
p31_fuel_cost_marg(tall,all_regi,all_enty)           "(Output) marginal pure extraction costs, calculated by hand from Nico's elasticity equation. Unit:"
p31_fuel_cost_noadj(tall,all_regi,all_enty)          "(Output) fuel cost without adjustment costs. Unit: "
$IFTHEN.oilt %cm_OILRETIRE% == "on"
p31_max_oil_extraction(all_regi,all_enty,rlf)        "maximum oil extraction, calculated from the total grade size and the decline constraint. Unit: TWyr"
$ENDIF.oilt
***BAU 2010 fixing
p31_fuel_cost(tall,all_regi,all_enty)                "Pure extraction costs"

p31_fuExtrCumMaxBound(all_regi,all_enty,rlf)         "value of regional uranium extraction bound"
p31_sol_itr_max                                      "parameter for maximum solves for MOFEX"

p31_extraseed(tall,all_regi,all_enty,rlf)                    "extra seed value that scales up the ramp-up potential"
;

*-------------------------------------------
*** VARIABLES
*-------------------------------------------
$IFTHEN.mofex %cm_MOFEX% == "on"
variables
*** MOFEX
v31_MOFEX_costMinFuelEx                              "Minimization of discounted fossil fuel extraction and trade costs"
$ENDIF.mofex
;

*-------------------------------------------
*** POSITIVE VARIABLES
*-------------------------------------------
positive variables
*** Others
v31_fuExtrCum(ttot,all_regi,all_enty,rlf)           "cumulated extraction of exhaustible resources"
v31_fuExtrCumMax(all_regi,all_enty,rlf)             "maximum of cumulated extraction of exhaustible resources"
v31_fuExtrMC(all_enty,rlf)                          "MC exhaustible resources"
$IFTHEN.oilt %cm_OILRETIRE% == "on"
v31_fuSlack(ttot,all_regi,all_enty,rlf)             "Amount of oil that is not extracted but put aside never to be used again. Unit: TWa/a"
$ENDIF.oilt
;

*-------------------------------------------
*** EQUATIONS
*-------------------------------------------
equations
*** MOFEX
$IFTHEN.mofex %cm_MOFEX% == "on"
q31_MOFEX_costMinFuelEx                                "Minimization of discounted fossil fuel extraction and trade costs"
q31_MOFEX_tradebal(ttot,all_enty)                      "New trade equation for MOFEX purposes"
$ENDIF.mofex
*** Cost
q31_costFuExPol(ttot,all_regi,all_enty)                "costs of fuels estimated by polynomial; exhaustible fuels (uranium)"
q31_mc_dummy(all_regi,all_enty)                        "marginal costs of fuels estimated by polynomial; exhaustible fuels (uranium)"
q31_totfuex_dummy(all_enty)                            "dummy for total global extraction; exhaustible fuels (uranium)"
q31_costFuExGrade(ttot,all_regi,all_enty)              "costs of fuels estimated step-wise by grades; exchaustible fuels (oil, gas and coal)"
*** Quantity
q31_fuExtrCum(ttot,all_regi,all_enty,rlf)              "cumulated extraction of exhaustible resources"
*** Dynamic constraints on fuel extraction
q31_fuExtrDec(ttot,all_regi,all_enty,rlf)              "lower bound on decline rate of fuel extraction (vm_fuExtr)"
q31_fuExtrInc(ttot,all_regi,all_enty,rlf)              "upper bound on growth rate of fuel extraction (vm_fuExtr)"
$IFTHEN.oilt %cm_OILRETIRE% == "on"
q31_smoothoilphaseout(ttot,all_regi,all_enty,rlf)      "limits the increase of v_fuelslack, leading to a smoother phase-out of oil"
$ENDIF.oilt
;

*** EOF ./modules/31_fossil/timeDepGrades/declarations.gms
