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
***                                    The (initial) carbon price in cm_startyear is chosen via cm_taxCO2_startyear. This value is endogenously adjusted to meet CO2 budget targets if cm_iterative_target_adj is set to 5, 7, or 9.
***                                    (linear):      The linear curve is determined by the two points (cm_taxCO2_historicalYr, cm_taxCO2_historical) and (cm_startyear, cm_taxCO2_startyear). 
***                                                   By default, cm_taxCO2_historicalYr is the last timestep before cm_startyear, and cm_taxCO2_historical is the carbon price in that timestep in the reference run (path_gdx_ref) - computed as the maximum of pm_taxCO2eq over all regions.
***                                    (exponential): The exponential curve is determined by exponential growth rate (cm_taxCO2_expGrowth).
***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Convert tax value in start year from $/t CO2eq to T$/GtC  
s45_taxCO2_startyear = cm_taxCO2_startyear * sm_DptCO2_2_TDpGtC;
*** Check that tax value in start year is strictly positive
if(s45_taxCO2_startyear le 0,
  abort "please initialize cm_taxCO2_startyear by setting it to a positive value"
);

$ifThen.taxCO2globalAnchor "%cm_taxCO2_functionalForm%" == "exponential"
*** price increases exponentially with growth rate cm_taxCO2_expGrowth from s45_taxCO2_startyear in startyear
p45_taxCO2eq_anchor(t) = s45_taxCO2_startyear * cm_taxCO2_expGrowth**(t.val - cm_startyear);
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
if((s45_taxCO2_historicalYr lt 2005) or (s45_taxCO2_historicalYr ge cm_startyear),
  abort "please choose cm_taxCO2_historicalYr to be at least 2005 and strictly smaller than cm_startyear"
);
display s45_taxCO2_historicalYr;

*** Set s45_taxCO2_historical based on the switch cm_taxCO2_historical
$ifthen.taxCO2historial "%cm_taxCO2_historical%" == "gdx_ref"
*** Check that s45_taxCO2_historicalYr is an element of ttot 
if(sum(ttot$(ttot.val eq s45_taxCO2_historicalYr),1)=0,
  abort "please choose cm_taxCO2_historicalYr to be last or an element of ttot"
);
*** Extract level of carbon price in s45_taxCO2_historicalYr (defined as maximum of pm_taxCO2eq over all regions)
s45_taxCO2_historical = smax( regi , sum ( ttot$(ttot.val eq s45_taxCO2_historicalYr) , p45_taxCO2eq_path_gdx_ref(ttot,regi) ) );
$else.taxCO2historial
*** Set s45_taxCO2_historical to be the value provided by the switch, converted from $/t CO2eq to T$/GtC 
s45_taxCO2_historical = %cm_taxCO2_historical% * sm_DptCO2_2_TDpGtC;
$endif.taxCO2historial
display s45_taxCO2_historical;
*** Make sure that initial carbon price trajectory is non-decreasing
if(s45_taxCO2_startyear lt s45_taxCO2_historical,
  display s45_taxCO2_startyear;
  abort "please make sure that cm_taxCO2_startyear is at least as large as the value provided by cm_taxCO2_historical"
);

*** Step I.2: Create linear global anchor trajectory through the points (s45_taxCO2_historicalYr, s45_taxCO2_historical) and (cm_startyear, s45_taxCO2_startyear)
p45_taxCO2eq_anchor(t) = s45_taxCO2_historical
                                + (s45_taxCO2_startyear - s45_taxCO2_historical) / (cm_startyear - s45_taxCO2_historicalYr) !! Yearly increase of carbon price 
                                  * (t.val - s45_taxCO2_historicalYr) ;
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
p45_taxCO2eq_anchor_until2150(t) = p45_taxCO2eq_anchor(t);

*** Adjust global anchor trajectory so that after cm_peakBudgYr, it increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr
if((cm_iterative_target_adj = 0) or (cm_iterative_target_adj = 9),
  p45_taxCO2eq_anchor(t)$(t.val gt cm_peakBudgYr) = sum(t2$(t2.val eq cm_peakBudgYr), p45_taxCO2eq_anchor_until2150(t2)) !! CO2 tax in peak budget year
                                                  + (t.val - cm_peakBudgYr) * cm_taxCO2_IncAfterPeakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
);

