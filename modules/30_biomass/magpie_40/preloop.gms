*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_4/preloop.gms

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

*** Eliminate effect of shift and mult for calculating the original emulator price
v30_priceshift.fx(ttot,regi) = 0;
v30_pricemult.fx(ttot,regi)  = 1;

***--------- declare models -----------------
model
model_biopresolve_p /q30_pebiolc_price/
;
model
model_priceshift  /q30_priceshift, q30_pebiolc_price/
;
model
model_biopresolve_c /q30_pebiolc_costs/
;

***------------ Step 1: Fix fuelex to MAgPIE demand -------------
*** BEFORE calculation: Regular emulator equations are applied to calculate costs and prices. Therefore set demand (fuelex) in
*** the emulator equations for price and costs to demand from MAgPIE reporting
vm_fuExtr.fx(ttot,regi,"pebiolc","1") = p30_pebiolc_demandmag(ttot,regi);

*** Shift factors only have to be calculateed if REMIND is run coupled to MAgPIE, else they are set to 1
*** ============================================================
$ifthen %cm_MAgPIE_coupling% == "on"
*** ============================================================

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

Solve model_priceshift using nlp minimizing v30_shift_r2;
*** Initialize shift factors
p30_pebiolc_pricshift(t,regi) = 0;
p30_pebiolc_pricmult(t,regi)  = 1;
*** Store results from fitting
p30_pebiolc_pricshift(ttot,regi) = v30_priceshift.l(ttot,regi);
p30_pebiolc_pricmult(ttot,regi)$(v30_pricemult.l(ttot,regi) gt 0) = v30_pricemult.l(ttot,regi);
v30_pricemult.fx(ttot,regi) = p30_pebiolc_pricmult(ttot,regi);
v30_priceshift.fx(ttot,regi) = p30_pebiolc_pricshift(ttot,regi);

*** Calculate shifted prices
if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve model_biopresolve_p using cns; !!! nothing has to be optimized here, just pure calculation
p30_pebiolc_price_emu_preloop_shifted(ttot,regi) = vm_pebiolc_price.l(ttot,regi); !!! save for reporting

s30_switch_shiftcalc = 0; !!! deactivate equations for shift calculation. This is necessary because the main model uses /all/

display p30_pebiolc_pricmult, p30_pebiolc_pricshift,p30_pebiolc_price_emu_preloop_shifted;

*** ============================================================
$endif 
*** ============================================================

***------------ Step 3: calculate bioenergy costs -------------
*** The costs are calculated applying the regular cost equation. 
*** This equation integrates the shifted (!) price supply curve over the demand.
*** It requires the price shift factor to be calcualted before (see above).

if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve model_biopresolve_c using cns; !!! nothing has to be optimized here, just pure calculation

p30_pebiolc_costs_emu_preloop(ttot,regi) = v30_pebiolc_costs.l(ttot,regi);

display p30_pebiolc_costs_emu_preloop;

***------------ Step 4: Release bounds on fuelex -------------
*** AFTER presolve calculations: prepare for main solve, therefore release bounds on fuelex
vm_fuExtr.lo(ttot,regi,"pebiolc","1") = 0;
vm_fuExtr.up(ttot,regi,"pebiolc","1") = inf;
*** Provide start values for fuelex
vm_fuExtr.l(ttot,regi,"pebiolc","1")  = p30_pebiolc_demandmag(ttot,regi);

***-------------------------------------------------------------
***  END: calculate shift factors
***-------------------------------------------------------------

*** EOF ./modules/30_biomass/magpie_4/preloop.gms

