*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffPhaseIn2Lin/postsolve.gms
***------------------------------------------------------------------------------------------------------------------------
*** *BS* 20190930 linear convergence with starting points differentiated by GDP/capita, global price from 2040
***-----------------------------------------------------------------------------------------------------------------------

***   *** updated constant global price as scalar (regional prices are the same anyway)
***   s45_constantCO2price = sum((ttot,regi)$(ttot.val eq s45_stageend), pm_taxCO2eq(ttot,regi))/card(regi) ;
***   *** entire path has been shifted in update, so have to set these again
***   pm_taxCO2eq(ttot,regi)$(ttot.val le s45_stagestart) = p45_tauCO2_ref(ttot, regi);
***   pm_taxCO2eq(ttot,regi)$(ttot.val gt s45_stagestart and ttot.val lt s45_stageend)
***     = s45_constantCO2price * (ttot.val - p45_phasein_zeroyear(regi))/(s45_stageend - p45_phasein_zeroyear(regi));
***   *** price trajectory should be constant anyway but let's be explicit here
***   pm_taxCO2eq(ttot,regi)$(ttot.val ge s45_stageend) = s45_constantCO2price;

display pm_taxCO2eq;
*** EOF ./modules/45_carbonprice/diffPhaseIn2Lin/postsolve.gms
