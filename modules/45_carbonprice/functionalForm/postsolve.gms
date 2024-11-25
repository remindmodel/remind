*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalForm/postsolve.gms

*** Only run postsolve if cm_iterative_target_adj is not equal to 0.
if((cm_iterative_target_adj ne 0),

***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part I and II (Global anchor trajectory and post-peak behaviour): Adjustment of global anchor trajectory to meet (peak or end-of-century) CO2 budget target prescribed via cm_budgetCO2from2020.
***    If iterative_target_adj = 7 or 9, cm_peakBudgYr also adjusted.
***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Algorithm for end-of-century CO2 budget targets
if(cm_iterative_target_adj eq 5,
*JeS* Iteratively update regional CO2 tax trajectories / regional CO2 budget to reach the global emission budget (s45_actualbudgetco2 runs from 2020-2100, not peak budget)
*KK* for a time step of 5 years, the budget is calculated as 3 * 2020 + ts(2025-2090) + 5.5 * 2100;
*** 10-pm_ts("2090")/2 and pm_ts("2020")/2 are the time periods that haven't been taken into account in the sum over ttot.
*** 0.5 year of emissions is added for the two boundaries, such that the budget is calculated for 81 years.
s45_actualbudgetco2 = sum(ttot$(ttot.val le 2090 AND ttot.val > 2020), (sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot)))
                      + sum(regi, vm_emiTe.l("2100",regi,"co2") + vm_emiCdr.l("2100",regi,"co2") + vm_emiMac.l("2100",regi,"co2")) * sm_c_2_co2 * (10 - pm_ts("2090")/2 + 0.5)
                      + sum(regi, vm_emiTe.l("2020",regi,"co2") + vm_emiCdr.l("2020",regi,"co2") + vm_emiMac.l("2020",regi,"co2")) * sm_c_2_co2 * (pm_ts("2020")/2 + 0.5);
display s45_actualbudgetco2;
		
	if (cm_emiscen eq 6,
		if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
		display sm_budgetCO2eqGlob;		
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob * (cm_budgetCO2from2020/s45_actualbudgetco2);
			pm_budgetCO2eq(regi) = pm_budgetCO2eq(regi) * (cm_budgetCO2from2020/s45_actualbudgetco2);
		else
			sm_budgetCO2eqGlob = sm_budgetCO2eqGlob;
		);
		display sm_budgetCO2eqGlob;
	elseif cm_emiscen eq 9,
		display p45_taxCO2eq_anchor;
	    if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s45_actualbudgetco2 > 0 AND abs(cm_budgetCO2from2020 - s45_actualbudgetco2) ge 0.5,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
		  sm_globalBudget_dev = s45_actualbudgetco2 / cm_budgetCO2from2020; 
*** make sure that iteration converges: 
*** use multiplicative for budgets higher than 1200 Gt; for lower budgets, use multiplicative adjustment only for first 3 iterations, 
			if(ord(iteration) lt 3 or cm_budgetCO2from2020 > 1200,
			    !! change in CO2 price through adjustment: new price - old price; needed for adjustment option 2
				pm_taxCO2eq_anchor_iterationdiff(t) = p45_taxCO2eq_anchor(t) * min(max((s45_actualbudgetco2/cm_budgetCO2from2020)** (25/(2 * iteration.val + 23)),0.5+iteration.val/208),2 - iteration.val/102)  - p45_taxCO2eq_anchor(t);
				p45_taxCO2eq_anchor(t) = p45_taxCO2eq_anchor(t) + pm_taxCO2eq_anchor_iterationdiff(t) ;
*** then switch to triangle-approximation based on last two iteration data points			
			else
*** change in CO2 price through adjustment: new price - old price; the two instances of p45_taxCO2eq_anchor cancel out -> only the difference term
				pm_taxCO2eq_anchor_iterationdiff_tmp(t) = 
				                      max(pm_taxCO2eq_anchor_iterationdiff(t) * min(max((cm_budgetCO2from2020 - s45_actualbudgetco2)/(s45_actualbudgetco2 - s45_actualbudgetco2_last),-2),2),-p45_taxCO2eq_anchor(t)/2);
				p45_taxCO2eq_anchor(t) = p45_taxCO2eq_anchor(t) + 
				                      max(pm_taxCO2eq_anchor_iterationdiff(t) * min(max((cm_budgetCO2from2020 - s45_actualbudgetco2)/(s45_actualbudgetco2 - s45_actualbudgetco2_last),-2),2),-p45_taxCO2eq_anchor(t)/2);
			  pm_taxCO2eq_anchor_iterationdiff(t) = pm_taxCO2eq_anchor_iterationdiff_tmp(t);
			);
      o45_taxCO2eq_anchor_iterDiff_Itr(iteration) = pm_taxCO2eq_anchor_iterationdiff("2100");
		else
			if(s45_actualbudgetco2 > 0 or abs(cm_budgetCO2from2020 - s45_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
				p45_taxCO2eq_anchor(t) = p45_taxCO2eq_anchor(t);
				o45_taxCO2eq_anchor_iterDiff_Itr(iteration) = 0;
			else
*** if budget has turned negative, reduce CO2 price by 20%
				pm_taxCO2eq_anchor_iterationdiff(t) = -0.2*p45_taxCO2eq_anchor(t);
				p45_taxCO2eq_anchor(t) = p45_taxCO2eq_anchor(t) + pm_taxCO2eq_anchor_iterationdiff(t);
				o45_taxCO2eq_anchor_iterDiff_Itr(iteration) = pm_taxCO2eq_anchor_iterationdiff("2100");
			);	
		);
		display o45_taxCO2eq_anchor_iterDiff_Itr;
*** If functionalForm is linear, re-adjust global anchor trajectory to go through the point (cm_taxCO2_historicalYr, cm_taxCO2_historical) 
$ifThen.taxCO2functionalForm2 "%cm_taxCO2_functionalForm%" == "linear"
p45_taxCO2eq_anchor(t)$(t.val lt 2110) = s45_taxCO2_historical 
        + (p45_taxCO2eq_anchor("2110") - s45_taxCO2_historical) / (2110 - s45_taxCO2_historicalYr) !! Yearly increase of CO2 price that interpolates between cm_taxCO2_historical in cm_taxCO2_historicalYr and p45_taxCO2eq_anchor in 2110
                                      * (t.val - s45_taxCO2_historicalYr) ;
p45_taxCO2eq_anchor(t)$(t.val gt 2110) = p45_taxCO2eq_anchor("2110");
$endIf.taxCO2functionalForm2
	);
);

