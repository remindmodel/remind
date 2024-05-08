*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/postsolve.gms

*-------------------------------calculate regional permit prices-----------------------------------

*** saving CO2 tax used in this iteration
p_taxCO2eq_iteration(iteration,ttot,regi) = pm_taxCO2eq(ttot,regi);
pm_taxemiMkt_iteration(iteration,ttot,regi,emiMkt) = pm_taxemiMkt(ttot,regi,emiMkt);

if( (cm_emiscen eq 6), 
$ifthen.neg %optimization% == 'negishi'     
    pm_taxCO2eqSum(ttot,regi) = abs((abs(q_co2eq.m(ttot,regi)) / pm_ts(ttot)) / (pm_pvp(ttot,"good") + sm_eps));
$else.neg
    pm_taxCO2eqSum(ttot,regi) = abs( abs(q_co2eq.m(ttot,regi)) / (abs(qm_budget.m(ttot,regi))+ sm_eps) );
$endif.neg 
   elseif (cm_emiscen eq 1),  !! even in a BAU scenario without other climate policies, the 2010/2015/2020 CO2 prices should be reported (that still needs to be fixed, I guess, maybe by adding the historic prices to the 45/carbonprice/off variation
    pm_taxCO2eqSum(ttot,regi)$(ttot.val < 2025) = pm_taxCO2eq(ttot,regi); 
);

if(cm_iterative_target_adj eq 4,
*JeS* Iteratively update regional CO2 tax trajectories / regional CO2 budget to reach the FF&I budget target (s_actualbudgetco2 runs from 2020-2100, not peak budget)
*KK* for a time step of 5 years, the budget is calculated as 3 * 2020 + ts(2025-2090) + 8 * 2100;
*** 10-pm_ts("2090")/2 and pm_ts("2020")/2 are the time periods that haven't been taken into account in the sum over ttot.
*** 0.5 year of emissions is added for the two boundaries, such that the budget is calculated for 81 years.
s_actualbudgetco2 =           sum(ttot$(ttot.val le 2090 AND ttot.val > 2020), (sum(regi, vm_emiTe.l(ttot,regi,"co2") + vm_emiMacSector.l(ttot,regi,"co2cement_process")) * sm_c_2_co2 * pm_ts(ttot)))
                            + sum(regi, vm_emiTe.l("2100",regi,"co2") + vm_emiMacSector.l("2100",regi,"co2cement_process")) * sm_c_2_co2 * (10 - pm_ts("2090")/2 + 0.5)
                            + sum(regi, vm_emiTe.l("2020",regi,"co2") + vm_emiMacSector.l("2020",regi,"co2cement_process")) * sm_c_2_co2 * (pm_ts("2020")/2 + 0.5);
display s_actualbudgetco2;
		
	if (cm_emiscen eq 6,
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display sm_budgetCO2eqGlob;		
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob + ((1/sm_c_2_co2) * (c_budgetCO2from2020FFI - s_actualbudgetco2));
			pm_budgetCO2eq(regi) = pm_budgetCO2eq(regi) + ((1/sm_c_2_co2) * (c_budgetCO2from2020FFI - s_actualbudgetco2) / card(regi));
		else
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob;
		);
		display sm_budgetCO2eqGlob;
	elseif cm_emiscen eq 9,
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display pm_taxCO2eq;		
			pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) * (s_actualbudgetco2/c_budgetCO2from2020FFI);
		else
			pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi);
		);
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
		display pm_taxCO2eq;
	 );
);

if(cm_iterative_target_adj eq 5,
*JeS* Iteratively update regional CO2 tax trajectories / regional CO2 budget to reach the global emission budget (s_actualbudgetco2 runs from 2020-2100, not peak budget)
*KK* for a time step of 5 years, the budget is calculated as 3 * 2020 + ts(2025-2090) + 8 * 2100;
*** 10-pm_ts("2090")/2 and pm_ts("2020")/2 are the time periods that haven't been taken into account in the sum over ttot.
*** 0.5 year of emissions is added for the two boundaries, such that the budget is calculated for 81 years.
s_actualbudgetco2 =           sum(ttot$(ttot.val le 2090 AND ttot.val > 2020), (sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot)))
                            + sum(regi, vm_emiTe.l("2100",regi,"co2") + vm_emiCdr.l("2100",regi,"co2") + vm_emiMac.l("2100",regi,"co2")) * sm_c_2_co2 * (10 - pm_ts("2090")/2 + 0.5)
                            + sum(regi, vm_emiTe.l("2020",regi,"co2") + vm_emiCdr.l("2020",regi,"co2") + vm_emiMac.l("2020",regi,"co2")) * sm_c_2_co2 * (pm_ts("2020")/2 + 0.5);

display s_actualbudgetco2;
		
	if (cm_emiscen eq 6,
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display sm_budgetCO2eqGlob;		
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob * (c_budgetCO2from2020/s_actualbudgetco2);
			pm_budgetCO2eq(regi) = pm_budgetCO2eq(regi) * (c_budgetCO2from2020/s_actualbudgetco2);
		else
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob;
		);
		display sm_budgetCO2eqGlob;
	elseif cm_emiscen eq 9,
		display pm_taxCO2eq;
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2from2020 - s_actualbudgetco2) ge 0.5,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
		  sm_globalBudget_dev = s_actualbudgetco2 / c_budgetCO2from2020; 
*** make sure that iteration converges: 
*** use multiplicative for budgets higher than 1200 Gt; for lower budgets, use multiplicative adjustment only for first 3 iterations, 
			if(ord(iteration) lt 3 or c_budgetCO2from2020 > 1200,
			    !! change in CO2 price through adjustment: new price - old price; needed for adjustment option 2
				pm_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq(t,regi) * min(max((s_actualbudgetco2/c_budgetCO2from2020)** (25/(2 * iteration.val + 23)),0.5+iteration.val/208),2 - iteration.val/102)  - pm_taxCO2eq(t,regi);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + pm_taxCO2eq_iterationdiff(t,regi) ;
*** then switch to triangle-approximation based on last two iteration data points			
			else
			    !! change in CO2 price through adjustment: new price - old price; the two instances of "pm_taxCO2eq" cancel out -> only the difference term
				pm_taxCO2eq_iterationdiff_tmp(t,regi) = 
				                      max(pm_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2from2020 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + 
				                      max(pm_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2from2020 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
			    pm_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq_iterationdiff_tmp(t,regi);
			);
      o_taxCO2eq_iterDiff_Itr(iteration,regi) = pm_taxCO2eq_iterationdiff("2030",regi);
		else
			if(s_actualbudgetco2 > 0 or abs(c_budgetCO2from2020 - s_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi);
				o_taxCO2eq_iterDiff_Itr(iteration,regi) = 0;
			else
*** if budget has turned negative, reduce CO2 price by 20%
				pm_taxCO2eq_iterationdiff(t,regi) = -0.2*pm_taxCO2eq(t,regi);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + pm_taxCO2eq_iterationdiff(t,regi);
				o_taxCO2eq_iterDiff_Itr(iteration,regi) = pm_taxCO2eq_iterationdiff("2030",regi);
			);	
		);
		display o_taxCO2eq_iterDiff_Itr;
		
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
    display pm_taxCO2eq;
	);
);

