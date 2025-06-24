*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalForm/datainput.gms

*** Check that cm_iterative_target_adj is equal to 0, 5, 7, or 9
if( not ((cm_iterative_target_adj = 0) or (cm_iterative_target_adj eq 5) or (cm_iterative_target_adj eq 7) or (cm_iterative_target_adj eq 9) ),
  abort "The realization 45_carbonprice/functionalForm is only compatible with cm_iterative_target_adj = 0, 5, 7 or 9. Please adjust config file accordingly"
);

*** Read pm_taxCO2eq from path_gdx_ref
Execute_Loadpoint 'input_ref' p45_taxCO2eq_path_gdx_ref = pm_taxCO2eq;
display p45_taxCO2eq_path_gdx_ref;

*** -------- initial declaration of parameters for iterative target adjustment
o45_reached_until2150pricepath(iteration) = 0;


***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part I (Global anchor trajectory): The functional form (linear/exponential) of the global anchor trajectory is chosen via cm_taxCO2_functionalForm. 
***                                    The (initial) global anchor carbon price in cm_startyear is chosen via cm_taxCO2_startyear. Alternatively, the (initial) global anchor carbon price in cm_peakBudgYr is chosen via cm_taxCO2_peakBudgYr.
***                                    This value is endogenously adjusted to meet CO2 budget targets if cm_iterative_target_adj is set to 5, 7 or 9.
***                                    (linear):      The linear curve is determined by the two points (cm_taxCO2_historicalYr, cm_taxCO2_historical) and (cm_startyear, cm_taxCO2_startyear). 
***                                                   By default, cm_taxCO2_historicalYr is the last timestep before cm_startyear, and cm_taxCO2_historical is the carbon price in that timestep in the reference run (path_gdx_ref) - computed as the maximum of pm_taxCO2eq over all regions.
***                                    (exponential): The exponential curve is determined by exponential growth rate (cm_taxCO2_expGrowth).
***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Convert tax values from $/t CO2eq to T$/GtC  
s45_taxCO2_startyear = cm_taxCO2_startyear * sm_DptCO2_2_TDpGtC; 
s45_taxCO2_peakBudgYr = cm_taxCO2_peakBudgYr * sm_DptCO2_2_TDpGtC; 

$ifThen.taxCO2globalAnchor "%cm_taxCO2_functionalForm%" == "exponential"

if( (cm_taxCO2_startyear gt 0) and (cm_taxCO2_peakBudgYr eq -1), 
***   Initial global anchor carbon price increases exponentially with growth rate cm_taxCO2_expGrowth from s45_taxCO2_startyear in cm_startyear
  p45_taxCO2eq_anchor(ttot)$(ttot.val ge 2005) = s45_taxCO2_startyear * cm_taxCO2_expGrowth**(ttot.val - cm_startyear);
elseif (cm_taxCO2_startyear eq -1) and (cm_taxCO2_peakBudgYr gt 0) , 
***   Initial global anchor carbon price increases exponentially with growth rate cm_taxCO2_expGrowth through s45_taxCO2_peakBudgYr in cm_peakBudgYr
  p45_taxCO2eq_anchor(ttot)$(ttot.val ge 2005) = s45_taxCO2_peakBudgYr * cm_taxCO2_expGrowth**(ttot.val - cm_peakBudgYr);
elseif (cm_taxCO2_startyear eq -1) and (cm_taxCO2_peakBudgYr le 0) ,
  abort "please initialize cm_taxCO2_peakBudgYr by setting it to a positive value"
else
  abort "please initialize cm_taxCO2_startyear by setting it to a positive value. Note that cm_taxCO2_peakBudgYr must be kept at default value -1 if not used."
); 

$elseIf.taxCO2globalAnchor "%cm_taxCO2_functionalForm%" == "linear"
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
$ifthen.taxCO2historial "%cm_taxCO2_historical%" == "gdx_ref"
*** Extract level of carbon price in s45_taxCO2_historicalYr (defined as maximum of pm_taxCO2eq over all regions)
s45_taxCO2_historical = smax( regi , sum ( ttot$(ttot.val eq s45_taxCO2_historicalYr) , p45_taxCO2eq_path_gdx_ref(ttot,regi) ) );
$else.taxCO2historial
*** Set s45_taxCO2_historical to be the value provided by the switch, converted from $/t CO2eq to T$/GtC 
s45_taxCO2_historical = %cm_taxCO2_historical% * sm_DptCO2_2_TDpGtC;
$endif.taxCO2historial
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
$endIf.taxCO2globalAnchor