*** Algorithm for ENGAGE peakBudg formulation that results in a peak budget with zero net CO2 emissions afterwards
if(cm_iterative_target_adj eq 7,
*JeS/CB* Iteratively update regional CO2 tax trajectories / regional CO2 budget to reach the target for global peak budget, but make sure CO2 emissions afterward are close to zero on the global level
*KK* p45_actualbudgetco2 for ttot > 2020. It includes emissions from 2020 to ttot (including ttot).
*** (ttot.val - (ttot - 1).val)/2 and pm_ts("2020")/2 are the time periods that haven't been taken into account in the sum over ttot2.
*** 0.5 year of emissions is added for the two boundaries, such that the budget includes emissions in ttot.
p45_actualbudgetco2(ttot)$(ttot.val > 2020) = sum(ttot2$(ttot2.val < ttot.val AND ttot2.val > 2020), (sum(regi, (vm_emiTe.l(ttot2,regi,"co2") + vm_emiCdr.l(ttot2,regi,"co2") + vm_emiMac.l(ttot2,regi,"co2"))) * sm_c_2_co2 * pm_ts(ttot2)))
                       + sum(regi, (vm_emiTe.l(ttot,regi,"co2") + vm_emiCdr.l(ttot,regi,"co2") + vm_emiMac.l(ttot,regi,"co2"))) * sm_c_2_co2 * ((pm_ttot_val(ttot)-pm_ttot_val(ttot-1))/2 + 0.5)
                       + sum(regi, (vm_emiTe.l("2020",regi,"co2") + vm_emiCdr.l("2020",regi,"co2") + vm_emiMac.l("2020",regi,"co2"))) * sm_c_2_co2 * (pm_ts("2020")/2 + 0.5);
s45_actualbudgetco2 = smax(t$(t.val le cm_peakBudgYr AND t.val le 2100),p45_actualbudgetco2(t));
							
o45_peakBudgYr_Itr(iteration) = cm_peakBudgYr;
							
display s45_actualbudgetco2, p45_actualbudgetco2;

	if (cm_emiscen eq 9,
	  if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s45_actualbudgetco2 > 0 AND abs(cm_budgetCO2from2020 - s45_actualbudgetco2) ge 0.5,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
		display p45_taxCO2eq_anchor;		
*** make sure that iteration converges: 
*** use multiplicative for budgets higher than 1600 Gt; for lower budgets, use multiplicative adjustment only for first 3 iterations, 
			if(ord(iteration) lt 3 or cm_budgetCO2from2020 > 1600,
			    !! change in CO2 price through adjustment: new price - old price; needed for adjustment option 2
				pm_taxCO2eq_anchor_iterationdiff(t) = p45_taxCO2eq_anchor(t) * min(max((s45_actualbudgetco2/cm_budgetCO2from2020)** (25/(2 * iteration.val + 23)),0.5+iteration.val/208),2 - iteration.val/102)  - p45_taxCO2eq_anchor(t);
				p45_taxCO2eq_anchor(t)$(t.val le cm_peakBudgYr) = p45_taxCO2eq_anchor(t) + pm_taxCO2eq_anchor_iterationdiff(t) ;
				p45_taxCO2eq_anchor_until2150(t) = p45_taxCO2eq_anchor_until2150(t) + pm_taxCO2eq_anchor_iterationdiff(t) ;
*** then switch to triangle-approximation based on last two iteration data points			
			else
			    !! change in CO2 price through adjustment: new price - old price; the two instances of "p45_taxCO2eq_anchor" cancel out -> only the difference term
				!! until cm_peakBudgYr: expolinear price trajectory
				pm_taxCO2eq_anchor_iterationdiff_tmp(t) = 
				                      max(pm_taxCO2eq_anchor_iterationdiff(t) * min(max((cm_budgetCO2from2020 - s45_actualbudgetco2)/(s45_actualbudgetco2 - s45_actualbudgetco2_last),-2),2),-p45_taxCO2eq_anchor(t)/2);
				p45_taxCO2eq_anchor(t)$(t.val le cm_peakBudgYr) = p45_taxCO2eq_anchor(t) + 
				                      max(pm_taxCO2eq_anchor_iterationdiff(t) * min(max((cm_budgetCO2from2020 - s45_actualbudgetco2)/(s45_actualbudgetco2 - s45_actualbudgetco2_last),-2),2),-p45_taxCO2eq_anchor(t)/2);
			  p45_taxCO2eq_anchor_until2150(t) = p45_taxCO2eq_anchor_until2150(t) + 
				                      max(pm_taxCO2eq_anchor_iterationdiff(t) * min(max((cm_budgetCO2from2020 - s45_actualbudgetco2)/(s45_actualbudgetco2 - s45_actualbudgetco2_last),-2),2),-p45_taxCO2eq_anchor_until2150(t)/2);
				pm_taxCO2eq_anchor_iterationdiff(t) = pm_taxCO2eq_anchor_iterationdiff_tmp(t);
				!! after cm_peakBudgYr: adjustment so that emissions become zero: increase/decrease tax in each time step after cm_peakBudgYr by percentage of that year's total CO2 emissions of 2015 emissions
			);
      o45_taxCO2eq_anchor_iterDiff_Itr(iteration) = pm_taxCO2eq_anchor_iterationdiff("2100");
      display o45_taxCO2eq_anchor_iterDiff_Itr;
		else
			if(s45_actualbudgetco2 > 0 or abs(cm_budgetCO2from2020 - s45_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
			p45_taxCO2eq_anchor(t) = p45_taxCO2eq_anchor(t);
			else
*** if budget has turned negative, reduce CO2 price by 20%
			p45_taxCO2eq_anchor(t) = 0.8*p45_taxCO2eq_anchor(t);
			p45_taxCO2eq_anchor_until2150(t) = 0.8*p45_taxCO2eq_anchor_until2150(t);
			);	
		);
*** after cm_peakBudgYr: always adjust to bring emissions close to zero
		p45_taxCO2eq_anchor(t)$(t.val gt cm_peakBudgYr) = p45_taxCO2eq_anchor(t) + p45_taxCO2eq_anchor(t)*max(sum(regi2,vm_emiAll.l(t,regi2,"co2"))/sum(regi2,vm_emiAll.l("2015",regi2,"co2")),-0.75);

*** check if cm_peakBudgYr is correct: if global emissions already negative, move cm_peakBudgYr forward
*** similar code block as used in iterative-adjust 9 below (credit to RP)
    o45_diff_to_Budg(iteration) = (cm_budgetCO2from2020 - s45_actualbudgetco2);
    o45_totCO2emi_peakBudgYr(iteration) = sum(t$(t.val = cm_peakBudgYr), sum(regi2, vm_emiAll.l(t,regi2,"co2")) );
    o45_totCO2emi_allYrs(t,iteration) = sum(regi2, vm_emiAll.l(t,regi2,"co2") );
    o45_change_totCO2emi_peakBudgYr(iteration) = sum(ttot$(ttot.val = cm_peakBudgYr), (o45_totCO2emi_allYrs(ttot-1,iteration) - o45_totCO2emi_allYrs(ttot+1,iteration) )/4 );  !! Only gives a tolerance range, exact value not important. Division by 4 somewhat arbitrary - could be 3 or 5 as well. 

    display cm_peakBudgYr, o45_diff_to_Budg, o45_peakBudgYr_Itr, o45_totCO2emi_allYrs, o45_totCO2emi_peakBudgYr, o45_change_totCO2emi_peakBudgYr;

***if( sum(t,sum(regi2,vm_emiAll.l(t,regi2,"co2")$(t.val = cm_peakBudgYr))) < -0.1,
*** cm_peakBudgYr = tt.val(t - 1)$(t.val = cm_peakBudgYr);
***);		

    if( abs(o45_diff_to_Budg(iteration)) < 20,                      !! only think about shifting peakBudgYr if the budget is close enough to target budget
      display "close enough to target budget to check timing of peak year";
      loop(ttot$(ttot.val = cm_peakBudgYr),                               !! look at the peak timing
***        if(  ( (o45_totCO2emi_peakBudgYr(iteration) < -(0.1 + o45_change_totCO2emi_peakBudgYr(iteration)) ) AND (cm_peakBudgYr > 2040) ), !! no peaking time before 2040
        if(  ( (o45_totCO2emi_peakBudgYr(iteration) < -(0.1) ) AND (cm_peakBudgYr > 2040) ), !! no peaking time before 2040
        display "shift peakBudgYr left";
		  o45_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot - 1);                
***          p45_taxCO2eq_anchor(t)$(t.val gt pm_ttot_val(ttot - 1)) = p45_taxCO2eq_anchor_until2150(ttot-1) + (t.val - pm_ttot_val(ttot - 1)) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2_IncAfterPeakBudgYr per year after peakBudgYr
*** if tax after cm_peakBudgYr is higher than normal increase rate (exceeding a 20% tolerance): shift right
		elseif( ( sum(regi, sum(t2$(t2.val = pm_ttot_val(ttot+1)),p45_taxCO2eq_anchor(t2))) > sum(regi,sum(t2$(t2.val = pm_ttot_val(ttot+1)),p45_taxCO2eq_anchor_until2150(t2)))*1.2 ) AND (cm_peakBudgYr < 2100) ), !! if peaking time would be after 2100, keep 2100 budget year
          if(  (iteration.val > 2) AND ( o45_peakBudgYr_Itr(iteration - 1) > o45_peakBudgYr_Itr(iteration) ) AND ( o45_peakBudgYr_Itr(iteration - 2) = o45_peakBudgYr_Itr(iteration) ) , !! if the target year was just shifted left after being shifted right
            o45_peakBudgYr_Itr(iteration+1) = o45_peakBudgYr_Itr(iteration); !! don't shift right again immediately
          else
		    display "shift peakBudgYr right";
            o45_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot + 1);  !! ttot+1 is the new peakBudgYr
			loop(t$(t.val ge pm_ttot_val(ttot + 1)),
              p45_taxCO2eq_anchor(t) = p45_taxCO2eq_anchor_until2150(t);
            );
		  );
        
		else   !! don't do anything if the peakBudgYr is already at the corner values (2040, 2100) or if the emissions in the peakBudgYr are close to 0
          o45_peakBudgYr_Itr(iteration+1) = o45_peakBudgYr_Itr(iteration)
        );
      );
      cm_peakBudgYr = o45_peakBudgYr_Itr(iteration+1);
      display cm_peakBudgYr;
    );
*** If functionalForm is linear, re-adjust global anchor trajectory to go through the point (cm_taxCO2_historicalYr, cm_taxCO2_historical) 
$ifThen.taxCO2functionalForm3 "%cm_taxCO2_functionalForm%" == "linear"
p45_taxCO2eq_anchor_until2150(t) = s45_taxCO2_historical 
        + (sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchor_until2150(t2)) - s45_taxCO2_historical) / (cm_peakBudgYr - s45_taxCO2_historicalYr) !! Yearly increase of CO2 price that interpolates between cm_taxCO2_historical in cm_taxCO2_historicalYr and p45_taxCO2eq_anchor_until2150 in peak year
                                      * (t.val - s45_taxCO2_historicalYr) ;
