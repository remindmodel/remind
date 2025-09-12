*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/30_biomass/magpie/presolve.gms

*** If MAgPIE runs inbetween the Nash iterations:
*** ============================================================
if(sm_magpieIter gt 0,
*** ============================================================

*** Since in the coupling MAgPIE data is first required in core/presolve
*** MAgPIE is executed there.

*** Update biomass prices and biomass production with MAgPIE's results
*** The landuse emissions are updated in the core/presolve.gms

*DK* Read prices and costs for 2nd gen. purpose grown bioenergy from MAgPIE (calculated with demnad from previous Remind run)
Execute_Loadpoint 'magpieData.gdx' p30_pebiolc_pricemag;

*DK* In coupled runs overwrite pebiolc production from look-up table with actual MAgPIE values.
*DK* Read production of 2nd gen. purpose grown bioenergy from MAgPIE (given to MAgPIE from previous Remind run)
*** Moved to core/presolve.gms because it is needed there for calcualtions

***=============================================================
***  BEGIN: calculate shift factors for bioenergy prices 
***  Compare price response from MAgPIE run with emulator prices
***  and shift emulator supply curves to match the MAgPIE price.
***  Steps:
***  1  Fix fuelex to MAgPIE demand
***  2a Calculate bioenergy prices with emulator based on MAgPIE demand
***  2b Calculate price shift factor by comparing 2a with original MAgPIE prices
***  3  Calculate costs based on MAgPIE demand
***  4  Release the bound on fuelex (to be precise: fuelex has to be fixed only for 2a and 3)  
***  Note: In the cost formula in 3a the price shift factor is used!

***--------- declare models -----------------
*** Models cant be delcard inside a loop.
*** They are therefore declared in preloop.gms.

***------------ Step 1: Fix fuelex to MAgPIE demand -------------
*** BEFORE calculation: Regular emulator equations are applied to calculate costs and prices. Therefore set demand (fuelex) in
*** the emulator equations for price and costs to demand from MAgPIE reporting
*** Save level of vm_fuelex to continue at the same point for the next nash iteration
p30_pebiolc_demand_helper(ttot,regi) = vm_fuExtr.l(ttot,regi,"pebiolc","1");
vm_fuExtr.fx(ttot,regi,"pebiolc","1") = pm_pebiolc_demandmag(ttot,regi);

*** Eliminate effect of shift and mult for calculating the original emulator price (p30_pebiolc_price_emu_preloop)
v30_priceshift.fx(ttot,regi) = 0;
v30_pricemult.fx(ttot,regi)  = 1;

***------------ Step 2a: calculate bioenergy prices -------------
if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve model_biopresolve_p using cns; !!! nothing has to be optimized here, just pure calculation
p30_pebiolc_price_emu_preloop(ttot,regi) = vm_pebiolc_price.l(ttot,regi); !!! save for shift factor calculation and reporting

***------------ Step 2b: Calculate shift factor for prices -------------
*** In the current coupling shift remains fixed to 0 (no shift, change of slope only)
v30_pricemult.lo(ttot,regi) = 0;
v30_pricemult.up(ttot,regi) = inf;

s30_switch_shiftcalc = 1; !!! activate equations for shift calculation
if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve model_priceshift using nlp minimizing v30_shift_r2;
*** Initialize shift factors
p30_pebiolc_pricshift(t,regi) = 0;
p30_pebiolc_pricmult(t,regi)  = 1;
*** Store results from fitting
p30_pebiolc_pricshift(ttot,regi) = v30_priceshift.l(ttot,regi);
p30_pebiolc_pricmult(ttot,regi)$(v30_pricemult.l(ttot,regi) gt 0) = v30_pricemult.l(ttot,regi);
v30_pricemult.fx(ttot,regi) = p30_pebiolc_pricmult(ttot,regi);
v30_priceshift.fx(ttot,regi) = p30_pebiolc_pricshift(ttot,regi);

s30_switch_shiftcalc = 0; !!! deactivate equations for shift calculation. This is necessary because the main model uses /all/

display p30_pebiolc_pricmult, p30_pebiolc_pricshift;

*** Calculate shifted prices
if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve model_biopresolve_p using cns; !!! nothing has to be optimized here, just pure calculation
p30_pebiolc_price_emu_preloop_shifted(ttot,regi) = vm_pebiolc_price.l(ttot,regi); !!! save for reporting

display p30_pebiolc_price_emu_preloop_shifted;


***------------ Step 3: calculate bioenergy costs -------------
*** The costs are calculated applying the regular cost equation. 
*** This equation integrates the shifted (!) price supply curve over the demand.
*** It requires the price shift factor to be calculated before (see above).

if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve model_biopresolve_c using cns; !!! nothing has to be optimized here, just pure calculation

p30_pebiolc_costs_emu_preloop(t,regi) = v30_pebiolc_costs.l(t,regi);

display p30_pebiolc_costs_emu_preloop;

***------------ Step 4: Release bounds on fuelex -------------
*** AFTER presolve calculations: prepare for main solve, therefore release bounds on fuelex
vm_fuExtr.lo(ttot,regi,"pebiolc","1") = 0;
vm_fuExtr.up(ttot,regi,"pebiolc","1") = inf;
*** Provide start values for fuelex taken from last iteration
vm_fuExtr.l(ttot,regi,"pebiolc","1")  = p30_pebiolc_demand_helper(ttot,regi);
***-------------------------------------------------------------
***  END: calculate shift factors
***-------------------------------------------------------------
*** ============================================================
);
*** ============================================================

*** Calculate total primary energy to limit BECCS (see q30_limitTeBio)
*** The summation is devided into actual primary energy carriers, e.g. coal or biomass, 
*** and primary-energy-equivalent secondary energy carriers like wind and solar. 
*** This must be calculated outside the optimization and stored in a 
*** parameter to not create an incentive to increase the total
*** PE demand just to increase the BECCS limit.
*** Using the substitution method to adjust vm_prodSE from non-fossil
*** energy sources to the primary energy inputs that would be needed
*** if it was generated from fossil fuels with an average efficiency of 40%.

p30_demPe(ttot,regi) =
  sum(pe2se(enty,enty2,te)$(sameas(enty,"peoil") OR sameas(enty,"pecoal") OR sameas(enty,"pegas") OR sameas(enty,"pebiolc") OR sameas(enty,"pebios") OR sameas(enty,"pebioil")),
    vm_demPe.l(ttot,regi,enty,enty2,te)
  ) 
  + sum(entySe,
      sum(te,
          vm_prodSe.l(ttot,regi,"pegeo",entySe,te)
        + vm_prodSe.l(ttot,regi,"pehyd",entySe,te)
        + vm_prodSe.l(ttot,regi,"pewin",entySe,te)
        + vm_prodSe.l(ttot,regi,"pesol",entySe,te)
        + vm_prodSe.l(ttot,regi,"peur",entySe,te)
      )
    ) * 100/40  !!! substitution method
;


*** EOF ./modules/30_biomass/magpie/presolve.gms
