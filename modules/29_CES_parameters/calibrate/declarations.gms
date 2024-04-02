*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
  p29_effGr(tall,all_regi,all_in)                                   "growth of factor efficiency from input.gdx"
  p29_trpdemand(tall,all_regi,all_GDPscen,all_demScen,EDGE_scenario_all,all_in) "transport demand for the edge_esm transport module, unit: trillion passenger/ton km"
  p29_efficiency_growth(tall,all_regi,all_in)         "efficency level paths for ppf beyond calibration"
  p29_capitalQuantity(tall,all_regi,all_in)            "capital quantities"
  p29_capitalPrice(tall,all_regi)                "capital prices"

  p29_test_CES_recursive(tall,all_regi,all_in)      "test the technological consistency of pm_cesdata"

  p29_esubGrowth         "long term growth of the elasticity of substitution"

  p29_t_tmp(tall)                                       "tmp value for calculations over t"

  p29_share_H2HTH_traj_indst(ttot,all_regi,all_in)  "H2 and electricity HTH baseline trajectories as share of gas (for H2) and low-temperature electricity (for HTH electricity) trajectories in industry"
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

$macro file_CES_calibration_integers \
  file_CES_calibration.nd = 0; \
  file_CES_calibration.nr = 1; \
  file_CES_calibration.nw = 0;

$macro file_CES_calibration_floats \
  file_CES_calibration.nd =  3; \
  file_CES_calibration.nr =  2; \
  file_CES_calibration.nw = 10;


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