***-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part II (Post-peak behaviour): The global anchor trajectory can be adjusted after reaching the peak of global CO2 emissions in cm_peakBudgYr.
***                                The (initial) choice of cm_peakBudgYr is endogenously adjusted if cm_iterative_target_adj is set to 7 or 9.
***                                    (with iterative_target_adj = 0): after cm_peakBudgYr, the global anchor trajectory increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr (default = 0, i.e. constant),
***                                                                     set cm_peakBudgYr = 2100 to avoid adjustment
***                                    (with iterative_target_adj = 5): no adjustment to the functional form after cm_peakBudgYr
***                                    (with iterative_target_adj = 7): after cm_peakBudgYr, the global anchor trajectory is adjusted so that global net CO2 emissions stay close to zero
***                                    (with iterative_target_adj = 9): after cm_peakBudgYr, the global anchor trajectory increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr (default = 0, i.e. constant)
***-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Save the original form of the global anchor trajectory so that it can be accessed if cm_peakBudgYr is shifted to the right
p45_taxCO2eq_anchor_until2150(ttot) = p45_taxCO2eq_anchor(ttot);

*** Adjust global anchor trajectory so that after cm_peakBudgYr, it increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr
if((cm_iterative_target_adj = 0) or (cm_iterative_target_adj = 9),
  p45_taxCO2eq_anchor(t)$(t.val gt cm_peakBudgYr) = sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchor_until2150(t2)) !! CO2 tax in peak budget year
                                                  + (t.val - cm_peakBudgYr) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
);

*** Always set carbon price constant after 2100 to prevent huge taxes after 2100 and the resulting convergence problems
p45_taxCO2eq_anchor(t)$(t.val gt 2100) = p45_taxCO2eq_anchor("2100");
display p45_taxCO2eq_anchor_until2150, p45_taxCO2eq_anchor;

***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*'  Part III (Regional differentiation): Regional carbon price differentiation relative to global anchor trajectory is chosen via cm_taxCO2_regiDiff.
*'                                     (none): No regional differentiation, i.e. globally uniform carbon pricing
*'                                     (ScenarioMIP2035): Carbon price differentiation with convergence year 2035 - used in ScenarioMIP - that takes carbon prices from path_gdx_ref or cm_taxCO2_regiDiff_startyearValue as starting point and assumes regionally differentiated speed of convergence to global anchor trajectory
*'                                     (ScenarioMIP2050): Carbon price differentiation with convergence year 2050 - used in ScenarioMIP - that takes carbon prices from path_gdx_ref or cm_taxCO2_regiDiff_startyearValue as starting point and assumes regionally differentiated speed of convergence to global anchor trajectory
*'                                     (ScenarioMIP2070): Carbon price differentiation with convergence year 2070 - used in ScenarioMIP - that takes carbon prices from path_gdx_ref or cm_taxCO2_regiDiff_startyearValue as starting point and assumes regionally differentiated speed of convergence to global anchor trajectory
*'                                     (ScenarioMIP2100): Carbon price differentiation with convergence year 2100 - used in ScenarioMIP - that takes carbon prices from path_gdx_ref or cm_taxCO2_regiDiff_startyearValue as starting point and assumes regionally differentiated speed of convergence to global anchor trajectory
*'                                     (initialSpread10): Maximal initial spread of carbon prices in 2030 between OECD regions and poorest region is equal to 10. Initial spread for each region determined based on GDP per capita (PPP) in 2030. By default, carbon prices converge using quadratic phase-in until 2050. Convergence scheme can be adjusted with cm_taxCO2_regiDiff_convergence.
*'                                     (initialSpread20): Maximal initial spread of carbon prices in 2030 between OECD regions and poorest region is equal to 20. Initial spread for each region determined based on GDP per capita (PPP) in 2030. By default, carbon prices converge using quadratic phase-in until 2070. Convergence scheme can be adjusted with cm_taxCO2_regiDiff_convergence.
*'                                     (gdpSpread):       Regional differentiation based on GDP per capita (PPP) throughout the century. Uses current GDP per capita (PPP) of OECD countries - around 50'000 US$2017 - as threshold for application of full carbon price.
*'                                     (manual):          Enables manual specification of regional carbon price differentiation based on cm_taxCO2_regiDiff_convergence and cm_taxCO2_regiDiff_startyearValue
***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Compute GDP per capita (in 1e3 $ PPP 2017) 
p45_gdppcap_PPP(ttot,regi)$(ttot.val ge 2005) = pm_gdp(ttot,regi) / pm_shPPPMER(regi) / pm_pop(ttot,regi);
display p45_gdppcap_PPP;

