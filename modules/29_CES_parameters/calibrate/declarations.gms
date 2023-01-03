*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/declarations.gms

Scalars
  s29_CES_calibration_new_structure    "CES structure differs from input.gdx"  /%c_CES_calibration_new_structure%/
;

Parameters
  p29_CESderivative(tall,all_regi,all_in,all_in)   "derivative of the CES function for calculating prices"

  p29_alpha(all_regi,all_in)                       "XXX"
  p29_beta(all_regi,all_in)                        "XXX"
  p29_cesdata_load(tall,all_regi,all_in,cesParameter)  "pm_cesdata from the gdx file"
  p29_cesIO_load(tall,all_regi,all_in)                "production factor vm_cesIO from input.gdx"
  p29_cesIOdelta_load(tall,all_regi,all_in)                "production factor vm_cesIOdelta from input.gdx"
  p29_effGr(tall,all_regi,all_in)                                   "growth of factor efficiency from input.gdx"
$ifthen.transpmodule "%transport%" == "edge_esm"
  p29_trpdemand(tall,all_regi,all_GDPscen,all_demScen,EDGE_scenario_all,all_in) "transport demand for the edge_esm transport module, unit: trillion passenger/ton km"
$endif.transpmodule
  p29_esdemand(tall,all_regi,all_in)                  "energy service demand"
  p29_efficiency_growth(tall,all_regi,all_in)         "efficency level paths for ppf beyond calibration"
  p29_capitalQuantity(tall,all_regi,all_in)            "capital quantities"
  p29_capitalPrice(tall,all_regi)                "capital prices"

   p29_test_CES_recursive(tall,all_regi,all_in)      "test the technological consistency of pm_cesdata"
   p29_test_CES_putty_recursive(tall,all_regi,all_in)      "test the technological consistency of pm_cesdata_putty"

  f29_capitalUnitProjections(all_regi,all_in,index_Nr,capUnitType)   "Capital cost per unit of consumed energy and FE per unit of UE (or UE per unit of ES) used to calibrate some Esubs. kap is in $/kWh; UE and FE in kWh. Data for new investments and for standing capital"
  p29_capitalUnitProjections(all_regi,all_in,index_Nr)  "Capital cost per unit of consumed energy and final energy per unit of useful energy (or UE per unit of ES) used to calibrate some elasticities of substitution. kap is in $/kWh; UE and FE in kWh"
  p29_output_estimation(all_regi,all_in)       "scaling of the target quantity for comparability with technological data"

  p29_esubGrowth         "long term growth of the elasticity of substitution"

  p29_t_tmp(tall)                                       "tmp value for calculations over t"

  p29_share_H2HTH_traj_indst(ttot,all_regi,all_in)  "H2 and electricity HTH baseline trajectories as share of gas (for H2) and low-temperature electricity (for HTH electricity) trajectories in industry"
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

*** Load calibration iteration number from environment variable
*** cm_CES_calibration_iteration
put_utility "shell" / "exit $cm_CES_calibration_iteration";
sm_CES_calibration_iteration = errorlevel;
if (sm_CES_calibration_iteration lt 1,
  abort "sm_CES_calibration_iteration is zero.  Is cm_CES_calibration_iteration unset?";
);

file file_CES_calibration / "CES_calibration.csv" /;

file_CES_calibration.ap =     1;   !! append to file
file_CES_calibration.pc =     5;   !! csv file
file_CES_calibration.lw =     0;   !! no label padding
file_CES_calibration.nr =     2;   !! scientific notation
file_CES_calibration.nd =     3;   !! three decimal places
file_CES_calibration.nw =    10;   !! number width: +0.000e+00
file_CES_calibration.pw = 32767;   !! page width

if (sm_CES_calibration_iteration eq 1,
  !! print a comment header giving the order of production factors in the CES
  !! tree so that they can be displayed in a meaningful order in calibration
  !! reports
  file_CES_calibration.pc =  0;   !! text file
  put file_CES_calibration;

  CES_tc("inco") = YES;
  put "# pf order: inco";

  loop (cesOut2cesIn(out,in),
    CES_tp(out) = YES;
    CES_tp(in) = YES;
  );

  !! as long as there are nodes pending
  while (0 lt card(CES_tp),
    !! if the current node is a calibration target and all of its child nodes
    !! are pending (so it has not been processed before)
    if (sum(CES_tc$(    (   ppf(CES_tc)
                         OR industry_ue_calibration_target_dyn37(CES_tc))
		    AND (   sum(cesOut2cesIn(CES_tc,in), 1)
		         eq sum(cesOut2cesIn(CES_tc,CES_tp), 1))
		   ), 1),
    !! add the current node to the list
    loop (CES_tc, put ", ", CES_tc.tl:0);
  );

  !! if no child nodes are pending
  if (0 eq sum(cesOut2cesIn(CES_tc,CES_tp), 1),
    !! remove current node from pending nodes
    CES_tp(CES_tc) = NO;
    !! set parent node as current node
    loop (cesOut2cesIn(out,CES_tc), CES_ts(out) = YES);
    CES_tc(all_in) = NO;
    CES_tc(CES_ts) = YES;
    CES_ts(all_in) = NO;

  !! if any child nodes are pending
  else
    !! set first pending child node as current node
    loop (cesOut2cesIn(CES_tc,CES_tp), CES_ts(CES_tp) = YES);
      CES_tc(all_in) = NO;
$offorder
      CES_tc(CES_ts)$( 1 eq ord(CES_ts) ) = YES;
$onorder
      CES_ts(all_in) = NO;
    );
  );
  put " " /;

  !! print the csv header
  file_CES_calibration.pc =  5;   !! csv file
  put "scenario", "iteration", "t", "regi", "variable", "pf", "value" /;
  putclose file_CES_calibration;
);


file capital_unit /"capital_unit.csv"/; !! file for the reporting of the ESUBs estimations

capital_unit.ap = 1; !!
capital_unit.pc =  5;
capital_unit.lw =  0;
capital_unit.nw = 15;
capital_unit.nd =  9;

if (sm_CES_calibration_iteration eq 1,
put capital_unit;
put "iteration","index","period","variable", "parameter","region","value" /;
putclose;
);
*** EOF ./modules/29_CES_parameters/calibrate/declarations.gms
