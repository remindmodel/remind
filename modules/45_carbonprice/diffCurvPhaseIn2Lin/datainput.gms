*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffCurvPhaseIn2Lin/datainput.gms
***------------------------------------------------------------------------------------------------------------------------
*** *BS* 20190930 linear convergence with starting points differentiated by GDP/capita, global price from 2040
***-----------------------------------------------------------------------------------------------------------------------


*** convergence to global CO2 price depends on GDP per capita (in 1e3 $ PPP 2005).
p45_gdppcap2015_PPP(regi) = pm_gdp("2015",regi)/pm_shPPPMER(regi) / pm_pop("2015",regi);
display p45_gdppcap2015_PPP;

p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) le 3) = 0.1;
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 3 and p45_gdppcap2015_PPP(regi) le 5) = 0.2;
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 5 and p45_gdppcap2015_PPP(regi) le 8) = 0.3;
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 8 and p45_gdppcap2015_PPP(regi) le 11) = 0.5;
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 11 and p45_gdppcap2015_PPP(regi) le 14) = 0.65;
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 14 and p45_gdppcap2015_PPP(regi) le 19) = 0.8;
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 19 and p45_gdppcap2015_PPP(regi) le 24) = 0.9;
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 24) = 1;
display p45_phasein_2025ratio;


*** for the current implementation, use the following trajectory for rich countries:
*** global price is linear from 2010 until the pkBudgYr, then increases with cm_taxCO2inc_after_peakBudgYr
if(cm_co2_tax_2020 lt 0,
  abort "please choose a valid cm_co2_tax_2020"
elseif cm_co2_tax_2020 ge 0,
*** convert tax value from $/t CO2eq to T$/GtC
  p45_CO2priceTrajDeveloped("2040")= 3 * cm_co2_tax_2020 * sm_DptCO2_2_TDpGtC;  !! shifted to 2040 to make sure that even in delay scenarios the fixpoint of the linear price path is inside the "t" range, otherwise the CO2 prices from reference run may be overwritten
*** The factor 3 comes from shifting the 2020 value 20 years into the future at linear increase of 10% of 2020 value per year.
);



p45_CO2priceTrajDeveloped(ttot)$((ttot.val gt 2005) AND (ttot.val ge cm_startyear)) = p45_CO2priceTrajDeveloped("2040")*( 1 + 0.1/3 * (ttot.val-2040)); !! no CO2 price in 2005 and only change CO2 prices after ; 
*** annual increase by (10/3)% of the 2040 value is the same as a 10% increase of the 2020 value is the same as a linear increase from 0 in 2010 to the 2020/2040 value


*** Then create regional phase-in:
loop(ttot$((ttot.val ge cm_startyear) AND (ttot.val le cm_CO2priceRegConvEndYr) ),
  p45_regCO2priceFactor(ttot,regi) = 
   min(1,
       max(0, 
	        p45_phasein_2025ratio(regi) + (1 - p45_phasein_2025ratio(regi)) 
			                               * ( ( (ttot.val - 2025) + (cm_CO2priceRegConvEndYr - 2025) * 0.1 ) 
                                               / ( (cm_CO2priceRegConvEndYr - 2025) * 1.1 ) 
											 ) ** 2
       )											 
   );
);
p45_regCO2priceFactor(ttot,regi)$(ttot.val ge cm_CO2priceRegConvEndYr) = 1;


*** transition to global price - starting point depends on GDP/cap
pm_taxCO2eq(t,regi) = p45_regCO2priceFactor(t,regi) * p45_CO2priceTrajDeveloped(t);


display p45_regCO2priceFactor, p45_CO2priceTrajDeveloped, pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/diffCurvPhaseIn2Lin/datainput.gms