p45_taxCO2eq_anchor(t)$(t.val le cm_peakBudgYr) = p45_taxCO2eq_anchor_until2150(t);
p45_taxCO2eq_anchor(t)$(t.val gt 2110) = p45_taxCO2eq_anchor("2110");
***TODO: CHECK IF ALGORITHM DOES WHAT IS EXPECTED. CURRENTLY NO RE-ADJUSTMENT OF GLOBAL ANCHOR TRAJECTORY BETWEEN PEAK YEAR AND 2110 AS NO SUCH ADJUSTMENT WAS CONTAINED IN ORIGINAL ALGORITHM
$endIf.taxCO2functionalForm3
	);
    display p45_taxCO2eq_anchor_until2150, p45_taxCO2eq_anchor;
);


*** Algorithm for new peakBudg formulation that results in a peak budget with linear increase given by cm_taxCO2_IncAfterPeakBudgYr
if (cm_iterative_target_adj eq 9,
*' Iteratively update regional CO2 tax trajectories / regional CO2 budget to reach the target for global peak budget, with a linear increase afterwards given by cm_taxCO2_IncAfterPeakBudgYr. The
*' peak budget year is determined automatically (within the time window 2040--2100)

*' `p45_actualbudgetco2(ttot)` includes emissions from 2020 to `ttot` (inclusive).
  p45_actualbudgetco2(ttot)$( 2020 lt ttot.val )
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

  s45_actualbudgetco2 = smax(t$( t.val le cm_peakBudgYr ), p45_actualbudgetco2(t));
  
  o45_peakBudgYr_Itr(iteration) = cm_peakBudgYr;
                  
  display s45_actualbudgetco2, p45_actualbudgetco2;

  if(cm_emiscen eq 9,
  
*** --------A: calculate the new CO2 price path,  the CO2 tax rescale factor----------------------------------------------------------  
  
    if(o_modelstat eq 2 AND ord(iteration) < cm_iteration_max AND s45_actualbudgetco2 > 0 AND abs(cm_budgetCO2from2020 - s45_actualbudgetco2) ge 2,   !!only for optimal iterations, and not after the last one, and only if budget still possitive, and only if target not yet reached
      display p45_taxCO2eq_anchor;

      if( ( ( p45_actualbudgetco2("2100") > 1.1 * s45_actualbudgetco2 ) AND ( abs(cm_budgetCO2from2020 - s45_actualbudgetco2) < 50 ) AND (iteration.val < 12) ), 
        display iteration;
*** if end-of-century budget is higher than budget at peak point, AND end-of-century budget is already in the range of the target budget (+/- 50 GtC), treat as end-of-century budget 
*** for this iteration. Only do this rough approach (jump to 2100) for the first iterations - at later iterations the slower adjustment of the peaking time should work better
        display "this is likely an end-of-century budget with no net negative emissions at all. Shift cm_peakBudgYr to 2100";
        s45_actualbudgetco2 = 0.5 * (p45_actualbudgetco2("2100") + s45_actualbudgetco2); !! due to the potential strong jump in cm_peakBudgYr, which implies that the CO2 price 
*** will increase over a longer time horizon, take the average of the budget at the old peak time and the new peak time
        cm_peakBudgYr = 2100;
      );

*** --------A1: for that, calculate the CO2 tax rescale factor---

      if(iteration.val lt 10,
        p45_factorRescale_taxCO2(iteration) = max(0.1, (s45_actualbudgetco2/cm_budgetCO2from2020) ) ** 3;
      else
        p45_factorRescale_taxCO2(iteration) = max(0.1, (s45_actualbudgetco2/cm_budgetCO2from2020) ) ** 2;
      );
      p45_factorRescale_taxCO2_Funneled(iteration) =
                max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p45_factorRescale_taxCO2(iteration)),
                        1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
                );

      pm_taxCO2eq_anchor_iterationdiff(t) = max(1* sm_DptCO2_2_TDpGtC, p45_taxCO2eq_anchor(t) * p45_factorRescale_taxCO2_Funneled(iteration) ) - p45_taxCO2eq_anchor(t);
      p45_taxCO2eq_anchor_until2150(t) = max(1* sm_DptCO2_2_TDpGtC, p45_taxCO2eq_anchor_until2150(t) * p45_factorRescale_taxCO2_Funneled(iteration) );
      p45_taxCO2eq_anchor(t) = max(1* sm_DptCO2_2_TDpGtC, p45_taxCO2eq_anchor(t) * p45_factorRescale_taxCO2_Funneled(iteration) );  !! rescale co2tax
      loop(t2$(t2.val eq cm_peakBudgYr),
*** Note: Adjustment of starting point linear curve is done at the end
	    p45_taxCO2eq_anchor(t)$(t.val gt cm_peakBudgYr) = p45_taxCO2eq_anchor_until2150(t2) + (t.val - t2.val) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2_IncAfterPeakBudgYr per year
	  );

      display p45_factorRescale_taxCO2, p45_factorRescale_taxCO2_Funneled;

      o45_taxCO2eq_anchor_iterDiff_Itr(iteration) = pm_taxCO2eq_anchor_iterationdiff("2100");
    
      display o45_taxCO2eq_anchor_iterDiff_Itr;
	  
  
    else !! if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s45_actualbudgetco2 > 0 AND abs(cm_budgetCO2from2020 ))
      if(s45_actualbudgetco2 > 0 or abs(cm_budgetCO2from2020 - s45_actualbudgetco2) < 2, !! if model was not optimal, or if budget already reached, keep tax constant
        p45_factorRescale_taxCO2(iteration)          = 1;
        p45_factorRescale_taxCO2_Funneled(iteration) = 1;
        p45_taxCO2eq_anchor_until2150(t) = p45_taxCO2eq_anchor_until2150(t); !! nothing changes
      else
*** if budget has turned negative, reduce CO2 price by 20%
      p45_factorRescale_taxCO2(iteration) = 0.8;
	  p45_factorRescale_taxCO2_Funneled(iteration) = p45_factorRescale_taxCO2(iteration);
	  
      p45_taxCO2eq_anchor_until2150(t) = p45_factorRescale_taxCO2(iteration) * p45_taxCO2eq_anchor_until2150(t);
      p45_taxCO2eq_anchor(t) = p45_factorRescale_taxCO2(iteration) * p45_taxCO2eq_anchor(t);
      );  
    ); !! if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max AND s45_actualbudgetco2 > 0 AND abs(cm_budgetCO2from2020 - s45_actualbudgetco2) ge 2,
    
    display p45_taxCO2eq_anchor, p45_taxCO2eq_anchor_until2150;

	
