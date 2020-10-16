*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC2constant/datainput.gms
***------------------------------------------------------------------------------------------------------------------------
*** *LB,BS* 20190927 calculation of tax paths for linear converge from NDC value in 2020 to constant global price in 2040
***-----------------------------------------------------------------------------------------------------------------------

*** can make this flexible later
s45_stagestart = 2020;
s45_stageend = 2040;
*** price from stageend onwards (value set here is for first iteration only, will be adjusted afterwards)
s45_constantCO2price = 500 * sm_DptCO2_2_TDpGtC;

*** get CO2 price before transition stage from reference (NDC) run
Execute_Loadpoint 'input_ref' p45_tauCO2_ref = pm_taxCO2eq;
pm_taxCO2eq(ttot,regi)$(ttot.val le s45_stagestart) = p45_tauCO2_ref(ttot,regi);
p45_NDCstartPrice(regi) = sum(ttot$(ttot.val eq s45_stagestart), p45_tauCO2_ref(ttot,regi));
display p45_tauCO2_ref;
display p45_NDCstartPrice;
*** linear transition to global price
pm_taxCO2eq(ttot,regi)$(ttot.val gt s45_stagestart and ttot.val lt s45_stageend)
  = p45_NDCstartPrice(regi) + (s45_constantCO2price - p45_NDCstartPrice(regi))/(s45_stageend-s45_stagestart) * (ttot.val - s45_stagestart);
*** constant price after end of transition stage
pm_taxCO2eq(ttot,regi)$(ttot.val ge s45_stageend) = s45_constantCO2price;

display pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/NDC2constant/datainput.gms
