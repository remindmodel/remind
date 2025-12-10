*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/equations.gms

*' @equations

*' For Nash solution: intertemporal trade balance must be zero (couple in agricultural trade costs: pvp deflator * net export)
q80_budg_intertemp(regi)..
  0 =e=
  pm_nfa_start(regi) * pm_pvp("2005","good") !! net value foreign assets in 2005
+ sum(ttot $ (ttot.val >= 2005),
    pm_ts(ttot) !! duration of the time step (average between previous and next time steps)
  * ( pm_pvp(ttot,"good") * pm_NXagr(ttot,regi) !! net value agricultural exports
    + vm_capacityTradeBalance(ttot,regi) !! only active in 24_trade capacity mode
    + sum(trade $ (not tradeSe(trade) and not tradeCap(trade)),
        (vm_Xport(ttot,regi,trade) - vm_Mport(ttot,regi,trade)) * pm_pvp(ttot,trade) !! net value of exports
      * ( 1
        +   sm_fadeoutPriceAnticip * p80_etaXp(trade)
          * ( (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) - (vm_Xport(ttot,regi,trade) - vm_Mport(ttot,regi,trade))
              - (p80_taxrev0(ttot,regi) - vm_taxrev(ttot,regi)) $ (sameas(trade,"good") and ttot.val > 2005))
          / (p80_marketVolume(ttot,regi,trade) + sm_eps)
        )
      )
    )
  );

*' quadratic adjustment costs, penalizing deviations from the trade pattern of the last iteration.
q80_costAdjNash(ttot,regi) $ (ttot.val >= cm_startyear) ..
  vm_costAdjNash(ttot,regi)
  =e= sum(trade $ (not tradeSe(trade)),
        p80_etaAdj(trade)
      * pm_pvp(ttot,trade)
      * power((pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) - (vm_Xport(ttot,regi,trade)  - vm_Mport(ttot,regi,trade)), 2)
      / (p80_marketVolume(ttot,regi,trade) + sm_eps));

*' link between permit budget and emission budget
q80_budgetPermRestr(regi)$(cm_emiscen=6) ..
     sum(ttot$(ttot.val < sm_endBudgetCO2eq and ttot.val >= cm_startyear), pm_ts(ttot)* vm_perm(ttot,regi))
     + sum(ttot$(ttot.val = sm_endBudgetCO2eq),pm_ts(ttot)/2 * (vm_perm(ttot,regi)))  =l=
     pm_budgetCO2eq(regi) - sum(ttot $((ttot.val >= 2005) and (ttot.val < cm_startyear)), pm_ts(ttot)* vm_co2eq(ttot,regi));

*' @stop
*** EOF ./modules/80_optimization/nash/equations.gms
