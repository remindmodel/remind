*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/solve.gms

hybrid.optfile = 9;
$IF %cm_quick_mode% == "on" hybrid.optfile = 4;

***reduce the problem to one region
regi(all_regi) = NO;
regi(regi_dyn80) = YES;


***      -------------------------------------------------------------------
***                     SOLVE statement
***      -------------------------------------------------------------------
option
  limrow = 2147483647
  limcol = 2147483647
  solprint = on
;

if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

if (cm_keep_presolve_gdxes eq 1,
  sm_tmp  = logfile.nr;
  sm_tmp2 = logfile.nd;
  logfile.nr = 1;
  logfile.nd = 0;
  loop (regi,
    execute_unload "presolve_tOR.gdx";
    put_utility logfile, "shell" /
      "mv presolve_tOR.gdx presolve_tOR_" regi.tl "_CES-" sm_CES_calibration_iteration "_Nash-" iteration.val "_Sol-" sol_itr.val ".gdx";
  );
  logfile.nr = sm_tmp;
  logfile.nd = sm_tmp2;
);

solve hybrid using nlp maximizing vm_welfareGlob;

o_modelstat = hybrid.modelstat;
display o_modelstat;

***helper parameter to access regional solution status
pm_SolNonInfes(regi) = 0;
loop(regi,
if((o_modelstat eq 2),
 pm_SolNonInfes(regi) = 1;
  );
);


*LB*AJS* Activate all regions again, otherwise the reporting will fail.
***Warning: All reported values from regions except regi_dyn80 are just dummies ! 
regi(all_regi) = YES;
*** EOF ./modules/80_optimization/testOneRegi/solve.gms