if(cm_iterative_target_adj eq 6,
*JeS* Iteratively update regional CO2 tax trajectories / regional CO2 budget to reach the target for global peak budget

*KK* p_actualbudgetco2 for ttot > 2020. It includes emissions from 2020 to ttot (including ttot).
*** (ttot.val - (ttot - 1).val)/2 and pm_ts("2020")/2 are the time periods that haven't been taken into account in the sum over ttot2.
*** 0.5 year of emissions is added for the two boundaries, such that the budget includes emissions in ttot.
p_actualbudgetco2(ttot)$(ttot.val > 2020) = sum(ttot2$(ttot2.val < ttot.val AND ttot2.val > 2020), (sum(regi, (vm_emiTe.l(ttot2,regi,"co2") + vm_emiCdr.l(ttot2,regi,"co2") + vm_emiMac.l(ttot2,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot2)))
                       + sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * ((pm_ttot_val(ttot)-pm_ttot_val(ttot-1))/2 + 0.5)
                       + sum(regi, (vm_emiTe.l("2020",regi,"co2") + vm_emiCdr.l("2020",regi,"co2") + vm_emiMac.l("2020",regi,"co2"))) * sm_c_2_co2 * (pm_ts("2020")/2 + 0.5);

s_actualbudgetco2 = smax(t,p_actualbudgetco2(t));
display s_actualbudgetco2;
		
	if (cm_emiscen eq 6,
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display sm_budgetCO2eqGlob;		
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob * (c_budgetCO2from2020/s_actualbudgetco2);
			pm_budgetCO2eq(regi) = pm_budgetCO2eq(regi) * (c_budgetCO2from2020/s_actualbudgetco2);
		else
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob;
		);
		display sm_budgetCO2eqGlob;
	elseif cm_emiscen eq 9,
		display pm_taxCO2eq;
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2from2020 - s_actualbudgetco2) ge 0.5,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
*** make sure that iteration converges: 
*** use multiplicative for budgets higher than 1200 Gt; for lower budgets, use multiplicative adjustment only for first 3 iterations, 
			if(ord(iteration) lt 3 or c_budgetCO2from2020 > 1200,
			    !! change in CO2 price through adjustment: new price - old price; needed for adjustment option 2
				pm_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq(t,regi) * min(max((s_actualbudgetco2/c_budgetCO2from2020)** (25/(2 * iteration.val + 23)),0.5+iteration.val/208),2 - iteration.val/102)  - pm_taxCO2eq(t,regi);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + pm_taxCO2eq_iterationdiff(t,regi) ;
*** then switch to triangle-approximation based on last two iteration data points			
			else
			    !! change in CO2 price through adjustment: new price - old price; the two instances of "pm_taxCO2eq" cancel out -> only the difference term
				pm_taxCO2eq_iterationdiff_tmp(t,regi) = 
				                      max(pm_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2from2020 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + 
				                      max(pm_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2from2020 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
			    pm_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq_iterationdiff_tmp(t,regi);
			);
      o_taxCO2eq_iterDiff_Itr(iteration,regi) = pm_taxCO2eq_iterationdiff("2030",regi);
		else
			if(s_actualbudgetco2 > 0 or abs(c_budgetCO2from2020 - s_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi);
				o_taxCO2eq_iterDiff_Itr(iteration,regi) = 0;
			else
*** if budget has turned negative, reduce CO2 price by 20%
				pm_taxCO2eq_iterationdiff(t,regi) = -0.2*pm_taxCO2eq(t,regi);
				pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi) + pm_taxCO2eq_iterationdiff(t,regi);
				o_taxCO2eq_iterDiff_Itr(iteration,regi) = pm_taxCO2eq_iterationdiff("2030",regi);
			);	
		);
		display o_taxCO2eq_iterDiff_Itr;
		
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
    display pm_taxCO2eq;
	);
);