*** Always set carbon price constant after 2100 to prevent huge taxes after 2100 and the resulting convergence problems
p45_taxCO2eq_anchor(t)$(t.val gt 2100) = p45_taxCO2eq_anchor("2100");
display p45_taxCO2eq_anchor_until2150, p45_taxCO2eq_anchor;

***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part III (Regional differentiation): Regional carbon price differentiation relative to global anchor trajectory is chosen via cm_taxCO2_regiDiff.
***                                    (none): No regional differetiation, i.e. uniform carbon pricing
***                                    (initialSpread10): Maximal initial spread of carbon prices in 2030 between OECD regions and poorest region is equal to 10. Initial spread for each region determined based on GDP per capita (PPP) in 2015. Carbon prices converge using quadratic phase-in until cm_taxCO2_regiDiff_endYr (default = 2050).
***                                    (initialSpread20): Maximal initial spread of carbon prices in 2030 between OECD regions and poorest region is equal to 20. Initial spread for each region determined based on GDP per capita (PPP) in 2015. Carbon prices converge using quadratic phase-in until cm_taxCO2_regiDiff_endYr (default = 2050).
***                                    (gdpSpread): Regional differentiation based on GDP per capita (PPP) throughout the century. Uses current GDP per capita (PPP) of OECD countries - around 50'000 US$2017 - as threshold for application of full carbon price.                                 
***-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Compute GDP per capita (in 1e3 $ PPP 2017) 
p45_gdppcap_PPP(ttot,regi)$(ttot.val ge 2005) = pm_gdp(ttot,regi) / pm_shPPPMER(regi) / pm_pop(ttot,regi);
display p45_gdppcap_PPP;

*** Define p45_regiDiff_convFactor based on chosen differentiation scheme
$ifThen.taxCO2regiDiff3 "%cm_taxCO2_regiDiff%" == "none"
p45_regiDiff_convFactor(t,regi)  =  1;
$elseIf.taxCO2regiDiff3 "%cm_taxCO2_regiDiff%" == "gdpSpread"
*** Set s45_regiDiff_gdpThreshold (in 1e3 $ PPP 2017)
s45_regiDiff_gdpThreshold = 50;
*** Compute ratio between GDP per capita (in 1e3 $ PPP 2017) and s45_regiDiff_gdpThreshold, and upper bound it by 1
p45_regiDiff_convFactor(t,regi) = min(p45_gdppcap_PPP(t,regi) / 50 , 1);
$else.taxCO2regiDiff3
$ifThen.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "initialSpread10"
*** Define p45_regiDiff_initialRatio for maximal initial spread equal to 10
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) le 3.5) = 0.1; !! SSA
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 3.5 and p45_gdppcap_PPP("2015",regi) le 5)  = 0.2; !! IND
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 5   and p45_gdppcap_PPP("2015",regi) le 10) = 0.3; !! OAS
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 10  and p45_gdppcap_PPP("2015",regi) le 15) = 0.5; !! CHA, LAM, MEA
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 15  and p45_gdppcap_PPP("2015",regi) le 20) = 0.7; !! REF
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 20) = 1; !! EUR, JPN, USA, CAZ, NEU
$elseIf.taxCO2regiDiff4 "%cm_taxCO2_regiDiff%" == "initialSpread20"
*** Define p45_regiDiff_initialRatio for maximal initial spread equal to 20
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) le 3.5) = 0.05; !! SSA
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 3.5 and p45_gdppcap_PPP("2015",regi) le 5)  = 0.1; !! IND
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 5   and p45_gdppcap_PPP("2015",regi) le 10) = 0.2; !! OAS
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 10  and p45_gdppcap_PPP("2015",regi) le 15) = 0.4; !! CHA, LAM, MEA
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 15  and p45_gdppcap_PPP("2015",regi) le 20) = 0.6; !! REF
p45_regiDiff_initialRatio(regi)$(p45_gdppcap_PPP("2015",regi) gt 20) = 1; !! EUR, JPN, USA, CAZ, NEU
$endIf.taxCO2regiDiff4
*** Set s45_regiDiff_startYr
s45_regiDiff_startYr = 2030;
*** Set p45_regiDiff_endYr based on data provided by switch cm_taxCO2_regiDiff_endYr
loop((ext_regi)$p45_regiDiff_endYr_data(ext_regi),
  loop(regi$regi_groupExt(ext_regi,regi),
    p45_regiDiff_endYr(regi) = p45_regiDiff_endYr_data(ext_regi);
  );
);
*** Set convergence factor equal to p45_regiDiff_initialRatio before s45_regiDiff_startYr:
p45_regiDiff_convFactor(t,regi)$(t.val lt s45_regiDiff_startYr) = p45_regiDiff_initialRatio(regi);
*** Set  convergence factor equal to 1 from p45_regiDiff_endYr:
p45_regiDiff_convFactor(t,regi)$(t.val ge p45_regiDiff_endYr(regi)) = 1;
*** Create quadratic convergence between s45_regiDiff_startYr and p45_regiDiff_endYr:
loop((t,regi)$((t.val ge s45_regiDiff_startYr) and (t.val lt p45_regiDiff_endYr(regi))),
  p45_regiDiff_convFactor(t,regi) = 
   min(1,
       max(0, 
	        p45_regiDiff_initialRatio(regi) + (1 - p45_regiDiff_initialRatio(regi)) * Power( (t.val - s45_regiDiff_startYr) / (p45_regiDiff_endYr(regi) - s45_regiDiff_startYr), 2) 
       )				 
   );
);
display  p45_regiDiff_initialRatio, p45_regiDiff_endYr;
$endIf.taxCO2regiDiff3

