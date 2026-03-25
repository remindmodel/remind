*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalFormRegi/datainput.gms

*** Check that cm_iterative_target_adj is equal to 5 and that a valid carbon price trajectory is set
if( not ((cm_iterative_target_adj = 5)),
  abort "The realization 45_carbonprice/functionalFormRegi is only compatible with cm_iterative_target_adj = 5. Please adjust config file accordingly"
);

$ifthen.PriceShapeCombination "%cm_taxCO2_functionalForm%" == "exponential" 
  if(cm_CPslopeAdjustment = 1,
  abort "The carbon price slope can only be adjusted if cm_taxCO2_functionalForm == 'linear'. Set cm_CPslopeAdjustment = 0 for an exponential price curve."
  );
$endif.PriceShapeCombination

***----------------------------------------------------------------------------------
*** ---- Miscellaneous datainput calculations

*** Calculation of regional budgets if provided by p45_budgetCO2from2020RegiShare
p45_budgetCO2from2020Regi(regi) = p45_budgetCO2from2020RegiShare(regi) * cm_budgetCO2from2020;

*** Save the absolute budget deviation tolerance level; currently the same for all regions - may need regional specification in the future, thus already with (regi)
pm_regionalBudget_absDevTol(regi) = cm_budgetCO2_absDevTol;

*** Calculation of the funnel for p45_factorRescale_taxCO2Regi (only upper multiplier value, lower = 1/Upper)
loop(iteration,
p45_FunnelUpper(iteration) = 2 * EXP(-0.15 * iteration.val) + 1.005;
);

*** Other
s45_YearBeforeStartYear = smax(ttot$( ttot.val lt cm_startyear ), ttot.val); !! Timestep before startyear


***----------------------------------------------------------------------------------
*** ---- Derive the starting co2 price path and shape

*** Read pm_taxCO2eq from the input_ref and the specified input file
Execute_Loadpoint 'input_ref' p45_taxCO2eq_path_gdx_ref = pm_taxCO2eq;
Execute_Loadpoint 'input' p45_taxCO2eq_path_gdx_input = pm_taxCO2eq;

display p45_taxCO2eq_path_gdx_ref;

*** Convert tax values from $/t CO2eq to T$/GtC  
s45_taxCO2_startyear = cm_taxCO2_startyear * sm_DptCO2_2_TDpGtC; 
s45_taxCO2_peakBudgYr = cm_taxCO2_peakBudgYr * sm_DptCO2_2_TDpGtC; 

*** --- 
* Part I (General Shape):
!! always set the carbon price equal to the reference runs' carbon price prior to start year
p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val le s45_YearBeforeStartYear) = p45_taxCO2eq_path_gdx_ref(ttot,regi);

!! (A) Exponential CO2 price ----------------------------------------------------------------------------------
$ifThen.taxCO2GeneralShape "%cm_taxCO2_functionalForm%" == "exponential"
!! (A.a) no input gdx specified in config.csv => the carbon price increases exponentially, starting from the input_ref's carbon prices for the last fixed year in each region
if(cm_useInputGdxForCarbonPrice eq 0,
  p45_taxCO2refYear(regi)  = sum(ttot$(ttot.val eq s45_YearBeforeStartYear), p45_taxCO2eq_anchorRegi(ttot,regi)); 
  p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val gt s45_YearBeforeStartYear) = p45_taxCO2refYear(regi)  * cm_taxCO2_expGrowth**(ttot.val - s45_YearBeforeStartYear);

!! (A.b) an input.gdx is specified in config.csv => the carbon price reaches the 2100 value in 2100 or the specified peak year
else
  if(cm_taxCO2_Shape eq 1,  !! if increase until EOC
    p45_taxCO2refYear(regi)  = p45_taxCO2eq_path_gdx_input("2100",regi);  !! save 2100 CO2 price from the input.gdx as reference point
    p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val gt s45_YearBeforeStartYear AND ttot.val le 2100) = 
              p45_taxCO2refYear(regi)  / (cm_taxCO2_expGrowth**(2100 - ttot.val));
    !! carbon price post 2100 is set in Part II for all cm_taxCO2_functionalForm
    
  else !! increase until cm_peakBudgYr
    p45_taxCO2refYear(regi)  = sum(ttot$(ttot.val eq cm_peakBudgYr), p45_taxCO2eq_path_gdx_input(ttot,regi));  !! save cm_peakBudgYr CO2 price from the input.gdx as reference point
    p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val gt s45_YearBeforeStartYear AND ttot.val le cm_peakBudgYr) = 
              p45_taxCO2refYear(regi)  / (cm_taxCO2_expGrowth**(cm_peakBudgYr - ttot.val));
    !! carbon price post peak year is set in Part II for all cm_taxCO2_functionalForm          
  );  !! EOC or Peak
); !! use input.gdx information or not

