*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/expoLinear/datainput.gms

*** Carbon price increases exponentially with rate given by cm_co2_tax_growth (default = 4.5%) %) until cm_expoLinear_yearStart (defaults to 2060) 
*** and then transitions into linear growth (with slope given by last timestep before  cm_expoLinear_yearStart).


if(cm_co2_tax_startyear le 0,
  abort "please choose a valid cm_co2_tax_startyear"
elseif cm_co2_tax_startyear gt 0,
*** convert tax value from $/t CO2eq to T$/GtC
  s45_co2_tax_startyear = cm_co2_tax_startyear * sm_DptCO2_2_TDpGtC;
);

*LKS* code cleaning: usage of ttot should be replaced by t.
*LB* calculate tax path until cm_expoLinear_yearStart (defaults to 2060)
pm_taxCO2eq(ttot,regi)$(ttot.val ge cm_startyear) = s45_co2_tax_startyear*cm_co2_tax_growth**(ttot.val-cm_startyear);
*LB* use linear tax path from cm_expoLinear_yearStart on
p45_tau_co2_tax_inc(regi) = sum(ttot$(ttot.val eq cm_expoLinear_yearStart),((pm_taxCO2eq(ttot, regi) - pm_taxCO2eq(ttot - 1, regi)) / (pm_ttot_val(ttot) - pm_ttot_val(ttot - 1)))); 
pm_taxCO2eq(ttot,regi)$(ttot.val gt cm_expoLinear_yearStart) = sum(t$(t.val eq cm_expoLinear_yearStart), pm_taxCO2eq(t, regi) +  p45_tau_co2_tax_inc(regi) * (pm_ttot_val(ttot) - pm_ttot_val(t)))  ;
*** set carbon price constant after 2110 to prevent huge carbon prices which lead to convergence problems
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2110) = pm_taxCO2eq("2110",regi);

display pm_taxCO2eq;
display p45_tau_co2_tax_inc;

*** EOF ./modules/45_carbonprice/expoLinear/datainput.gms
