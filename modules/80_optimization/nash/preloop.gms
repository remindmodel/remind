*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/preloop.gms

***------------------------------------------------------------------------------
*** Use gdx to initialise prices, trade volumes etc
***------------------------------------------------------------------------------

*** read data from gdx with explicit instruction execute_loadpoint
Execute_Loadpoint 'input' pm_pvp      = pm_pvp;
Execute_Loadpoint 'input' vm_Xport.l  = vm_Xport.l;
Execute_Loadpoint 'input' vm_Mport.l  = vm_Mport.l;
Execute_Loadpoint 'input' vm_cons.l   = vm_cons.l;
Execute_Loadpoint 'input' vm_taxrev.l = vm_taxrev.l;
Execute_Loadpoint 'input' vm_fuExtr.l = vm_fuExtr.l;
Execute_Loadpoint 'input' vm_prodPe.l = vm_prodPe.l;

loop(ttot $ (ttot.val >= 2005),
  loop(trade $ (not tradeSe(trade)),
*** in case price paths from the gdx are not valid, fall back to prices read from input/prices_NASH.inc
    if(pm_pvp(ttot,trade) = NA or pm_pvp(ttot,trade) < 1e-12 or pm_pvp(ttot,trade) > 0.1,
      pm_pvp(ttot,trade) = p80_pvpFallback(ttot,trade);
      display 'Nash: Info: Could not load useful initial price from gdx, falling back to the one found in input/prices_NASH.inc. This should not be a problem, the runs can stil converge. ';
    );

*** initialise trade volumes from gdx, and set missing values to zero
    pm_Xport0(ttot,regi,trade)  = vm_Xport.l(ttot,regi,trade);
    p80_Mport0(ttot,regi,trade) = vm_Mport.l(ttot,regi,trade);
    pm_Xport0(ttot,regi,trade)  $ (pm_Xport0(ttot,regi,trade) = NA) = 0;
    vm_Xport.l(ttot,regi,trade) $ (pm_Xport0(ttot,regi,trade) = NA) = 0;
    p80_Mport0(ttot,regi,trade) $ (p80_Mport0(ttot,regi,trade) = NA) = 0;
    vm_Mport.l(ttot,regi,trade) $ (p80_Mport0(ttot,regi,trade) = NA) = 0;

*** initialise market volume for different trades; has to match calculation in nash/postsolve
    p80_regiMarketVolume(ttot,regi,"good")  = vm_cons.l(ttot,regi);
    p80_regiMarketVolume(ttot,regi,"perm")  = abs(pm_shPerm(ttot,regi) * pm_emicapglob(ttot));
    p80_regiMarketVolume(ttot,regi,tradePe) = (sum(rlf, vm_fuExtr.l(ttot,regi,tradePe,rlf)) + vm_prodPe.l(ttot,regi,tradePe)) / 2;
    p80_regiMarketVolume(ttot,regi,trade)   = max(sm_eps, p80_regiMarketVolume(ttot,regi,trade)) !! ensure market volume is positive

    p80_taxrev0(ttot,regi) = vm_taxrev.l(ttot,regi);
  );
);

*** AJS: starting policy runs from permit prices that are all zero does not work; start from 30$ price path instead
if(cm_emiscen ne 1 and cm_emiscen ne 9 and smax(t, pm_pvp(t,"perm")) = 0,
  pm_pvp("2005","perm") = 0;
  loop(ttot $ (ttot.val > 2005),
    pm_pvp(ttot,"perm") = 0.11 * 1.05**(ttot.val - 2020) * pm_pvp(ttot,"good"); !! this is a 30$/tCo2eq in 2020 trajectory
  );
);
*** if there is no permit trade, set the price to zero
pm_pvp(ttot,"perm") $ (cm_emiscen = 1 or cm_emiscen = 9) = 0;

*** AJS: for resource with price zero, fall back to previous period in order to avoid convergence problems (seen for peur in 2150)
loop(ttot $ (ttot.val > 2005),
  pm_pvp(ttot,tradePe) $ (pm_pvp(ttot,tradePe) = 0) = pm_pvp(ttot-1,tradePe);
);

*** save prices of the first iteration
p80_pvp_itr(ttot,trade,"1") $ (not tradeSe(trade)) = pm_pvp(ttot,trade);

*** debug display
display pm_pvp,p80_regiMarketVolume;
display pm_Xport0,p80_Mport0;
display p80_surplusMaxTolerance;

*** assign fake values for p80_repyLastOptim which gets initialised in nash/solve
p80_repyLastOptim(regi,solveinfo80) = NA;

*** EMIOPT
$ifthen.emiopt %emicapregi% == 'none' 
if(cm_emiscen = 6,
  pm_budgetCO2eq(regi) = pm_shPerm("2050",regi) * sm_budgetCO2eqGlob;
  display pm_shPerm, sm_budgetCO2eqGlob, pm_budgetCO2eq;
);
$endif.emiopt

*** EOF ./modules/80_optimization/nash/preloop.gms
