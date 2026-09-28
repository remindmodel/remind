*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/datainput.gms

*** get global GDP -- NOTE: should be moved to postsolve to be continuously updated as pm_gdp changes over the iterations
p41_gdpGlob(t) =
    sum(regi, pm_gdp(t,regi));

*** initiate trade volume of other regions to 0 for the first iteration
pm_otherRegionsTradeVolume(t,regi) = 0;
vm_permTradeVolumeGlo.l(t,regi) = 0;	 

*** EOF ./modules/41_emicapregi/JUSTMip/datainput.gms
