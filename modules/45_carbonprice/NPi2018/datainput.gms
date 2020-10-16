*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi2018/datainput.gms

Execute_Loadpoint "input_ref" pm_taxCO2eq = pm_taxCO2eq;

*** convergence scheme post 2020: exponential increase of 5$ dollar in 2020with 1.25% AND regional convergence
pm_taxCO2eq(ttot,regi)$(ttot.val ge cm_startyear) =
  (sum(ttot2,(pm_taxCO2eq(ttot2,regi)$(ttot2.val eq cm_startyear -5)))*max(2100-cm_startyear-5-ttot.val+cm_startyear,0)
  + 5 * sm_DptCO2_2_TDpGtC * 1.0125**(ttot.val-cm_startyear)*min(ttot.val-cm_startyear,2100-cm_startyear))/(2100-cm_startyear);

display pm_taxCO2eq;
*** EOF ./modules/45_carbonprice/NPi2018/datainput.gms
