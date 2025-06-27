*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalForm/postsolve.gms

***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part 0 (Actual CO2 budget): If iterative_target_adj = 0, 7 or 9, compute actual CO2 peak budget in current iteration. If iterative_target_adj = 5, compute actual CO2 end-of-century budget in current iteration. 
***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if(cm_iterative_target_adj = 5,  !! End-of-century budget
  s45_actualbudgetco2 = sum(t$(t.val eq 2100),pm_actualbudgetco2(t)); 
else !! Peak budget
  s45_actualbudgetco2 = smax(t$(t.val le cm_peakBudgYr AND t.val le 2100),pm_actualbudgetco2(t));
  o45_peakBudgYr_Itr(iteration) = cm_peakBudgYr;
);
                  
display pm_actualbudgetco2, s45_actualbudgetco2;

*** Copied from postsolve algorithm for cm_iterative_target_adj = 5. TODO: Check where cm_emiscen eq 6 is used and if this should be kept.
if ((cm_emiscen eq 6) AND (cm_iterative_target_adj eq 5), 
	if(o_modelstat eq 2 AND ord(iteration)<cm_iteration_max ,   !!only for optimal iterations, and not after the last one
	display sm_budgetCO2eqGlob;		
		sm_budgetCO2eqGlob = sm_budgetCO2eqGlob * (cm_budgetCO2from2020/s45_actualbudgetco2);
		pm_budgetCO2eq(regi) = pm_budgetCO2eq(regi) * (cm_budgetCO2from2020/s45_actualbudgetco2);
	else
		sm_budgetCO2eqGlob = sm_budgetCO2eqGlob;
	);
	display sm_budgetCO2eqGlob;
);

