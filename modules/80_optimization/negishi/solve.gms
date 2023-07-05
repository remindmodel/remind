*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi/solve.gms

hybrid.optfile = s80_cnptfile;

***      -------------------------------------------------------------------
***                     SOLVE statement
***      -------------------------------------------------------------------
if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve hybrid using nlp maximizing vm_welfareGlob;
o_modelstat = hybrid.modelstat;

*this parameter is especially useful in nash mode
pm_SolNonInfes(regi) = 0;
if(o_modelstat eq 2,
    pm_SolNonInfes(regi) = 1;
    );
***      -------------------------------------------------------------------


IF(o_modelstat eq 2, 
*AJS*2013-05* Default Negishi convergence scheme:
    if (ord(iteration) eq 1, s80_cnptfile = 2); !! rtredg = 1.d-6
    if (ord(iteration) eq 2, s80_cnptfile = 3); !! rtredg = 1.d-7
    if (ord(iteration) eq 3, s80_cnptfile = 3); !! rtredg = 1.d-7
    if (ord(iteration) eq 4, s80_cnptfile = 3); !! rtredg = 1.d-7
);
*** EOF ./modules/80_optimization/negishi/solve.gms

