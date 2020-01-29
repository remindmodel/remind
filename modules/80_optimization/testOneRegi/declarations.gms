*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/declarations.gms

parameter
p80_pvpFallback(ttot,all_enty)                      "Helper parameter. Price path from input/prices_NASH.inc. Only used if reading prices from gdx fails.",
p80_etaXp(all_enty)                                 "Parameter governing price anticipation on commodity markets",
p80_taxrev0(tall,all_regi)                          "???"
p80_Mport0(tall,all_regi,all_enty)                  "Imports in last iteration"
p80_normalize0(ttot,all_regi,all_enty)              "Normalization parameter for market volume"
pm_cumEff(tall,all_regi,all_in)                     "parameter for spillover externality (aggregated productivity level)"
pm_fuExtrForeign(ttot,all_regi,all_enty,rlf)        "foreign fuel extraction"
;

positive variable
*AJS* Adjustment costs for Nash trade algorithm.  Only non-zero in the Nash_test realization of 80_optimization module.
vm_costAdjNash(ttot,all_regi)               "Adjustment costs for deviation from the trade structure of the last iteration." 
;

equations
q80_budg_intertemp(all_regi)                        "interemporal trade balance (Nash mode only)"
q80_costAdjNash(ttot,all_regi)                      "plays a dummy role for now, allowing fixing to Nash GDX files"
;

scalar
s80_cnptfile                                       "parameter that indicates which optimality tolerance will be used"      /1/
;

*** EOF ./modules/80_optimization/testOneRegi/declarations.gms