*** -------B: checking the peak timing, if cm_peakBudgYr is still correct or needs to be shifted-----------------------

    o45_diff_to_Budg(iteration) = (cm_budgetCO2from2020 - s45_actualbudgetco2);
    o45_totCO2emi_peakBudgYr(iteration) = sum(t$(t.val = cm_peakBudgYr), sum(regi2, vm_emiAll.l(t,regi2,"co2")) );
    o45_totCO2emi_allYrs(t,iteration) = sum(regi2, vm_emiAll.l(t,regi2,"co2") );
	
*RP* calculate how fast emissions are changing around the peaking time to get an idea how close it is possible to get to 0 due to the 5(10) year time steps 	
    o45_change_totCO2emi_peakBudgYr(iteration) = sum(ttot$(ttot.val = cm_peakBudgYr), (o45_totCO2emi_allYrs(ttot-1,iteration) - o45_totCO2emi_allYrs(ttot+1,iteration) )/4 );  !! Only gives a tolerance range, exact value not important. Division by 4 somewhat arbitrary - could be 3 or 5 as well. 

    display cm_peakBudgYr, o45_diff_to_Budg, o45_peakBudgYr_Itr, o45_totCO2emi_allYrs, o45_totCO2emi_peakBudgYr, o45_change_totCO2emi_peakBudgYr;


