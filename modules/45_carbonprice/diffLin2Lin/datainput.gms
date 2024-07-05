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
*** linear carbon price curve of developed regions starts at 0 in 2020 
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
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 10  and p45_gdppcap2015_PPP(regi) le 15) = 0.5; !! CHA, REF, LAM
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 15  and p45_gdppcap2015_PPP(regi) le 20) = 0.7; !! MEA, NEU
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 20) = 1; !! EUR, JPN, USA, CAZ
);

if(cm_co2_tax_spread eq 20,
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) le 3.5) = 0.05; !! SSA
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 3.5 and p45_gdppcap2015_PPP(regi) le 5)  = 0.1; !! IND
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 5   and p45_gdppcap2015_PPP(regi) le 10) = 0.2; !! OAS
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 10  and p45_gdppcap2015_PPP(regi) le 15) = 0.4; !! CHA, REF, LAM
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 15  and p45_gdppcap2015_PPP(regi) le 20) = 0.6; !! MEA, NEU
p45_phasein_2025ratio(regi)$(p45_gdppcap2015_PPP(regi) gt 20) = 1; !! EUR, JPN, USA, CAZ
);
display p45_phasein_2025ratio;


*** for the current implementation, use the following trajectory for rich countries:
*** price increases linearly from 0 in 2020 (warning: quick fix for more near-term realism. To be changed to NPI fixing) until the pkBudgYr, then increases with c_taxCO2inc_after_peakBudgYr
if(cm_co2_tax_2020 lt 0,
  abort "please choose a valid cm_co2_tax_2020"
elseif cm_co2_tax_2020 ge 0,
*** convert tax value from $/t CO2eq to T$/GtC
  p45_CO2priceTrajDeveloped("2040")= 3 * cm_co2_tax_2020 * sm_DptCO2_2_TDpGtC;  !! shifted to 2040 to make sure that even in delay scenarios the fixpoint of the linear price path is inside the "t" range, otherwise the CO2 prices from reference run may be overwritten
*** The factor 3 is inherited from old fixing to 0 in 2010. Switch cm_co2_tax_2020 should be renamed or removed.
);



p45_CO2priceTrajDeveloped(t)$(t.val ge 2020) = p45_CO2priceTrajDeveloped("2040")*( 1 + (t.val-2040) / 20); !! no CO2 price until 2020 and only change CO2 prices after ; 
*** annual increase by 5% (=1/20) of the 2040 value corresponds to a linear increase from 0 in 2020 to the 2040 value


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
