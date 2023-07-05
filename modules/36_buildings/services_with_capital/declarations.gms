*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/declarations.gms
Scalar
s36_vintage_calib "switch for the inclusion of vintage equations and restricting ttot to historical. It should exclude the equations from hybrid" /0/,
s36_logit         "switch for the inclusion of vintage equations. It should exclude the equations from hybrid" /0/
;

Parameter
p36_floorspace(tall,all_regi)  "buildings floorspace, billion m2"
p36_adjFactor(tall,all_regi)    "factor applied for the adjustment costs" 

p36_cesIONoRebound(tall,all_regi,all_in) "loads the vm_cesIO values from the input_ref and sets the upper bound to vm_cesIO to forbid a rebound effect"
p36_demFeForEs_scen(tall,all_regi,all_GDPscen,all_enty,all_esty,all_teEs)  "Final energy demand for technologies producing energy services (useful energy in the case of buildings)"
p36_demFeForEs(ttot,all_regi,all_enty,all_esty,all_teEs)                     "Final energy demand for technologies producing energy services (useful energy in the case of buildings)"

p36_prodEs_scen(tall,all_regi,all_GDPscen,all_enty,all_esty,all_teEs)     "Energy service demand (UE in the case of buildings) for technologies producing energy services and using FE"
p36_prodEs(ttot,all_regi,all_enty,all_esty,all_teEs)                      "Energy service demand (UE in the case of buildings) for technologies producing energy services and using FE"
p36_prodEs_iter(iteration,ttot,all_regi,all_enty,all_esty,all_teEs)       "Energy service demand (UE in the case of buildings) for technologies producing energy services and using FE over iterations"
p36_deltaProdEs_iter(iteration,ttot,all_regi,all_enty,all_esty,all_teEs)  "Energy service demand (UE in the case of buildings) addition for a year. For technologies producing energy services and using FE over iterations"
p36_deltaProdEs(ttot,all_regi,all_enty,all_esty,all_teEs)                 "Energy service demand (UE in the case of buildings) addition for a year. Result of vintage_36"

p36_shFeCes(ttot,all_regi,all_enty,all_in,all_teEs)                 "share of Final energy of technology teEs in the final energy producing all_in"
p36_shFeCes_iter(iteration,ttot,all_regi,all_enty,all_in,all_teEs)  "share of Final energy of technology teEs in the final energy producing all_in"
p36_shUeCes(ttot,all_regi,all_enty,all_in,all_teEs)                 "share of Useful energy of technology teEs in the final energy producing all_in"
p36_shUeCes_iter(iteration,ttot,all_regi,all_enty,all_in,all_teEs)  "share of Useful energy of technology teEs in the final energy producing all_in"
p36_fe2es(ttot,all_regi,all_teEs)                                   "FE to ES(UE) efficiency of technology teES"

p36_logitLambda(all_regi,all_in)                                        "logit parameter for homogeneity"
p36_logitLambda_load (all_regi,all_in)                                  "logit parameter for homogeneity, loaded from GDX_ref"
p36_fePrice_load(tall,all_regi,all_enty,all_enty,all_te)                "Final energy price from GDX"
p36_fePrice(tall,all_regi,all_enty)                                     "Final energy price"
p36_fePrice_iter(iteration,tall,all_regi,all_enty)                      "Final energy price over iterations"
p36_marginalUtility(tall,all_regi)                                      "Marginal utility of income: used to compute the final energy price from the marginal of balance equation"
p36_techCosts(tall,all_regi,all_enty,all_esty,all_teEs)                 "Relevant costs of each ES technology for the computation of the share in the multinomial logit"
p36_techCosts_iter(iteration,tall,all_regi,all_enty,all_esty,all_teEs)  "Relevant costs of each ES technology for the computation of the share in the multinomial logit over iterations"
p36_logitCalibration(tall,all_regi,all_enty,all_esty,all_teEs)          "calibration parameter for the multinomial logit function"
p36_logitCalibration_load(tall,all_regi,all_enty,all_esty,all_teEs)     "calibration parameter for the multinomial logit function from input_ref.gdx"
p36_logitNorm(iteration,tall,all_regi,all_in)                           "Norm of the share vector difference between iterations"