*** ----B1: check if cm_peakBudgYr should be shifted left or right: 
    if( abs(o45_diff_to_Budg(iteration)) < 20,                      !! only think about shifting peakBudgYr if the budget is close enough to target budget
      display "close enough to target budget to check timing of peak year";
	  
	  !!  check if the target year was just shifted back left after being shifted right before
	  if ( (iteration.val > 2) AND ( o45_peakBudgYr_Itr(iteration - 1) > o45_peakBudgYr_Itr(iteration) ) AND ( o45_peakBudgYr_Itr(iteration - 2) = o45_peakBudgYr_Itr(iteration) ),
	    o45_pkBudgYr_flipflop(iteration) = 1; 
        display "flipflop observed (before loop)";
	  );
	  
      loop(ttot$(ttot.val = cm_peakBudgYr),                               !! look at the peak timing
        if(  ( (o45_totCO2emi_peakBudgYr(iteration) < -(0.1 + o45_change_totCO2emi_peakBudgYr(iteration)) ) AND (cm_peakBudgYr > 2040) ), !! no peaking time before 2040
          display "shift peakBudgYr left";
		  o45_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot - 1);                
          p45_taxCO2eq_anchor(t)$(t.val gt pm_ttot_val(ttot - 1)) = p45_taxCO2eq_anchor_until2150(ttot-1) + (t.val - pm_ttot_val(ttot - 1)) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2_IncAfterPeakBudgYr per year after peakBudgYr
        
		elseif ( ( o45_totCO2emi_peakBudgYr(iteration) > (0.1 + o45_change_totCO2emi_peakBudgYr(iteration)) ) AND (cm_peakBudgYr < 2100) ), !! if peaking time would be after 2100, keep 2100 budget year
          if(  (o45_pkBudgYr_flipflop(iteration) eq 1), !! if the target year was just shifted left after being shifted right, and would now be shifted right again
            display "peakBudgYr was left, right, left and is now supposed to be shifted right again -> flipflop, thus go into separate loop";
            o45_peakBudgYr_Itr(iteration+1) = o45_peakBudgYr_Itr(iteration); !! don't shift right again immediately, but go into a different loop:
            o45_delay_increase_peakBudgYear(iteration) = 1;
		  elseif ( o45_delay_increase_peakBudgYear(iteration) eq 1 ),
		    display "still in separate loop trying to resolve flip-flop behavior";
			o45_peakBudgYr_Itr(iteration+1) = o45_peakBudgYr_Itr(iteration); !! keep current peakBudgYr,
          else
		    display "shift peakBudgYr right";
            o45_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot + 1);  !! ttot+1 is the new peakBudgYr
			loop(t$(t.val ge pm_ttot_val(ttot + 1)),
              p45_taxCO2eq_anchor(t) = p45_taxCO2eq_anchor_until2150(ttot+1) 
			                        + (t.val - pm_ttot_val(ttot + 1)) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2_IncAfterPeakBudgYr per year 
            );
		  );
        
		else   !! don't do anything if the peakBudgYr is already at the corner values (2040, 2100) or if the emissions in the peakBudgYr are close enough to 0 (within the range of +/- o45_change_totCO2emi_peakBudgYr)
          o45_peakBudgYr_Itr(iteration+1) = o45_peakBudgYr_Itr(iteration)
        );
      );
      cm_peakBudgYr = o45_peakBudgYr_Itr(iteration+1);
      display cm_peakBudgYr;
    );