*** ---------------------------------------------------------------------------------------------------------------
*** ENGAGE peakBudg formulation that works with several CO2 price path realizations of module 45 ---------------------
*** it results in a peak budget with zero net CO2 emissions afterwards
*** ---------------------------------------------------------------------------------------------------------------
if(cm_iterative_target_adj eq 7,
*JeS/CB* Iteratively update regional CO2 tax trajectories / regional CO2 budget to reach the target for global peak budget, but make sure CO2 emissions afterward are close to zero on the global level
 
*** Save the original functional form of the CO2 price trajectory so values for all times can be accessed even if the peakBudgYr is shifted. 
  if( iteration.val eq 1, 
    p_taxCO2eq_until2150(t,regi) = pm_taxCO2eq(t,regi);
	); 

*KK* p_actualbudgetco2 for ttot > 2020. It includes emissions from 2020 to ttot (including ttot).
*** (ttot.val - (ttot - 1).val)/2 and pm_ts("2020")/2 are the time periods that haven't been taken into account in the sum over ttot2.
*** 0.5 year of emissions is added for the two boundaries, such that the budget includes emissions in ttot.
p_actualbudgetco2(ttot)$(ttot.val > 2020) = sum(ttot2$(ttot2.val < ttot.val AND ttot2.val > 2020), (sum(regi, (vm_emiTe.l(ttot2,regi,"co2") + vm_emiCdr.l(ttot2,regi,"co2") + vm_emiMac.l(ttot2,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot2)))
                       + sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * ((pm_ttot_val(ttot)-pm_ttot_val(ttot-1))/2 + 0.5)
                       + sum(regi, (vm_emiTe.l("2020",regi,"co2") + vm_emiCdr.l("2020",regi,"co2") + vm_emiMac.l("2020",regi,"co2"))) * sm_c_2_co2 * (pm_ts("2020")/2 + 0.5);
s_actualbudgetco2 = smax(t$(t.val le c_peakBudgYr AND t.val le 2100),p_actualbudgetco2(t));
							

  o_peakBudgYr_Itr(iteration) = c_peakBudgYr;
							
display s_actualbudgetco2;  
display p_actualbudgetco2;

	if (cm_emiscen eq 9,
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2from2020 - s_actualbudgetco2) ge 0.5,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
		display pm_taxCO2eq;		
*** make sure that iteration converges: 
*** use multiplicative for budgets higher than 1600 Gt; for lower budgets, use multiplicative adjustment only for first 3 iterations, 
			if(ord(iteration) lt 3 or c_budgetCO2from2020 > 1600,
			    !! change in CO2 price through adjustment: new price - old price; needed for adjustment option 2
				pm_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq(t,regi) * min(max((s_actualbudgetco2/c_budgetCO2from2020)** (25/(2 * iteration.val + 23)),0.5+iteration.val/208),2 - iteration.val/102)  - pm_taxCO2eq(t,regi);
				pm_taxCO2eq(t,regi)$(t.val le c_peakBudgYr) = pm_taxCO2eq(t,regi) + pm_taxCO2eq_iterationdiff(t,regi) ;
				p_taxCO2eq_until2150(t,regi) = p_taxCO2eq_until2150(t,regi) + pm_taxCO2eq_iterationdiff(t,regi) ;
*** then switch to triangle-approximation based on last two iteration data points			
			else
			    !! change in CO2 price through adjustment: new price - old price; the two instances of "pm_taxCO2eq" cancel out -> only the difference term
				!! until c_peakBudgYr: expolinear price trajectory
				pm_taxCO2eq_iterationdiff_tmp(t,regi) = 
				                      max(pm_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2from2020 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
				pm_taxCO2eq(t,regi)$(t.val le c_peakBudgYr) = pm_taxCO2eq(t,regi) + 
				                      max(pm_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2from2020 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-pm_taxCO2eq(t,regi)/2);
			    p_taxCO2eq_until2150(t,regi) = p_taxCO2eq_until2150(t,regi) + 
				                      max(pm_taxCO2eq_iterationdiff(t,regi) * min(max((c_budgetCO2from2020 - s_actualbudgetco2)/(s_actualbudgetco2 - s_actualbudgetco2_last),-2),2),-p_taxCO2eq_until2150(t,regi)/2);
				pm_taxCO2eq_iterationdiff(t,regi) = pm_taxCO2eq_iterationdiff_tmp(t,regi);
				!! after c_peakBudgYr: adjustment so that emissions become zero: increase/decrease tax in each time step after c_peakBudgYr by percentage of that year's total CO2 emissions of 2015 emissions
			);
      o_taxCO2eq_iterDiff_Itr(iteration,regi) = pm_taxCO2eq_iterationdiff("2030",regi);
      display o_taxCO2eq_iterDiff_Itr;
		else
			if(s_actualbudgetco2 > 0 or abs(c_budgetCO2from2020 - s_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
			pm_taxCO2eq(t,regi) = pm_taxCO2eq(t,regi);
			else
*** if budget has turned negative, reduce CO2 price by 20%
			pm_taxCO2eq(t,regi) = 0.8*pm_taxCO2eq(t,regi);
			p_taxCO2eq_until2150(t,regi) = 0.8*p_taxCO2eq_until2150(t,regi);
			);	
		);
*** after c_peakBudgYr: always adjust to bring emissions close to zero
		pm_taxCO2eq(t,regi)$(t.val gt c_peakBudgYr) = pm_taxCO2eq(t,regi) + pm_taxCO2eq(t,regi)*max(sum(regi2,vm_emiAll.l(t,regi2,"co2"))/sum(regi2,vm_emiAll.l("2015",regi2,"co2")),-0.75);

*** check if c_peakBudgYr is correct: if global emissions already negative, move c_peakBudgYr forward
*** similar code block as used in iterative-adjust 9 below (credit to RP)
    o_diff_to_Budg(iteration) = (c_budgetCO2from2020 - s_actualbudgetco2);
    o_totCO2emi_peakBudgYr(iteration) = sum(t$(t.val = c_peakBudgYr), sum(regi2, vm_emiAll.l(t,regi2,"co2")) );
    o_totCO2emi_allYrs(t,iteration) = sum(regi2, vm_emiAll.l(t,regi2,"co2") );
    o_change_totCO2emi_peakBudgYr(iteration) = sum(ttot$(ttot.val = c_peakBudgYr), (o_totCO2emi_allYrs(ttot-1,iteration) - o_totCO2emi_allYrs(ttot+1,iteration) )/4 );  !! Only gives a tolerance range, exact value not important. Division by 4 somewhat arbitrary - could be 3 or 5 as well. 

    display c_peakBudgYr, o_diff_to_Budg, o_peakBudgYr_Itr, o_totCO2emi_allYrs, o_totCO2emi_peakBudgYr, o_change_totCO2emi_peakBudgYr;

***if( sum(t,sum(regi2,vm_emiAll.l(t,regi2,"co2")$(t.val = c_peakBudgYr))) < -0.1,
*** c_peakBudgYr = tt.val(t - 1)$(t.val = c_peakBudgYr);
***);		

    if( abs(o_diff_to_Budg(iteration)) < 20,                      !! only think about shifting peakBudgYr if the budget is close enough to target budget
      display "close enough to target budget to check timing of peak year";
      loop(ttot$(ttot.val = c_peakBudgYr),                               !! look at the peak timing
***        if(  ( (o_totCO2emi_peakBudgYr(iteration) < -(0.1 + o_change_totCO2emi_peakBudgYr(iteration)) ) AND (c_peakBudgYr > 2040) ), !! no peaking time before 2040
        if(  ( (o_totCO2emi_peakBudgYr(iteration) < -(0.1) ) AND (c_peakBudgYr > 2040) ), !! no peaking time before 2040
        display "shift peakBudgYr left";
		  o_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot - 1);                
***          pm_taxCO2eq(t,regi)$(t.val gt pm_ttot_val(ttot - 1)) = p_taxCO2eq_until2150(ttot-1,regi) + (t.val - pm_ttot_val(ttot - 1)) * c_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by c_taxCO2inc_after_peakBudgYr per year after peakBudgYr
*** if tax after c_peakBudgYr is higher than normal increase rate (exceeding a 20% tolerance): shift right
		elseif( ( sum(regi, sum(t2$(t2.val = pm_ttot_val(ttot+1)),pm_taxCO2eq(t2,regi))) > sum(regi,sum(t2$(t2.val = pm_ttot_val(ttot+1)),p_taxCO2eq_until2150(t2,regi)))*1.2 ) AND (c_peakBudgYr < 2100) ), !! if peaking time would be after 2100, keep 2100 budget year
          if(  (iteration.val > 2) AND ( o_peakBudgYr_Itr(iteration - 1) > o_peakBudgYr_Itr(iteration) ) AND ( o_peakBudgYr_Itr(iteration - 2) = o_peakBudgYr_Itr(iteration) ) , !! if the target year was just shifted left after being shifted right
            o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration); !! don't shift right again immediately
          else
		    display "shift peakBudgYr right";
            o_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot + 1);  !! ttot+1 is the new peakBudgYr
			loop(t$(t.val ge pm_ttot_val(ttot + 1)),
              pm_taxCO2eq(t,regi) = p_taxCO2eq_until2150(t,regi);
            );
		  );
        
		else   !! don't do anything if the peakBudgYr is already at the corner values (2040, 2100) or if the emissions in the peakBudgYr are close to 0
          o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration)
        );
      );
      c_peakBudgYr = o_peakBudgYr_Itr(iteration+1);
      display c_peakBudgYr;
    );




		
    pm_taxCO2eq(t,regi)$(t.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
    display pm_taxCO2eq;
	 );
);


*** ---------------------------------------------------------------------------------------------------------------
*** new peakBudg formulation that works with several CO2 price path realizations of module 45 ---------------------
*** it results in a peak budget with linear increase by 2$/yr afterwards
*** ---------------------------------------------------------------------------------------------------------------

