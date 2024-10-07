*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPiexpo/datainput.gms
***----------------------------
*** CO2 Tax level
***----------------------------

*** CO2 tax level is calculated at an exponential increase from the tax level before cm_startyear

Execute_Loadpoint "input_ref" pm_taxCO2eq = pm_taxCO2eq;

*** calculate pm_taxCO2eq for year before startyear
pm_taxCO2eq(t,regi) = sum(ttot, pm_taxCO2eq(ttot,regi)$(ttot.val eq smax(ttot2$( ttot2.val lt cm_startyear ), ttot2.val))) * cm_co2_tax_growth**(t.val-smax(ttot2$( ttot2.val lt cm_startyear ), ttot2.val));
pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value


*** EOF ./modules/45_carbonprice/NPiexpo/datainput.gms