*** Step III.1: Determine p45_regiDiff_endYr and p45_regiDiff_exponent based on cm_taxCO2_regiDiff and cm_taxCO2_regiDiff_convergence 

$ifThen.taxCO2regiDiff3 "%cm_taxCO2_regiDiff_convergence%" == "scenario"
***   Define p45_regiDiff_endYr and p45_regiDiff_exponent based on scenario chosen via cm_taxCO2_regiDiff
$ifThen.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "none"
***     Nothing to declare
$elseIf.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "gdpSpread"
***     Nothing to declare
$elseIf.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "ScenarioMIP2035"
***     p45_regiDiff_endYr 
    p45_regiDiff_endYr(regi) = 2035;
***     p45_regiDiff_exponent
    p45_regiDiff_exponent(regi)$(regi_group("EUR_regi",regi) OR regi_group("NEU_regi",regi) OR regi_group("USA_regi",regi) OR regi_group("CAZ_regi",regi) OR
                                 regi_group("JPN_regi",regi)) = 0.5;
    p45_regiDiff_exponent(regi)$(regi_group("CHA_regi",regi) OR regi_group("MEA_regi",regi) OR regi_group("REF_regi",regi) OR 
                                 regi_group("LAM_regi",regi)) = 0.75;
    p45_regiDiff_exponent(regi)$(regi_group("OAS_regi",regi)) = 1;
    p45_regiDiff_exponent(regi)$(regi_group("IND_regi",regi)) = 1.5;
    p45_regiDiff_exponent(regi)$(regi_group("SSA_regi",regi)) = 2;
    display  p45_regiDiff_endYr, p45_regiDiff_exponent;
$elseIf.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "ScenarioMIP2050"
***     p45_regiDiff_endYr 
    p45_regiDiff_endYr(regi)$(regi_group("EUR_regi",regi) OR regi_group("NEU_regi",regi) OR regi_group("USA_regi",regi) OR regi_group("CAZ_regi",regi) OR
                              regi_group("JPN_regi",regi)) = 2040;
    p45_regiDiff_endYr(regi)$(regi_group("CHA_regi",regi) OR regi_group("MEA_regi",regi) OR regi_group("REF_regi",regi) OR 
                              regi_group("LAM_regi",regi)) = 2050;
    p45_regiDiff_endYr(regi)$(regi_group("OAS_regi",regi) OR regi_group("IND_regi",regi) OR 
                              regi_group("SSA_regi",regi)) = 2050;
***     p45_regiDiff_exponent
    p45_regiDiff_exponent(regi)$(regi_group("EUR_regi",regi) OR regi_group("NEU_regi",regi) OR regi_group("USA_regi",regi) OR regi_group("CAZ_regi",regi) OR
                                 regi_group("JPN_regi",regi)) = 0.5;
    p45_regiDiff_exponent(regi)$(regi_group("CHA_regi",regi) OR regi_group("MEA_regi",regi) OR regi_group("REF_regi",regi) OR 
                                 regi_group("LAM_regi",regi)) = 0.75;
    p45_regiDiff_exponent(regi)$(regi_group("OAS_regi",regi)) = 1;
    p45_regiDiff_exponent(regi)$(regi_group("IND_regi",regi)) = 1.5;
    p45_regiDiff_exponent(regi)$(regi_group("SSA_regi",regi)) = 2;
    display  p45_regiDiff_endYr, p45_regiDiff_exponent;
$elseIf.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "ScenarioMIP2070"
***     p45_regiDiff_endYr 
    p45_regiDiff_endYr(regi)$(regi_group("EUR_regi",regi) OR regi_group("NEU_regi",regi) OR regi_group("USA_regi",regi) OR regi_group("CAZ_regi",regi) OR
                              regi_group("JPN_regi",regi)) = 2040;
    p45_regiDiff_endYr(regi)$(regi_group("CHA_regi",regi) OR regi_group("MEA_regi",regi) OR regi_group("REF_regi",regi) OR 
                              regi_group("LAM_regi",regi)) = 2060;
    p45_regiDiff_endYr(regi)$(regi_group("OAS_regi",regi) OR regi_group("IND_regi",regi) OR 
                              regi_group("SSA_regi",regi)) = 2070;
