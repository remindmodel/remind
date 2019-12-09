*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/preloop.gms


*** The value of the capital price cannot be set in datainput as in calibration runs, pm_cesdata is computed in preloop.gms of module 29
p36_kapPrice(t,regi_dyn36(regi)) = pm_cesdata(t,regi,"kap","price") - pm_delta_kap(regi,"kap"); 
loop (fe2ces_dyn36(entyFe,esty,teEs,in),
p36_kapPriceImplicit(t,regi_dyn36(regi),teEs) = p36_kapPrice(t,regi) + p36_implicitDiscRateMarg(t,regi,in);
);

*** EOF ./modules/36_buildings/services_with_capital/preloop.gms
