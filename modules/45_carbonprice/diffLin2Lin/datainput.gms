*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffLin2Lin/datainput.gms
***----------------------------------------------------------------------------------------------------------------------------------------------------
*** regional prices are initially differentiated by GDP/capita and converge using quadratic phase-in, 
*** global price from cm_CO2priceRegConvEndYr (default = 2050)
*** carbon price of developed regions increases linearly until peak year (with iterative_target_adj = 9) or until 2100 (with iterative_target_adj = 5)
*** linear carbon price curve of developed regions starts at 25$/t CO2eq in 2020 (corresponding to historical CO2 price for EUR, which is the highest among regions)
***----------------------------------------------------------------------------------------------------------------------------------------------------


*** convergence to global CO2 price depends on GDP per capita (in 1e3 $ PPP 2005).
*** benchmark year kept at 2015 since 2020 not suitable. 
p45_gdppcap2015_PPP(regi) = pm_gdp("2015",regi)/pm_shPPPMER(regi) / pm_pop("2015",regi);
display p45_gdppcap2015_PPP;

*** Selection of differentiation scheme via cm_co2_tax_spread
if(cm_co2_tax_spread eq 1,
p45_phasein_2025ratio(regi) = 1; !! all regions
);

if(cm_co2_tax_spread eq 10,
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) le 3.5) = 0.1; !! SSA
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 3.5 and p45_gdppcap2015_PPP(regi) le 5)  = 0.2; !! IND
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 5   and p45_gdppcap2015_PPP(regi) le 10) = 0.3; !! OAS
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 10  and p45_gdppcap2015_PPP(regi) le 15) = 0.5; !! CHA, LAM, MEA
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 15  and p45_gdppcap2015_PPP(regi) le 20) = 0.7; !! REF
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 20) = 1; !! EUR, JPN, USA, CAZ, NEU
);

if(cm_co2_tax_spread eq 20,
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) le 3.5) = 0.05; !! SSA
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 3.5 and p45_gdppcap2015_PPP(regi) le 5)  = 0.1; !! IND
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 5   and p45_gdppcap2015_PPP(regi) le 10) = 0.2; !! OAS
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 10  and p45_gdppcap2015_PPP(regi) le 15) = 0.4; !! CHA, LAM, MEA
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 15  and p45_gdppcap2015_PPP(regi) le 20) = 0.6; !! REF
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 20) = 1; !! EUR, JPN, USA, CAZ, NEU
);
display p45_phasein_2025ratio;


*** for the current implementation, use the following trajectory for rich countries:
*** price increases linearly from 25$/t CO2eq in 2020 until peak budget year (if cm_iterative_target_adj = 6|7|9) or until end of century (otherwise), 
*** then increases with c_taxCO2inc_after_peakBudgYr
if(cm_co2_tax_startyear le 25,
  abort "please choose a valid cm_co2_tax_startyear of more than 25$/t CO2eq"
else
*** convert tax value from $/t CO2eq to T$/GtC
  s45_co2_tax_2020      = 25 * sm_DptCO2_2_TDpGtC;
  s45_co2_tax_startyear = cm_co2_tax_startyear * sm_DptCO2_2_TDpGtC;
);
*** define linear curve through the points (2020, s45_co2_tax_2020) and (cm_startyear, s45_co2_tax_startyear)
p45_CO2priceTrajDeveloped(t) = s45_co2_tax_2020
                                + (s45_co2_tax_startyear - s45_co2_tax_2020) / (cm_startyear - 2020) !! Yearly increase of CO2 price 
                                  * (t.val - 2020) ;
p45_CO2priceTrajDeveloped(t)$(t.val gt 2110) = p45_CO2priceTrajDeveloped("2110"); !! set taxes constant after 2110
*** for peak budget runs (if cm_iterative_target_adj = 6|7|9), the adjustment of the CO2 price trajectory after the peak year is made in core/postsolve.gms


*** Then create regional phase-in:
*** Set regional CO2 price factor equal to p45_phasein_2025ratio until 2025:
p45_regCO2priceFactor(t,regi)$(t.val le 2025) = p45_phasein_2025ratio(regi);
*** Then define quadratic phase-in until cm_CO2priceRegConvEndYr:
loop(t$((t.val gt 2025) and (t.val le cm_CO2priceRegConvEndYr)),
  p45_regCO2priceFactor(t,regi) = 
   min(1,
       max(0, 
	        p45_phasein_2025ratio(regi) + (1 - p45_phasein_2025ratio(regi)) * Power( (t.val - 2025) / (cm_CO2priceRegConvEndYr - 2025), 2) 
       )				 
   );
);
p45_regCO2priceFactor(t,regi)$(t.val ge cm_CO2priceRegConvEndYr) = 1;


*** transition to global price - starting point depends on GDP/cap
pm_taxCO2eq(t,regi) = p45_regCO2priceFactor(t,regi) * p45_CO2priceTrajDeveloped(t);


display p45_regCO2priceFactor, p45_CO2priceTrajDeveloped, pm_taxCO2eq;
*** EOF ./modules/45_carbonprice/diffLin2Lin/datainput.gms
