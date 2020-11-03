*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/grades2poly/declarations.gms
scalars
s31_debug                                         "debugging option to display more output"        /0/
s31_max_disp_peur                                 "maximum amount of cumulative uranium production in Megatonnes of metal uranium (    U3O8, the stuff that is traded at 40-60US$/lb)."
;


parameter
p31_ffPolyRent(all_regi,all_enty,polyCoeffRent)   "Linear rent approx (e.g. Price - average extraction cost) (Oil, Gas and Coal)"
p31_ffPolyCoeffs(all_regi,all_enty,polyCoeffCost) "3rd-order polynomial coefficents (Oil, Gas and Coal)"
pm_ffPolyCumEx(all_regi,all_enty,char)                "Minimum / maximum cumulative extraction (condition to activate rent / upper bound on v31_fuExtrCum for Oil, Gas and Coal)"
p31_costExPoly(all_regi,xirog,all_enty)           "3rd-order polynomial coefficients (Uranium)"
p31_fosadjco_xi5xi6(all_regi,xirog,all_enty)      "data and parameters that describe the adjustment cost function of the fossil fuel extraction"

p31_rentdisc(all_enty)                            "discount factor for the rent, used for the sensitivity analysis"
p31_rentdisc2(all_enty)                           "discount factor for the rent achieved in 2100, used for the sensitivity analysis"
p31_rentconv(all_enty)                            "number of year that the convergence to rentdisc2 takes"
p31_rentdisctot(ttot, all_enty)                   "rent discount factor applied to the model"
p31_fuExtrCumMaxBound(all_regi,all_enty,rlf)      "value of regional uranium extraction bound"
;

positive variables
v31_fuExtrCum(ttot,all_regi,all_enty,rlf)        "cumulated extraction of exhaustible resources"
v31_fuExtrCumMax(all_regi,all_enty,rlf)                         "maximum of cumulated extraction of exhaustible resources"
v31_fuExtrMC(all_enty,rlf)                       "MC exhaustible resources"
;

variables
v31_squaredDiff                                  "objective for dummy model to determine uranium bound"
;

equations
q31_costFuExPol(ttot,all_regi,all_enty)          "costs of fuels estimated by 3rd-order polynomial; Uranium only"
q31_costfu_ex2(ttot,all_regi,all_enty)           "costs of fuels estimated by 3rd-order polynomial; Oil, Gas and Coal"
q31_fuExtrCum(ttot,all_regi,all_enty)            "cumulated extraction of exhaustible resources"

q31_mc_dummy(all_regi,all_enty)                  "marginal costs of fuels estimated by polynomial; exhaustible fuels (uranium)"
q31_totfuex_dummy                                "dummy for total global extraction; exhaustible fuels (uranium)"
;
*** EOF ./modules/31_fossil/grades2poly/declarations.gms
