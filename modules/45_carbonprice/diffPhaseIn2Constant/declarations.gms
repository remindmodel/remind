*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffPhaseIn2Constant/declarations.gms
***------------------------------------------------------------------------------------------------------------------------
*** *BS* 20190930 linear convergence with starting points differentiated by GDP/capita, global price from 2040
***-----------------------------------------------------------------------------------------------------------------------

parameters
p45_tauCO2_ref(ttot, all_regi)              "CO2 tax path of reference policy (NDC)"
p45_gdppcap2015_PPP(all_regi)               "2015 GDP per capita (k $ PPP 2005)"
p45_phasein_zeroyear(all_regi)              "year when CO2 price convergence line crosses zero"
;
scalars
s45_stagestart                              "last time-step fixed to ref. / beginning of staged accession period"
s45_stageend                                "first time-step of constant global CO2 price"
s45_constantCO2price                        "initial value for constant global CO2 price"
;
*** EOF ./modules/45_carbonprice/diffPhaseIn2Constant/declarations.gms
