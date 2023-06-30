*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi/datainput.gms

pm_taxCO2eq(ttot,regi)$(ttot.val lt 2020) = 0;

*** Carbon prices defined in $/t CO2, will be rescaled to right unit at the end of this file

parameter f45_taxCO2eqHist(ttot,all_regi)       "historic CO2 prices ($/tCO2)"
/
$ondelim
$include "./modules/45_carbonprice/NPi/input/pm_taxCO2eqHist.cs4r"
$offdelim
/
;

pm_taxCO2eq(t,regi)$(t.val < 2025) = f45_taxCO2eqHist(t,regi);

*** convergence scheme post 2020: parabolic convergence up to 40$/tCO2 in the convergence year (here chosen as 2070) and then linear increase of 2$/year afterwards
pm_taxCO2eq(ttot,regi)$( (ttot.val ge 2025) AND (ttot.val le 2070)) =
  pm_taxCO2eq("2020",regi) 
  + ( 
      ( 40 - pm_taxCO2eq("2020",regi) ) 
      * ( 
          (ttot.val - 2020) / (2070 - 2020) 
        ) ** 2 
    )
;
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2070) = pm_taxCO2eq("2070",regi) + (ttot.val - 2070) * 0.5;

*** rescale everything to $/t CO2
pm_taxCO2eq(ttot,regi) = pm_taxCO2eq(ttot,regi) * sm_DptCO2_2_TDpGtC;

display pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/NPi/datainput.gms
