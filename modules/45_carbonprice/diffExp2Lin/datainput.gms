*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffExp2Lin/datainput.gms
***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** diff: regional prices are initially differentiated by GDP/capita and converge using quadratic phase-in until cm_CO2priceRegConvEndYr (default = 2050), globally uniform price thereafter,
***       level of regional carbon price differentiation (uniform, medium, strong) can be chosen via cm_co2_tax_spread
*** Exp:  carbon price of developed regions increases exponentially with rate given by cm_co2_tax_growth (default = 4.5 percent),
***       initial value in cm_startyear is given by cm_co2_tax_startyear (if iterative_target_adj != 0, this value will be adjusted to meet prescribed CO2 budget)
*** 2Lin: (with iterative_target_adj = 9):  after the peak year (initial value given by cm_peakBudgYr, will be adjusted by algorithm in core/postsolve.gms), 
***                                         carbon price of developed countries increases linearly with fixed annual increase given by cm_taxCO2inc_after_peakBudgYr (default = 0, i.e. constant)
***       (with iterative_target_adj = 5):  carbon price of developed countries keeps increasing exponentially until end of century, i.e. no change after peak year 
***       (with iterative_target_adj = 0):  after year given by cm_peakBudgYr (default = 2050), carbon price of developed countries increases linearly with fixed annual increase given by cm_taxCO2inc_after_peakBudgYr (default = 0, i.e. constant),
***                                         for exponentially increasing carbon price until end of century, set cm_peakBudgYr = 2110         
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

*** Step 2: Create CO2 price trajectory for developed countries

if(cm_co2_tax_startyear gt 0,
*** convert tax value in start year from $/t CO2eq to T$/GtC  
  s45_co2_tax_startyear = cm_co2_tax_startyear * sm_DptCO2_2_TDpGtC;
else
  abort "please initialize cm_co2_tax_startyear by setting it to a positive value"
);

*** price increases exponentially with growth rate cm_co2_tax_growth from s45_co2_tax_startyear in startyear
p45_CO2priceTrajDeveloped(t) = s45_co2_tax_startyear * cm_co2_tax_growth**(t.val-cm_startyear);
*** for peak budget runs (if cm_iterative_target_adj = 6|7|9), the adjustment of the CO2 price trajectory after the peak year is made in core/postsolve.gms
*** for runs without iterative carbon price adjustment (if cm_iterative_target_adj = 0), price increases linearly after year given by cm_peakBudgYr (for exponentially increasing carbon price until end of century, set cm_peakBudgYr = 2110)
if((cm_iterative_target_adj eq 0),
  p45_CO2priceTrajDeveloped(t)$(t.val gt cm_peakBudgYr) 
                                  = sum(t2$(t2.val eq cm_peakBudgYr), p45_CO2priceTrajDeveloped(t2))
                                    +  (t.val - cm_peakBudgYr) * cm_taxCO2inc_after_peakBudgYr * sm_DptCO2_2_TDpGtC;  !! increase by cm_taxCO2inc_after_peakBudgYr per year 
);
*** set taxes constant after 2110 to prevent huge taxes after 2110 and the resulting convergence problems,
p45_CO2priceTrajDeveloped(t)$(t.val gt 2110) = p45_CO2priceTrajDeveloped("2110");
display p45_CO2priceTrajDeveloped;

*** Step 3: Create regional CO2 price trajectories using 1) regional multiplicative CO2 price factors and 2) CO2 price trajectory for developed countries
pm_taxCO2eq(t,regi) = p45_regCO2priceFactor(t,regi) * p45_CO2priceTrajDeveloped(t);
display pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/diffExp2Lin/datainput.gms
