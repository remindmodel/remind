*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/declarations.gms

Parameters
  p29_CESderivative(tall,all_regi,all_in,all_in)   "derivative of the CES function for calculating prices"
  
  p29_alpha(all_regi,all_in)                       "XXX"
  p29_beta(all_regi,all_in)                        "XXX"
  p29_cesdata_load(tall,all_regi,all_in,cesParameter)  "pm_cesdata from the gdx file"
  p29_cesIO_load(tall,all_regi,all_in)                "production factor vm_cesIO from input.gdx"
  p29_cesIOdelta_load(tall,all_regi,all_in)                "production factor vm_cesIOdelta from input.gdx"
  p29_effGr(tall,all_regi,all_in)                                   "growth of factor efficiency from input.gdx"
  p29_cesdata_price(tall,all_regi,all_in)                          "exogenous prices in case they are needed"
$ifthen.transpmodule "%transport%" == "edge_esm"
  p29_trpdemand(tall,all_regi,all_GDPscen,EDGE_scenario_all,all_in) "transport demand for the edge_esm transport module, unit: trillion passenger/ton km"
$endif.transpmodule
  p29_esdemand(tall,all_regi,all_GDPscen,all_in)                  "energy service demand"
  p29_efficiency_growth(tall,all_regi,all_GDPscen,all_in)         "efficency level paths for ppf beyond calibration"
  p29_capitalQuantity(tall,all_regi,all_GDPscen,all_in)            "capital quantities"
  p29_capitalPrice(tall,all_regi)                "capital prices"
  
   p29_test_CES_recursive(tall,all_regi,all_in)      "test the technological consistency of pm_cesdata"
   p29_test_CES_putty_recursive(tall,all_regi,all_in)      "test the technological consistency of pm_cesdata_putty"
   
  f29_capitalUnitProjections(all_regi,all_in,index_Nr,capUnitType)   "Capital cost per unit of consumed energy and FE per unit of UE (or UE per unit of ES) used to calibrate some Esubs. kap is in $/kWh; UE and FE in kWh. Data for new investments and for standing capital"
  p29_capitalUnitProjections(all_regi,all_in,index_Nr)  "Capital cost per unit of consumed energy and final energy per unit of useful energy (or UE per unit of ES) used to calibrate some elasticities of substitution. kap is in $/kWh; UE and FE in kWh"
  p29_output_estimation(all_regi,all_in)       "scaling of the target quantity for comparability with technological data"                                          

p29_esubGrowth         "long term growth of the elasticity of substitution"

  p29_t_tmp(tall)                                       "tmp value for calculations over t"
;

*** in case of a putty formulation, the model putty_paths will try to 
*** find a pathway of variations which fits approximately the exogenous trajectories
*** the underlying variables (e.g. the consumption of useful energy in the whole buildings stock)
*** may vary but this is very costly in the objective function (we allow for these variations
*** because EDGE does not have a vintage structure and the projections might not fit the putty formulation
Variables
v29_cesdata(tall,all_regi,all_in)       "underlying variables to the putty variations"
v29_cesdata_putty(tall,all_regi,all_in) "variation in the underlying variable"
v29_puttyTechDiff(tall,all_regi,all_in) "Difference to be minimised between the K/E ratio of putty and the K/E ratio from the technological data"
v29_putty_obj                           "index of the step by step variation of v29_cesdata_putty"
v29_ratioTotalPutty(tall,all_regi,all_in,all_in,all_in) "Ratio of the ratio between input quantities for total and putty quantities"

v29_esub_err                   "sum of errors to be minimized"
v29_outputtech(all_regi,all_in,index_Nr)         "CES output from the technological data"
v29_rho(all_regi,all_in)                        "parameter to be calibrated, related to the esub through: rho = 1 - 1/esub"
;

Equations
q29_pathConstraint(tall,all_regi,all_in)  "equation describing the relation between a variable and its variation"
q29_esubsConstraint(tall,all_regi,all_in,all_in,all_in) "constraint ensuring that the ratio between capital and energy in putty for the last historical region will be close to the technological data used for the ESUB estimation"
q29_ratioTotalPutty (tall,all_regi,all_in,all_in,all_in) "Computation of the ratio between the two putty inputs of a same CES nestand the the ratio of pm_cesdata"
q29_putty_obj                              "objective function"

q29_esub_obj                               "objective function of esub estimation"
q29_outputtech(all_regi,all_in,index_Nr)            "CES equation for technological data"

;          

file file_CES_calibration / "CES_calibration.csv" /;

file_CES_calibration.ap =  1; !! append to file
file_CES_calibration.pc =  5; !! csv file
file_CES_calibration.lw =  0;
file_CES_calibration.nw = 20;
file_CES_calibration.nd = 15;

if (%c_CES_calibration_iteration% eq 1,
  put file_CES_calibration; 
  put "scenario", "iteration", "t", "regi", "variable", "pf", "value" /;
  putclose file_CES_calibration;
);


file capital_unit /"capital_unit.csv"/; !! file for the reporting of the ESUBs estimations

capital_unit.ap = 1; !!
capital_unit.pc =  5;
capital_unit.lw =  0;
capital_unit.nw = 15;
capital_unit.nd =  9;

if (%c_CES_calibration_iteration% eq 1,
put capital_unit;
put "iteration","index","period","variable", "parameter","region","value" /;
putclose;
);
*** EOF ./modules/29_CES_parameters/calibrate/declarations.gms