*** Only run adjustment of carbon price trajectory if cm_emiscen eq 9 and if cm_iterative_target_adj is equal to 5,7 or 9.
if((cm_emiscen eq 9) AND ((cm_iterative_target_adj eq 5) OR (cm_iterative_target_adj eq 7) OR (cm_iterative_target_adj eq 9)),

*** Save pm_taxCO2eq and p45_taxCO2eq_anchor over iterations for debugging
pm_taxCO2eq_iter(iteration,ttot,regi) = pm_taxCO2eq(ttot,regi);
p45_taxCO2eq_anchor_iter(iteration,ttot) = p45_taxCO2eq_anchor(ttot);

*** Compute absolute deviation of actual budget from target budget
sm_globalBudget_absDev = s45_actualbudgetco2 - cm_budgetCO2from2020;

***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part I and II (Global anchor trajectory and post-peak behaviour): Adjustment of global anchor trajectory to meet (peak or end-of-century) CO2 budget target prescribed via cm_budgetCO2from2020.
***    If iterative_target_adj = 7 or 9, cm_peakBudgYr automatically adjusted (within the time window 2040--2100)
***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** --------ALGORITHM for cm_iterative_target_adj eq 5 or 9 ----------------------------------------------------------------------------------------
*** --------A: calculate the new CO2 price path, beginning with the CO2 tax rescale factor----------------------------------------------------------
*** --------   this step applies for peak budget and end-of-century budget targets -----------------------------------------------------------------
if((cm_iterative_target_adj eq 5) OR (cm_iterative_target_adj eq 9),

  if(cm_iterative_target_adj eq 9, !! stronger sensitivity of CO2 price adjustment to CO2 budget deviation for peak budget targets
    s45_factorRescale_taxCO2_exponent_before10 = 3;
    s45_factorRescale_taxCO2_exponent_from10 = 2;
  else !! less sensitivity of CO2 price adjustment to CO2 budget deviation for peak budget targets
    s45_factorRescale_taxCO2_exponent_before10 = 2;
    s45_factorRescale_taxCO2_exponent_from10 = 1;
  );

  if( (o_modelstat ne 2) OR (abs(sm_globalBudget_absDev) le cm_budgetCO2_absDevTol) OR (ord(iteration) = cm_iteration_max), 
    !! keep CO2 tax constant if model was not optimal, if maximal number of iterations is reached, or if budget already reached
    p45_factorRescale_taxCO2(iteration)          = 1;
    p45_factorRescale_taxCO2_Funneled(iteration) = p45_factorRescale_taxCO2(iteration);
  else !! adjust CO2 tax 
    if (s45_actualbudgetco2 > 0, !! if budget positive

      !! if end-of-century budget is higher than budget at peak point, AND end-of-century budget is already in the range of the target budget (+/- 50 GtC), treat as end-of-century budget 
      !! for this iteration. Only do this rough approach (jump to 2100) for the first iterations - at later iterations the slower adjustment of the peaking time should work better
      if( (cm_iterative_target_adj eq 9) AND ( pm_actualbudgetco2("2100") > 1.1 * s45_actualbudgetco2 ) AND ( abs(cm_budgetCO2from2020 - s45_actualbudgetco2) < 50 ) AND (iteration.val < 12), 
        display iteration;
        display "this is likely an end-of-century budget with no net negative emissions at all. Shift cm_peakBudgYr to 2100";
        cm_peakBudgYr = 2100;
        !! due to the potential strong jump in cm_peakBudgYr, which implies that the CO2 price will increase over a longer time horizon,
        !! take the average of the budget at the old peak time and the new peak time
        s45_actualbudgetco2 = 0.5 * (pm_actualbudgetco2("2100") + s45_actualbudgetco2); 
      );

      !! CO2 tax rescale factor
      if(iteration.val lt 10,
        p45_factorRescale_taxCO2(iteration) = max(0.1, (s45_actualbudgetco2/cm_budgetCO2from2020) ) ** s45_factorRescale_taxCO2_exponent_before10;
      else
        p45_factorRescale_taxCO2(iteration) = max(0.1, (s45_actualbudgetco2/cm_budgetCO2from2020) ) ** s45_factorRescale_taxCO2_exponent_from10;
      );
      p45_factorRescale_taxCO2_Funneled(iteration) 
        = max(min( 2 * EXP( -0.15 * iteration.val ) + 1.01 ,p45_factorRescale_taxCO2(iteration)),
              1/ ( 2 * EXP( -0.15 * iteration.val ) + 1.01)
          );
    else !! if budget has turned negative, reduce CO2 price by 20%
      !! CO2 tax rescale factor
      p45_factorRescale_taxCO2(iteration) = 0.8;
      p45_factorRescale_taxCO2_Funneled(iteration) = p45_factorRescale_taxCO2(iteration);
    );
    display p45_taxCO2eq_anchor, p45_taxCO2eq_anchor_until2150, p45_factorRescale_taxCO2, p45_factorRescale_taxCO2_Funneled;

    !! Apply CO2 tax rescale factor
    p45_taxCO2eq_anchor_until2150(ttot)$(ttot.val ge 2005) = p45_taxCO2eq_anchor_until2150(ttot) * p45_factorRescale_taxCO2_Funneled(iteration);
    display p45_taxCO2eq_anchor_until2150;

    !! If functionalForm is linear, re-adjust global anchor trajectory to go through the point (cm_taxCO2_historicalYr, cm_taxCO2_historical) 
$ifThen.taxCO2functionalForm4 "%cm_taxCO2_functionalForm%" == "linear"
    p45_taxCO2eq_anchor_until2150(ttot)$(ttot.val ge s45_taxCO2_historicalYr) = s45_taxCO2_historical 
        + (sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchor_until2150(t2)) - s45_taxCO2_historical) / (cm_peakBudgYr - s45_taxCO2_historicalYr) !! Yearly increase of CO2 price that interpolates between cm_taxCO2_historical in cm_taxCO2_historicalYr and p45_taxCO2eq_anchor_until2150 in peak year
                                      * (ttot.val - s45_taxCO2_historicalYr) ;
    display p45_taxCO2eq_anchor_until2150;
$endIf.taxCO2functionalForm4 

    !! Use rescaled p45_taxCO2eq_anchor_until2150 as starting point for re-defining p45_taxCO2eq_anchor
    p45_taxCO2eq_anchor(ttot)$(ttot.val ge 2005) = p45_taxCO2eq_anchor_until2150(ttot);
    
    if(cm_iterative_target_adj = 9, !! After cm_peakBudgYr, the global anchor trajectory increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr
      p45_taxCO2eq_anchor(t)$(t.val gt cm_peakBudgYr) = sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchor_until2150(t2)) !! CO2 tax in peak budget year
                                                  + (t.val - cm_peakBudgYr) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
    );  
    !! Always set carbon price constant after 2100 to prevent huge taxes after 2100 and the resulting convergence problems
    p45_taxCO2eq_anchor(t)$(t.val gt 2100) = p45_taxCO2eq_anchor("2100");

    !! Compute difference for debugging
    pm_taxCO2eq_anchor_iterationdiff(t) = p45_taxCO2eq_anchor(t) - p45_taxCO2eq_anchor_iter(iteration,t);
    o45_taxCO2eq_anchor_iterDiff_Itr(iteration) = pm_taxCO2eq_anchor_iterationdiff("2100");

    display p45_taxCO2eq_anchor, pm_taxCO2eq_anchor_iterationdiff, o45_taxCO2eq_anchor_iterDiff_Itr;

  ); !! if( (o_modelstat ne 2) OR (abs(sm_globalBudget_absDev) le cm_budgetCO2_absDevTol) OR (ord(iteration) = cm_iteration_max), 
); !! if((cm_iterative_target_adj eq 5) OR (cm_iterative_target_adj eq 9),


*** -------B: checking the peak timing, if cm_peakBudgYr is still correct or needs to be shifted-----------------------
*** --------  this step only applies for peak budget targets-----------------------------------------------------------
if(cm_iterative_target_adj eq 9,
  o45_diff_to_Budg(iteration) = (cm_budgetCO2from2020 - s45_actualbudgetco2);
  o45_totCO2emi_peakBudgYr(iteration) = sum(t$(t.val = cm_peakBudgYr), sum(regi2, vm_emiAll.l(t,regi2,"co2")) );
  o45_totCO2emi_allYrs(t,iteration) = sum(regi2, vm_emiAll.l(t,regi2,"co2") );
	
  !! calculate how fast emissions are changing around the peaking time to get an idea how close it is possible to get to 0 due to the 5(10) year time steps 	
  o45_change_totCO2emi_peakBudgYr(iteration) = sum(ttot$(ttot.val = cm_peakBudgYr), (o45_totCO2emi_allYrs(ttot-1,iteration) - o45_totCO2emi_allYrs(ttot+1,iteration) )/4 );  !! Only gives a tolerance range, exact value not important. Division by 4 somewhat arbitrary - could be 3 or 5 as well. 

  display cm_peakBudgYr, o45_diff_to_Budg, o45_peakBudgYr_Itr, o45_totCO2emi_allYrs, o45_totCO2emi_peakBudgYr, o45_change_totCO2emi_peakBudgYr;


  !!----B1: check if cm_peakBudgYr should be shifted left or right: 
  if( abs(o45_diff_to_Budg(iteration)) < 20, !! only think about shifting peakBudgYr if the budget is close enough to target budget
    display "close enough to target budget to check timing of peak year";
	 
	  !!  check if the target year was just shifted back left after being shifted right before
	  if ( (iteration.val > 2) AND ( o45_peakBudgYr_Itr(iteration - 1) > o45_peakBudgYr_Itr(iteration) ) AND ( o45_peakBudgYr_Itr(iteration - 2) = o45_peakBudgYr_Itr(iteration) ),
	    o45_pkBudgYr_flipflop(iteration) = 1; 
        display "flipflop observed (before loop)";
	  );
	 
    loop(ttot$(ttot.val = cm_peakBudgYr), !! look at the peak timing
      if(  ( (o45_totCO2emi_peakBudgYr(iteration) < -(0.1 + o45_change_totCO2emi_peakBudgYr(iteration)) ) AND (cm_peakBudgYr > 2040) ), !! no peaking time before 2040
        display "shift peakBudgYr left";
	      o45_peakBudgYr_Itr(iteration+1) =  pm_ttot_val(ttot - 1);                
        p45_taxCO2eq_anchor(t)$(t.val gt pm_ttot_val(ttot - 1)) = p45_taxCO2eq_anchor_until2150(ttot-1) + (t.val - pm_ttot_val(ttot - 1)) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2_IncAfterPeakBudgYr per year after peakBudgYr
       
	    elseif (( o45_totCO2emi_peakBudgYr(iteration) > (0.1 + o45_change_totCO2emi_peakBudgYr(iteration)) ) AND (cm_peakBudgYr < 2100)), !! if peaking time would be after 2100, keep 2100 budget year
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
  p45_taxCO2eq_anchor(ttot)$((ttot.val ge 2005) AND (ttot.val le cm_peakBudgYr)) = p45_taxCO2eq_anchor_until2150(ttot); !! until peakBudgYr, take the contiuous price trajectory
   
  !!-----B2: if there was a flip-floping of cm_peakBudgYr in the previous iterations, try to overome this by adjusting the CO2 price path after the peaking year	
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
    
	      elseif ( o45_totCO2emi_peakBudgYr(iteration) < (0.1 + o45_change_totCO2emi_peakBudgYr(iteration) ) ), 
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
  display p45_taxCO2eq_anchor, p45_taxCO2eq_anchor_until2150, o45_delay_increase_peakBudgYear, o45_reached_until2150pricepath, o45_peakBudgYr_Itr, o45_pkBudgYr_flipflop, cm_peakBudgYr;
);   !! if cm_iterative_target_adj eq 9,

*** --------ALGORITHM for cm_iterative_target_adj eq 7 ----------------------------------------------------------------------------------------
*** Algorithm for ENGAGE peakBudg formulation that results in a peak budget with zero net CO2 emissions afterwards
if(cm_iterative_target_adj eq 7,
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
				p45_taxCO2eq_anchor_iterationdiff_tmp(t) = 
				                      max(pm_taxCO2eq_anchor_iterationdiff(t) * min(max((cm_budgetCO2from2020 - s45_actualbudgetco2)/(s45_actualbudgetco2 - s45_actualbudgetco2_last),-2),2),-p45_taxCO2eq_anchor(t)/2);
				p45_taxCO2eq_anchor(t)$(t.val le cm_peakBudgYr) = p45_taxCO2eq_anchor(t) + 
				                      max(pm_taxCO2eq_anchor_iterationdiff(t) * min(max((cm_budgetCO2from2020 - s45_actualbudgetco2)/(s45_actualbudgetco2 - s45_actualbudgetco2_last),-2),2),-p45_taxCO2eq_anchor(t)/2);
			  p45_taxCO2eq_anchor_until2150(t) = p45_taxCO2eq_anchor_until2150(t) + 
				                      max(pm_taxCO2eq_anchor_iterationdiff(t) * min(max((cm_budgetCO2from2020 - s45_actualbudgetco2)/(s45_actualbudgetco2 - s45_actualbudgetco2_last),-2),2),-p45_taxCO2eq_anchor_until2150(t)/2);
				pm_taxCO2eq_anchor_iterationdiff(t) = p45_taxCO2eq_anchor_iterationdiff_tmp(t);
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
    p45_taxCO2eq_anchor(t)$(t.val gt 2100) = p45_taxCO2eq_anchor("2100");
***TODO: CHECK IF ALGORITHM DOES WHAT IS EXPECTED. CURRENTLY NO RE-ADJUSTMENT OF GLOBAL ANCHOR TRAJECTORY BETWEEN PEAK YEAR AND 2100 AS NO SUCH ADJUSTMENT WAS CONTAINED IN ORIGINAL ALGORITHM
$endIf.taxCO2functionalForm3

display p45_taxCO2eq_anchor_until2150, p45_taxCO2eq_anchor;
); !! if(cm_iterative_target_adj eq 7,

*** Save s45_actualbudgetco2 for having it available in next iteration:
s45_actualbudgetco2_last = s45_actualbudgetco2;


***----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part III (Regional differentiation): Re-compute p45_regiDiff_ratio, and 
***                                      re-create regional carbon price trajectories p45_taxCO2eq_regiDiff using p45_taxCO2eq_anchor (updated in parts I-II above) and p45_regiDiff_ratio
***----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Step III.1: Re-compute p45_regiDiff_initialRatio. This is necessary if p45_taxCO2eq_anchor was adjusted.

$ifThen.taxCO2regiDiff3 "%cm_taxCO2_regiDiff_startyearValue%" == "endogenous"
if( (cm_taxCO2_regiDiff = 0) or (cm_taxCO2_regiDiff = 3), !! none or gdpSpread
  !! Both parameters are not needed. No need to re-compute
elseif (cm_taxCO2_regiDiff = 1) or (cm_taxCO2_regiDiff = 2), !! initialSpread10 or initialSpread20
  !! Nothing to re-compute as p45_regiDiff_initialRatio does not depend on p45_taxCO2eq_anchor
elseif (cm_taxCO2_regiDiff = 5) or (cm_taxCO2_regiDiff = 6) or (cm_taxCO2_regiDiff = 7) or (cm_taxCO2_regiDiff = 8) or (cm_taxCO2_regiDiff = 10), !! ScenarioMIP2035, ScenarioMIP2050, ScenarioMIP2070, ScenarioMIP2100, or manual
  !! Re-compute p45_regiDiff_initialRatio based on regional carbon prices in p45_regiDiff_startYr
  p45_regiDiff_initialRatio(regi) = sum(ttot$(ttot.val eq p45_regiDiff_startYr(regi)), p45_taxCO2eq_path_gdx_ref(ttot,regi) / p45_taxCO2eq_anchor(ttot));
else
  abort "please choose a valid scenario via cm_taxCO2_regiDiff or set cm_taxCO2_regiDiff to manual"
);
$else.taxCO2regiDiff3
if( (cm_taxCO2_regiDiff = 0) or (cm_taxCO2_regiDiff = 1) or (cm_taxCO2_regiDiff = 2) or (cm_taxCO2_regiDiff = 3), !! none, initialSpread10, initialSpread20, or gdpSpread
  abort "Regional carbon prices can only be set manually via cm_taxCO2_regiDiff_startyearValue if cm_taxCO2_regiDiff equals (ScenarioMIP2035), (ScenarioMIP2050), (ScenarioMIP2070), (ScenarioMIP2100), or (manual)."
else
  !! Re-compute p45_regiDiff_initialRatio
  p45_regiDiff_initialRatio(regi) = sum(ttot$(ttot.val eq cm_startyear), p45_regiDiff_startyearValue(regi) / p45_taxCO2eq_anchor(ttot));
);
$endIf.taxCO2regiDiff3
display  p45_regiDiff_initialRatio;

*** Step III.3: Create ratio between regional carbon price and global anchor trajectory based on previously defined convergence

if( (cm_taxCO2_regiDiff = 0) or (cm_taxCO2_regiDiff = 3), !! none or gdpSpread
  !! Nothing to re-compute
else 
  !! Set convergence factor equal to p45_regiDiff_initialRatio before p45_regiDiff_startYr:
  p45_regiDiff_ratio(t,regi)$(t.val lt p45_regiDiff_startYr(regi)) = p45_regiDiff_initialRatio(regi);
  !! Set  convergence factor equal to 1 from p45_regiDiff_endYr:
  p45_regiDiff_ratio(t,regi)$(t.val ge p45_regiDiff_endYr(regi)) = 1;
  !! Create convergence between p45_regiDiff_startYr and p45_regiDiff_endYr:
  loop((t,regi)$((t.val ge p45_regiDiff_startYr(regi)) and (t.val lt p45_regiDiff_endYr(regi))),
    p45_regiDiff_ratio(t,regi) = p45_regiDiff_initialRatio(regi) 
                                + (1 - p45_regiDiff_initialRatio(regi)) * rPower( (t.val - p45_regiDiff_startYr(regi)) / (p45_regiDiff_endYr(regi) - p45_regiDiff_startYr(regi)), p45_regiDiff_exponent(regi));
  );
);
display p45_regiDiff_ratio;

*** Step III.4: Create regionally differentiated carbon price trajectories based on global anchor trajectory and p45_regiDiff_ratio

p45_taxCO2eq_regiDiff(t,regi) = p45_regiDiff_ratio(t,regi) * p45_taxCO2eq_anchor(t);
display p45_taxCO2eq_regiDiff;

*** Step III.5: If regional carbon prices in cm_startyear where set manually via cm_taxCO2_regiDiff_startyearValue, ensure that convergence to global anchor trajectory does not lead to lower regional carbon prices in some timesteps (this could happen if regional carbon price in cm_startyear is much higher than global anchor price)

$ifThen.taxCO2regiDiffStartyearValue2 "%cm_taxCO2_regiDiff_startyearValue%" == "endogenous"
$else.taxCO2regiDiffStartyearValue2
  p45_taxCO2eq_regiDiff(t,regi) = max(p45_taxCO2eq_regiDiff(t,regi), p45_regiDiff_startyearValue(regi));
  display "Apply p45_regiDiff_startyearValue(regi) as lower bound for p45_taxCO2eq_regiDiff"
  display p45_taxCO2eq_regiDiff;
$endIf.taxCO2regiDiffStartyearValue2

***------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part IV (Interpolation from path_gdx_ref): Re-create interpolation based on p45_taxCO2eq_regiDiff (updated in part III above), and s45_interpolation_startYr and s45_interpolation_endYr (computed in datainput)
***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Step IV.2: Re-create interpolation
pm_taxCO2eq(ttot,regi) = p45_taxCO2eq_path_gdx_ref(ttot,regi); !! Initialize pm_taxCO2eq with p45_taxCO2eq_path_gdx_ref. Then overwrite all time steps after cm_startyear
pm_taxCO2eq(t,regi)$(t.val le s45_interpolation_startYr) = p45_taxCO2eq_regiDiff(t,regi);
pm_taxCO2eq(t,regi)$((t.val gt s45_interpolation_startYr) and (t.val lt s45_interpolation_endYr)) =
    sum(ttot2$(ttot2.val eq s45_interpolation_startYr), p45_taxCO2eq_path_gdx_ref(ttot2,regi)) !! value of p45_taxCO2eq_path_gdx_ref in s45_interpolation_startYr
    * (s45_interpolation_endYr - t.val) / (s45_interpolation_endYr - s45_interpolation_startYr)
  + sum(t2$(t2.val eq s45_interpolation_endYr), p45_taxCO2eq_regiDiff(t2,regi)) !! value of p45_taxCO2eq_regiDiff in s45_interpolation_endYr
    * (t.val - s45_interpolation_startYr) / (s45_interpolation_endYr - s45_interpolation_startYr);
pm_taxCO2eq(t,regi)$(t.val ge s45_interpolation_endYr) = p45_taxCO2eq_regiDiff(t,regi);

display pm_taxCO2eq;

*** Step IV.3: Re-introduce lower bound pm_taxCO2eq by p45_taxCO2eq_path_gdx_ref if switch cm_taxCO2_lowerBound_path_gdx_ref is on
if(cm_taxCO2_lowerBound_path_gdx_ref = 1,
  pm_taxCO2eq(t,regi) = max(pm_taxCO2eq(t,regi), p45_taxCO2eq_path_gdx_ref(t,regi));
  display pm_taxCO2eq;
);


); !! if((cm_emiscen eq 9) AND ((cm_iterative_target_adj eq 5) OR (cm_iterative_target_adj eq 7) OR (cm_iterative_target_adj eq 9)),
*** EOF ./modules/45_carbonprice/functionalForm/postsolve.gms