if (cm_iterative_target_adj eq 9,
*' Update Iteratively update regional CO2 tax trajectories / regional CO2 budget to reach the target for global peak budget, with a linear increase afterwards given by `c_taxCO2inc_after_peakBudgYr`.  The
*' peak budget year is determined automatically (within the time window 2040--2100)

*' `p_actualbudgetco2(ttot)` includes emissions from 2020 to `ttot` (inclusive).
  p_actualbudgetco2(ttot)$( 2020 lt ttot.val )
  = sum((regi,ttot2)$( 2020 le ttot2.val AND ttot2.val le ttot.val ),
      ( vm_emiTe.l(ttot2,regi,"co2")
      + vm_emiCdr.l(ttot2,regi,"co2")
      + vm_emiMac.l(ttot2,regi,"co2")
      )
    * ( !! second half of the 2020 period: 2020-22
        (pm_ts(ttot2) / 2 + 0.5)$( ttot2.val eq 2020 )
        !! entire middle periods
      + (pm_ts(ttot2))$( 2020 lt ttot2.val AND ttot2.val lt ttot.val )
	!! first half of the final period, until the end of the middle year
      + ((pm_ttot_val(ttot) - pm_ttot_val(ttot-1)) / 2 + 0.5)$(
                                                         ttot2.val eq ttot.val )
      )
    )
  * sm_c_2_co2;

  s_actualbudgetco2 = smax(t$( t.val le c_peakBudgYr ), p_actualbudgetco2(t));
  
  o_peakBudgYr_Itr(iteration) = c_peakBudgYr;
                  
  display s_actualbudgetco2, p_actualbudgetco2;

  if(cm_emiscen eq 9,
  
*** --------A: calculate the new CO2 price path,  the CO2 tax rescale factor----------------------------------------------------------  
  
    if(o_modelstat eq 2 AND ord(iteration) < cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2from2020 - s_actualbudgetco2) ge 2,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
      display pm_taxCO2eq;

      if( ( ( p_actualbudgetco2("2100") > 1.1 * s_actualbudgetco2 ) AND ( abs(c_budgetCO2from2020 - s_actualbudgetco2) < 50 ) AND (iteration.val < 12) ), 
        display iteration;
*** if end-of-century budget is higher than budget at peak point, AND end-of-century budget is already in the range of the target budget (+/- 50 GtC), treat as end-of-century budget 
*** for this iteration. Only do this rough approach (jump to 2100) for the first iterations - at later iterations the slower adjustment of the peaking time should work better
        display "this is likely an end-of-century budget with no net negative emissions at all. Shift c_peakBudgYr to 2100";
        s_actualbudgetco2 = 0.5 * (p_actualbudgetco2("2100") + s_actualbudgetco2); !! due to the potential strong jump in c_peakBudgYr, which implies that the CO2 price 
*** will increase over a longer time horizon, take the average of the budget at the old peak time and the new peak time
        c_peakBudgYr = 2100;
      );

*** --------A1: for that, calculate the CO2 tax rescale factor---

      if(iteration.val lt 10,
        p_factorRescale_taxCO2(iteration) = max(0.1, (s_actualbudgetco2/c_budgetCO2from2020) ) ** 3;
      else
        p_factorRescale_taxCO2(iteration) = max(0.1, (s_actualbudgetco2/c_budgetCO2from2020) ) ** 2;
      );
      p_factorRescale_taxCO2_Funneled(iteration) =
                max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p_factorRescale_taxCO2(iteration)),
                        1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
                );

      pm_taxCO2eq_iterationdiff(t,regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq(t,regi) * p_factorRescale_taxCO2_Funneled(iteration) ) - pm_taxCO2eq(t,regi);
      p_taxCO2eq_until2150(t,regi) = max(1* sm_DptCO2_2_TDpGtC, p_taxCO2eq_until2150(t,regi) * p_factorRescale_taxCO2_Funneled(iteration) );
      pm_taxCO2eq(t,regi) = max(1* sm_DptCO2_2_TDpGtC, pm_taxCO2eq(t,regi) * p_factorRescale_taxCO2_Funneled(iteration) );  !! rescale co2tax
      loop(t2$(t2.val eq c_peakBudgYr),
	    pm_taxCO2eq(t,regi)$(t.val gt c_peakBudgYr) = p_taxCO2eq_until2150(t2,regi) + (t.val - t2.val) * c_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by c_taxCO2inc_after_peakBudgYr per year
	  );

      display p_factorRescale_taxCO2, p_factorRescale_taxCO2_Funneled;

      o_taxCO2eq_iterDiff_Itr(iteration,regi) = pm_taxCO2eq_iterationdiff("2030",regi);
      loop(regi, !! not a nice solution to having only the price of one regi display (for better visibility), but this way it overwrites again and again until the value from the last regi remain
	    o_taxCO2eq_Itr_1regi(t,iteration+1) = pm_taxCO2eq(t,regi); 
	  );
    
      display o_taxCO2eq_iterDiff_Itr, o_taxCO2eq_Itr_1regi;
	  
  
    else !! if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2from2020 ))
      if(s_actualbudgetco2 > 0 or abs(c_budgetCO2from2020 - s_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
        p_factorRescale_taxCO2(iteration)          = 1;
        p_factorRescale_taxCO2_Funneled(iteration) = 1;
        p_taxCO2eq_until2150(t,regi) = p_taxCO2eq_until2150(t,regi); !! nothing changes
      else
*** if budget has turned negative, reduce CO2 price by 20%
      p_factorRescale_taxCO2(iteration) = 0.8;
	  p_factorRescale_taxCO2_Funneled(iteration) = p_factorRescale_taxCO2(iteration);
	  
      p_taxCO2eq_until2150(t,regi) = p_factorRescale_taxCO2(iteration) * p_taxCO2eq_until2150(t,regi);
      pm_taxCO2eq(t,regi) = p_factorRescale_taxCO2(iteration) * pm_taxCO2eq(t,regi);
      );  
    ); !! if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s_actualbudgetco2 > 0 AND abs(c_budgetCO2from2020 - s_actualbudgetco2) ge 2,
    
    display pm_taxCO2eq, p_taxCO2eq_until2150;

	
*** -------B: checking the peak timing, if c_peakBudgYr is still correct or needs to be shifted-----------------------

    o_diff_to_Budg(iteration) = (c_budgetCO2from2020 - s_actualbudgetco2);
    o_totCO2emi_peakBudgYr(iteration) = sum(t$(t.val = c_peakBudgYr), sum(regi2, vm_emiAll.l(t,regi2,"co2")) );
    o_totCO2emi_allYrs(t,iteration) = sum(regi2, vm_emiAll.l(t,regi2,"co2") );
	
*RP* calculate how fast emissions are changing around the peaking time to get an idea how close it is possible to get to 0 due to the 5(10) year time steps 	
    o_change_totCO2emi_peakBudgYr(iteration) = sum(ttot$(ttot.val = c_peakBudgYr), (o_totCO2emi_allYrs(ttot-1,iteration) - o_totCO2emi_allYrs(ttot+1,iteration) )/4 );  !! Only gives a tolerance range, exact value not important. Division by 4 somewhat arbitrary - could be 3 or 5 as well. 

    display c_peakBudgYr, o_diff_to_Budg, o_peakBudgYr_Itr, o_totCO2emi_allYrs, o_totCO2emi_peakBudgYr, o_change_totCO2emi_peakBudgYr;


