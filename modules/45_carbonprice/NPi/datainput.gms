*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi/datainput.gms

*** Historic data including year 2020 is read in core/datainput.gms

*** convergence scheme post 2020: parabolic convergence up to 25$/tCO2 in the convergence year (here chosen as 2100) and then constant
pm_taxCO2eq(ttot,regi)$( (ttot.val ge 2025) AND (ttot.val le 2100)) =
  pm_taxCO2eq("2020",regi) 
  + ( 
      ( 25 * sm_D2005_2_D2017 * sm_DptCO2_2_TDpGtC - pm_taxCO2eq("2020",regi) )
      * ( 
          (ttot.val - 2020) / (2100 - 2020)
        ) ** 2 
    )
;
pm_taxCO2eq(ttot,regi)$(ttot.val gt 2100) = pm_taxCO2eq("2100",regi);

display pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/NPi/datainput.gms