!! (B) Linear CO2 price ----------------------------------------------------------------------------------
$elseIf.taxCO2GeneralShape "%cm_taxCO2_functionalForm%" == "linear"

***----------------------------------------------------------------------------------
!! (B.1) For setting a global carbon price slope, for the case that the slope is not adjusted  OR if the carbon price information from input.gdx is not used => analogous to functionalForm

*** Step I.1: Determine the point (s45_taxCO2_historicalYr, s45_taxCO2_historical)
*** Set s45_taxCO2_historicalYr based on the switch cm_taxCO2_historicalYr
$ifthen.taxCO2historicalYr "%cm_taxCO2_historicalYr%" == "last"
*** Choose s45_taxCO2_historicalYr to be the last time period before start year 
s45_taxCO2_historicalYr = smax(ttot$( ttot.val lt cm_startyear ), ttot.val);
$else.taxCO2historicalYr
*** Set s45_taxCO2_historicalYr to be the value provided by the switch
s45_taxCO2_historicalYr = %cm_taxCO2_historicalYr%;
$endif.taxCO2historicalYr
*** Check validity of s45_taxCO2_historicalYr 
if((s45_taxCO2_historicalYr lt 2005) or (s45_taxCO2_historicalYr ge cm_startyear) or (sum(ttot$(ttot.val eq s45_taxCO2_historicalYr),1)=0),
  abort "please choose cm_taxCO2_historicalYr to be an element of ttot that is at least 2005 and strictly smaller than cm_startyear"
);
display s45_taxCO2_historicalYr;

*** Set s45_taxCO2_historical based on the switch cm_taxCO2_historical
$ifthen.taxCO2historical "%cm_taxCO2_historical%" == "gdx_ref"
*** Extract level of carbon price in s45_taxCO2_historicalYr (defined as maximum of pm_taxCO2eq over all regions)
s45_taxCO2_historical = smax( regi , sum ( ttot$(ttot.val eq s45_taxCO2_historicalYr) , p45_taxCO2eq_path_gdx_ref(ttot,regi) ) );
$else.taxCO2historical
*** Set s45_taxCO2_historical to be the value provided by the switch, converted from $/t CO2eq to T$/GtC 
s45_taxCO2_historical = %cm_taxCO2_historical% * sm_DptCO2_2_TDpGtC;
$endif.taxCO2historical

display s45_taxCO2_historical;

*** Step I.2: Create linear global anchor trajectory through the points (s45_taxCO2_historicalYr, s45_taxCO2_historical), and (cm_startyear, s45_taxCO2_startyear) or (cm_peakBudgYr, cm_taxCO2_peakBudgYr) 

if((cm_taxCO2_startyear gt 0) and (cm_taxCO2_peakBudgYr eq -1), !! Initial global carbon price trajectory defined via (cm_startyear, s45_taxCO2_startyear)

  !! Make sure that initial carbon price trajectory is non-decreasing
  if(s45_taxCO2_startyear lt s45_taxCO2_historical,
    display cm_taxCO2_startyear;
    abort "please make sure that cm_taxCO2_startyear is at least as large as the value provided by cm_taxCO2_historical"
  );
  p45_taxCO2eq_anchor(ttot)$(ttot.val ge s45_taxCO2_historicalYr) = 
                          s45_taxCO2_historical
                          + (s45_taxCO2_startyear - s45_taxCO2_historical) / (cm_startyear - s45_taxCO2_historicalYr) !! Yearly increase of carbon price 
                            * (ttot.val - s45_taxCO2_historicalYr) ;

elseif (cm_taxCO2_startyear eq -1) and (cm_taxCO2_peakBudgYr gt 0) , !! Initial global carbon price trajetory defined via (cm_peakBudgYr, s45_taxCO2_peakBudgYr)

  !! Make sure that initial carbon price trajectory is non-decreasing, and cm_peakBudgYr is at least cm_startyear
  if (cm_peakBudgYr lt cm_startyear,
    abort "please initialize cm_peakBudgYr by setting it to a value that is larger or equal to cm_startyear"
  elseif s45_taxCO2_peakBudgYr lt s45_taxCO2_historical,
    display cm_taxCO2_peakBudgYr;
    abort "please make sure that cm_taxCO2_peakBudgYr is at least as large as the value provided by cm_taxCO2_historical"
  );
  p45_taxCO2eq_anchor(ttot)$(ttot.val ge s45_taxCO2_historicalYr) = 
                          s45_taxCO2_historical
                          + (s45_taxCO2_peakBudgYr - s45_taxCO2_historical) / (cm_peakBudgYr - s45_taxCO2_historicalYr) !! Yearly increase of carbon price 
                            * (ttot.val - s45_taxCO2_historicalYr) ;

elseif (cm_taxCO2_startyear eq -1) and (cm_taxCO2_peakBudgYr le 0) ,
  abort "please initialize cm_taxCO2_peakBudgYr by setting it to a positive value"
else 
  abort "please initialize cm_taxCO2_startyear by setting it to a positive value. Note that cm_taxCO2_peakBudgYr must be kept at default value -1 if not used."
); 