*** ----B1: check if c_peakBudgYr should be shifted left or right: 
    if( abs(o_diff_to_Budg(iteration)) < 20,                      !! only think about shifting peakBudgYr if the budget is close enough to target budget
      display "close enough to target budget to check timing of peak year";
	  
	  !!  check if the target year was just shifted back left after being shifted right before
	  if ( (iteration.val > 2) AND ( o_peakBudgYr_Itr(iteration - 1) > o_peakBudgYr_Itr(iteration) ) AND ( o_peakBudgYr_Itr(iteration - 2) = o_peakBudgYr_Itr(iteration) ),
	    o_pkBudgYr_flipflop(iteration) = 1; 
        display "flipflop observed (before loop)";
	  );
	  
      loop(ttot$(ttot.val = c_peakBudgYr),                               !! look at the peak timing
        if(  ( (o_totCO2emi_peakBudgYr(iteration) < -(0.1 + o_change_totCO2emi_peakBudgYr(iteration)) ) AND (c_peakBudgYr > 2040) ), !! no peaking time before 2040
          display "shift peakBudgYr left";
		  o_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot - 1);                
          pm_taxCO2eq(t,regi)$(t.val gt pm_ttot_val(ttot - 1)) = p_taxCO2eq_until2150(ttot-1,regi) + (t.val - pm_ttot_val(ttot - 1)) * c_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by c_taxCO2inc_after_peakBudgYr per year after peakBudgYr
        
		elseif ( ( o_totCO2emi_peakBudgYr(iteration) > (0.1 + o_change_totCO2emi_peakBudgYr(iteration)) ) AND (c_peakBudgYr < 2100) ), !! if peaking time would be after 2100, keep 2100 budget year
          if(  (o_pkBudgYr_flipflop(iteration) eq 1), !! if the target year was just shifted left after being shifted right, and would now be shifted right again
            display "peakBudgYr was left, right, left and is now supposed to be shifted right again -> flipflop, thus go into separate loop";
            o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration); !! don't shift right again immediately, but go into a different loop:
            o_delay_increase_peakBudgYear(iteration) = 1;
		  elseif ( o_delay_increase_peakBudgYear(iteration) eq 1 ),
		    display "still in separate loop trying to resolve flip-flop behavior";
			o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration); !! keep current peakBudgYr,
          else
		    display "shift peakBudgYr right";
            o_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot + 1);  !! ttot+1 is the new peakBudgYr
			loop(t$(t.val ge pm_ttot_val(ttot + 1)),
              pm_taxCO2eq(t,regi) = p_taxCO2eq_until2150(ttot+1,regi) 
			                        + (t.val - pm_ttot_val(ttot + 1)) * c_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by c_taxCO2inc_after_peakBudgYr per year 
            );
		  );
        
		else   !! don't do anything if the peakBudgYr is already at the corner values (2040, 2100) or if the emissions in the peakBudgYr are close enough to 0 (within the range of +/- o_change_totCO2emi_peakBudgYr)
          o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration)
        );
      );
      c_peakBudgYr = o_peakBudgYr_Itr(iteration+1);
      display c_peakBudgYr;
    );
        
    pm_taxCO2eq(t,regi)$(t.val le c_peakBudgYr) = p_taxCO2eq_until2150(t,regi); !! until peakBudgYr, take the contiuous price trajectory
    
*** -----B2: if there was a flip-floping of c_peakBudgYr in the previous iterations, try to overome this by adjusting the CO2 price path after the peaking year	
    if (o_delay_increase_peakBudgYear(iteration) = 1,   
      display "not shifting peakBudgYr right, instead adjusting CO2 price for following year";
      loop(ttot$(ttot.val eq c_peakBudgYr),  !! set ttot to the current peakBudgYr 
        loop(t2$(t2.val eq pm_ttot_val(ttot+1)),  !! set t2 to the following time step
          o_factorRescale_taxCO2_afterPeakBudgYr(iteration) = 1 + max(sum(regi2,vm_emiAll.l(ttot,regi2,"co2"))/sum(regi2,vm_emiAll.l("2015",regi2,"co2")),-0.75) ; 
		  !! this was inspired by Christoph's approach. This value is 1 if emissions in the peakBudgYr are 0; goes down to 0.25 if emissions are <0 and approaching the size of 2015 emissions, and > 1 if emissions > 0. 
          
		  !! in case the normal linear extension still is not enough to get emissions to 0 after the peakBudgYr, shift peakBudgYr right again:
          if( ( o_reached_until2150pricepath(iteration-1) eq 1 ) AND ( o_totCO2emi_peakBudgYr(iteration) > (0.1 + o_change_totCO2emi_peakBudgYr(iteration)) ), 
            display "price in following year reached original path in previous iteration and is still not enough -> shift peakBudgYr to right";
            o_delay_increase_peakBudgYear(iteration+1) = 0;  !! probably is not necessary
            o_reached_until2150pricepath(iteration) = 0;
            o_peakBudgYr_Itr(iteration+1) = t2.val;        !! shift PeakBudgYear to the following time step
            c_peakBudgYr = o_peakBudgYr_Itr(iteration+1);
            pm_taxCO2eq(t2,regi) = p_taxCO2eq_until2150(t2,regi) ;  !! set CO2 price in t2 to value in the "continuous path"
      
            display c_peakBudgYr;
		  elseif ( ( o_reached_until2150pricepath(iteration-1) eq 1 ) AND ( o_totCO2emi_peakBudgYr(iteration) < (0.1 + o_change_totCO2emi_peakBudgYr(iteration)) ) ), 
            display "New intermediate price in timestep after c_peakBudgYr is sufficient to stabilize peaking year - go back to normal loop";	
			o_delay_increase_peakBudgYear(iteration+1) = 0;  !! probably is not necessary
            o_reached_until2150pricepath(iteration) = 0;
			o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration);  
            c_peakBudgYr = o_peakBudgYr_Itr(iteration+1);
          else      !! either didn't reach the continued "until2150"-price path in last iteration, or the increase was high enough to get emissions to 0. 
		            !! in this case, keep PeakBudgYr, and adjust the price in the year after the peakBudgYr to get emissions close to 0,
			o_delay_increase_peakBudgYear(iteration+1) = 1; !! make sure next iteration peakBudgYr is not shifted right again
		    o_peakBudgYr_Itr(iteration+1) = o_peakBudgYr_Itr(iteration);
            pm_taxCO2eq(t2,regi) = max(pm_taxCO2eq(ttot,regi), !! at least as high as the price in the peakBudgYr
                                       pm_taxCO2eq(t2,regi) * (o_factorRescale_taxCO2_afterPeakBudgYr(iteration) / p_factorRescale_taxCO2_Funneled(iteration) ) !! the full path was already rescaled by p_factorRescale_taxCO2_Funneled, so adjust the second rescaling
                                   );
            loop(regi,                   !! this loop is necessary to allow the <-comparison in the next if statement
              if( p_taxCO2eq_until2150(t2,regi) < pm_taxCO2eq(t2,regi) ,   !! check if new price would be higher than the price if the peakBudgYr would be one timestep later 
                display "price increase reached price from path with c_peakBudgYr one timestep later - downscale to 99%"; 
				pm_taxCO2eq(t2,regi) = 0.99 * p_taxCO2eq_until2150(t2,regi); !! reduce the new CO2 price to 99% of the price that it would be if the peaking year was one timestep later. The next iteration will show if this is enough, otherwise c_peakBudgYr will be shifted right 
                o_reached_until2150pricepath(iteration) = 1;             !! upward CO2 price correction reached the continued price path - check in next iteration if this is high enough.  
              );
            );
          );
        
          display o_factorRescale_taxCO2_afterPeakBudgYr;
		  pm_taxCO2eq(t,regi)$(t.val gt t2.val) = pm_taxCO2eq(t2,regi) + (t.val - t2.val) * c_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by c_taxCO2inc_after_peakBudgYr per year
		  
        ); !! loop t2$(t2.val eq pm_ttot_val(ttot+1)),  !! set t2 to the following time step
      );  !! loop ttot$(ttot.val eq c_peakBudgYr),  !! set ttot to the current peakBudgYr 
      c_peakBudgYr = o_peakBudgYr_Itr(iteration+1);  !! this has to happen outside the loop, otherwise the loop condition might be true twice
    ); !! if o_delay_increase_peakBudgYear(iteration) = 1,   !! if there was a flip-floping in the previous iterations, try to solve this
	
	
	loop(regi, !! not a nice solution to having only the price of one regi display (for better visibility), but this way it overwrites again and again until the value from the last regi remain
	    o_taxCO2eq_afterPeakShiftLoop_Itr_1regi(t,iteration+1) = pm_taxCO2eq(t,regi); 
	);
	
    display o_delay_increase_peakBudgYear, o_reached_until2150pricepath, pm_taxCO2eq, o_peakBudgYr_Itr, o_taxCO2eq_afterPeakShiftLoop_Itr_1regi, o_pkBudgYr_flipflop;
  ); !! if cm_emiscen eq 9,
);   !! if cm_iterative_target_adj eq 9,

