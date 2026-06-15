*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/TradingOnRef/datainput.gms


*** read in data of cost-optimal reference climate policy run
*' load CO2 emissions from reference run to assing the allocates permits

Execute_Loadpoint "input_ref" p41_co2eq_in = vm_emiAll.l;
p41_co2eq(t, regi) = p41_co2eq_in(t,regi,"co2");


*** initialization of pm_shPermit
pm_emicapglob(t) = sum(regi, p41_co2eq(t,regi));
pm_shPerm(t,regi) = p41_co2eq(t,regi) / pm_emicapglob(t);

		 
*** EOF ./modules/41_emicapregi/TradingOnRef/datainput.gms
