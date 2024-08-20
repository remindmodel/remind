*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffLin2Lin/postsolve.gms
***----------------------------------------------------------------------------------------------------------------------------------------------------
*** regional prices are initially differentiated by GDP/capita and converge using quadratic phase-in, 
*** global price from cm_CO2priceRegConvEndYr (default = 2050)
*** carbon price of developed regions increases linearly until peak year (with iterative_target_adj = 9) or until 2100 (with iterative_target_adj = 5)
*** linear carbon price curve of developed regions starts at 25$/t CO2eq in 2020 (corresponding to historical CO2 price for EUR, which is the highest among regions)
***----------------------------------------------------------------------------------------------------------------------------------------------------

*** Re-create the linear carbon price trajectory for rich countries to ensure that it 
*** starts at 25$/t CO2eq in 2020, and
*** ends at the endogenously adjusted tax level in the peak year (with iterative_target_adj = 6|7|9) or in 2110 (otherwise; choice of 2110 since this is the year from which the trajectory is set to be constant - see datainput.gms file of this realization)
if((cm_iterative_target_adj eq 6) or (cm_iterative_target_adj eq 7) or (cm_iterative_target_adj eq 9),
   loop(regi$(p45_gdppcap2015_PPP(regi) gt 20), !! This doesn't need to be a loop, but it will be correct for any cycle of the loop, so also for the last cycle.
      p45_CO2priceTrajDeveloped(t)$(t.val le cm_peakBudgYr) 
                                  = s45_co2_tax_2020
                                    + (sum(t2$(t2.val eq cm_peakBudgYr), pm_taxCO2eq(t2,regi)) - s45_co2_tax_2020) / (cm_peakBudgYr - 2020) !! Yearly increase of CO2 price that interpolates between s45_co2_tax_2020 in 2020 and pm_taxCO2eq in peak year
                                      * (t.val - 2020) ;
      p45_CO2priceTrajDeveloped(t)$(t.val gt cm_peakBudgYr) = pm_taxCO2eq(t,regi);
    );
  else
    loop(regi$(p45_gdppcap2015_PPP(regi) gt 20), !! This doesn't need to be a loop, but it will be correct for any cycle of the loop, so also for the last cycle.
      p45_CO2priceTrajDeveloped(t)$(t.val le 2110) 
                                  = s45_co2_tax_2020 
                                    + (pm_taxCO2eq("2110",regi) - s45_co2_tax_2020) / (2110 - 2020) !! Yearly increase of CO2 price that interpolates between s45_co2_tax_2020 in 2020 and pm_taxCO2eq in 2110
                                      * (t.val - 2020) ;
      p45_CO2priceTrajDeveloped(t)$(t.val gt 2110) = pm_taxCO2eq(t,regi);
    );
);

*** re-create the regional differentation, use path from developed countries as the basis.
*** quadratic transition to global price - starting point depends on GDP/cap
pm_taxCO2eq(t,regi) = p45_regCO2priceFactor(t,regi) * p45_CO2priceTrajDeveloped(t);

display pm_taxCO2eq;
*** EOF ./modules/45_carbonprice/diffLin2Lin/postsolve.gms
