*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/preloop.gms

*** MLB/AG: for Nash algorithm read initial price data from gdx
Execute_Loadpoint 'input' pm_pvp      = pm_pvp;
Execute_Loadpoint 'input' vm_Xport.l  = vm_Xport.l;
Execute_Loadpoint 'input' vm_Mport.l  = vm_Mport.l;
Execute_Loadpoint 'input' vm_cons.l   = vm_cons.l;
Execute_Loadpoint 'input' vm_taxrev.l = vm_taxrev.l;
Execute_Loadpoint 'input' vm_fuExtr.l = vm_fuExtr.l;
Execute_Loadpoint 'input' vm_prodPe.l = vm_prodPe.l;

*** assign fake values for p80_repyLastOptim which gets initialised in the loop
p80_repyLastOptim(regi,solveinfo80) = NA;

*** AJS: initialize starting points for prices, trade volumes etc. from gdx.
*** In order to read parameters like p80_priceXXX from a gdx, instead of only variables, we have to explicitly instruct gams to do so
*** using execute_loadpoint in core/preloop.gms. The price paths are the trickiest part. Try to find p80_priceXXX prices in the gdx first,
*** if that fails, fallback to price path read from input/prices_NASH.inc
loop(ttot $ (ttot.val >= 2005),
  loop(trade $ (not tradeSe(trade)),
    if(pm_pvp(ttot,trade) = NA or pm_pvp(ttot,trade) < 1e-12 or pm_pvp(ttot,trade) > 0.1, !! in case price paths from the gdx are not valid
      pm_pvp(ttot,trade) = p80_pvpFallback(ttot,trade);
      display 'Nash: Info: Could not load useful initial price from gdx, falling back to the one found in input/prices_NASH.inc. This should not be a problem, the runs can stil converge. ';
    );

    if(pm_pvp(ttot,trade) = NA, pm_pvp(ttot,trade) = 0;); !! in case pm_pvp is not found in gdx

    loop(regi,	  
      pm_Xport0(ttot,regi,trade)  = vm_Xport.l(ttot,regi,trade);
      p80_Mport0(ttot,regi,trade) = vm_Mport.l(ttot,regi,trade);
      
      if(pm_Xport0(ttot,regi,trade) = NA, !! in case export is not found in gdx
        pm_Xport0(ttot,regi,trade) = 0;
        vm_Xport.L(ttot,regi,trade) = 0;
      );
      if(p80_Mport0(ttot,regi,trade) = NA, !! in case import is not found in gdx
        p80_Mport0(ttot,regi,trade) = 0;
        vm_Mport.L(ttot,regi,trade) = 0;
      );
      p80_marketVolume(ttot,regi,"good") = vm_cons.l(ttot,regi);
      p80_marketVolume(ttot,regi,"perm") $ (ttot.val >= 2005) = max(abs(pm_shPerm(ttot,regi) * pm_emicapglob(ttot)) , 1e-6);
      p80_marketVolume(ttot,regi,tradePe) = (sum(rlf, vm_fuExtr.l(ttot,regi,tradePe,rlf)) + vm_prodPe.l(ttot,regi,tradePe)) / 2;

      p80_taxrev0(ttot,regi) = vm_taxrev.l(ttot,regi);
    );
  );
);
p80_Mport0("2005",regi,tradePe) $ (p80_Mport0("2005",regi,tradePe) = NA) = 0;

*** AJS: starting policy runs from permit prices that are all zero does not work; start from 30$ price path instead
if(cm_emiscen ne 1 and cm_emiscen ne 9 and smax(t, pm_pvp(t,"perm")) = 0,
  pm_pvp("2005","perm") = 0;
  loop(ttot $ (ttot.val > 2005),
    pm_pvp(ttot,"perm") = 0.11 * 1.05**(ttot.val - 2020) * pm_pvp(ttot,"good"); !! this is a 30$/tCo2eq in 2020 trajectory
  );
);

*** if there is no permit trade, set the price to zero
pm_pvp(ttot,"perm") $ (cm_emiscen = 1 or cm_emiscen = 9) = 0;

p80_pvp_itr(ttot,trade,"1") $ (not tradeSe(trade)) = pm_pvp(ttot,trade);

*** AJS: Take care of resource prices that were imported as zero (as seen for 2150, peur), as they cause problems in the covergence process.
*** Default to last periods price:
loop(ttot $ (not sameas(ttot,"2005")),
  p80_pvp_itr(ttot,tradePe,"1") $ (p80_pvp_itr(ttot,tradePe,"1") = 0) = p80_pvp_itr(ttot-1,tradePe,"1");
);

*** debug display
display pm_pvp,p80_marketVolume;
display pm_Xport0,p80_Mport0;
display p80_surplusMaxTolerance;

*** EMIOPT
$ifthen.emiopt %emicapregi% == 'none' 
if(cm_emiscen = 6,
  pm_budgetCO2eq(regi) = pm_shPerm("2050",regi) * sm_budgetCO2eqGlob;
  display pm_shPerm, sm_budgetCO2eqGlob, pm_budgetCO2eq;
);
$endif.emiopt

*** EOF ./modules/80_optimization/nash/preloop.gms
