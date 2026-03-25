*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalFormRegi/postsolve.gms

***------------------------------------------------------------------------------------------------------------------------------------------------
*** regional eoc emission budget: 
***------------------------------------------------------------------------------------------------------------------------------------------------
if(cm_iterative_target_adj eq 5,
*** 1. Get the relevant information from this iteration
  !! Update the actual budget by region and save across iterations for debugging
  p45_actualbudgetco2Regi_2100(regi) = sum(t$(t.val eq 2100), pm_actualbudgetco2Regi(t,regi)); 
  p45_actualbudgetco2Regi_2100_iter(iteration, regi) = p45_actualbudgetco2Regi_2100(regi);

  !! Save pm_taxCO2eq over iterations
  pm_taxCO2eq_iter(iteration,ttot,regi) = pm_taxCO2eq(ttot,regi);
  
  !! Compute deviation from regional target budget 
  pm_budgetDeviation(regi) =  p45_actualbudgetco2Regi_2100(regi) - p45_budgetCO2from2020Regi(regi);
  p45_budgetDeviation_iter(iteration, regi) = pm_budgetDeviation(regi) ; 

  !!  Save the best available information about the reaction of the actual budget to the change in prices 
  if (iteration.val ge 2,
     !! determine the (price change / budget change) in the last iteration. If no change in tax, then 0; no change of budget at all is very unlikely, thus negligible risk of infeasibility
      loop(regi,
        if ((p45_actualbudgetco2Regi_2100_iter(iteration, regi) -  p45_actualbudgetco2Regi_2100_iter(iteration - 1, regi)) ne 0,
        p45_TaxBudgetSlopeCurrent(regi) = (pm_taxCO2eq_iter(iteration, "2100", regi) - pm_taxCO2eq_iter(iteration-1, "2100", regi))
                                          / (p45_actualbudgetco2Regi_2100_iter(iteration, regi) -  p45_actualbudgetco2Regi_2100_iter(iteration - 1, regi));
        else
        p45_TaxBudgetSlopeCurrent(regi) = 1000; !! TBD: it has now happened, that there was absolutely no change in the budget between iterations. 
                                                !! How to deal with that case? Preliminary idea: 1000 as a marker for this case
         ); !! If condition
        );  !! Regi loop
      p45_TaxBudgetSlopeCurrent_iter(iteration, regi) = p45_TaxBudgetSlopeCurrent(regi);
      
      !! The slope is expected to be negative (i.e. price increase leads to lower actual budget). 
      !! If it is indeed negative, update the information from the previous iterations. (if there was no change, then the previously established relation remains available)
      loop(regi, 
        if((p45_TaxBudgetSlopeCurrent(regi) <0),
           p45_TaxBudgetSlopeBest(regi) = p45_TaxBudgetSlopeCurrent(regi);
          ); !! If condition
          ); !! Regi loop
      p45_TaxBudgetSlopeBest_iter(iteration,regi) = p45_TaxBudgetSlopeBest(regi);
     
  );

*** 2. Compute the rescaling factor 
loop(regi, 
 !! No adjustment if within tolerance
if (abs(pm_budgetDeviation(regi)) < abs(pm_regionalBudget_absDevTol(regi) ), 
            p45_factorRescale_taxCO2Regi(iteration, regi) = 1;
            
else   !! if not yet within tolerance
*** 2.1 for later iterations and if there is information about the carbon price adjustment leading into the right direction  
  if ((iteration.val ge 3) AND (p45_TaxBudgetSlopeBest(regi) lt 0), !! i.e. increase in carbon price led to reduction in budget, or vice versa; i.e. slope was meaningful     
        p45_factorRescale_taxCO2Regi(iteration, regi) =  (pm_taxCO2eq("2100", regi) + !! price in the previous iteration
                                                               (- pm_budgetDeviation(regi) *  p45_TaxBudgetSlopeBest(regi))) !! price change needed according to p45_TaxBudgetSlopeBest
                                                          / pm_taxCO2eq("2100", regi);     
      !! Note: p45_factorRescale_taxCO2Regi from this calculation coudl be negative when |pm_taxCO2eq| < |negative required price change|. 
      !! This is the case when the carbon-price-sensitivity is very low compared to the required budget change. 
      !! Leaving it for now, because the funnel takes care of it.
*** 2.2 for the first iteration or if p45_TaxBudgetSlopeBest is not yet established
  else  !! i.e. if iteration.val < 3 or unintuitive change
    !! a) positive budget target 
    if (p45_budgetCO2from2020Regi(regi) > 0,   
      !! a1) positive actual budget        => case analogous to global target default case: ratio = (actual budget/target)
          if (p45_actualbudgetco2Regi_2100(regi) >= 0,
            p45_factorRescale_taxCO2Regi(iteration, regi) = max(0.5, (p45_actualbudgetco2Regi_2100(regi) / p45_budgetCO2from2020Regi(regi))); 
      !! a2) negative actual budget       => ratio = (positive target) / (absolute difference). Potential problem: Approaches 1 for small negative budgets              
          else 
            p45_factorRescale_taxCO2Regi(iteration, regi) = 
                max(0.5, (p45_budgetCO2from2020Regi(regi) / (p45_budgetCO2from2020Regi(regi) + abs(p45_actualbudgetco2Regi_2100(regi))) ) ) ;
         )  !! positive target sub-categories             
    !! b) negative budget target
    else
      !! b1) positive actual budget             => take the absolute deviation & rescale to get a factor: ratio = log(actual + asb(target))
           if (p45_actualbudgetco2Regi_2100(regi) >= 0,
             p45_factorRescale_taxCO2Regi(iteration, regi) =  log(abs(p45_budgetCO2from2020Regi(regi)) + p45_actualbudgetco2Regi_2100(regi)) 
      !! b2) negative actual budget         => case reverse to global target default case: ratio = (target/actual budget)
          else
            p45_factorRescale_taxCO2Regi(iteration, regi) = max(0.5, (p45_budgetCO2from2020Regi(regi) / p45_actualbudgetco2Regi_2100(regi))))
          )  !! target type
      ); !! earlier vs. later iterations
    ); !! tolerance check
  ); !! regi loop for scaling factor calculation

