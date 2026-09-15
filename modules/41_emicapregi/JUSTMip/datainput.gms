*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/datainput.gms




*** initialization of pm_shPermit and vm_perm for preloop not used as condition in optimization
pm_emicapglob(t) = 
sum(regi, vm_perm(t,regi));

pm_shPerm(t,regi) = 
vm_perm(t,regi) / pm_emicapglob(t);


*** get global GDP
p41_gdpGlob(t) =
    sum(regi, pm_gdp(t,regi));
	 
*** EOF ./modules/41_emicapregi/JUSTMip/datainput.gms
