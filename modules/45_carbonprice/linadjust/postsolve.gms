*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/linadjust/postsolve.gms
*** calculate carbon price path for period of staged accession: linear interpolation between price of reference policy and marked-up price of first best policy as calculated from iterative adjustment

*#' @equations
*#' calculate carbon price path for period of staged accession: 
*#' linear interpolation between price of reference policy and marked-up price of first best policy as calculated from iterative adjustment
pm_taxCO2eq(ttot,regi)$(ttot.val > s45_stagestart AND ttot.val < s45_stageend )  
  = (s45_stageend - ttot.val) / (s45_stageend - s45_stagestart) * p45_tauCO2_ref(ttot,regi) +
	(ttot.val - s45_stagestart)	/ (s45_stageend - s45_stagestart) * p45_tauCO2_opt(ttot,regi) * 
	sum(ttot2$(ttot2.val eq s45_stageend),
        pm_taxCO2eq(ttot2,regi)/ p45_tauCO2_opt(ttot2,regi)
    ) 
;

display pm_taxCO2eq;
*** EOF ./modules/45_carbonprice/linadjust/postsolve.gms
