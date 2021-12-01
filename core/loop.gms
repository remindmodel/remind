*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/loop.gms

*--------------------------------------------------------------------------
***         solveoptions
*--------------------------------------------------------------------------
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
!! Calibrating industry/subsectors lead to random infeasibilities on the order
!! of 1e-15.  Relaxing this attribute a little solves this problem.
hybrid.tolinfeas = 1e-14;
$endif.subsectors
$endif.calibrate

***-------------------------------------------------------------------
***                     read GDX
***-------------------------------------------------------------------
*** load start gdx
execute_loadpoint 'input';

***--------------------------------------------------------------------------
***    start iteration loop 
***--------------------------------------------------------------------------

LOOP(iteration $(ord(iteration)<(cm_iteration_max+1)),

      IF(ord(iteration)>(cm_iteration_max-1),
            OPTION solprint=on
        );
*--------------------------------------------------------------------------
***         BOUNDS
*--------------------------------------------------------------------------
$include    "./core/bounds.gms";
$batinclude "./modules/include.gms" bounds


***--------------------------------------------------------------------------
***         PRESOLVE
***--------------------------------------------------------------------------
$include    "./core/presolve.gms";
$batinclude "./modules/include.gms" presolve

*cb 20140305 Fixing information (.L, .FX and .M) from run to be fixed to is read in from input_ref.gdx (t < cm_startyear)
*cb 20140305 happens via submit.R script (files levs.gms, fixings.gms, margs.gms)
*cb 20140305 submit.R looks for the unique string in the following line and replaces it with the offlisting include into the full.gms at this position
***cb20140305readinpositionforfinxingfiles

*AJS* In case of fixing, fix to prices from input_ref.gdx (t < cm_startyear). 
*** Parameters are not automatically treated by the fixing mechanism above.
if( (cm_startyear gt 2005),
    Execute_Loadpoint 'input_ref' p_pvpRef = pm_pvp;
    pm_pvp(ttot,trade)$( (ttot.val ge 2005) and (ttot.val lt cm_startyear) and (NOT tradeSe(trade))) = p_pvpRef(ttot,trade);
);    

***--------------------------------------------------------------------------
***         SOLVE 
***--------------------------------------------------------------------------
***this disables solprint in cm_nash_mode=debug case by default. It is switched on in case of infes in nash/solve.gms
*RP* for faster debugging, turn solprint immediately on
$IF %cm_nash_mode% == "debug" option solprint = on ;

o_modelstat = 100;
loop(sol_itr$(sol_itr.val <= c_solver_try_max),
    if(o_modelstat ne 2,
$batinclude "./modules/include.gms" solve
    )
);  !! end of sol_itr loop, when o_modelstat is not equal to 2

***---------------------------------------------------------
***     Track of changes between iterations
***---------------------------------------------------------
loop(entyPe$(NOT sameas(entyPe,'peur')),
  o_negitr_cumulative_peprod(iteration,entyPe) = 0.031536 
    * sum(regi, 
        sum(ttot$( (ttot.val lt 2100) AND (ttot.val gt 2005)), vm_prodPe.l(ttot,regi,entyPe) * pm_ts(ttot)  )
        + sum(ttot$(ttot.val eq 2005), vm_prodPe.l(ttot,regi,entyPe) * pm_ts(ttot) * 0.5  )
        + sum(ttot$(ttot.val eq 2100), vm_prodPe.l(ttot,regi,entyPe) * ( pm_ttot_val(ttot)- pm_ttot_val(ttot-1) ) * 0.5  )
    );
);
o_negitr_cumulative_peprod(iteration,"peur") = 
sum(regi, 
        sum(ttot$( (ttot.val lt 2100) AND (ttot.val gt 2005)), sum(pe2rlf('peur',rlf), 0.4102 * vm_prodPe.l(ttot,regi,'peur') * pm_ts(ttot) ) )
        + sum(ttot$(ttot.val eq 2005), 0.4102 * vm_prodPe.l(ttot,regi,'peur') * pm_ts(ttot) * 0.5 ) 
        + sum(ttot$(ttot.val eq 2100), 0.4102 * vm_prodPe.l(ttot,regi,'peur') * ( pm_ttot_val(ttot)- pm_ttot_val(ttot-1) ) * 0.5 ) 
); 
o_negitr_cumulative_CO2_emineg_co2luc(iteration) =
sum(regi,
    sum(ttot$( (ttot.val lt 2100) AND (ttot.val gt 2005)), 3.6667 * vm_emiMacSector.l(ttot,regi,"co2luc") * pm_ts(ttot) )
    + sum(ttot$(ttot.val eq 2005), 3.6667 * vm_emiMacSector.l(ttot,regi,"co2luc") * pm_ts(ttot) * 0.5 ) 
    + sum(ttot$(ttot.val eq 2100), 3.6667 * vm_emiMacSector.l(ttot,regi,"co2luc") * ( pm_ttot_val(ttot)- pm_ttot_val(ttot-1) ) * 0.5 )
);

o_negitr_cumulative_CO2_emineg_cement(iteration) =
sum(regi,
    sum(ttot$( (ttot.val lt 2100) AND (ttot.val gt 2005)), 3.6667 * vm_emiMacSector.l(ttot,regi,"co2cement_process") * pm_ts(ttot) )
    + sum(ttot$(ttot.val eq 2005), 3.6667 * vm_emiMacSector.l(ttot,regi,"co2cement_process") * pm_ts(ttot) * 0.5 ) 
    + sum(ttot$(ttot.val eq 2100), 3.6667 * vm_emiMacSector.l(ttot,regi,"co2cement_process") * ( pm_ttot_val(ttot)- pm_ttot_val(ttot-1) ) * 0.5 )
); 
o_negitr_cumulative_CO2_emieng_seq(iteration)
  =
    3.6667
  * sum(regi,
      sum((ttot,emi2te(enty,enty2,te,"cco2"))$( ttot.val gt 2005 AND ttot.val lt 2100 ),
        vm_emiTeDetail.l(ttot,regi,enty,enty2,te,"cco2")
      * pm_ts(ttot)
      )
    + sum((ttot,emi2te(enty,enty2,te,"cco2"))$( ttot.val eq 2005 ),
        vm_emiTeDetail.l(ttot,regi,enty,enty2,te,"cco2")
      * pm_ts(ttot) 
      / 2
      ) 
    + sum((ttot,emi2te(enty,enty2,te,"cco2"))$( ttot.val eq 2100 ),
        vm_emiTeDetail.l(ttot,regi,enty,enty2,te,"cco2")
      * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
      / 2
      )
    )
;
o_negitr_disc_cons_dr5_reg(iteration,regi) =
    sum(ttot$( (ttot.val lt 2100) AND (ttot.val gt 2005)), vm_cons.l(ttot,regi) * (0.95 ** (pm_ttot_val(ttot) - s_t_start)) * pm_ts(ttot) )
    + sum(ttot$(ttot.val eq 2005), vm_cons.l(ttot,regi) * (0.95 ** (pm_ttot_val(ttot) - s_t_start)) * pm_ts(ttot) * 0.5 ) 
    + sum(ttot$(ttot.val eq 2100), vm_cons.l(ttot,regi) * (0.95 ** (pm_ttot_val(ttot) - s_t_start)) * ( pm_ttot_val(ttot)- pm_ttot_val(ttot-1) ) * 0.5 )
;
o_negitr_disc_cons_drInt_reg(iteration,regi) =
    sum(ttot$( (ttot.val lt 2100) AND (ttot.val gt 2005)), vm_cons.l(ttot,regi) * qm_budget.m(ttot,regi)/ (qm_budget.m('2005',regi) + 1.e-8) * pm_ts(ttot) )
    + sum(ttot$(ttot.val eq 2005), vm_cons.l(ttot,regi) * qm_budget.m(ttot,regi)/ (qm_budget.m('2005',regi) + 1.e-8) * pm_ts(ttot) * 0.5 ) 
    + sum(ttot$(ttot.val eq 2100), vm_cons.l(ttot,regi) * qm_budget.m(ttot,regi)/ (qm_budget.m('2005',regi) + 1.e-8) * ( pm_ttot_val(ttot)- pm_ttot_val(ttot-1) ) * 0.5 )
;

***--------------------------------------------------------------------------
***         POSTSOLVE
***--------------------------------------------------------------------------
$include    "./core/postsolve.gms";
$batinclude "./modules/include.gms" postsolve

*--------------------------------------------------------------------------
***                  save gdx
*--------------------------------------------------------------------------
*** write the fulldata.gdx file after each optimal iteration
*AJS* in Nash status 7 is considered optimal in that respect (see definition of
***   o_modelstat in solve.gms)
logfile.nr = 1;
if (o_modelstat le 2,
  execute_unload 'fulldata';
  !! retain gdxes of intermediate iterations by copying them using shell
  !! commands
  if (c_keep_iteration_gdxes eq 1,
    put_utility logfile, "shell" / 
      "cp fulldata.gdx fulldata_" iteration.val:0:0 ".gdx";
  );
else
  execute_unload 'non_optimal';
  if (c_keep_iteration_gdxes eq 1,
    put_utility logfile, "shell" / 
      "cp non_optimal.gdx non_optimal_" iteration.val:0:0 ".gdx";
  );
);
logfile.nr = 2;

);  !! close iteration loop
*** EOF ./core/loop.gms
