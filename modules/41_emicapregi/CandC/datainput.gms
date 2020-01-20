*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/CandC/datainput.gms

***   contraction & convergence (reference year 2005)  +++++++++
p41_lambda(tall) $(tall.val<2050) = (tall.val - 2005) / 45;
p41_lambda(tall) $(tall.val>2049) = 1;

Execute_Loadpoint "input_ref" p41_co2eq = vm_co2eq.l;

p41_shEmi2005(regi) = p41_co2eq("2005",regi) / sum(regi2, p41_co2eq("2005",regi2) );
display p41_shEmi2005;

     pm_shPerm(t,regi) =  p41_lambda(t) * pm_pop(t,regi) / sum(regi2,pm_pop(t,regi2))
         + (1 - p41_lambda(t)) * p41_shEmi2005(regi) / sum(regi2, p41_shEmi2005(regi2));
*** EOF ./modules/41_emicapregi/CandC/datainput.gms