*** 3. add a funnel to avoid excessive adjustments. 
  !! regi loop 3
  loop(regi,
     p45_factorRescale_taxCO2Regi_Funneled(iteration, regi)                                        
        = max(min( 2 * EXP( -0.15 * iteration.val) + 1.005, !! a) a maximum adjustment value which decreases with the number of iterations
                    p45_factorRescale_taxCO2Regi(iteration,regi)), 
              1/ ( 2 * EXP( -0.15 * iteration.val) + 1.005) !! b) a minimum adjustment value which increases with the number of iterations (0.95 for iter 25)
          );
    ); !! regi loop 3 (funnelling the rescaling factor)
  
  !! copy the information before further funnel adjustments
  pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi)  = p45_factorRescale_taxCO2Regi_Funneled(iteration, regi) ;
  
  !! check how the rescaling factor changed over the last three iterations to dampen or expand the rescaling factor depending on the case
  if ((iteration.val ge 4),
  loop(regi, 
    !! if the factor was set to the *upper* bound for this and the last 2 iterations: increase the allowed factor this iteration
    if ((   (pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) ge p45_FunnelUpper(iteration))  !! ge because last iteration may have already been adjusted upwards
        AND (pm_factorRescale_taxCO2Regi_Funneled2(iteration-1, regi) ge p45_FunnelUpper(iteration-1))
        AND (pm_factorRescale_taxCO2Regi_Funneled2(iteration-2, regi) ge p45_FunnelUpper(iteration-2))),
        pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) = min(1.2 * p45_FunnelUpper(iteration), !! if funnel was 1.001, it is now 1.201
                                                                      p45_factorRescale_taxCO2Regi(iteration,regi));  !! unless the original planned rescaling factor was less
        );

    !! if the factor was set to the *lower* bound for this and the last 2 iterations: increase the allowed factor this iteration
    if ((   (pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) le (1/p45_FunnelUpper(iteration)))  !! le because last iteration may have already been adjusted upwards
        AND (pm_factorRescale_taxCO2Regi_Funneled2(iteration-1, regi) le (1/p45_FunnelUpper(iteration-1)))
        AND (pm_factorRescale_taxCO2Regi_Funneled2(iteration-2, regi) le (1/p45_FunnelUpper(iteration-2)))),
        pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) = max( (1/p45_FunnelUpper(iteration)) / 1.2, 
                                                                      p45_factorRescale_taxCO2Regi(iteration,regi));
        );
    !! if the factor jumping pos-neg-pos or neg-pos-neg or if it was already on 1 for the last two iterations -> make the last increase only 30% of what was intended
    if ((   (pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) le 1)  !! ge because last iteration may have already been adjusted upwards
        AND (pm_factorRescale_taxCO2Regi_Funneled2(iteration-1, regi) ge 1)
        AND (pm_factorRescale_taxCO2Regi_Funneled2(iteration-2, regi) le 1))
        OR 
        (   (pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) ge 1)  !! ge because last iteration may have already been adjusted upwards
        AND (pm_factorRescale_taxCO2Regi_Funneled2(iteration-1, regi) le 1)
        AND (pm_factorRescale_taxCO2Regi_Funneled2(iteration-2, regi) ge 1)),
        pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) = 1 - (0.3 * (1-p45_factorRescale_taxCO2Regi_Funneled(iteration, regi))); !! decrease the distance to 1
        );
  ); !! regi loop
  ); !! if iteration far enough