*** Note: Adjustment of starting point linear curve is done at the end        
    p45_taxCO2eq_anchor(t)$(t.val le cm_peakBudgYr) = p45_taxCO2eq_anchor_until2150(t); !! until peakBudgYr, take the contiuous price trajectory
    
*** -----B2: if there was a flip-floping of cm_peakBudgYr in the previous iterations, try to overome this by adjusting the CO2 price path after the peaking year	
    if (o45_delay_increase_peakBudgYear(iteration) = 1,   
      display "not shifting peakBudgYr right, instead adjusting CO2 price for following year";
      loop(ttot$(ttot.val eq cm_peakBudgYr),  !! set ttot to the current peakBudgYr 
        loop(t2$(t2.val eq pm_ttot_val(ttot+1)),  !! set t2 to the following time step
          o45_factorRescale_taxCO2_afterPeakBudgYr(iteration) = 1 + max(sum(regi2,vm_emiAll.l(ttot,regi2,"co2"))/sum(regi2,vm_emiAll.l("2015",regi2,"co2")),-0.75) ; 
		  !! this was inspired by Christoph's approach. This value is 1 if emissions in the peakBudgYr are 0; goes down to 0.25 if emissions are <0 and approaching the size of 2015 emissions, and > 1 if emissions > 0. 
          
		  !! in case the normal linear extension still is not enough to get emissions to 0 after the peakBudgYr, shift peakBudgYr right again:
          if( ( o45_reached_until2150pricepath(iteration-1) eq 1 ) AND ( o45_totCO2emi_peakBudgYr(iteration) > (0.1 + o45_change_totCO2emi_peakBudgYr(iteration)) ), 
            display "price in following year reached original path in previous iteration and is still not enough -> shift peakBudgYr to right";
            o45_delay_increase_peakBudgYear(iteration+1) = 0;  !! probably is not necessary
            o45_reached_until2150pricepath(iteration) = 0;
            o45_peakBudgYr_Itr(iteration+1) = t2.val;        !! shift PeakBudgYear to the following time step
            p45_taxCO2eq_anchor(t2) = p45_taxCO2eq_anchor_until2150(t2) ;  !! set CO2 price in t2 to value in the "continuous path"
      
		  elseif ( ( o45_reached_until2150pricepath(iteration-1) eq 1 ) AND ( o45_totCO2emi_peakBudgYr(iteration) < (0.1 + o45_change_totCO2emi_peakBudgYr(iteration)) ) ), 
            display "New intermediate price in timestep after cm_peakBudgYr is sufficient to stabilize peaking year - go back to normal loop";	
			o45_delay_increase_peakBudgYear(iteration+1) = 0;  !! probably is not necessary
            o45_reached_until2150pricepath(iteration) = 0;
			o45_peakBudgYr_Itr(iteration+1) = o45_peakBudgYr_Itr(iteration);  
          else      !! either didn't reach the continued "until2150"-price path in last iteration, or the increase was high enough to get emissions to 0. 
		            !! in this case, keep PeakBudgYr, and adjust the price in the year after the peakBudgYr to get emissions close to 0,
			o45_delay_increase_peakBudgYear(iteration+1) = 1; !! make sure next iteration peakBudgYr is not shifted right again
		    o45_peakBudgYr_Itr(iteration+1) = o45_peakBudgYr_Itr(iteration);
            p45_taxCO2eq_anchor(t2) = max(p45_taxCO2eq_anchor(ttot), !! at least as high as the price in the peakBudgYr
                                       p45_taxCO2eq_anchor(t2) * (o45_factorRescale_taxCO2_afterPeakBudgYr(iteration) / p45_factorRescale_taxCO2_Funneled(iteration) ) !! the full path was already rescaled by p45_factorRescale_taxCO2_Funneled, so adjust the second rescaling
                                   );
            loop(regi,                   !! this loop is necessary to allow the <-comparison in the next if statement
              if( p45_taxCO2eq_anchor_until2150(t2) < p45_taxCO2eq_anchor(t2) ,   !! check if new price would be higher than the price if the peakBudgYr would be one timestep later 
                display "price increase reached price from path with cm_peakBudgYr one timestep later - downscale to 99%"; 
				p45_taxCO2eq_anchor(t2) = 0.99 * p45_taxCO2eq_anchor_until2150(t2); !! reduce the new CO2 price to 99% of the price that it would be if the peaking year was one timestep later. The next iteration will show if this is enough, otherwise cm_peakBudgYr will be shifted right 
                o45_reached_until2150pricepath(iteration) = 1;             !! upward CO2 price correction reached the continued price path - check in next iteration if this is high enough.  
              );
            );
          );
        
          display o45_factorRescale_taxCO2_afterPeakBudgYr;
		  p45_taxCO2eq_anchor(t)$(t.val gt t2.val) = p45_taxCO2eq_anchor(t2) + (t.val - t2.val) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2_IncAfterPeakBudgYr per year
		  
        ); !! loop t2$(t2.val eq pm_ttot_val(ttot+1)),  !! set t2 to the following time step
      );  !! loop ttot$(ttot.val eq cm_peakBudgYr),  !! set ttot to the current peakBudgYr 
      cm_peakBudgYr = o45_peakBudgYr_Itr(iteration+1);  !! this has to happen outside the loop, otherwise the loop condition might be true twice
    ); !! if o45_delay_increase_peakBudgYear(iteration) = 1,   !! if there was a flip-floping in the previous iterations, try to solve this

