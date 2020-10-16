*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/81_codePerformance/on/presolve.gms
*ag* start performance test loop
LOOP(run  $(ord(run)<(c81_runs+1)),

IF(MOD(ord(run)+2,3) EQ 0,
cm_co2_tax_2020 = 0;
ELSEIF MOD(ord(run)+2,3) EQ 1,
cm_co2_tax_2020 = 30;
ELSEIF MOD(ord(run)+2,3) EQ 2,
cm_co2_tax_2020 = 150;
);

*** CO2 tax level is calculated at a 5% exponential increase from the 2020 tax level exogenously defined

*GL: tax path in 10^12$/GtC = 1000 $/tC
*** according to Asian Modeling Excercise tax case setup, 30$/t CO2eq in 2020 = 0.110 k$/tC

if(cm_co2_tax_2020 lt 0,
abort "please choose a valid cm_co2_tax_2020"
elseif cm_co2_tax_2020 ge 0,
*** cocnvert tax value from $/t CO2eq to T$/GtC
pm_taxCO2eq("2020",regi)= cm_co2_tax_2020 * sm_DptCO2_2_TDpGtC;
);

pm_taxCO2eq(ttot,regi)$(ttot.val ge 2005) = pm_taxCO2eq("2020",regi)*cm_co2_tax_growth**(ttot.val-2020);
pm_taxCO2eq("2005",regi)=0;

display pm_taxCO2eq;

*** EOF ./modules/81_codePerformance/on/presolve.gms
