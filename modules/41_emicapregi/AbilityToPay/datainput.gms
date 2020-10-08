*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/AbilityToPay/datainput.gms


*** read in data of cost-optimal reference climate policy run
Execute_Loadpoint "input_ref" p41_co2eq = vm_co2eq.l;
*** read in data of baseline run
Execute_Loadpoint "input_bau" p41_co2eq_bau = vm_co2eq.l;


*** Step 1: calculate regional mitigation based on cost-optimal and baseline emissions, and per-capita gdp (pm_gdp is in MER, pm_shPPPMER is the MER-PPP multiplier, 1 for USA, and ~0.3 for IND)
p41_precorrection_reduction(t,regi) = (pm_gdp(t,regi)/pm_shPPPMER(regi)/pm_pop(t,regi)/(sum(regi2,pm_gdp(t,regi2)/pm_shPPPMER(regi2))/sum(regi2,pm_pop(t,regi2))))** 1/3 
										*sum(regi2,p41_co2eq_bau(t,regi2)-p41_co2eq(t,regi2))/sum(regi2,p41_co2eq_bau(t,regi2))
										*p41_co2eq_bau(t,regi);
*** Step 2: Calculate correction factor
p41_correct_factor(t) = sum(regi2,p41_precorrection_reduction(t,regi2))/sum(regi2,p41_co2eq_bau(t,regi2)-p41_co2eq(t,regi2));

*** Step 3 is directly done in modules/41_emicapregi/AbilityToPay/bounds.gms	 
*** vm_perm.fx(t,regi) = p41_co2eq_bau(t,regi) - p41_precorrection_reduction(t,regi)/p41_correct_factor(t);

*** inititialization of pm_shPermit
pm_shPerm(t,regi) = (p41_co2eq_bau(t,regi) - p41_precorrection_reduction(t,regi)/p41_correct_factor(t))
                     /sum(regi2,p41_co2eq_bau(t,regi2) - p41_precorrection_reduction(t,regi2)/p41_correct_factor(t));		 
		 
*** EOF ./modules/41_emicapregi/AbilityToPay/datainput.gms