*** If functionalForm is linear, re-adjust global anchor trajectory to go through the point (cm_taxCO2_historicalYr, cm_taxCO2_historical) 
$ifThen.taxCO2functionalForm4 "%cm_taxCO2_functionalForm%" == "linear"
p45_taxCO2eq_anchor_until2150(t) = s45_taxCO2_historical 
        + (sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchor(t2)) - s45_taxCO2_historical) / (cm_peakBudgYr - s45_taxCO2_historicalYr) !! Yearly increase of CO2 price that interpolates between cm_taxCO2_historical in cm_taxCO2_historicalYr and p45_taxCO2eq_anchor in peak year
                                      * (t.val - s45_taxCO2_historicalYr) ;
p45_taxCO2eq_anchor(t)$(t.val le cm_peakBudgYr) = p45_taxCO2eq_anchor_until2150(t);
p45_taxCO2eq_anchor(t)$(t.val gt cm_peakBudgYr) = sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchor_until2150(t2)) !! CO2 tax in peak budget year
                                                  + (t.val - cm_peakBudgYr) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
p45_taxCO2eq_anchor(t)$(t.val gt 2110) = p45_taxCO2eq_anchor("2110");
$endIf.taxCO2functionalForm4
	
    display p45_taxCO2eq_anchor, p45_taxCO2eq_anchor_until2150, o45_delay_increase_peakBudgYear, o45_reached_until2150pricepath, o45_peakBudgYr_Itr, o45_pkBudgYr_flipflop, cm_peakBudgYr;
  ); !! if cm_emiscen eq 9,
);   !! if cm_iterative_target_adj eq 9,