***     p45_regiDiff_exponent
    p45_regiDiff_exponent(regi)$(regi_group("EUR_regi",regi) OR regi_group("NEU_regi",regi) OR regi_group("USA_regi",regi) OR regi_group("CAZ_regi",regi) OR
                                 regi_group("JPN_regi",regi)) = 0.5;
    p45_regiDiff_exponent(regi)$(regi_group("CHA_regi",regi) OR regi_group("MEA_regi",regi) OR regi_group("REF_regi",regi) OR 
                                 regi_group("LAM_regi",regi)) = 0.75;
    p45_regiDiff_exponent(regi)$(regi_group("OAS_regi",regi)) = 1;
    p45_regiDiff_exponent(regi)$(regi_group("IND_regi",regi)) = 1.5;
    p45_regiDiff_exponent(regi)$(regi_group("SSA_regi",regi)) = 2;
    display  p45_regiDiff_endYr, p45_regiDiff_exponent;
$elseIf.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "ScenarioMIP2100"
***     p45_regiDiff_endYr 
    p45_regiDiff_endYr(regi)$(regi_group("EUR_regi",regi) OR regi_group("NEU_regi",regi) OR regi_group("USA_regi",regi) OR regi_group("CAZ_regi",regi) OR
                              regi_group("JPN_regi",regi)) = 2050;
    p45_regiDiff_endYr(regi)$(regi_group("CHA_regi",regi) OR regi_group("MEA_regi",regi) OR regi_group("REF_regi",regi) OR 
                              regi_group("LAM_regi",regi)) = 2080;
    p45_regiDiff_endYr(regi)$(regi_group("OAS_regi",regi) OR regi_group("IND_regi",regi) OR 
                              regi_group("SSA_regi",regi)) = 2100;
***     p45_regiDiff_exponent
    p45_regiDiff_exponent(regi)$(regi_group("EUR_regi",regi) OR regi_group("NEU_regi",regi) OR regi_group("USA_regi",regi) OR regi_group("CAZ_regi",regi) OR
                                 regi_group("JPN_regi",regi)) = 0.5;
    p45_regiDiff_exponent(regi)$(regi_group("CHA_regi",regi) OR regi_group("MEA_regi",regi) OR regi_group("REF_regi",regi) OR 
                                 regi_group("LAM_regi",regi)) = 0.75;
    p45_regiDiff_exponent(regi)$(regi_group("OAS_regi",regi)) = 1;
    p45_regiDiff_exponent(regi)$(regi_group("IND_regi",regi)) = 1.5;
    p45_regiDiff_exponent(regi)$(regi_group("SSA_regi",regi)) = 2;
    display  p45_regiDiff_endYr, p45_regiDiff_exponent;
$elseIf.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "initialSpread10"
***     p45_regiDiff_endYr 
    p45_regiDiff_endYr(regi) = 2050;
***     p45_regiDiff_exponent
    p45_regiDiff_exponent(regi) = 2;
    display  p45_regiDiff_endYr, p45_regiDiff_exponent;
$elseIf.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "initialSpread20"
***     p45_regiDiff_endYr 
    p45_regiDiff_endYr(regi) = 2070;
***     p45_regiDiff_exponent
    p45_regiDiff_exponent(regi) = 2;
    display  p45_regiDiff_endYr, p45_regiDiff_exponent;
$else.taxCO2regiDiff4
    abort "please choose a valid scenario via cm_taxCO2_regiDiff or set cm_taxCO2_regiDiff to manual"
$endIf.taxCO2regiDiff4
$else.taxCO2regiDiff3
***   Define p45_regiDiff_endYr and p45_regiDiff_exponent based on manually provided values
$ifThen.taxCO2regiDiffManual1 "%cm_taxCO2_regiDiff%" == "none"
    abort "It is not possible to provide manual values via cm_taxCO2_regiDiff_convergence if cm_taxCO2_regiDiff is set to none."
$elseIf.taxCO2regiDiffManual1 "%cm_taxCO2_regiDiff%" == "gdpSpread"
    abort "It is not possible to provide manual values via cm_taxCO2_regiDiff_convergence if cm_taxCO2_regiDiff is set to gdpSpread."
$else.taxCO2regiDiffManual1
***     Set p45_regiDiff_endYr and p45_regiDiff_exponent based on data provided by switch cm_taxCO2_regiDiff_convergence
    loop((ext_regi,ttot)$p45_regiDiff_convergence_data(ext_regi,ttot),
      loop(regi$regi_groupExt(ext_regi,regi),
        p45_regiDiff_exponent(regi) = p45_regiDiff_convergence_data(ext_regi,ttot);
        p45_regiDiff_endYr(regi) = ttot.val;
      );
    );
    display  p45_regiDiff_endYr, p45_regiDiff_exponent;