***Create regionally differentiated carbon price trajectories based on global anchor trajectory and p45_regiDiff_convFactor
p45_taxCO2eq_regiDiff(t,regi) = p45_regiDiff_convFactor(t,regi) * p45_taxCO2eq_anchor(t);
display p45_regiDiff_convFactor, p45_taxCO2eq_regiDiff;

***---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Part IV (Interpolation from path_gdx_ref): To smoothen a potential jump of carbon prices in cm_startyear, an interpolation between (a) the carbon prices before cm_startyear provided by path_gdx_ref and (b) the carbon prices from cm_startyear onward defined by parts I-III can be chosen via cm_taxCO2_interpolation.
***                                    In addition, the carbon prices provided by path_gdx_ref are used as lower bound if switch cm_taxCO2_lowerBound_path_gdx_ref is on.
***                                    (off): no interpolation, i.e. (b) is used from cm_startyear onward
***                                    (one_step): linear interpolation within 10 years between (a) and (b). For example, if cm_startyear = 2030, it uses (a) until 2025, the average of (a) and (b) in 2030, and (b) from 2035.
***                                    (two_steps): linear interpolation within 15 years between (a) and (b). For example, if cm_startyear = 2030, it uses (a) until 2025, weighted averages of (a) and (b) in 2030 and 2035, and (b) from 2040.
***                                    For manual settings, see description of the switch 
***---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Step IV.1: Set parameters for interpolation
*** Set linear interpolation as default
p45_interpolation_exponent(regi) = 1;
*** Set last timestep before cm_startyear as default for interpolation start
p45_interpolation_startYr(regi) = smax(ttot$( ttot.val lt cm_startyear ), ttot.val); 

$ifThen.CO2taxInterpolation2 "%cm_taxCO2_interpolation%" == "off"
*** No interpolation
p45_interpolation_endYr(regi) = p45_interpolation_startYr(regi); 
$elseIf.CO2taxInterpolation2 "%cm_taxCO2_interpolation%" == "one_step"
*** Interpolation in 10 years, i.e. one intermediate step 
p45_interpolation_endYr(regi) = smin(ttot$( ttot.val ge cm_startyear + 5), ttot.val); 
$elseIf.CO2taxInterpolation2 "%cm_taxCO2_interpolation%" == "two_steps"
*** Interpolation in 15 years, i.e. two intermediate steps
p45_interpolation_endYr(regi) = smin(ttot$( ttot.val ge cm_startyear + 10), ttot.val); 
$else.CO2taxInterpolation2 
*** Overwrite with p45_interpolation_exponent, p45_interpolation_startYr, and p45_interpolation_endYr according to manual settings
loop((ext_regi,ttot,ttot2)$p45_interpolation_data(ext_regi,ttot,ttot2),
  loop(regi$regi_groupExt(ext_regi,regi),
    p45_interpolation_exponent(regi) = p45_interpolation_data(ext_regi,ttot,ttot2);
    p45_interpolation_startYr(regi) = ttot.val;
    p45_interpolation_endYr(regi) = ttot2.val;
  );
);
$endIf.CO2taxInterpolation2