p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val ge cm_startyear) = p45_taxCO2eq_anchor(ttot);

***----------------------------------------------------------------------------------
!! (B.2) If carbon price is adjusted and the carbon price information from input.gdx should be used: overwrite the previously derived data
if((cm_CPslopeAdjustment eq 1) and (cm_useInputGdxForCarbonPrice eq 1), 
p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val ge cm_startyear) = 
        !! start value
        sum(ttot2$(ttot2.val eq s45_YearBeforeStartYear), p45_taxCO2eq_anchorRegi(ttot2,regi))
        !!  Yearly regional increase of carbon price in input.gdx in the time step after cm_startyear
        + (sum(ttot3$(ttot3.val eq cm_startyear), p45_taxCO2eq_path_gdx_input(ttot3+1,regi) - p45_taxCO2eq_path_gdx_input(ttot3,regi)) 
                    / sum(ttot3$(ttot3.val eq cm_startyear), pm_dt(ttot3))) 
            !! times years from last given time step
            * (ttot.val - s45_YearBeforeStartYear) ;

!! Check if this leads to negative values and set the 2100 price to 1 USD/tCO2 in that case. (possible if negative slope and different starting point in path_gdx_ref and path_gdx_input)
loop(regi,
if(p45_taxCO2eq_anchorRegi("2100",regi) le 0,
  p45_taxCO2eq_anchorRegi("2100",regi) = 1 * sm_DptCO2_2_TDpGtC;  
 !! start value
  p45_taxCO2eq_anchorRegi(ttot,regi)$(ttot.val ge cm_startyear) = 
        !! start value
        sum(ttot2$(ttot2.val eq s45_YearBeforeStartYear), p45_taxCO2eq_anchorRegi(ttot2,regi))
        !!  Yearly regional increase of carbon price in input.gdx in the time step after cm_startyear
        + ((sum(ttot3$(ttot3.val eq 2100), p45_taxCO2eq_anchorRegi(ttot3,regi)) 
            - sum(ttot4$(ttot4.val eq s45_YearBeforeStartYear), p45_taxCO2eq_anchorRegi(ttot4,regi))) 
            / (2100 - s45_YearBeforeStartYear))
            !! times years from last given time step
            * (ttot.val - s45_YearBeforeStartYear) ;
  );
);
); !! If carbon price information from input.gdx should be used

$endif.taxCO2GeneralShape 
!! exponential and linear shape specification

***-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part II (Post-peak behaviour): The global anchor trajectory can be adjusted after reaching the peak of global CO2 emissions in cm_peakBudgYr.
***                                The choice of cm_peakBudgYr is  adjusted if cm_taxCO2_Shape is set to "Peak"

*** Adjust global anchor trajectory so that after cm_peakBudgYr, it increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr
if(cm_taxCO2_Shape eq 2,
   p45_taxCO2eq_anchorRegi(t,regi)$(t.val gt cm_peakBudgYr) = sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchorRegi(t2,regi)) !! CO2 tax in peak budget year
                                                  + (t.val - cm_peakBudgYr) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
);

*** Always set carbon price constant after 2100 to prevent huge taxes after 2100 and the resulting convergence problems
p45_taxCO2eq_anchorRegi(t,regi)$(t.val gt 2100) = p45_taxCO2eq_anchorRegi("2100",regi);

*** Set pm_taxCO2eq to that value for the first iteration.
pm_taxCO2eq(ttot,regi) = p45_taxCO2eq_anchorRegi(ttot,regi);

*** Lower bound pm_taxCO2eq by p45_taxCO2eq_path_gdx_ref if switch cm_taxCO2_lowerBound_path_gdx_ref is on
if(cm_taxCO2_lowerBound_path_gdx_ref = 1,
  pm_taxCO2eq(t,regi) = max(pm_taxCO2eq(t,regi), p45_taxCO2eq_path_gdx_ref(t,regi));
  display pm_taxCO2eq;
);

display p45_taxCO2eq_anchorRegi;

*** Save the form of the regional anchor trajectory from the first iteration !! CHECK if necessary
p45_taxCO2eq_anchorRegi_until2150(ttot,regi) = p45_taxCO2eq_anchorRegi(ttot,regi);

*** EOF ./modules/45_carbonprice/functionalFormRegi/datainput.gms