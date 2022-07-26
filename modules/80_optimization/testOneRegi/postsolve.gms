*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/postsolve.gms

o_iterationNumber = iteration.val;

*AJS* feed updated prices and quantities into the next iteration:
loop(trade$(NOT tradeSe(trade)),
    loop(regi,
    loop(ttot$(ttot.val ge cm_startyear),
        pm_Xport0(ttot,regi,trade)$(pm_SolNonInfes(regi) eq 1)  = vm_Xport.l(ttot,regi,trade);
        p80_Mport0(ttot,regi,trade)$(pm_SolNonInfes(regi) eq 1) = vm_Mport.l(ttot,regi,trade);
    );
    );
);

*** Save FE prices in each iteration for easier monitoring
pm_FEPrice_iter(iteration,t,regi,enty,sector,emiMkt) =
  pm_FEPrice(t,regi,enty,sector,emiMkt);

*-----------------------------------------------------------------------------------------------
*** EOF ./modules/80_optimization/testOneRegi/postsolve.gms