***------ end of "cm_iterative_target_adj" variants-----------------------------------------


*** for having it available in next iteration, too:
s_actualbudgetco2_last = s_actualbudgetco2;

***-----------------------------------------------
*RP* calculate shares of SE used for different FEs
***-----------------------------------------------
*NB* this is only relevant for reporting purposes. With reporting tranferred to R, the entire part will become obsolete.

loop ((ttot,regi), 

  if (sum(se2fe("seh2",entyFe,te), vm_demSe.l(ttot,regi,"seh2",entyFe,te)) ne 0, 
    p_share_seh2_s(ttot,regi) = 
      sum(se2fe("seh2","feh2s",te), vm_demSe.l(ttot,regi,"seh2","feh2s",te)) 
    / sum(se2fe("seh2", entyFe,  te), vm_demSe.l(ttot,regi,"seh2", entyFe,  te)); 
  else 
    p_share_seh2_s(ttot,regi) = NA;
  );

  if (sum(se2fe("seel",entyFe,te), vm_demSe.l(ttot,regi,"seel",entyFe,te)) ne 0, 
    p_share_seel_s(ttot,regi) = 
      sum(se2fe("seel","feels",te), vm_demSe.l(ttot,regi,"seel","feels",te)) 
    / sum(se2fe("seel", entyFe,  te), vm_demSe.l(ttot,regi,"seel", entyFe,  te)); 
  else
    p_share_seel_s(ttot,regi) = NA;
  );

  if (sum(se2fe(entySe,entyFe,te)$(sameas(entySe,"seliqfos") OR sameas(entySe,"seliqbio")),
        vm_demSe.l(ttot,regi,entySe,entyFe,te)) ne 0, 
    p_share_seliq_s(ttot,regi) = 
      ( sum(se2fe("seliqfos","fehos",te), vm_demSe.l(ttot,regi,"seliqfos","fehos",te)) + sum(se2fe("seliqbio","fehos",te), vm_demSe.l(ttot,regi,"seliqbio","fehos",te)) )
      / ( sum(se2fe("seliqfos",entyFe,te),  vm_demSe.l(ttot,regi,"seliqfos",entyFe,te)) + sum(se2fe("seliqbio",entyFe,te),  vm_demSe.l(ttot,regi,"seliqbio",entyFe,te)) )
    ;
  else
    p_share_seliq_s(ttot,regi) = NA;
  );

); 

DISPLAY  p_share_seliq_s, p_share_seh2_s, p_share_seel_s;


*LB* update parameter that are used for variables during the run
pm_gdp_gdx(ttot,regi)$(ttot.val ge 2005)    = vm_cesIO.l(ttot,regi,"inco");
p_inv_gdx(ttot,regi)$(ttot.val ge 2005)     = vm_invMacro.l(ttot,regi,"kap");

pm_GDPGross(ttot,regi)$( (pm_SolNonInfes(regi) eq 1) ) =  vm_cesIO.l(ttot,regi,"inco");


*interpolate GDP
loop(ttot$(ttot.val ge 2005),
    loop(tall$(pm_tall_2_ttot(tall, ttot)),
        pm_GDPGross(tall,regi) =
       (1- pm_interpolWeight_ttot_tall(tall)) * pm_GDPGross(ttot,regi)
       + pm_interpolWeight_ttot_tall(tall) * pm_GDPGross(ttot+1,regi);
));

*** assume GDP is flat from 2150 on (only enters damage calculations in the far future)
pm_GDPGross(tall,regi)$(tall.val ge 2150) = pm_GDPGross("2149",regi); 


*** CG: calculate marginal adjustment cost for capacity investment: d(vm_costInvTeAdj) / d(vm_deltaCap)  !!!! the closed formula only holds when v_adjFactorGlob.fx(t,regi,te) = 0;
o_margAdjCostInv(ttot,regi,te)$(ttot.val ge max(2010, cm_startyear) AND teAdj(te)) =  vm_costTeCapital.l(ttot,regi,te) * p_adj_coeff(ttot,regi,te)
    * 2 * (sum(te2rlf(te,rlf), vm_deltaCap.l(ttot,regi,te,rlf)) - sum(te2rlf(te,rlf), vm_deltaCap.l(ttot-1,regi,te,rlf)))
    / power((pm_ttot_val(ttot) - pm_ttot_val(ttot-1)), 2)
    / (sum(te2rlf(te,rlf), vm_deltaCap.l(ttot-1,regi,te,rlf)) + p_adj_seed_reg(ttot,regi) * p_adj_seed_te(ttot,regi,te)
      + p_adj_deltacapoffset("2010",regi,te)$(ttot.val eq 2010) + p_adj_deltacapoffset("2015",regi,te)$(ttot.val eq 2015)
      + p_adj_deltacapoffset("2020",regi,te)$(ttot.val eq 2020) + p_adj_deltacapoffset("2025",regi,te)$(ttot.val eq 2025)
    )
    * (1 + 0.02/pm_ies(regi) + pm_prtp(regi)) ** (pm_ts(ttot) / 2)
;

*** CG: calculate average adjustment cost for capacity investment: vm_costInvTeAdj / vm_deltaCap
o_avgAdjCostInv(ttot,regi,te)$(ttot.val ge 2010 AND teAdj(te) AND
                              (vm_costInvTeAdj.l(ttot,regi,te) eq 0 OR sum(te2rlf(te,rlf),vm_deltaCap.l(ttot,regi,te,rlf)) eq 0))
    = 0;
o_avgAdjCostInv(ttot,regi,te)$(ttot.val ge 2010 AND teAdj(te) AND (sum(te2rlf(te,rlf),vm_deltaCap.l(ttot,regi,te,rlf)) ne 0 ))
    = vm_costInvTeAdj.l(ttot,regi,te) / sum(te2rlf(te,rlf),vm_deltaCap.l(ttot,regi,te,rlf));
*** and ratio between average adjCost and direct investment cost
o_avgAdjCost_2_InvCost_ratioPc(ttot,regi,te)$(vm_costInvTeDir.l(ttot,regi,te) ge 1E-22) = vm_costInvTeAdj.l(ttot,regi,te)/vm_costInvTeDir.l(ttot,regi,te) * 100;

*** calculation of PE and SE Prices (useful for internal use and reporting purposes)
pm_SEPrice(ttot,regi,entySe)$(abs (qm_budget.m(ttot,regi)) gt sm_eps AND (NOT (sameas(entySe,"seel")))) = 
       q_balSe.m(ttot,regi,entySe) / qm_budget.m(ttot,regi);

pm_PEPrice(ttot,regi,entyPe)$(abs (qm_budget.m(ttot,regi)) gt sm_eps) = 
       q_balPe.m(ttot,regi,entyPe) / qm_budget.m(ttot,regi);

*** calculate share of stored CO2 from captured CO2
pm_share_CCS_CCO2(t,regi) = sum(teCCS2rlf(te,rlf), vm_co2CCS.l(t,regi,"cco2","ico2",te,rlf)) / (sum(teCCS2rlf(te,rlf), vm_co2capture.l(t,regi,"cco2","ico2",te,rlf))+sm_eps);

*** emissions reporting helper parameters
o_emissions_bunkers(ttot,regi,emi)$(ttot.val ge 2005) = 
    sum(se2fe(enty,enty2,te),
        pm_emifac(ttot,regi,enty,enty2,te,emi)
        * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other")
    )*o_emi_conv(emi);