$endIf.taxCO2regiDiffManual1
$endIf.taxCO2regiDiff3

*** Step III.2: Determine p45_regiDiff_startYr and p45_regiDiff_initialRatio based on cm_taxCO2_regiDiff and cm_taxCO2_regiDiff_startyearValue

$ifThen.taxCO2regiDiff5 "%cm_taxCO2_regiDiff_startyearValue%" == "endogenous"
***   Define p45_regiDiff_startYr and p45_regiDiff_initialRatio based on cm_taxCO2_regiDiff
$ifThen.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "none"
***     Nothing to declare
$elseIf.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "gdpSpread"
***     Nothing to declare
$elseIf.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "ScenarioMIP2035"
***     Choose p45_regiDiff_startYr to be the last time period before start year 
    p45_regiDiff_startYr(regi) = smax(ttot$( ttot.val lt cm_startyear ), ttot.val);
***     Define p45_regiDiff_initialRatio based on regional carbon prices in p45_regiDiff_startYr
    p45_regiDiff_initialRatio(regi) = sum(ttot$(ttot.val eq p45_regiDiff_startYr(regi)), p45_taxCO2eq_path_gdx_ref(ttot,regi) / p45_taxCO2eq_anchor(ttot));
    display  p45_regiDiff_startYr, p45_regiDiff_initialRatio;
$elseIf.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "ScenarioMIP2050"
***     Choose p45_regiDiff_startYr to be the last time period before start year 
    p45_regiDiff_startYr(regi) = smax(ttot$( ttot.val lt cm_startyear ), ttot.val);
***     Define p45_regiDiff_initialRatio based on regional carbon prices in p45_regiDiff_startYr
    p45_regiDiff_initialRatio(regi) = sum(ttot$(ttot.val eq p45_regiDiff_startYr(regi)), p45_taxCO2eq_path_gdx_ref(ttot,regi) / p45_taxCO2eq_anchor(ttot));
    display  p45_regiDiff_startYr, p45_regiDiff_initialRatio;
$elseIf.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "ScenarioMIP2070"
***     Choose p45_regiDiff_startYr to be the last time period before start year 
    p45_regiDiff_startYr(regi) = smax(ttot$( ttot.val lt cm_startyear ), ttot.val);
***     Define p45_regiDiff_initialRatio based on regional carbon prices in p45_regiDiff_startYr
    p45_regiDiff_initialRatio(regi) = sum(ttot$(ttot.val eq p45_regiDiff_startYr(regi)), p45_taxCO2eq_path_gdx_ref(ttot,regi) / p45_taxCO2eq_anchor(ttot));
    display  p45_regiDiff_startYr, p45_regiDiff_initialRatio;
$elseIf.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "ScenarioMIP2100"
***     Choose p45_regiDiff_startYr to be the last time period before start year 
    p45_regiDiff_startYr(regi) = smax(ttot$( ttot.val lt cm_startyear ), ttot.val);
***     Define p45_regiDiff_initialRatio based on regional carbon prices in p45_regiDiff_startYr
    p45_regiDiff_initialRatio(regi) = sum(ttot$(ttot.val eq p45_regiDiff_startYr(regi)), p45_taxCO2eq_path_gdx_ref(ttot,regi) / p45_taxCO2eq_anchor(ttot));
    display  p45_regiDiff_startYr, p45_regiDiff_initialRatio;
$elseIf.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "initialSpread10"
***     Set p45_regiDiff_startYr
    p45_regiDiff_startYr(regi) = 2030;
***     Define p45_regiDiff_initialRatio for maximal initial spread equal to 10
***     Guiding principle: Apply full carbon price (ratio = 1) for regions with GDP per capita at least 50 (in 1e3 $ PPP 2017),
***                        apply 10 percent of it (ratio = 0.1) for regions with GDP per capita below 5 (in 1e3 $ PPP 2017),
***                        linear increase of ratio for intermediate GDP per capita values
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) le 5) = 0.1; !! SSA (about 4)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 5  and p45_gdppcap_PPP("2030",regi) le 12.5) = 0.2; !! IND (about 12)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 12.5 and p45_gdppcap_PPP("2030",regi) le 15) = 0.3; !! OAS (about 14)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 15 and p45_gdppcap_PPP("2030",regi) le 21) = 0.4; !! LAM, MEA (about 17-20)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 21 and p45_gdppcap_PPP("2030",regi) le 25) = 0.5; 
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 25 and p45_gdppcap_PPP("2030",regi) le 30) = 0.6; !! CHA, REF (about 26-29)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 30) = 1; !! EUR, JPN, USA, CAZ, NEU (between 42 and 75 - category starts lower to include all subregions of EUR and NEU in H21)
    display  p45_regiDiff_startYr, p45_regiDiff_initialRatio;
