*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/26_agCosts/costs/declarations.gms
parameter
pm_totLUcosts(tall,all_regi)           "Total landuse costs (agriculture, bioenergy, MAC, etc). In standalone runs MAC costs are substituted by costs from the endogenous REMIND-MAC [T$US]"
p26_totLUcost_coupling(tall,all_regi)  "Total landuse cost read from magpie.gdx in coupling"
p26_totLUcosts_withMAC(tall,all_regi)  "Total landuse costs including agricultural MAC costs (agriculture, bioenergy, MAC, etc) [T$US]"
p26_macCostLu(tall,all_regi)           "Land use emissions MAC cost [T$US]"
pm_NXagr(tall,all_regi)                "Net agricultural exports"

o_p26_totLUcosts_withMAC(iteration,ttot,all_regi) "track p26_totLUcosts_withMAC across Nash iterations"
o_pm_totLUcosts(iteration,ttot,all_regi)          "track pm_totLUcosts across Nash iterations"
o_p26_macCostLu(iteration,ttot,all_regi)          "track p26_macCostLu across Nash iterations"
;

*** EOF ./modules/26_agCosts/costs/declarations.gms
