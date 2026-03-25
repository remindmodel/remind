*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/26_agCosts/costs/presolve.gms

*' @code

*** Since in the coupling MAgPIE data is first required in core/presolve
*** MAgPIE is executed there.


*** MAC costs must be zero once MAgPIE has run for the first time because MAgPIE's total costs (see below) already include MAC costs.
if(sm_magpieIter gt 0,
  p26_macCostLu(ttot,regi) = 0;
);

*' Update landuse costs only and every time MAgPIE actually has run.
if(sm_updateMagpieData gt 0, 
  Execute_Loadpoint 'magpieData.gdx' p26_totLUcost_coupling;
  p26_totLUcosts_withMAC(ttot,regi) = p26_totLUcost_coupling(ttot,regi);
);

*' **Total agricultural costs (excluding MAC costs)**
*' For standalone runs replace exogenous land use MAC cots (p26_macCostLu) with endogenous land use MAC costs (pm_macCost). 
*' Note: dont include mac costs for CO2luc, because they are already implicitly included in p26_totLUcosts_withMAC (and not in p26_macCostLu).
*' In coupled runs these two components are zero and the original data from MAgPIE are used.
pm_totLUcosts_excl_costFuBio(ttot,regi) =  p26_totLUcosts_withMAC(ttot,regi) 
                                         - p26_macCostLu(ttot,regi) 
                                         + sum(enty$(emiMacMagpie(enty) AND (NOT emiMacMagpieCO2(enty))), pm_macCost(ttot,regi,enty))
                                         - pm_pebiolc_costs_emu_preloop(ttot,regi); !! Need to be substracted since they are also included in the total agricultural production costs

*' **Bioenergy costs**
*' The costs for biomass production cannot be determined directly as individual costs in MAgPIE, but are included 
*' in the total land use costs (p26_totLUcosts_withMAC), which are exogenous (i.e., fixed) to REMIND. In REMIND, 
*' bioenergy costs (v30_pebiolc_costs) are calculated in the biomass module ([30_biomass]) as an integral under the
*' price curve. The bioenergy costs included in the total land use costs are approximated in REMIND in the preloop 
*' (model_biopresolve_c) before the main solve by calculating this integral with the bioenergy demand from the same
*' MAgPIE scenario from which the total costs are taken. The bioenergy costs calculated in this pre-step are subtracted
*' as a fixed component (pm_pebiolc_costs_emu_preloop) during optimization (see above). The actual bioenergy costs
*' (v30_pebiolc_costs) going into the budget equation are calculated during optimization using the endogenous 
*' bioenergy demand (also as an integral under the price curve).

*' @stop

*** Save values for tracking across Nash iterations
o_p26_totLUcosts_withMAC(iteration,ttot,regi)       = p26_totLUcosts_withMAC(ttot,regi);
o_pm_totLUcosts_excl_costFuBio(iteration,ttot,regi) = pm_totLUcosts_excl_costFuBio(ttot,regi);
o_p26_macCostLu(iteration,ttot,regi)                = p26_macCostLu(ttot,regi);

*** EOF ./modules/26_agCosts/costs/presolve.gms