$elseIf.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "initialSpread20"
***     Set p45_regiDiff_startYr
    p45_regiDiff_startYr(regi) = 2030;
***     Define p45_regiDiff_initialRatio for maximal initial spread equal to 10
***     Guiding principle: Apply full carbon price (ratio = 1) for regions with GDP per capita at least 50 (in 1e3 $ PPP 2017),
***                        apply 5 percent of it (ration = 0.05) for regions with GDP per capita below 5 (in 1e3 $ PPP 2017)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) le 5) = 0.05; !! SSA (about 4)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 5  and p45_gdppcap_PPP("2030",regi) le 12.5) = 0.1; !! IND (about 12)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 12.5 and p45_gdppcap_PPP("2030",regi) le 15) = 0.2; !! OAS (about 14)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 15 and p45_gdppcap_PPP("2030",regi) le 21) = 0.3; !! LAM, MEA (about 17-20)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 21 and p45_gdppcap_PPP("2030",regi) le 25) = 0.4;
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 25 and p45_gdppcap_PPP("2030",regi) le 30) = 0.5; !! CHA, REF (about 26-29)
    p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2030",regi) gt 30) = 1; !! EUR, JPN, USA, CAZ, NEU (between 42 and 75 - category starts lower to include all subregions of EUR and NEU in H21)
    display  p45_regiDiff_startYr, p45_regiDiff_initialRatio;
$elseIf.taxCO2regiDiff6 "%cm_taxCO2_regiDiff%" == "manual"
***     Choose p45_regiDiff_startYr to be the last time period before start year 
    p45_regiDiff_startYr(regi) = smax(ttot$( ttot.val lt cm_startyear ), ttot.val);
***     Define p45_regiDiff_initialRatio based on regional carbon prices in p45_regiDiff_startYr
    p45_regiDiff_initialRatio(regi) = sum(ttot$(ttot.val eq p45_regiDiff_startYr(regi)), p45_taxCO2eq_path_gdx_ref(ttot,regi) / p45_taxCO2eq_anchor(ttot));
    display  p45_regiDiff_startYr, p45_regiDiff_initialRatio;
$else.taxCO2regiDiff6
    abort "please choose a valid scenario via cm_taxCO2_regiDiff or set cm_taxCO2_regiDiff to manual"
$endIf.taxCO2regiDiff6

$else.taxCO2regiDiff5
$ifThen.taxCO2regiDiffStartyearValue2 "%cm_taxCO2_regiDiff%" == "none"
  abort "Regional carbon prices can only be set manually via cm_taxCO2_regiDiff_startyearValue if cm_taxCO2_regiDiff equals (ScenarioMIP2035), (ScenarioMIP2050), (ScenarioMIP2070), (ScenarioMIP2100), or (manual)."
$elseIf.taxCO2regiDiffStartyearValue2 "%cm_taxCO2_regiDiff%" == "initialSpread10"
  abort "Regional carbon prices can only be set manually via cm_taxCO2_regiDiff_startyearValue if cm_taxCO2_regiDiff equals (ScenarioMIP2035), (ScenarioMIP2050), (ScenarioMIP2070), (ScenarioMIP2100), or (manual)."
$elseIf.taxCO2regiDiffStartyearValue2 "%cm_taxCO2_regiDiff%" == "initialSpread20"
  abort "Regional carbon prices can only be set manually via cm_taxCO2_regiDiff_startyearValue if cm_taxCO2_regiDiff equals (ScenarioMIP2035), (ScenarioMIP2050), (ScenarioMIP2070), (ScenarioMIP2100), or (manual)."
$elseIf.taxCO2regiDiffStartyearValue2 "%cm_taxCO2_regiDiff%" == "gdpSpread"
  abort "Regional carbon prices can only be set manually via cm_taxCO2_regiDiff_startyearValue if cm_taxCO2_regiDiff equals (ScenarioMIP2035), (ScenarioMIP2050), (ScenarioMIP2070), (ScenarioMIP2100), or (manual)."
$else.taxCO2regiDiffStartyearValue2
***   Set p45_regiDiff_startYr equal to cm_startyear
  p45_regiDiff_startYr(regi) = cm_startyear;
