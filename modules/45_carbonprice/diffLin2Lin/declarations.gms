*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffLin2Lin/declarations.gms
***----------------------------------------------------------------------------------------------------------------------------------------------------
*** regional prices are initially differentiated by GDP/capita and converge using quadratic phase-in, 
*** global price from cm_CO2priceRegConvEndYr (default = 2050)
*** carbon price of developed regions increases linearly until peak year (with iterative_target_adj = 9) or until 2100 (with iterative_target_adj = 5)
*** linear carbon price curve of developed regions starts at 25$/t CO2eq in 2020 (corresponding to historical CO2 price for EUR, which is the highest among regions)
***----------------------------------------------------------------------------------------------------------------------------------------------------

parameters
p45_gdppcap2015_PPP(all_regi)               "2015 GDP per capita (k $ PPP 2005)"
p45_phasein_2025ratio(all_regi)             "ratio of CO2 price to that of developed region in 2025"

p45_regCO2priceFactor(ttot,all_regi)                    "regional multiplicative factor to the CO2 price of the developed countries"
p45_CO2priceTrajDeveloped(ttot)                         "CO2 price trajectory for developed/rich countries"
;

scalars
s45_co2_tax_startyear                       "level of CO2 tax in start year converted from $/t CO2eq to T$/GtC"
s45_co2_tax_2020                            "level of CO2 tax in 2020 converted from $/t CO2eq to T$/GtC"
;


*** EOF ./modules/45_carbonprice/diffLin2Lin/declarations.gms
