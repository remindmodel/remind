*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/datainput.gms




*** initialization of pm_shPermit and vm_perm for preloop not used as condition in optimization
pm_emicapglob(t) = 100;
pm_shPerm(t,regi) = 1;
vm_perm.fx(t,regi) = 0;

*** get global GDP
p41_gdpGlob(t) =
    sum(regi, pm_gdp(t,regi));
	 
*** EOF ./modules/41_emicapregi/JUSTMip/datainput.gms
