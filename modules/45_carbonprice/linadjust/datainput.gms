*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/linadjust/datainput.gms
***-------------------------------------------------------------------------------
*** *GL,IM* 20140402 calculation of tax paths for staged accession
***-------------------------------------------------------------------------------
s45_stagestart = cm_stagestart;
s45_stageend = cm_stageend; 

*** calculate tax paths based on carbon prices from reference policy and first best policy loaded from gdxs
Execute_Loadpoint 'input_ref' p45_pvpRegi_ref = pm_pvpRegi;
p45_tauCO2_ref(ttot, regi)$(ttot.val ge 2005) = p45_pvpRegi_ref(ttot,regi,"perm") / p45_pvpRegi_ref(ttot,regi,"good");

Execute_Loadpoint 'input_opt' p45_pvpRegi_opt = pm_pvpRegi;
p45_tauCO2_opt(ttot, regi)$(ttot.val ge 2005) = p45_pvpRegi_opt(ttot,regi,"perm") / p45_pvpRegi_opt(ttot,regi,"good");

pm_taxCO2eq(ttot,regi)$(ttot.val ge 2005 and ttot.val le s45_stagestart) = p45_tauCO2_ref(ttot, regi);
 
*** calculate carbon price path for period of staged accession: linear interpolation between price of reference policy and marked-up price of first best policy
pm_taxCO2eq(ttot,regi)$(ttot.val > s45_stagestart AND ttot.val < s45_stageend )  
  = (s45_stageend - ttot.val) / (s45_stageend - s45_stagestart) * p45_tauCO2_ref(ttot,regi) 
  + (ttot.val - s45_stagestart)	/ (s45_stageend - s45_stagestart) * p45_tauCO2_opt(ttot,regi);

*** calculate carbon price for period of comprehensive cooperation (after staged accession): price path from first best (e.g. SPA0) with markup factor
pm_taxCO2eq(ttot,regi)$(ttot.val >= s45_stageend) =  p45_tauCO2_opt(ttot,regi);

*** assign carbon price for period after 2100 to that of 2100 (that is needed when the input_opt is from runs with no carbon price after 2100 e.g. budget runs)
pm_taxCO2eq(ttot,regi)$(ttot.val > 2100) = pm_taxCO2eq("2100",regi);

display p45_tauCO2_ref, p45_tauCO2_opt, pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/linadjust/datainput.gms
