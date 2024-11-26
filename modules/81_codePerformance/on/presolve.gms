*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/81_codePerformance/on/presolve.gms
*ag* start performance test loop
LOOP(run  $(ord(run)<(c81_runs+1)),

IF(MOD(ord(run)+2,3) EQ 0,
cm_taxCO2_startyear = 0;
ELSEIF MOD(ord(run)+2,3) EQ 1,
cm_taxCO2_startyear = 30;
ELSEIF MOD(ord(run)+2,3) EQ 2,
cm_taxCO2_startyear = 150;
);

*** Globally uniform, exponentially increasing carbonprice starting from the tax level (exogenously defined above) in the start year
pm_taxCO2eq(t,regi) = cm_taxCO2_startyear * sm_DptCO2_2_TDpGtC * cm_taxCO2_expGrowth**(t.val-cm_startyear); 
pm_taxCO2eq("2005",regi)=0;

display pm_taxCO2eq;

*** EOF ./modules/81_codePerformance/on/presolve.gms
