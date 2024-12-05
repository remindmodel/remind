*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi2025expo/datainput.gms

***----------------------------
*** CO2 Tax level growing exponentially from 2025 value taken from input data
***----------------------------

pm_taxCO2eq(ttot,regi)$(ttot.val le 2025) = fm_taxCO2eqHist(ttot,regi) * sm_DptCO2_2_TDpGtC;

pm_taxCO2eq(t,regi)$(t.val gt 2025) = sum(ttot, pm_taxCO2eq(ttot,regi)$(ttot.val eq 2025)) * cm_taxCO2_expGrowth**(t.val - 2025);

loop(ext_regi$sameas(ext_regi, "EUR_regi"),
  pm_taxCO2eq(t,regi)$(t.val ge 2030 AND regi_group(ext_regi,regi)) = fm_taxCO2eqHist("2030",regi) * sm_DptCO2_2_TDpGtC * cm_taxCO2_expGrowth**(t.val - 2030);
);

pm_taxCO2eq(t,regi)$(t.val gt 2100) = pm_taxCO2eq("2100",regi); !! to prevent huge taxes after 2100 and the resulting convergence problems, set taxes after 2100 equal to 2100 value

*** EOF ./modules/45_carbonprice/NPi2025expo/datainput.gms
