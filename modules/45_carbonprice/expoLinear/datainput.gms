*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/expoLinear/datainput.gms

*** CO2 tax level is calculated at a 5% exponential increase from the 2020 tax level exogenously defined

*** convert tax value from $/t CO2eq to T$/GtC
pm_taxCO2eq("2020",regi)= cm_co2_tax_2020 * sm_DptCO2_2_TDpGtC;

*LB* calculate tax path until cm_expoLinear_yearStart (defaults to 2060)
pm_taxCO2eq(ttot,regi)$(ttot.val ge max(2020,cm_startyear) ) = pm_taxCO2eq("2020",regi)*cm_co2_tax_growth**(ttot.val-2020);
*LB* use linear tax path from cm_expoLinear_yearStart on
p45_tau_co2_tax_inc(regi) = sum(ttot$(ttot.val eq cm_expoLinear_yearStart),((pm_taxCO2eq(ttot, regi) - pm_taxCO2eq(ttot - 1, regi)) / (pm_ttot_val(ttot) - pm_ttot_val(ttot - 1)))); 
pm_taxCO2eq(ttot,regi)$(ttot.val gt cm_expoLinear_yearStart) = sum(t$(t.val eq cm_expoLinear_yearStart), pm_taxCO2eq(t, regi) +  p45_tau_co2_tax_inc(regi) * (pm_ttot_val(ttot) - pm_ttot_val(t)))  ;
*** set carbon price constant after 2110 to prevent huge carbon prices which lead to convergence problems
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2110) = pm_taxCO2eq("2110",regi);

display pm_taxCO2eq;
display p45_tau_co2_tax_inc;

*** EOF ./modules/45_carbonprice/expoLinear/datainput.gms