o_emissions(ttot,regi,emi)$(ttot.val ge 2005) = 
    sum(emiMkt, vm_emiAllMkt.l(ttot,regi,emi,emiMkt))*o_emi_conv(emi)
    - o_emissions_bunkers(ttot,regi,emi);

*** note! this still excludes industry CCS and CCU. To fix. 
o_emissions_energy(ttot,regi,emi)$(ttot.val ge 2005) = 
    sum(emiMkt, vm_emiTeMkt.l(ttot,regi,emi,emiMkt))*o_emi_conv(emi)
    - o_emissions_bunkers(ttot,regi,emi);

*** note! this still excludes industry CCS. To fix. 
o_emissions_energy_demand(ttot,regi,emi)$(ttot.val ge 2005) = 
    sum(sector2emiMkt(sector,emiMkt),
        sum(se2fe(enty,enty2,te),
            pm_emifac(ttot,regi,enty,enty2,te,emi)
            * vm_demFeSector.l(ttot,regi,enty,enty2,sector,emiMkt)
        )
    )*o_emi_conv(emi)
    - o_emissions_bunkers(ttot,regi,emi)
;

*** note! this still excludes industry CCS. To fix.
o_emissions_energy_demand_sector(ttot,regi,emi,sector)$(ttot.val ge 2005) =
    sum(emiMkt$sector2emiMkt(sector,emiMkt),
        sum(se2fe(enty,enty2,te),
            pm_emifac(ttot,regi,enty,enty2,te,emi) * vm_demFeSector.l(ttot,regi,enty,enty2,sector,emiMkt)
        )
    )*o_emi_conv(emi)
    +
   (sum(emiMacSector$(emiMac2sector(emiMacSector,"trans","process",emi)),
        vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
        - o_emissions_bunkers(ttot,regi,emi)
    )$(sameas(sector,"trans"))
    +
    (sum(emiMacSector$(emiMac2sector(emiMacSector,"waste","process",emi)),
         vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
    )$(sameas(sector,"waste"))
;

o_emissions_energy_extraction(ttot,regi,emi,entyPe)$(ttot.val ge 2005) =
***   emissions from non-conventional fuel extraction
    (
    ( sum(emi2fuelMine(emi,entyPe,rlf),      
           p_cint(regi,emi,entyPe,rlf)
         * vm_fuExtr.l(ttot,regi,entyPe,rlf)
         )$( c_cint_scen eq 1 )
     )
***   emissions from conventional fuel extraction
    + ( sum(pe2rlf(entyPe,rlf2),sum(enty2,      
         (pm_cintraw(enty2)
          * pm_fuExtrOwnCons(regi, enty2, entyPe) 
          * vm_fuExtr.l(ttot,regi,entyPe,rlf2)
         )$(pm_fuExtrOwnCons(regi, entyPe, enty2) gt 0)    
        ))
    )
    )*o_emi_conv(emi)
    +
    (sum(emiMacSector$(emiMac2sector("ch4coal","extraction","process",emi)),
         vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
    )$(sameas(entyPe,"pecoal"))
    +
    (sum(emiMacSector$(emiMac2sector("ch4gas","extraction","process",emi)),
         vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
    )$(sameas(entyPe,"pegas"))
    +
    (sum(emiMacSector$(emiMac2sector("ch4oil","extraction","process",emi)),
         vm_emiMacSector.l(ttot,regi,emiMacSector)
        )*o_emi_conv(emi)
    )$(sameas(entyPe,"peoil"))
;


o_emissions_energy_supply_gross(ttot,regi,emi)$(ttot.val ge 2005) =
    sum(pe2se(entyPe,entySe,te)$(pm_emifac(ttot,regi,entyPe,entySe,te,emi)>0),
         pm_emifac(ttot,regi,entyPe,entySe,te,emi)
         * vm_demPe.l(ttot,regi,entyPe,entySe,te)
    )*o_emi_conv(emi)
    +
    sum(entyPe, o_emissions_energy_extraction(ttot,regi,emi,entyPe))
;
    
o_emissions_energy_supply_gross_carrier(ttot,regi,emi,entySe)$(ttot.val ge 2005) =
    sum((entyPe,te)$(pe2se(entyPe,entySe,te) AND (pm_emifac(ttot,regi,entyPe,entySe,te,emi)>0)),
         pm_emifac(ttot,regi,entyPe,entySe,te,emi)
         * vm_demPe.l(ttot,regi,entyPe,entySe,te)
    )*o_emi_conv(emi)
    +
    (
    o_emissions_energy_extraction(ttot,regi,emi,"pecoal")
    )$(sameas(entySe,"sesofos"))
    +
    (
    o_emissions_energy_extraction(ttot,regi,emi,"pegas")
    )$(sameas(entySe,"segafos"))
    +
    (	
    o_emissions_energy_extraction(ttot,regi,emi,"peoil")
    )$(sameas(entySe,"seliqfos"))
;

o_emissions_energy_negative(ttot,regi,emi)$(ttot.val ge 2005) =
    (
     sum(pe2se(entyPe,entySe,te)$(pm_emifac(ttot,regi,entyPe,entySe,te,emi)<0),
         pm_emifac(ttot,regi,entyPe,entySe,te,emi)
         * vm_demPe.l(ttot,regi,entyPe,entySe,te)
    )
    +
    sum((ccs2Leak(enty,enty2,te,emi),teCCS2rlf(te,rlf)),
            pm_emifac(ttot,regi,enty,enty2,te,emi)
            * vm_co2CCS.l(ttot,regi,enty,enty2,te,rlf)
          )
***   Industry CCS emissions
    - sum(emiInd37_fuel,
          vm_emiIndCCS.l(ttot,regi,emiInd37_fuel)
        )$( sameas(emi,"co2") )
    )*o_emi_conv(emi)
;

o_emissions_industrial_processes(ttot,regi,emi)$(ttot.val ge 2005) =
    sum(emiMacSector$(emiMac2sector(emiMacSector,"indst","process",emi)),
        vm_emiMacSector.l(ttot,regi,emiMacSector)
    )*o_emi_conv(emi);

o_emissions_AFOLU(ttot,regi,emi)$(ttot.val ge 2005) =
    sum(emiMacSector$(emiMac2sector(emiMacSector,"agriculture","process",emi) OR emiMac2sector(emiMacSector,"lulucf","process",emi)),
        vm_emiMacSector.l(ttot,regi,emiMacSector)
    )*o_emi_conv(emi);

o_emissions_CDRmodule(ttot,regi,emi)$(ttot.val ge 2005) =
   vm_emiCdr.l(ttot,regi,emi)*o_emi_conv(emi)
;

o_emissions_other(ttot,regi,emi)$(ttot.val ge 2005) =
    pm_emiExog(ttot,regi,emi)*o_emi_conv(emi)
;

***Carbon Management|Carbon Capture (Mt CO2/yr)
o_capture(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(teCCS2rlf(te,rlf),
        vm_co2capture.l(ttot,regi,"cco2","ico2","ccsinje",rlf)
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Energy (Mt CO2/yr)
o_capture_energy(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(emi2te(enty3,enty4,te2,"cco2"),
        vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Energy|Electricity (Mt CO2/yr)
o_capture_energy_elec(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(emi2te(enty3,enty4,te2,"cco2")$(sameas(enty4,"seel")),
        vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Energy|Other (Mt CO2/yr)
o_capture_energy_other(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(emi2te(enty3,enty4,te2,"cco2")$(NOT(sameas(enty4,"seel"))),
        vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Direct Air Capture (Mt CO2/yr)
o_capture_cdr(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(teCCS2rlf("ccsinje",rlf),
      vm_ccs_cdr.l(ttot,regi,"cco2","ico2","ccsinje",rlf)
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Process|Industrial Processes (Mt CO2/yr)
o_capture_industry(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(emiInd37,
      vm_emiIndCCS.l(ttot,regi,emiInd37)
    )*o_emi_conv("co2")
;

***Carbon Management|Carbon Capture|Primary Energy|Biomass (Mt CO2/yr)
o_capture_energy_bio(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(enty3$peBio(enty3),
        sum(emi2te(enty3,enty4,te2,"cco2"),
            vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
        )
    )*o_emi_conv("co2");

***Carbon Management|Carbon Capture|Primary Energy|Fossil (Mt CO2/yr)
o_capture_energy_fos(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(enty3$(NOT(peBio(enty3))),
        sum(emi2te(enty3,enty4,te2,"cco2"),
            vm_emiTeDetail.l(ttot,regi,enty3,enty4,te2,"cco2")
        )
    )*o_emi_conv("co2");

***Carbon Management|CCU (Mt CO2/yr)
o_carbon_CCU(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(teCCU2rlf(te2,rlf),
        vm_co2CCUshort.l(ttot,regi,"cco2","ccuco2short",te2,rlf)
    )*o_emi_conv("co2");

***Carbon Management|Land Use (Mt CO2/yr)
o_carbon_LandUse(ttot,regi,"co2")$(ttot.val ge 2005) =
    vm_emiMacSector.l(ttot,regi,"co2luc")
    *o_emi_conv("co2");

***Carbon Management|Underground Storage (Mt CO2/yr)
o_carbon_underground(ttot,regi,"co2")$(ttot.val ge 2005) =
    sum(teCCS2rlf(te,rlf), 
         vm_co2CCS.l(ttot,regi,"cco2","ico2",te,rlf)
    )*o_emi_conv("co2") 	
;
    
***Carbon Management|Carbon Re-emitted (Mt CO2/yr)
o_carbon_reemitted(ttot,regi,"co2")$(ttot.val ge 2005) =
     v_co2capturevalve.l(ttot,regi)	
     *o_emi_conv("co2") 	
;

*CG**ML*: capital interest rate
p_r(ttot,regi)$(ttot.val gt 2005 and ttot.val le 2130)
    = 1 / pm_ies(regi) * (( (vm_cons.l(ttot+1,regi)/pm_pop(ttot+1,regi)) /
      (vm_cons.l(ttot-1,regi)/pm_pop(ttot-1,regi)) )
      ** (1 / ( pm_ttot_val(ttot+1)- pm_ttot_val(ttot-1))) - 1) + pm_prtp(regi)
;

*** CG: growth rate after 2100 is very small (0.02 instead of around 0.05) due to various artefact, we simply set interest rates to 0.05 after 2100
p_r(ttot,regi)$(ttot.val gt 2100) = 0.05;

***------------ FE prices ----------------------
*** calculation of FE Prices including sector specific and energy source information
p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt)$(abs (qm_budget.m(t,regi)) gt sm_eps) =
  q_balFeAfterTax.m(t,regi,entySe,entyFe,sector,emiMkt) / qm_budget.m(t,regi);

*** marginal prices of aggregates equal to minimal non-zero marginal price of full equation marginal
loop((t,regi,entySe,entyFe,sector,emiMkt)$(sefe(entySe,entyFe) AND sector2emiMkt(sector,emiMkt) AND entyFe2Sector(entyFe,sector)),

*** initialize prices
  p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt)=0;
  pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector)=0;
  p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt)=0;
  p_FEPrice_by_SE(t,regi,entySe,entyFe)=0;
  p_FEPrice_by_Sector(t,regi,entyFe,sector)=0;
  p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt)=0;
  p_FEPrice_by_FE(t,regi,entyFe)=0;

*** lower level marginal price is equal to non-zero, non-eps minimal price at higher level 
  loop(entySe2, 
    p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt) > EPS) 
      AND
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt) < p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt))
        OR (p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt) eq 0)
      ))
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt);
  );

  loop(emiMkt2, 
    pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt2) > EPS) 
      AND
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt2) < pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector))
        OR (pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt2);
  );

  loop(sector2,
    p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt) > EPS) 
      AND
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt) < p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt))
        OR (p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt);
  );

  loop((sector2,emiMkt2)$sector2emiMkt(sector2,emiMkt2), 
    p_FEPrice_by_SE(t,regi,entySe,entyFe)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt2) > EPS) 
      AND 
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt2) < p_FEPrice_by_SE(t,regi,entySe,entyFe))
        OR (p_FEPrice_by_SE(t,regi,entySe,entyFe) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector2,emiMkt2);
  );

  loop((entySe2,emiMkt2), !! take minimal non-zero price for aggregation if carrier has no quantity in the model
    p_FEPrice_by_Sector(t,regi,entyFe,sector)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt2) > EPS) 
      AND 
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt2) < p_FEPrice_by_Sector(t,regi,entyFe,sector))
        OR (p_FEPrice_by_Sector(t,regi,entyFe,sector) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector,emiMkt2);
  );

  loop((entySe2,sector2), !! take minimal non-zero price for aggregation if carrier has no quantity in the model
    p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt) > EPS) 
      AND 
      ( (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt) < p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt))
        OR (p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt);
  );

  loop((entySe2,sector2,emiMkt2)$(sefe(entySe2,entyFe) AND sector2emiMkt(sector2,emiMkt2)), !! take minimal non-zero price for aggregation if carrier has no quantity in the model
    p_FEPrice_by_FE(t,regi,entyFe)$(
      (p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt2) > EPS) 
      AND 
      ((p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt2) < p_FEPrice_by_FE(t,regi,entyFe))
        OR (p_FEPrice_by_FE(t,regi,entyFe) eq 0)
      )) 
      = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe2,entyFe,sector2,emiMkt2);
  );

);