$ifThen.taxCO2startYearValue2 "%cm_taxCO2_startYearValue%" == "off"
$else.taxCO2startYearValue2
*** Set manually chosen regional carbon price in cm_startyear
loop((ext_regi)$p45_taxCO2eq_startYearValue_data(ext_regi),
  loop(regi$regi_groupExt(ext_regi,regi),
    p45_taxCO2eq_startYearValue(regi) = p45_taxCO2eq_startYearValue_data(ext_regi) * sm_DptCO2_2_TDpGtC; !! Converted from $/t CO2eq to T$/GtC  
  );
);
display p45_taxCO2eq_startYearValue;
*** Set interpolation start to cm_startyear
p45_interpolation_startYr(regi) = cm_startyear;
$endIf.taxCO2startYearValue2
display p45_interpolation_exponent, p45_interpolation_startYr, p45_interpolation_endYr;

*** Step IV.2: Create interpolation
$ifThen.taxCO2startYearValue3 "%cm_taxCO2_startYearValue%" == "off"
loop(regi,
  pm_taxCO2eq(ttot,regi) = p45_taxCO2eq_path_gdx_ref(ttot,regi); !! Initialize pm_taxCO2eq with p45_taxCO2eq_path_gdx_ref. Then overwrite all time steps after cm_startyear and p45_interpolation_startYr(regi) 
  pm_taxCO2eq(t,regi)$((t.val ge p45_interpolation_startYr(regi)) and (t.val lt p45_interpolation_endYr(regi))) = 
      sum(ttot2$(ttot2.val eq p45_interpolation_startYr(regi)), p45_taxCO2eq_path_gdx_ref(ttot2,regi)) !! value of p45_taxCO2eq_path_gdx_ref in p45_interpolation_startYr
      * (1 - rPower( (t.val - p45_interpolation_startYr(regi)) / (p45_interpolation_endYr(regi) - p45_interpolation_startYr(regi)), p45_interpolation_exponent(regi)))
    + sum(t2$(t2.val eq p45_interpolation_endYr(regi)), p45_taxCO2eq_regiDiff(t2,regi)) !! value of p45_taxCO2eq_regiDiff in p45_interpolation_endYr
      * rPower( (t.val - p45_interpolation_startYr(regi)) / (p45_interpolation_endYr(regi) - p45_interpolation_startYr(regi)), p45_interpolation_exponent(regi));
  pm_taxCO2eq(t,regi)$(t.val ge p45_interpolation_endYr(regi)) = p45_taxCO2eq_regiDiff(t,regi);
);
$else.taxCO2startYearValue3
loop(regi,
  pm_taxCO2eq(ttot,regi) = p45_taxCO2eq_path_gdx_ref(ttot,regi); !! Initialize pm_taxCO2eq with p45_taxCO2eq_path_gdx_ref. Then overwrite all time steps after cm_startyear
  pm_taxCO2eq(t,regi)$(t.val lt p45_interpolation_endYr(regi)) = 
      p45_taxCO2eq_startYearValue(regi)
      * (1 - rPower( (t.val - cm_startyear) / (p45_interpolation_endYr(regi) - cm_startyear), p45_interpolation_exponent(regi)))
    + sum(t2$(t2.val eq p45_interpolation_endYr(regi)), p45_taxCO2eq_regiDiff(t2,regi)) !! value of p45_taxCO2eq_regiDiff in p45_interpolation_endYr
      * rPower( (t.val - cm_startyear) / (p45_interpolation_endYr(regi) - cm_startyear), p45_interpolation_exponent(regi));
  pm_taxCO2eq(t,regi)$(t.val ge p45_interpolation_endYr(regi)) = p45_taxCO2eq_regiDiff(t,regi);
);
$endIf.taxCO2startYearValue3
display pm_taxCO2eq;

*** Step IV.3: Lower bound pm_taxCO2eq by p45_taxCO2eq_path_gdx_ref if switch cm_taxCO2_lowerBound_path_gdx_ref is on
$ifthen.lowerBound "%cm_taxCO2_lowerBound_path_gdx_ref%" == "on"
  pm_taxCO2eq(t,regi) = max(pm_taxCO2eq(t,regi), p45_taxCO2eq_path_gdx_ref(t,regi));
$endIf.lowerBound
display pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/functionalForm/datainput.gms
