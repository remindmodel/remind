*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie/preloop.gms

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

*** Initialize shift and mult for standalone runs
*** If REMIND runs coupled to MAgPIE they get updated in presolve.gms
v30_priceshift.fx(ttot,regi) = 0;
v30_pricemult.fx(ttot,regi)  = 1;

***------------ Step 1: Fix fuelex to MAgPIE demand -------------
*** BEFORE calculation: Regular emulator equations are applied to calculate costs and prices. Therefore set demand (fuelex) in
*** the emulator equations for price and costs to demand from MAgPIE reporting
*** This step is repeated in presolve only if MAgPIE has been run before
vm_fuExtr.fx(ttot,regi,"pebiolc","1") = pm_pebiolc_demandmag(ttot,regi);

***------------ Step 2: calculate shift factors -------------
*** Is done in presolve and only if MAgPIE has been run before

***------------ Step 3: calculate bioenergy costs -------------
*** The costs are calculated applying the regular cost equation. 
*** This equation integrates the shifted (!) price supply curve over the demand.
*** It requires the price shift factor to be calculated before (see above).
*** This step is repeated in presolve only if MAgPIE has been run before

if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve model_biopresolve_c using cns; !!! nothing has to be optimized here, just pure calculation

p30_pebiolc_costs_emu_preloop(t,regi) = v30_pebiolc_costs.l(t,regi);

display p30_pebiolc_costs_emu_preloop;

***------------ Step 4: Release bounds on fuelex -------------
*** AFTER presolve calculations: prepare for main solve, therefore release bounds on fuelex
*** This step is repeated in presolve only if MAgPIE has been run before
vm_fuExtr.lo(ttot,regi,"pebiolc","1") = 0;
vm_fuExtr.up(ttot,regi,"pebiolc","1") = inf;
*** Provide start values for fuelex
vm_fuExtr.l(ttot,regi,"pebiolc","1")  = pm_pebiolc_demandmag(ttot,regi);


*** load values of v30_BioPEProdTotal from input GDX as this is required for switch cm_bioprod_regi_lim 
$IFTHEN.bioprod_regi_lim not "%cm_bioprod_regi_lim%" == "off"
Execute_Loadpoint 'input' v30_BioPEProdTotal.l = v30_BioPEProdTotal.l;
$ENDIF.bioprod_regi_lim


*** EOF ./modules/30_biomass/magpie/preloop.gms