!! Simultaneous up- and downward adjustment of carbon prices in early iterations
if (iteration.val le 12,
  p45_factorRescale_taxCO2Regi_Final(iteration, regi) = pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi);
  !! For later iterations, set the adjustment factors to 1 according to iteration number
  else
  !! a) uneven iteration => only update downwards
  if ((mod(iteration.val, 2) eq 1), 
  loop(regi, 
   if(pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) gt 1,
      p45_factorRescale_taxCO2Regi_Final(iteration, regi) = 1;
    else 
    p45_factorRescale_taxCO2Regi_Final(iteration, regi) = pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi);
    ); !! if condition
    ); !! regi Loop
  !! b) even iteration => only update upwards  
  else
  loop(regi, 
   if(pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi) lt 1,
      p45_factorRescale_taxCO2Regi_Final(iteration, regi) = 1;
    else 
    p45_factorRescale_taxCO2Regi_Final(iteration, regi) = pm_factorRescale_taxCO2Regi_Funneled2(iteration, regi);
    ); !! if condition
    ); !! regi Loop
  ); !! un/even iteration
);

*** 4. Shift anchor curve with regional adjustment factor
!! 4.1. get the carbon price trajectory used in this iteration
p45_taxCO2eq_anchorRegi(ttot, regi)$(ttot.val gt 2005) = pm_taxCO2eq(ttot,regi); 

!! Option 4A: slope of CP is not adjusted --> entire trajectory is rescaled, values will be used as of cm_startyear (see below)
if(cm_CPslopeAdjustment = 0, 
    !! A4.2. Scale the anchor trajectory in this iteration to get the adjusted trajectory to be used in iteration+1 
    p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val gt 2005) = 
        p45_taxCO2eq_anchorRegi(ttot, regi) * p45_factorRescale_taxCO2Regi_Final(iteration,regi);

    !! Adjust the shape if the peak-budget carbon price shape is set
  if(cm_taxCO2_Shape eq 2,
  !! After cm_peakBudgYr, the global anchor trajectory increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr
        p45_taxCO2eq_anchorRegi(t,regi)$(t.val gt cm_peakBudgYr) = sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchorRegi(t2,regi)) !! CO2 tax in peak budget year
                                                      + (t.val - cm_peakBudgYr) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
  ); !! peak shape
);  !! no CP slope adjustment

