*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffPriceSameCost/datainput.gms




*start from uniform price trrajectory

*exponential code:
if(cm_co2_tax_2020 lt 0,
abort "please choose a valid cm_co2_tax_2020"
elseif cm_co2_tax_2020 ge 0,
*** cocnvert tax value from $/t CO2eq to T$/GtC
pm_taxCO2eq("2020",regi)= cm_co2_tax_2020 * sm_DptCO2_2_TDpGtC;
);

pm_taxCO2eq(ttot,regi)$(ttot.val ge 2005) = pm_taxCO2eq("2020",regi)*cm_co2_tax_growth**(ttot.val-2020);

*LB* read in GDP from baseline scenario
p45_gdpBAU(ttot,regi) = 0;
Execute_Loadpoint 'input_bau'      vm_cesIO;
p45_gdpBAU(ttot,regi)    = vm_cesIO.l(ttot,regi,"inco");
*** EOF ./modules/45_carbonprice/diffPriceSameCost/datainput.gms
