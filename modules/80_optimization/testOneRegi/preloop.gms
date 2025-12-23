*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/preloop.gms

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
Execute_Loadpoint 'input' pm_capCumForeign = pm_capCumForeign;

loop(ttot $ (ttot.val >= 2005),
  loop(trade $ (not tradeSe(trade)),
*** initialise trade volumes from gdx, and set missing values to zero
    pm_Xport0(ttot,regi,trade)  = vm_Xport.l(ttot,regi,trade);
    p80_Mport0(ttot,regi,trade) = vm_Mport.l(ttot,regi,trade);

    p80_regiMarketVolume(ttot,regi,"good")  = vm_cons.l(ttot,regi);
    p80_regiMarketVolume(ttot,regi,"perm")  = abs(pm_shPerm(ttot,regi) * pm_emicapglob(ttot));
    p80_regiMarketVolume(ttot,regi,tradePe) = (sum(rlf, vm_fuExtr.l(ttot,regi,tradePe,rlf)) + vm_prodPe.l(ttot,regi,tradePe)) / 2;
    p80_regiMarketVolume(ttot,regi,trade)   = max(sm_eps, p80_regiMarketVolume(ttot,regi,trade)); !! ensure market volume is positive

    p80_taxrev0(ttot,regi) = vm_taxrev.l(ttot,regi);
	);
);

*** AJS: for resource with price zero, fall back to previous period in order to avoid convergence problems (seen for peur in 2150)
loop(ttot $ (ttot.val > 2005),
  pm_pvp(ttot,tradePe) $ (pm_pvp(ttot,tradePe) = 0) = pm_pvp(ttot-1,tradePe);
);

display "info: starting from this price path";
display pm_pvp;

display regi;

cm_solver_try_max = max(5, cm_solver_try_max)
*** EOF ./modules/80_optimization/testOneRegi/preloop.gms
