*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffPhaseIn2Lin/datainput.gms
***------------------------------------------------------------------------------------------------------------------------
*** *BS* 20190930 linear convergence with starting points differentiated by GDP/capita, global price from 2040
***-----------------------------------------------------------------------------------------------------------------------

*** can make this flexible later
s45_stagestart = 2020;
s45_stageend = 2040;
*** price from stageend onwards (value set here is for first iteration only, will be adjusted afterwards)
s45_constantCO2price = 500 * sm_DptCO2_2_TDpGtC;

*** convergence to global CO2 price depends on GDP per capita (in 1e3 $ PPP 2005).
p45_gdppcap2015_PPP(regi) = pm_gdp("2015",regi)/pm_shPPPMER(regi) / pm_pop("2015",regi);
display p45_gdppcap2015_PPP;
*** suggestion by Robert: differentiate "zero-crossing" of linear convergence path
*** earlier zero-crossing --> higher starting price during convergence period
*** for now GDP/cap differentiation hardcoded
*** BS: modified limits to have SSA in first category
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) le 3) = 2024;
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) gt 3 and p45_gdppcap2015_PPP(regi) le 5) = 2023;
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) gt 5 and p45_gdppcap2015_PPP(regi) le 8) = 2022;
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) gt 8 and p45_gdppcap2015_PPP(regi) le 11) = 2021;
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) gt 11 and p45_gdppcap2015_PPP(regi) le 14) = 2020;
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) gt 14 and p45_gdppcap2015_PPP(regi) le 19) = 2018;
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) gt 19 and p45_gdppcap2015_PPP(regi) le 24) = 2016;
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) gt 24 and p45_gdppcap2015_PPP(regi) le 30) = 2013;
p45_phasein_zeroyear(regi)$(p45_gdppcap2015_PPP(regi) gt 30) = 2010;
display p45_phasein_zeroyear;

*** get CO2 price before transition stage from reference (NDC) run
***Execute_Loadpoint 'input_ref' p45_tauCO2_ref = pm_taxCO2eq;
***pm_taxCO2eq(ttot,regi)$(ttot.val le s45_stagestart) = p45_tauCO2_ref(ttot,regi);
***display p45_tauCO2_ref;

*** global price is linear from 2010
if(cm_co2_tax_2020 lt 0,
  abort "please choose a valid cm_co2_tax_2020"
elseif cm_co2_tax_2020 ge 0,
*** convert tax value from $/t CO2eq to T$/GtC
  pm_taxCO2eq("2040",regi)= 3 * cm_co2_tax_2020 * sm_DptCO2_2_TDpGtC;  !! shifted to 2040 to make sure that even in delay scenarios the fixpoint of the linear price path is inside the "t" range, otherwise the CO2 prices from reference run may be overwritten
*** The factor 3 comes from shifting the 2020 value 20 years into the future at linear increase of 10% of 2020 value per year.
);

pm_taxCO2eq(ttot,regi)$((ttot.val gt 2005) AND (ttot.val ge cm_startyear)) = pm_taxCO2eq("2040",regi)*( 1 + 0.1/3 * (ttot.val-2040)); !! no CO2 price in 2005 and only change CO2 prices after ; 
*** annual increase by (10/3)% of the 2040 value is the same as a 10% increase of the 2020 value is the same as a linear increase from 0 in 2010 to the 2020/2040 value

pm_taxCO2eq(ttot,regi)$(ttot.val gt 2110) = pm_taxCO2eq("2110",regi); !! to prevent huge taxes after 2110 and the resulting convergence problems, set taxes after 2110 equal to 2110 value
display pm_taxCO2eq;

*** s45_yearly_taxCO2Increase = (s45_stageend - p45_phasein_zeroyear(regi)
*** linear transition to global price - starting point depends on GDP/cap
loop(regi,
  loop(t$(t.val eq s45_stageend),
    s45_convergenceCO2price = pm_taxCO2eq(t,regi);
  );
);

pm_taxCO2eq(ttot,regi)$( (ttot.val ge cm_startyear) AND (ttot.val lt s45_stageend))
    = max(0, s45_convergenceCO2price * (ttot.val - p45_phasein_zeroyear(regi))/(s45_stageend - p45_phasein_zeroyear(regi)) );



display s45_convergenceCO2price, pm_taxCO2eq;

*** EOF ./modules/45_carbonprice/diffPhaseIn2Lin/datainput.gms