p_FEPrice_by_SE_Sector_EmiMkt_iter(iteration,t,regi,entySe,entyFe,sector,emiMkt) = p_FEPrice_by_SE_Sector_EmiMkt(t,regi,entySe,entyFe,sector,emiMkt);
p_FEPrice_by_Sector_EmiMkt_iter(iteration,t,regi,entyFe,sector,emiMkt) = p_FEPrice_by_Sector_EmiMkt(t,regi,entyFe,sector,emiMkt);
p_FEPrice_by_SE_Sector_iter(iteration,t,regi,entySe,entyFe,sector) = pm_FEPrice_by_SE_Sector(t,regi,entySe,entyFe,sector);
p_FEPrice_by_SE_EmiMkt_iter(iteration,t,regi,entySe,entyFe,emiMkt) = p_FEPrice_by_SE_EmiMkt(t,regi,entySe,entyFe,emiMkt);
p_FEPrice_by_SE_iter(iteration,t,regi,entySe,entyFe) = p_FEPrice_by_SE(t,regi,entySe,entyFe);
p_FEPrice_by_Sector_iter(iteration,t,regi,entyFe,sector) = p_FEPrice_by_Sector(t,regi,entyFe,sector);
p_FEPrice_by_EmiMkt_iter(iteration,t,regi,entyFe,emiMkt) = p_FEPrice_by_EmiMkt(t,regi,entyFe,emiMkt);
p_FEPrice_by_FE_iter(iteration,t,regi,entyFe) = p_FEPrice_by_FE(t,regi,entyFe);

*** EOF ./core/postsolve.gms
