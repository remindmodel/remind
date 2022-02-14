*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/solve.gms

hybrid.optfile = 9;

***reduce the problem to one region
regi(all_regi) = NO;
regi(regi_dyn80) = YES;


***      -------------------------------------------------------------------
***                     SOLVE statement
***      -------------------------------------------------------------------
option
  limrow = 10000000
  limcol = 10000000
  solprint = on
;

if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
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

*** if solution infes, write abort.gdx
if(NOT(o_modelstat eq 2),
  execute_unload "abort.gdx";
);

*LB*AJS* Activate all regions again, otherwise the reporting will fail.
***Warning: All reported values from regions except regi_dyn80 are just dummies ! 
regi(all_regi) = YES;
*** EOF ./modules/80_optimization/testOneRegi/solve.gms

