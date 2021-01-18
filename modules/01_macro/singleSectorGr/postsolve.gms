*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr/postsolve.gms
*** Consumption per capita
pm_consPC(ttot,regi)$(ttot.val gt 2005 and ttot.val le 2150 and (pm_SolNonInfes(regi) eq 1) ) =
    vm_cons.l(ttot,regi)/pm_pop(ttot,regi)
;

*** Interpolate years
loop(ttot$(ttot.val ge 2005),
	loop(tall$(pm_tall_2_ttot(tall, ttot)),
		pm_consPC(tall,regi) =
		    (1- pm_interpolWeight_ttot_tall(tall)) * pm_consPC(ttot,regi)
		    + pm_interpolWeight_ttot_tall(tall) * pm_consPC(ttot + 1,regi);
));
pm_consPC(tall,regi)$(tall.val gt 2150) = pm_consPC("2150",regi);
*** EOF ./modules/01_macro/singleSectorGr/postsolve.gms
