*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffLin2Lin/postsolve.gms
***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** diff: regional prices are initially differentiated by GDP/capita and converge using quadratic phase-in until cm_CO2priceRegConvEndYr (default = 2050), globally uniform price thereafter,
***       level of regional carbon price differentiation (uniform, medium, strong) can be chosen via cm_co2_tax_spread
*** Lin:  carbon price of developed regions increases linearly starting at historical level given by cm_co2_tax_hist in year cm_year_co2_tax_hist
***       initial value in cm_startyear is given by cm_co2_tax_startyear (if iterative_target_adj != 0, this value will be adjusted to meet prescribed CO2 budget)
*** 2Lin: (with iterative_target_adj = 9):  after the peak year (initial value given by cm_peakBudgYr, will be adjusted by algorithm in core/postsolve.gms), 
***                                         carbon price of developed countries increases linearly with fixed annual increase given by cm_taxCO2inc_after_peakBudgYr (default = 0, i.e. constant)
***       (with iterative_target_adj = 5):  carbon price of developed countries keeps increasing linearly (with same slope) until end of century, i.e. no change after peak year 
***       (with iterative_target_adj = 0):  after year given by cm_peakBudgYr (default = 2050), carbon price of developed countries increases linearly with fixed annual increase given by cm_taxCO2inc_after_peakBudgYr (default = 0, i.e. constant),
***                                         for linearly increasing carbon price (with same slope) until end of century, set cm_peakBudgYr = 2110         
***--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** if CO2 price is iteratively adjusted (i.e. cm_iterative_target_adj != 0), 
if((cm_iterative_target_adj ne 0),
*** re-create the linear carbon price trajectory for developed countries to ensure that it 
*** starts at historical level given by cm_co2_tax_hist in year cm_year_co2_tax_hist, and
*** ends at the endogenously adjusted tax level in the peak year (with iterative_target_adj = 6|7|9) or in 2100 (otherwise)
if((cm_iterative_target_adj eq 6) or (cm_iterative_target_adj eq 7) or (cm_iterative_target_adj eq 9),
   loop(regi$(p45_gdppcap2015_PPP(regi) gt 20), !! This doesn't need to be a loop, but it will be correct for any cycle of the loop, so also for the last cycle.
      p45_CO2priceTrajDeveloped(t)$(t.val le cm_peakBudgYr) 
                                  = s45_co2_tax_hist
                                    + (sum(t2$(t2.val eq cm_peakBudgYr), pm_taxCO2eq(t2,regi)) - s45_co2_tax_hist) / (cm_peakBudgYr - s45_year_co2_tax_hist) !! Yearly increase of CO2 price that interpolates between s45_co2_tax_hist in s45_year_co2_tax_hist and pm_taxCO2eq in peak year
                                      * (t.val - s45_year_co2_tax_hist) ;
      p45_CO2priceTrajDeveloped(t)$(t.val gt cm_peakBudgYr) = pm_taxCO2eq(t,regi);
    );
  else
    loop(regi$(p45_gdppcap2015_PPP(regi) gt 20), !! This doesn't need to be a loop, but it will be correct for any cycle of the loop, so also for the last cycle.
      p45_CO2priceTrajDeveloped(t)$(t.val le 2100) 
                                  = s45_co2_tax_hist 
                                    + (pm_taxCO2eq("2100",regi) - s45_co2_tax_hist) / (2100 - s45_year_co2_tax_hist) !! Yearly increase of CO2 price that interpolates between s45_co2_tax_hist in s45_year_co2_tax_hist and pm_taxCO2eq in 2100
                                      * (t.val - s45_year_co2_tax_hist) ;
      p45_CO2priceTrajDeveloped(t)$(t.val gt 2100) = pm_taxCO2eq(t,regi);
    );
);

*** Re-create the regional CO2 price trajectories using 1) regional multiplicative CO2 price factors and 2) CO2 price trajectory for developped countries
pm_taxCO2eq(t,regi) = p45_regCO2priceFactor(t,regi) * p45_CO2priceTrajDeveloped(t);
display pm_taxCO2eq;
);
*** EOF ./modules/45_carbonprice/diffLin2Lin/postsolve.gms
