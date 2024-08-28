*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffLin2Lin/datainput.gms
***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** diff: regional prices are initially differentiated by GDP/capita and converge using quadratic phase-in until cm_CO2priceRegConvEndYr (default = 2050), globally uniform price thereafter,
***       level of regional carbon price differentiation (uniform, medium, strong) can be chosen via cm_co2_tax_spread
*** Lin:  carbon price of developed regions increases linearly starting at historical level given by cm_co2_tax_hist in year cm_year_co2_tax_hist
***       initial value in cm_startyear is given by cm_co2_tax_startyear (if iterative_target_adj != 0, this value will be adjusted to meet prescribed CO2 budget)
*** 2Lin: (with iterative_target_adj = 9):  after the peak year (initial value given by cm_peakBudgYr, will be adjusted by algorithm in core/postsolve.gms), 
***                                         carbon price of developed countries increases linearly with fixed annual increase given by cm_taxCO2inc_after_peakBudgYr (default = 0, i.e. constant)
***       (with iterative_target_adj = 5):  carbon price of developed countries keeps increasing linearly (with same slope) until end of century, i.e. no change after peak year 
***       (with iterative_target_adj = 0):  after year given by cm_peakBudgYr (default = 2050), carbon price of developed countries increases linearly with fixed annual increase given by cm_taxCO2inc_after_peakBudgYr (default = 0, i.e. constant),
***                                         for linearly increasing carbon price (with same slope) until end of century, set cm_peakBudgYr = 2100         
***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** Step 1: Define regional multiplicative factors between regional CO2 price and CO2 price of the developed countries
*** Warning regarding code changes: This first step also appears in diffLin2Lin and should be changed simultaneously.

*** Step 1.1: Define initial regional multiplicative CO2 price factors

*** based on GDP per capita (in 1e3 $ PPP 2005) in 2015 (benchmark year kept at 2015 since 2020 not suitable) 
p45_gdppcap2015_PPP(regi) = pm_gdp("2015",regi)/pm_shPPPMER(regi) / pm_pop("2015",regi);

*** Selection of differentiation scheme via cm_co2_tax_spread
if(cm_co2_tax_spread eq 1,
p45_phasein_ratio(regi) = 1; !! all regions
);

if(cm_co2_tax_spread eq 10,
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) le 3.5) = 0.1; !! SSA
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 3.5 and p45_gdppcap2015_PPP(regi) le 5)  = 0.2; !! IND
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 5   and p45_gdppcap2015_PPP(regi) le 10) = 0.3; !! OAS
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 10  and p45_gdppcap2015_PPP(regi) le 15) = 0.5; !! CHA, LAM, MEA
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 15  and p45_gdppcap2015_PPP(regi) le 20) = 0.7; !! REF
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 20) = 1; !! EUR, JPN, USA, CAZ, NEU
);

if(cm_co2_tax_spread eq 20,
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) le 3.5) = 0.05; !! SSA
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 3.5 and p45_gdppcap2015_PPP(regi) le 5)  = 0.1; !! IND
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 5   and p45_gdppcap2015_PPP(regi) le 10) = 0.2; !! OAS
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 10  and p45_gdppcap2015_PPP(regi) le 15) = 0.4; !! CHA, LAM, MEA
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 15  and p45_gdppcap2015_PPP(regi) le 20) = 0.6; !! REF
p45_phasein_ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 20) = 1; !! EUR, JPN, USA, CAZ, NEU
);

*** Step 1.2: Create regional multiplicative CO2 price factors for quadratic convergence between s45_CO2priceRegConvStartYr and cm_CO2priceRegConvEndYr

*** Set year until which initial ratios of CO2 prices are applied and after which convergence starts to 2030
s45_CO2priceRegConvStartYr = 2030;
*** Set regional CO2 price factor equal to p45_phasein_ratio until s45_CO2priceRegConvStartYr:
p45_regCO2priceFactor(t,regi)$(t.val le s45_CO2priceRegConvStartYr) = p45_phasein_ratio(regi);
*** Create quadratic phase-in between s45_CO2priceRegConvStartYr and cm_CO2priceRegConvEndYr:
loop(t$((t.val gt s45_CO2priceRegConvStartYr) and (t.val le cm_CO2priceRegConvEndYr)),
  p45_regCO2priceFactor(t,regi) = 
   min(1,
       max(0, 
	        p45_phasein_ratio(regi) + (1 - p45_phasein_ratio(regi)) * Power( (t.val - s45_CO2priceRegConvStartYr) / (cm_CO2priceRegConvEndYr - s45_CO2priceRegConvStartYr), 2) 
       )				 
   );
);
*** Set regional CO2 price factor equal to 1 after cm_CO2priceRegConvEndYr:
p45_regCO2priceFactor(t,regi)$(t.val gt cm_CO2priceRegConvEndYr) = 1;

display p45_gdppcap2015_PPP, p45_phasein_ratio, p45_regCO2priceFactor;


