*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffExp2Lin/postsolve.gms
***---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** regional prices are initially differentiated by GDP/capita and converge using quadratic phase-in, 
*** global price from cm_CO2priceRegConvEndYr (default = 2050)
*** carbon price of developed regions increases exponentially with rate given by cm_co2_tax_growth until peak year (with iterative_target_adj = 9) or until 2100 (with iterative_target_adj = 5)
*** linear carbon price curve of developed regions starts at 0 in 2020 
***---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** re-create the regional differentation, use path from developed countries as the basis.
*** This doesn't need to be a loop, but it will be correct for any cycle of the loop, so also for the last cycle.
loop(regi$(p45_gdppcap2015_PPP(regi) gt 20),
  p45_CO2priceTrajDeveloped(t) = pm_taxCO2eq(t,regi);
);

*** quadratic transition to global price - starting point depends on GDP/cap
pm_taxCO2eq(t,regi) = p45_regCO2priceFactor(t,regi) * p45_CO2priceTrajDeveloped(t);

display pm_taxCO2eq;
*** EOF ./modules/45_carbonprice/diffExp2Lin/postsolve.gms
