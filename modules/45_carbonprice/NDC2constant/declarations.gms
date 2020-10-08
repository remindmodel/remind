*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC2constant/declarations.gms
***------------------------------------------------------------------------------------------------------------------------
*** *LB,BS* 20190927 calculation of tax paths for linear converge from NDC value in 2020 to constant global price in 2040
***-----------------------------------------------------------------------------------------------------------------------

parameters
p45_tauCO2_ref(ttot, all_regi)              "CO2 tax path of reference policy (NDC)"
p45_NDCstartPrice(all_regi)                 "start price for linear phase-in from NDC"
;
scalars
s45_stagestart                              "last time-step fixed to ref. / beginning of staged accession period"
s45_stageend                                "first time-step of constant global CO2 price"
s45_constantCO2price                        "initial value for constant global CO2 price"
;
*** EOF ./modules/45_carbonprice/NDC2constant/declarations.gms