p36_prodUEintern(tall,all_regi,all_enty,all_esty,all_teEs)   "UE production from depreciated technologies of the previous period"
p36_prodUEintern_load(tall,all_regi,all_enty,all_esty,all_teEs)   "UE production from depreciated technologies of the previous period -- From GDX"
p36_demUEtotal(tall,all_regi,all_in)                     "Demand for UE, independent of the technology"
p36_demUEdelta(tall,all_regi,all_in)                     "Demand for UE, independent of the technology, and which is not covered by the depreciated technologies"
p36_shUeCesDelta(ttot,all_regi,all_enty,all_in,all_teEs) "Technological shares in UE which is not covered by former depreciated technologies"
p36_depreciationRate(all_teEs)                       "Depreciation rates for the indivudal conversion technologies, rouhgly derived from their lifetime parameter"

p36_esCapCost(tall,all_regi,all_teEs)           "Capital costs for each technology transforming FE into UE. Cost per unit of FE"
p36_esCapCostImplicit(tall,all_regi,all_teEs)   "Capital costs for each technology transforming FE into UE, taking the implicit discount rate into account. Cost per unit of FE"
p36_kapPrice(tall,all_regi)                     "Macroeconomic capital price, net of depreciation"
p36_kapPriceImplicit(tall,all_regi,all_teEs)    "Macroeconomic capital price, net of depreciation, to which the implicit discount rate is added"
p36_implicitDiscRateMarg(tall,all_regi,all_in)  "Implicit discount rate for the choice of conversion technologies from UE to FE in buildings"
p36_depreciationRate(all_teEs)                  "Depreciation rates for the indivudal conversion technologies, rouhgly derived from their lifetime parameter"
p36_pushCalib(tall,all_teEs)                    "degree to which the calibration parameter should be reduced/increased for these technologies"
p36_costReduc(tall,all_teEs)                    "Reduction of costs for some technologies"
f36_inconvpen(all_teEs)                         "maximum inconvenience penalty for traditional conversion technologies. Unit: T$/TWa"
p36_inconvpen(ttot,all_regi,all_teEs)           "parameter for inconvenience penalty depending on income level. Unit: T$/TWa"

p36_aux_lifetime(all_teEs)                      "auxiliary parameter for calculating life times"
p36_omegEs(all_regi,opTimeYr,all_teEs)          "technical depreciation parameter, gives the share of a capacity that is still usable after tlt. [none/share, value between 0 and 1]"
;

Variables
v36_prodEs(ttot,all_regi,all_enty,all_esty,all_teEs)        "Energy service demand (UE in the case of buildings) for technologies producing energy services and using FE"
v36_deltaProdEs(ttot,all_regi,all_enty,all_esty,all_teEs)   "Energy service demand (UE in the case of buildings) addition for a year. For technologies producing energy services and using FE"
v36_vintageInfes(ttot,all_regi,all_enty,all_esty,all_teEs)  "slack variable to avoid infeasibilities in the initialisation of vintages"
v36_logitInfes(tall,all_regi,all_in)                        "slack variable to avoid infeasibilities in case historical demand cannot be declined fast enough"
v36_costs(ttot,all_regi)                                    "technological costs"
v36_vintage_obj                                             "objective variable for vintage model"
v36_shares_obj                                              "objective variable for heterogeneity preferences"
;

Equations
q36_demFeBuild(ttot,all_regi,all_enty,all_emiMkt) "buildings final energy demand"
q36_ueTech2Total(tall,all_regi,all_in)            "definition of total UE buildings demand, based on the sum of demand by technology"
q36_cap(tall,all_regi,all_enty,all_esty,all_teEs) "definition of available capacities"
q36_budget(tall,all_regi)                         "budget equation"
q36_vintage_obj                                   "objective function for vintage model"
q36_shares_obj                                    "objective function for logit shares: heterogeneity preferences"
;


file testfile /""/;

testfile.nd = 10;


file file_logit_buildings / "Logit_buildings.csv" /;

file_logit_buildings.ap =  0; !! append to file is negative to overwrite former file if existing
file_logit_buildings.pc =  5; !! csv file
file_logit_buildings.lw =  0;
file_logit_buildings.nw = 20;
file_logit_buildings.nd = 15;

*** EOF ./modules/36_buildings/services_with_capital/declarations.gms
