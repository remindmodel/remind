*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffExp2Lin/declarations.gms
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
parameters
p45_gdppcap2015_PPP(all_regi)               "2015 GDP per capita (k $ PPP 2005)"
p45_phasein_ratio(all_regi)                 "inital ratio of CO2 price to that of developed region"

p45_regCO2priceFactor(ttot,all_regi)        "regional multiplicative factor to the CO2 price of the developed countries"
p45_CO2priceTrajDeveloped(ttot)             "CO2 price trajectory for developed/rich countries"
;

scalars
s45_co2_tax_startyear                       "level of CO2 tax in start year converted from $/t CO2eq to T$/GtC"
s45_CO2priceRegConvStartYr                  "year until which initial ratios of CO2 prices are applied and after which convergence starts"
;

*** EOF ./modules/45_carbonprice/diffExp2Lin/declarations.gms