!! Option 4B: slope of CP is adjusted (only compatible with cm_taxCO2_functionalForm == "lin2peak" or "linear")
$ifthen.PriceIsLinear "%cm_taxCO2_functionalForm%" == "linear"
if(cm_CPslopeAdjustment = 1, 
    !! B4.2: Save the carbon price. The values prior to cm_startyear will not be adjusted    
    p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val ge 2005) = pm_taxCO2eq(ttot,regi); 
    p45_temp_anchor(ttot,regi)$(ttot.val ge 2005) = pm_taxCO2eq(ttot,regi); !! helper

    !! Option (a): If peak-budget shape:
  if(cm_taxCO2_Shape eq 2,
      !! B4.3a: Set the rescaled anchor trajectory as of cm_peakBudgYr
        p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val eq cm_peakBudgYr) = 
                    p45_temp_anchor(ttot,regi) * p45_factorRescale_taxCO2Regi_Final(iteration,regi);
      !! Set the peakBudgYr value plus predefined increase thereafter (the only currently tested version is post-increase slope = 0) (necessary because initial shape & thus all following are taken from the anchor trajectory)
        p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val ge cm_peakBudgYr) = 
                                            sum(ttot2$(ttot2.val eq cm_peakBudgYr), p45_taxCO2eq_anchorRegi(ttot2,regi)) !! CO2 tax in peak budget year
                                          + (ttot.val - cm_peakBudgYr) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
      
      !! B4.4a: Calculate the slope for a linear connection between the last carbon price from input data and the Price in the Peak Budget year
        p45_CarbonPriceSlope(regi) = (sum(ttot2$(ttot2.val eq cm_peakBudgYr), p45_taxCO2eq_anchorRegi(ttot2,regi)) 
                                  - sum(ttot3$(ttot3.val eq s45_YearBeforeStartYear), p45_taxCO2eq_anchorRegi(ttot3,regi)))
                                        /  (cm_peakBudgYr - s45_YearBeforeStartYear);
        p45_CarbonPriceSlope_iter(iteration,regi) = p45_CarbonPriceSlope(regi);
        
        p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val ge cm_startyear AND ttot.val lt cm_peakBudgYr) = 
                                            sum(ttot3$(ttot3.val eq s45_YearBeforeStartYear), p45_taxCO2eq_anchorRegi(ttot3,regi)) !! CO2 tax in last fixed period
                                                    + (ttot.val - s45_YearBeforeStartYear) * p45_CarbonPriceSlope(regi) ; 

      !! Option (b): If increase until EOC
  elseif(cm_taxCO2_Shape eq 1),
       !! B2.3b: Set the rescaled anchor trajectory as of cm_peakBudgYr
        p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val eq 2100) = 
                    p45_temp_anchor(ttot,regi) * p45_factorRescale_taxCO2Regi_Final(iteration,regi);

        !! Calculate the carbon price slope between last year from input gdx and 2100
        p45_CarbonPriceSlope(regi) = (sum(ttot2$(ttot2.val eq 2100), p45_taxCO2eq_anchorRegi(ttot2,regi)) 
                                        - sum(ttot3$(ttot3.val eq s45_YearBeforeStartYear), p45_taxCO2eq_anchorRegi(ttot3,regi)))
                                              /  (2100- s45_YearBeforeStartYear);

        p45_CarbonPriceSlope_iter(iteration,regi) = p45_CarbonPriceSlope(regi);

        p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val ge cm_startyear AND ttot.val lt 2100) = 
                                            sum(ttot3$(ttot3.val eq s45_YearBeforeStartYear), p45_taxCO2eq_anchorRegi(ttot3,regi)) !! CO2 tax in last fixed period
                                                    + (ttot.val - s45_YearBeforeStartYear) * p45_CarbonPriceSlope(regi) ;
  ); !! Peak shape
);!! CP slope adjustment 
$endif.PriceIsLinear

!! 4.4. Always set carbon price constant after 2100 to prevent huge taxes after 2100 and the resulting convergence problems
p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val gt 2100) = p45_taxCO2eq_anchorRegi("2100",regi);

!! 4.5. assign p45_taxCO2eq_anchorRegi as the new value of pm_taxCO2eq that will be used in the next iteration
pm_taxCO2eq(ttot,regi)$(ttot.val ge cm_startyear) = p45_taxCO2eq_anchorRegi(ttot,regi);

!! save the adjusted carbon price trajectory
p45_taxCO2eq_anchorRegi_iter(ttot, regi, iteration)  = p45_taxCO2eq_anchorRegi(ttot, regi);
); !! closing the overarching cm_iterative Target condition

*** Lower bound pm_taxCO2eq by p45_taxCO2eq_path_gdx_ref if switch cm_taxCO2_lowerBound_path_gdx_ref is on
if(cm_taxCO2_lowerBound_path_gdx_ref = 1,
  pm_taxCO2eq(t,regi) = max(pm_taxCO2eq(t,regi), p45_taxCO2eq_path_gdx_ref(t,regi));
  display pm_taxCO2eq;
);

***------------------------------------------------------------------------------------------------------------------------------------------------
***END regional eoc emission budget 
***------------------------------------------------------------------------------------------------------------------------------------------------
*** EOF ./modules/45_carbonprice/functionalFormRegi/postsolve.gms