***   Define p45_regiDiff_startyearValue in T$/GtC based on data provided by p45_regiDiff_startyearValue_data in $/t CO2eq
  loop((ext_regi)$p45_regiDiff_startyearValue_data(ext_regi),
      loop(regi$regi_groupExt(ext_regi,regi),
        p45_regiDiff_startyearValue(regi) = p45_regiDiff_startyearValue_data(ext_regi) * sm_DptCO2_2_TDpGtC; 
      );
  );
***   p45_regiDiff_initialRatio
  p45_regiDiff_initialRatio(regi) = sum(ttot$(ttot.val eq cm_startyear), p45_regiDiff_startyearValue(regi) / p45_taxCO2eq_anchor(ttot));
  display  p45_regiDiff_startYr, p45_regiDiff_initialRatio;
$endIf.taxCO2regiDiffStartyearValue2
$endIf.taxCO2regiDiff5



*** Step III.3: Create ratio between regional carbon price and global anchor trajectory based on previously defined convergence

$ifThen.taxCO2regiDiff7 "%cm_taxCO2_regiDiff%" == "none"
  p45_regiDiff_ratio(t,regi)  =  1;
$elseIf.taxCO2regiDiff7 "%cm_taxCO2_regiDiff%" == "gdpSpread"
***   Set s45_regiDiff_gdpThreshold (in 1e3 $ PPP 2017)
  s45_regiDiff_gdpThreshold = 50;
***   Compute ratio between GDP per capita (in 1e3 $ PPP 2017) and s45_regiDiff_gdpThreshold, and upper bound it by 1
  p45_regiDiff_ratio(t,regi) = min(p45_gdppcap_PPP(t,regi) / 50 , 1);
$else.taxCO2regiDiff7
***   Set convergence factor equal to p45_regiDiff_initialRatio before p45_regiDiff_startYr:
  p45_regiDiff_ratio(t,regi)$(t.val lt p45_regiDiff_startYr(regi)) = p45_regiDiff_initialRatio(regi);
***   Set  convergence factor equal to 1 from p45_regiDiff_endYr:
  p45_regiDiff_ratio(t,regi)$(t.val ge p45_regiDiff_endYr(regi)) = 1;
***   Create convergence between p45_regiDiff_startYr and p45_regiDiff_endYr:
  loop((t,regi)$((t.val ge p45_regiDiff_startYr(regi)) and (t.val lt p45_regiDiff_endYr(regi))),
    p45_regiDiff_ratio(t,regi) = p45_regiDiff_initialRatio(regi) 
                                + (1 - p45_regiDiff_initialRatio(regi)) * rPower( (t.val - p45_regiDiff_startYr(regi)) / (p45_regiDiff_endYr(regi) - p45_regiDiff_startYr(regi)), p45_regiDiff_exponent(regi));
  );
$endIf.taxCO2regiDiff7

display p45_regiDiff_ratio;

*** Step III.4: Create regionally differentiated carbon price trajectories based on global anchor trajectory and p45_regiDiff_ratio

p45_taxCO2eq_regiDiff(t,regi) = p45_regiDiff_ratio(t,regi) * p45_taxCO2eq_anchor(t);
display p45_taxCO2eq_regiDiff;

*** Step III.5: If regional carbon prices in cm_startyear where set manually via cm_taxCO2_regiDiff_startyearValue, ensure that convergence to global anchor trajectory does not lead to lower regional carbon prices in some timesteps (this could happen if regional carbon price in cm_startyear is much higher than global anchor price)

$ifThen.taxCO2regiDiffStartyearValue3 "%cm_taxCO2_regiDiff_startyearValue%" == "endogenous"
$else.taxCO2regiDiffStartyearValue3
  p45_taxCO2eq_regiDiff(t,regi) = max(p45_taxCO2eq_regiDiff(t,regi), p45_regiDiff_startyearValue(regi));
  display "Apply p45_regiDiff_startyearValue(regi) as lower bound for p45_taxCO2eq_regiDiff"
  display p45_taxCO2eq_regiDiff;
$endIf.taxCO2regiDiffStartyearValue3

