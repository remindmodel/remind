*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/loop.gms

***-------------------------------------------------------------------
***         solveoptions
***-------------------------------------------------------------------
option limcol    = 0;
option limrow    = 0;
hybrid.optfile   = 1;
hybrid.holdfixed = 1;
hybrid.scaleopt  = 1;
option savepoint = 0;
option resLim    = 3e6;
option solprint  = off;
o_modelstat      = 100;

$ifthen.calibrate "%CES_parameters%" == "calibrate"   !! CES_parameters
$ifthen.subsectors "%industry%" == "subsectors"       !! industry
*** Calibrating industry/subsectors lead to random infeasibilities on the order of 1e-15.
*** Relaxing this attribute a little solves this problem.
hybrid.tolinfeas = 1e-14;
$endif.subsectors
$endif.calibrate

***-------------------------------------------------------------------
***         read GDX
***-------------------------------------------------------------------
execute_loadpoint "input";

***-------------------------------------------------------------------
***         start iteration loop
***-------------------------------------------------------------------
loop(iteration $ (iteration.val <= cm_iteration_max),
  if(iteration.val = cm_iteration_max,
    option solprint = on
  );

***-------------------------------------------------------------------
***         BOUNDS
***-------------------------------------------------------------------
$include    "./core/bounds.gms";
$batinclude "./modules/include.gms" bounds


***-------------------------------------------------------------------
***         PRESOLVE
***-------------------------------------------------------------------
$include    "./core/presolve.gms";
$batinclude "./modules/include.gms" presolve

*** When there is a reference run, input_ref.gdx contains the necessary fixing information (.L, .FX and .M) for t < cm_startyear
*** Script submit.R creates reference files (levs.gms, fixings.gms, margs.gms) and inludes them in full.gms by replacing the following line
*** cb20140305readinpositionforfixingfiles

*** Also fix prices, which are not automatically treated by the fixing mechanism above.
  if(cm_startyear > 2005,
    Execute_Loadpoint "input_ref" p_pvpRef = pm_pvp;
    pm_pvp(ttot,trade) $ (ttot.val >= 2005 and ttot.val < cm_startyear and not tradeSe(trade)) = p_pvpRef(ttot,trade);
  );

***-------------------------------------------------------------------
***         SOLVE
***-------------------------------------------------------------------
*** Set options for debugging
  if(cm_nash_mode = 1, 
    option 
      solprint = on
      limcol   = 2147483647
      limrow   = 2147483647
    ;
  );

o_modelstat = 100;
loop(sol_itr $ (sol_itr.val <= cm_solver_try_max),
  if(o_modelstat ne 2,
$batinclude "./modules/include.gms" solve
  )
);  !! end of sol_itr loop, when o_modelstat is not equal to 2

***-------------------------------------------------------------------
***         Track of changes between iterations
***-------------------------------------------------------------------
o_negitr_cumulative_peprod(iteration,entyPe) =
    ((1 / s_ZJ_2_TWa) $ (not sameas(entyPe,"peur")) + 0.4102 $ (sameas(entyPe,"peur"))) !! conversion from TWa (or Mt uranium) to ZJ
  * sum(regi,
      sum(ttot $ (ttot.val < 2100 and ttot.val > 2005), vm_prodPe.l(ttot,regi,entyPe) * pm_ts(ttot) )
    + sum(ttot $ (ttot.val = 2005), vm_prodPe.l(ttot,regi,entyPe) * pm_ts(ttot) * 0.5 )
    + sum(ttot $ (ttot.val = 2100), vm_prodPe.l(ttot,regi,entyPe) * ( pm_ttot_val(ttot) - pm_ttot_val(ttot-1) ) * 0.5 )
  );

o_negitr_cumulative_CO2_emineg_co2luc(iteration) = sm_c_2_co2 !! conversion from carbon to CO2
  * sum(regi,
      sum(ttot $ (ttot.val < 2100 and ttot.val > 2005), vm_emiMacSector.l(ttot,regi,"co2luc") * pm_ts(ttot) )
    + sum(ttot $ (ttot.val = 2005), vm_emiMacSector.l(ttot,regi,"co2luc") * pm_ts(ttot) * 0.5 )
    + sum(ttot $ (ttot.val = 2100), vm_emiMacSector.l(ttot,regi,"co2luc") * ( pm_ttot_val(ttot) - pm_ttot_val(ttot-1) ) * 0.5 )
  );

o_negitr_cumulative_CO2_emineg_cement(iteration) = sm_c_2_co2 !! conversion from carbon to CO2
  * sum(regi,
      sum(ttot $ (ttot.val < 2100 and ttot.val > 2005), vm_emiMacSector.l(ttot,regi,"co2cement_process") * pm_ts(ttot) )
    + sum(ttot $ (ttot.val = 2005), vm_emiMacSector.l(ttot,regi,"co2cement_process") * pm_ts(ttot) * 0.5 )
    + sum(ttot $ (ttot.val = 2100), vm_emiMacSector.l(ttot,regi,"co2cement_process") * ( pm_ttot_val(ttot) - pm_ttot_val(ttot-1) ) * 0.5 )
  );

o_negitr_cumulative_CO2_emieng_seq(iteration) = sm_c_2_co2 !! conversion from carbon to CO2
  * sum((regi,emi2te(enty,enty2,te,"cco2")),
      sum(ttot $ ( ttot.val > 2005 and ttot.val < 2100 ), vm_emiTeDetail.l(ttot,regi,enty,enty2,te,"cco2") * pm_ts(ttot))
    + sum(ttot $ ( ttot.val = 2005 ), vm_emiTeDetail.l(ttot,regi,enty,enty2,te,"cco2") * pm_ts(ttot) * 0.5)
    + sum(ttot $ ( ttot.val = 2100 ), vm_emiTeDetail.l(ttot,regi,enty,enty2,te,"cco2") * ( pm_ttot_val(ttot) - pm_ttot_val(ttot-1) ) * 0.5)
  );

o_negitr_disc_cons_dr5_reg(iteration,regi) =
    sum(ttot $ ( (ttot.val < 2100) and (ttot.val > 2005)), vm_cons.l(ttot,regi) * (0.95 ** (pm_ttot_val(ttot) - s_t_start)) * pm_ts(ttot) )
  + sum(ttot $ (ttot.val = 2005), vm_cons.l(ttot,regi) * (0.95 ** (pm_ttot_val(ttot) - s_t_start)) * pm_ts(ttot) * 0.5 )
  + sum(ttot $ (ttot.val = 2100), vm_cons.l(ttot,regi) * (0.95 ** (pm_ttot_val(ttot) - s_t_start)) * ( pm_ttot_val(ttot) - pm_ttot_val(ttot-1) ) * 0.5 );

o_negitr_disc_cons_drInt_reg(iteration,regi) =
    sum(ttot $ ( (ttot.val < 2100) and (ttot.val > 2005)), vm_cons.l(ttot,regi) * qm_budget.m(ttot,regi)/ (qm_budget.m("2005",regi) + sm_eps) * pm_ts(ttot) )
  + sum(ttot $ (ttot.val = 2005), vm_cons.l(ttot,regi) * qm_budget.m(ttot,regi) / (qm_budget.m("2005",regi) + sm_eps) * pm_ts(ttot) * 0.5 )
  + sum(ttot $ (ttot.val = 2100), vm_cons.l(ttot,regi) * qm_budget.m(ttot,regi) / (qm_budget.m("2005",regi) + sm_eps) * ( pm_ttot_val(ttot) - pm_ttot_val(ttot-1) ) * 0.5 );

***-------------------------------------------------------------------
***         POSTSOLVE
***-------------------------------------------------------------------
$include    "./core/postsolve.gms";
$batinclude "./modules/include.gms" postsolve

***-------------------------------------------------------------------
***         save gdx
***-------------------------------------------------------------------
*** Write the fulldata.gdx file after each optimal iteration
*** In Nash, status 7 is considered optimal (see definition of o_modelstat in solve.gms)
logfile.nr = 1;
if(o_modelstat <= 2,
  execute_unload "fulldata";
  if(c_keep_iteration_gdxes = 1, !! save gdx of intermediate iterations using shell command "copy"
    put_utility logfile, "shell" /
      "cp fulldata.gdx fulldata_" iteration.val:0:0 ".gdx";
  );
else
  execute_unload "non_optimal";
  if(c_keep_iteration_gdxes = 1,
    put_utility logfile, "shell" /
      "cp non_optimal.gdx non_optimal_" iteration.val:0:0 ".gdx";
  );
);
logfile.nr = 2;

);  !! close iteration loop
*** EOF ./core/loop.gms
