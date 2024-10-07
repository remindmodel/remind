*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffLin2Lin/realization.gms

*' @description: This realization implements linearly increasing carbon price - either until 2100 or until peak year (constant or linear thereafter). Optional carbon price differentiation and quadratic phase-in can be activated via switch cm_co2_tax_spread.

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

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/diffLin2Lin/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/diffLin2Lin/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/diffLin2Lin/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/45_carbonprice/diffLin2Lin/realization.gms
