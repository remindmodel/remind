*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*' @code
*' **Total agricultural costs (excluding MAC costs)**
*' For standalone runs replace exogenous land use MAC cots (p26_macCostLu) with endogenous land use MAC costs (pm_macCost). 
*' Note: dont include mac costs for CO2luc, because they are already implicitly included in p26_totLUcosts_withMAC (and not in p26_macCostLu).
*' In coupled runs these two components are zero and the original data from MAgPIE are used.
pm_totLUcosts(ttot,regi) =  p26_totLUcosts_withMAC(ttot,regi) - p26_macCostLu(ttot,regi) + sum(enty$(emiMacMagpie(enty) AND (NOT emiMacMagpieCO2(enty))), pm_macCost(ttot,regi,enty));

*' **Bioenergy costs**
*' For standalone and coupled runs costs for biomass production are calculated endogenously (v30_pebiolc_costs). Since they
*' are also included in the exogenous total landuse costs (p26_totLUcostLookup) they need to be substracted from these total
*' landuse costs. This is done in the biomass module ([30_biomass]) by calculating them before the main solve as a
*' parameter (p30_pebiolc_costs_emu_preloop), and during the optimization substracting this parameter from the fuel costs
*' while including the variable v30_pebiolc_costs.

*' @stop