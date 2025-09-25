*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/solve.gms

regi(all_regi) = NO;
remindgamsmodel.solvelink = 3; !! activate multiple-CPU mode for GAMS
remindgamsmodel.optfile   = 9;

if(cm_nash_mode eq 1,
  remindgamsmodel.solvelink = 0;  !! activate single-CPU mode for GAMS
);

loop (all_regi,
  !! only solve for regions that do not have a valid solution from the
  !! last solver iteration
  if (    (   sol_itr.val gt 1 
           OR s80_runInDebug eq 1)
      AND (   p80_repy(all_regi,"modelstat") eq 2
$ifthen.repeatNonOpt "%cm_repeatNonOpt%" == "off"
           OR p80_repy(all_regi,"modelstat") eq 7
$endif.repeatNonOpt
          ),

    p80_repy_thisSolitr(all_regi,solveinfo80) = 0;
    continue;
  );

  regi(all_regi) = YES;

  if (execError > 0,
    execute_unload "abort.gdx";
    abort "at least one execution error occured, possibly in the loop";
  );

  if (cm_keep_presolve_gdxes eq 1,
    execute_unload "presolve_nash.gdx";
    sm_tmp  = logfile.nr;
    sm_tmp2 = logfile.nd;
    logfile.nr = 1;
    logfile.nd = 0;
    put_utility logfile, "shell" /
      "mv presolve_nash.gdx presolve_nash_" all_regi.tl "_CES-"
       sm_CES_calibration_iteration "_Nash-" iteration.val "_Sol-" sol_itr.val
       ".gdx";
    logfile.nr = sm_tmp;
    logfile.nd = sm_tmp2;
  );
  
  solve remindgamsmodel using nlp maximizing vm_welfareGlob;

  if(cm_nash_mode eq 1,
    p80_repy_thisSolitr(all_regi,"solvestat") = remindgamsmodel.solvestat;
    p80_repy_thisSolitr(all_regi,"modelstat") = remindgamsmodel.modelstat;
    p80_repy_thisSolitr(all_regi,"resusd")    = remindgamsmodel.resusd;
    p80_repy_thisSolitr(all_regi,"objval")    = remindgamsmodel.objval;
    if (p80_repy_thisSolitr(all_regi,"modelstat") eq 2,
      p80_repyLastOptim(all_regi,"objval") = p80_repy_thisSolitr(all_regi,"objval");
    );
  );

  regi(all_regi) = NO;
  p80_handle(all_regi) = remindgamsmodel.handle;
);  !! close regi loop

if(cm_nash_mode eq 2,
repeat
  loop (all_regi$handlecollect(p80_handle(all_regi)),
    p80_repy_thisSolitr(all_regi,"solvestat") = remindgamsmodel.solvestat;
    p80_repy_thisSolitr(all_regi,"modelstat") = remindgamsmodel.modelstat;
    p80_repy_thisSolitr(all_regi,"resusd")    = remindgamsmodel.resusd;
    p80_repy_thisSolitr(all_regi,"objval")    = remindgamsmodel.objval;

    if (p80_repy_thisSolitr(all_regi,"modelstat") eq 2,
      p80_repyLastOptim(all_regi,"objval") = p80_repy_thisSolitr(all_regi,"objval");
    );

    display$handledelete(p80_handle(all_regi)) "trouble deleting handles" ;
    p80_handle(all_regi) = 0
  );
  display$sleep(5) "sleep some time";
until card(p80_handle) = 0;
);

regi(all_regi) = YES;

*** internal nash helper paramter:
pm_SolNonInfes(regi) = 0;
p80_SolNonOpt(regi)  = 0;

putclose foo_msg;  
*** This putclose serves to make foo_msg the last "active" put file, and thus makes GAMS use the foo_msg formating (namely F-format, not scientific E-format)
*** Otherwise, the following put messages will try to write modelstat in scientif format, throwing errors because of insufficient space

loop (regi,
  if( (p80_repy_thisSolitr(regi,"solvestat") > 0) ,
    put_utility foo_msg "msg" / "Solitr:" sol_itr.tl:2:0 " " regi.tl:4:0 "     updated. Modstat new " p80_repy_thisSolitr(regi,"modelstat"):2:0 ", old " p80_repy(regi,"modelstat"):2:0 "; Resusd new" p80_repy_thisSolitr(regi,"resusd"):5:0 ", old" p80_repy(regi,"resusd"):5:0 "; Obj new" p80_repy_thisSolitr(regi,"objval"):7:3 ", old" p80_repy(regi,"objval"):7:3 ;
    p80_repy(regi,solveinfo80) = p80_repy_thisSolitr(regi,solveinfo80); !! copy info from this Solitr into p80_repy
  else
    put_utility foo_msg "msg" / "Solitr:" sol_itr.tl:2:0 " " regi.tl:4:0 " not updated. Modstat new " p80_repy_thisSolitr(regi,"modelstat"):2:0 ", old " p80_repy(regi,"modelstat"):2:0 "; Resusd new" p80_repy_thisSolitr(regi,"resusd"):5:0 ", old" p80_repy(regi,"resusd"):5:0 "; Obj new" p80_repy_thisSolitr(regi,"objval"):7:3 ", old" p80_repy(regi,"objval"):7:3 ;
  );

  if (p80_repy(regi,"modelstat") eq 2 OR p80_repy(regi,"modelstat") eq 7,
    pm_SolNonInfes(regi) = 1;
  );
  if (p80_repy(regi,"modelstat") eq 7, 
    p80_SolNonOpt(regi) = 1);
);

*** set o_modelstat to the highest value across all regions
o_modelstat
$ifthen.repeatNonOpt "%cm_repeatNonOpt%" == "off"
  = smax(regi, p80_repy(regi,"modelstat")$(p80_repy(regi,"modelstat") ne 7));  !! ignoring status 7 
$else.repeatNonOpt
  = smax(regi, p80_repy(regi,"modelstat"));                                    !! also taking into account status 7
$endif.repeatNonOpt

!! add information if this region was solved in this iteration
p80_repy_iteration(regi,solveinfo80,iteration)$(
                                         p80_repy_thisSolitr(regi,solveinfo80) )
    !! store sum of resusd for all sol_itrs
  = ( p80_repy_iteration(regi,solveinfo80,iteration)
    + p80_repy_thisSolitr(regi,solveinfo80)$( 
                                   p80_repy_thisSolitr(regi,solveinfo80) ne NA )
    )$( sameas(solveinfo80,"resusd") )
  + p80_repy_thisSolitr(regi,solveinfo80)$( NOT sameas(solveinfo80,"resusd") );

!! add information if this region was solved in this iteration
p80_repy_nashitr_solitr(regi,solveinfo80,iteration,sol_itr)$(
                                         p80_repy_thisSolitr(regi,solveinfo80) )
  = p80_repy_thisSolitr(regi,solveinfo80);

put_utility "msg" / "Solve overview: The following are the results for iteration " iteration.tl:3:0  " , sol_itr " sol_itr.tl:3:0 ;
display o_modelstat;
display p80_repy;
display p80_repy_thisSolitr;
display p80_repy_iteration;
display p80_repy_nashitr_solitr;


*** EOF ./modules/80_optimization/nash/solve.gms
