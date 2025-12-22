*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/declarations.gms

parameter
p80_priceAnticipStrength(all_enty) "Parameter governing price anticipation on commodity markets"
p80_pvpFallback(ttot,all_enty) "Helper parameter. Price path from input/prices_NASH.inc. Only used if reading prices from gdx fails."
p80_regiMarketVolume(ttot,all_regi,all_enty) "Regional market volume of a trade item, used for normalisation [amount of trade item]"
p80_Mport0(tall,all_regi,all_enty) "Imports in last iteration"
p80_taxrev0(tall,all_regi) "vm_taxrev from last iteration"
pm_cumEff(tall,all_regi,all_in) "parameter for spillover externality (aggregated productivity level)"
pm_fuExtrForeign(ttot,all_regi,all_enty,rlf) "foreign fuel extraction"
;

positive variable
*** adjustment costs for Nash trade algorithm (only non-zero in the nash realization of 80_optimization module)
vm_costAdjNash(ttot,all_regi) "Adjustment costs for deviation from the trade structure of the last iteration." 
;

equations
q80_budg_intertemp(all_regi) "interemporal trade balance (Nash mode only)"
q80_costAdjNash(ttot,all_regi) "calculate Nash adjustment costs; no role in testOneRegi mode"
;

*** EOF ./modules/80_optimization/testOneRegi/declarations.gms