*** Step 2: Define CO2 price trajectory for developed countries

*** Step 2.1: Determine starting point for linear CO2 price trajectory: (s45_year_co2_tax_hist,s45_co2_tax_hist) 
*** Set s45_year_co2_tax_hist based on the switch cm_year_co2_tax_hist
$ifthen "%cm_year_co2_tax_hist%" == "last"
*** Choose s45_year_co2_tax_hist to be the last time period before start year 
s45_year_co2_tax_hist = smax(ttot$( ttot.val lt cm_startyear ), ttot.val);
$else
*** Set s45_year_co2_tax_hist to be the value provided by the switch
s45_year_co2_tax_hist = %cm_year_co2_tax_hist%;
$endif
*** Check validity of s45_year_co2_tax_hist 
if((s45_year_co2_tax_hist lt 2005) or (s45_year_co2_tax_hist ge cm_startyear),
  abort "please choose cm_year_co2_tax_hist to be at least 2005 and strictly smaller than cm_startyear"
);
display s45_year_co2_tax_hist;

*** Set s45_co2_tax_hist based on the switch cm_co2_tax_hist
$ifthen "%cm_co2_tax_hist%" == "gdx_ref"
*** Check that s45_year_co2_tax_hist is an element of ttot 
if(sum(ttot$(ttot.val eq s45_year_co2_tax_hist),1)=0,
  abort "please choose cm_year_co2_tax_hist to be last or an element of ttot"
);
*** Read pm_taxCO2eq from path_gdx_ref
Execute_Loadpoint 'input_ref' p45_tau_CO2_tax_gdx_ref = pm_taxCO2eq;
*** Extract level of co2 tax in cm_year_co2_tax_hist (defined as maximum of pm_taxCO2eq over all regions)
s45_co2_tax_hist = smax( regi , sum ( ttot$(ttot.val eq s45_year_co2_tax_hist) , p45_tau_CO2_tax_gdx_ref(ttot,regi) ) );
$else
*** Set s45_co2_tax_hist to be the value provided by the switch, converted from $/t CO2eq to T$/GtC 
s45_co2_tax_hist = %cm_co2_tax_hist% * sm_DptCO2_2_TDpGtC;
$endif
display s45_co2_tax_hist;

*** Step 2.2: Create CO2 price trajectory for developed countries

if(cm_co2_tax_startyear gt 0,
*** convert tax value in start year from $/t CO2eq to T$/GtC  
  s45_co2_tax_startyear = cm_co2_tax_startyear * sm_DptCO2_2_TDpGtC;
else
  abort "please initialize cm_co2_tax_startyear by setting it to a positive value"
);
*** make sure that the initial CO2 price trajectory is increasing
if(s45_co2_tax_startyear le s45_co2_tax_hist,
  abort "please choose a value for cm_co2_tax_startyear that is larger than the value provided by cm_co2_tax_hist"
);
display s45_co2_tax_startyear;

*** price increases linearly from s45_co2_tax_hist in s45_year_co2_tax_hist until peak budget year (if cm_iterative_target_adj = 6|7|9) or until end of century (otherwise)
*** define linear curve through the points (s45_year_co2_tax_hist, s45_co2_tax_hist) and (cm_startyear, s45_co2_tax_startyear)
p45_CO2priceTrajDeveloped(t) = s45_co2_tax_hist
                                + (s45_co2_tax_startyear - s45_co2_tax_hist) / (cm_startyear - s45_year_co2_tax_hist) !! Yearly increase of CO2 price 
                                  * (t.val - s45_year_co2_tax_hist) ;
*** for peak budget runs (if cm_iterative_target_adj = 6|7|9), the adjustment of the CO2 price trajectory after the peak year is made in core/postsolve.gms
*** for runs without iterative carbon price adjustment (if cm_iterative_target_adj = 0), price increases linearly with fixed annual increase given by cm_taxCO2inc_after_peakBudgYr after year given by cm_peakBudgYr (for linearly increasing carbon price (with same slope) until end of century, set cm_peakBudgYr = 2100)
if((cm_iterative_target_adj eq 0),
  p45_CO2priceTrajDeveloped(t)$(t.val gt cm_peakBudgYr) 
                                  = sum(t2$(t2.val eq cm_peakBudgYr), p45_CO2priceTrajDeveloped(t2))
                                    +  (t.val - cm_peakBudgYr) * cm_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
);
*** set taxes after 2100 equal to 2100 value
p45_CO2priceTrajDeveloped(t)$(t.val gt 2100) = p45_CO2priceTrajDeveloped("2100");
display p45_CO2priceTrajDeveloped;

*** Step 3: Create regional CO2 price trajectories using 1) regional multiplicative CO2 price factors and 2) CO2 price trajectory for developed countries
pm_taxCO2eq(t,regi) = p45_regCO2priceFactor(t,regi) * p45_CO2priceTrajDeveloped(t);
display pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/diffLin2Lin/datainput.gms