*** Save s45_actualbudgetco2 for having it available in next iteration:
s45_actualbudgetco2_last = s45_actualbudgetco2;


***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part III (Regional differentiation): Re-create regional carbon price trajectories p45_taxCO2eq_regiDiff using p45_taxCO2eq_anchor (updated in parts I-II above) and p45_regiDiff_convFactor (computed in datainput)
***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
p45_taxCO2eq_regiDiff(t,regi) = p45_regiDiff_convFactor(t,regi) * p45_taxCO2eq_anchor(t);
display p45_taxCO2eq_regiDiff;

***------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part IV (Interpolation from path_gdx_ref): Re-create interpolation based on p45_taxCO2eq_regiDiff (updated in part III above) and p45_interpolation_exponent, p45_interpolation_startYr, p45_interpolation_endYr (computed in datainput)
***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Re-reate interpolation for all timesteps after cm_startyear
loop(regi,
  pm_taxCO2eq(t,regi)$(t.val lt p45_interpolation_startYr(regi)) = p45_taxCO2eq_path_gdx_ref(t,regi);
  pm_taxCO2eq(t,regi)$((t.val ge p45_interpolation_startYr(regi)) and (t.val lt p45_interpolation_endYr(regi))) = 
      sum(ttot2$(ttot2.val eq p45_interpolation_startYr(regi)), p45_taxCO2eq_path_gdx_ref(ttot2,regi)) !! value of p45_taxCO2eq_path_gdx_ref in p45_interpolation_startYr
      * (1 - rPower( (t.val - p45_interpolation_startYr(regi)) / (p45_interpolation_endYr(regi) - p45_interpolation_startYr(regi)), p45_interpolation_exponent(regi)))
    + sum(t2$(t2.val eq p45_interpolation_endYr(regi)), p45_taxCO2eq_regiDiff(t2,regi)) !! value of p45_taxCO2eq_regiDiff in p45_interpolation_endYr
      * rPower( (t.val - p45_interpolation_startYr(regi)) / (p45_interpolation_endYr(regi) - p45_interpolation_startYr(regi)), p45_interpolation_exponent(regi));
  pm_taxCO2eq(t,regi)$(t.val ge p45_interpolation_endYr(regi)) = p45_taxCO2eq_regiDiff(t,regi);
);
display pm_taxCO2eq;

*** Re-introduce lower bound pm_taxCO2eq by p45_taxCO2eq_path_gdx_ref if switch cm_taxCO2_lowerBound_path_gdx_ref is on
$ifthen.lowerBound "%cm_taxCO2_lowerBound_path_gdx_ref%" == "on"
  pm_taxCO2eq(t,regi) = max(pm_taxCO2eq(t,regi), p45_taxCO2eq_path_gdx_ref(t,regi));
$endIf.lowerBound
display pm_taxCO2eq;

*** Save pm_taxCO2eq and p45_taxCO2eq_anchor over iterations for debugging
p45_taxCO2eq_iteration(iteration,ttot,regi) = pm_taxCO2eq(ttot,regi);
p45_taxCO2eq_anchor_iteration(iteration,t) = p45_taxCO2eq_anchor(t);

);
*** EOF ./modules/45_carbonprice/functionalForm/postsolve.gms
