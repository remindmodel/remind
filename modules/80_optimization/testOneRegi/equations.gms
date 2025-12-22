*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/equations.gms

*' @equations

*' Intertemporal trade balance must be zero. Terms are:
*' sum over all time steps of (time step duration * net exports in this time step):
*'   difference of net exports compared to previous iteration, adjusted for price anticipation
q80_budg_intertemp(regi)..
  0 =e=
  sum(ttot $ (ttot.val >= 2005),
    pm_ts(ttot) !! duration of the time step (average between previous and next time steps)
  * ( vm_capacityTradeBalance(ttot,regi) !! trade balance for 24_trade capacity realisation
    + sum(trade $ (not tradeSe(trade) and not tradeCap(trade)),
        (vm_Xport(ttot,regi,trade) - vm_Mport(ttot,regi,trade)) * pm_pvp(ttot,trade) !! net value of exports
      * ( 1 + p80_priceAnticipStrength(trade)
          * ( (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) - (vm_Xport(ttot,regi,trade) - vm_Mport(ttot,regi,trade)) )
          / p80_regiMarketVolume(ttot,regi,trade)
        )
      )
    )
  );


q80_costAdjNash(ttot,regi) $ (ttot.val ge cm_startyear)..
   vm_costAdjNash(ttot,regi) =e= 0;
     
*** EOF ./modules/80_optimization/testOneRegi/equations.gms