***---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*'  Part IV (Interpolation from path_gdx_ref): To smoothen a potential jump of carbon prices in cm_startyear, an interpolation between (a) the carbon prices before cm_startyear provided by path_gdx_ref and (b) the carbon prices from cm_startyear onward defined by parts I-III can be chosen via cm_taxCO2_interpolation
*'                                     In addition, the carbon prices provided by path_gdx_ref are used as lower bound if switch cm_taxCO2_lowerBound_path_gdx_ref is on.
*'                                     (off): no interpolation, i.e. (b) is used from cm_startyear onward. This must be chosen if regional carbon prices are manually set via cm_taxCO2_regiDiff_startyearValue.
*'                                     (one_step): linear interpolation within 10 years between (a) and (b). For example, if cm_startyear = 2030, it uses (a) until 2025, the average of (a) and (b) in 2030, and (b) from 2035.
*'                                     (two_steps): linear interpolation within 15 years between (a) and (b). For example, if cm_startyear = 2030, it uses (a) until 2025, weighted averages of (a) and (b) in 2030 and 2035, and (b) from 2040.
***---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Step IV.1: Set parameters for interpolation
s45_interpolation_startYr = smax(ttot$( ttot.val lt cm_startyear ), ttot.val); !! Timestep before startyear

$ifThen.CO2taxInterpolation2 "%cm_taxCO2_interpolation%" == "off"
*** Interpolation in 5 years, i.e. no intermediate step 
  s45_interpolation_endYr = cm_startyear;
$elseIf.CO2taxInterpolation2 "%cm_taxCO2_interpolation%" == "one_step"
$ifThen.CO2taxInterpolation3 "%cm_taxCO2_regiDiff_startyearValue%" == "endogenous"
*** Interpolation in 10 years (one intermediate step if 5 year timesteps)
    s45_interpolation_endYr = smin(ttot$( ttot.val ge (cm_startyear + 5)), ttot.val); 
$else.CO2taxInterpolation3
    abort "Interpolation cannot be used if regional carbon prices in cm_startyear where set manually via cm_taxCO2_regiDiff_startyearValue. This would overwrite manually set values."
$endIf.CO2taxInterpolation3
$elseIf.CO2taxInterpolation2 "%cm_taxCO2_interpolation%" == "two_steps"
$ifThen.CO2taxInterpolation4 "%cm_taxCO2_regiDiff_startyearValue%" == "endogenous"
*** Interpolation in 15 years (two intermediate steps if 5 year timesteps)
    s45_interpolation_endYr = smin(ttot$( ttot.val ge cm_startyear + 10), ttot.val); 
$else.CO2taxInterpolation4
    abort "Interpolation cannot be used if regional carbon prices in cm_startyear where set manually via cm_taxCO2_regiDiff_startyearValue. This would overwrite manually set values."
$endIf.CO2taxInterpolation4
$endIf.CO2taxInterpolation2

display s45_interpolation_startYr, s45_interpolation_endYr;

*** Step IV.2: Create interpolation
pm_taxCO2eq(ttot,regi) = p45_taxCO2eq_path_gdx_ref(ttot,regi); !! Initialize pm_taxCO2eq with p45_taxCO2eq_path_gdx_ref. Then overwrite all time steps after cm_startyear
pm_taxCO2eq(t,regi)$(t.val le s45_interpolation_startYr) = p45_taxCO2eq_regiDiff(t,regi);
pm_taxCO2eq(t,regi)$((t.val gt s45_interpolation_startYr) and (t.val lt s45_interpolation_endYr)) =
    sum(ttot2$(ttot2.val eq s45_interpolation_startYr), p45_taxCO2eq_path_gdx_ref(ttot2,regi)) !! value of p45_taxCO2eq_path_gdx_ref in s45_interpolation_startYr
    * (s45_interpolation_endYr - t.val) / (s45_interpolation_endYr - s45_interpolation_startYr)
  + sum(t2$(t2.val eq s45_interpolation_endYr), p45_taxCO2eq_regiDiff(t2,regi)) !! value of p45_taxCO2eq_regiDiff in s45_interpolation_endYr
    * (t.val - s45_interpolation_startYr) / (s45_interpolation_endYr - s45_interpolation_startYr);
pm_taxCO2eq(t,regi)$(t.val ge s45_interpolation_endYr) = p45_taxCO2eq_regiDiff(t,regi);

display pm_taxCO2eq;

*** Step IV.3: Lower bound pm_taxCO2eq by p45_taxCO2eq_path_gdx_ref if switch cm_taxCO2_lowerBound_path_gdx_ref is on
$ifthen.lowerBound1 "%cm_taxCO2_lowerBound_path_gdx_ref%" == "on"
  pm_taxCO2eq(t,regi) = max(pm_taxCO2eq(t,regi), p45_taxCO2eq_path_gdx_ref(t,regi));
  display pm_taxCO2eq;
$endIf.lowerBound1


*** EOF ./modules/45_carbonprice/functionalForm/datainput.gms
