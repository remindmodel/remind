*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDCexpo/datainput.gms
***----------------------------
*** CO2 Tax level
***----------------------------

*** CO2 tax level is calculated at an exponential increase from the tax level before cm_startyear
p45_tau_co2_tax(ttot, regi) = 0;

$ifthen exist "./modules/45_carbonprice/NDCexpo/input/p45_tau_co2_tax.inc"
$include "./modules/45_carbonprice/NDCexpo/input/p45_tau_co2_tax.inc"
$endif

pm_taxCO2eq(ttot,regi)$(ttot.val ge 2005) = p45_tau_co2_tax(ttot,regi);



*Execute_Loadpoint "input_ref" pm_taxCO2eq = pm_taxCO2eq;

*** calculate pm_taxCO2eq for year before startyear and then inceases with cm_taxCO2_expGrowth
pm_taxCO2eq(t,regi) = sum(ttot, pm_taxCO2eq(ttot,regi)$(ttot.val eq smax(ttot2$( ttot2.val lt cm_startyear ), ttot2.val))) * cm_taxCO2_expGrowth**(t.val-smax(ttot2$( ttot2.val lt cm_startyear ), ttot2.val));
pm_taxCO2eq(t,regi)$(t.val gt 2100) = pm_taxCO2eq("2100",regi); !! to prevent huge taxes after 2100 and the resulting convergence problems, set taxes after 2100 equal to 2100 value


*** EOF ./modules/45_carbonprice/NDCexpo/datainput.gms
