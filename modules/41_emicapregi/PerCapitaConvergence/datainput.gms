*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/PerCapitaConvergence/datainput.gms

***   contraction & convergence (reference year 2020)  +++++++++
p41_convergenceyear = 2050;
p41_lambda(tall) $(tall.val < p41_convergenceyear) = (tall.val - 2020) / (p41_convergenceyear-2020);
p41_lambda(tall) $(tall.val>2049) = 1;

*** read in data of cost-optimal reference climate policy run
Execute_Loadpoint "input_ref" p41_co2eq = vm_co2eq.l;

***calculate 2020 share of emissions by region
p41_shEmi20200(regi) = p41_co2eq("2020",regi) / sum(regi2, p41_co2eq("2020",regi2) );
display p41_shEmi2020;

*** calculate global emissions pathway in cost-optimal scenario
pm_emicapglob(ttot) = sum(regi, p41_co2eq(ttot,regi));

*** calculate share of global emissions 
     pm_shPerm(t,regi) =  p41_lambda(t) * pm_pop(t,regi) / sum(regi2,pm_pop(t,regi2))
         + (1 - p41_lambda(t)) * p41_shEmi2020(regi) / sum(regi2, p41_shEmi2020(regi2));

		 
		 
*** EOF ./modules/41_emicapregi/PerCapitaConvergence/datainput.gms
