*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/equations.gms

*' @equations

*' for Nash solution: intertemporal trade balance must be zero
q80_budg_intertemp(regi).. 
0 =e=  
 SUM(ttot$(ttot.val ge 2005), 
    pm_ts(ttot) 
       * SUM(trade$(NOT tradeSe(trade)), 
              (vm_Xport(ttot,regi,trade)-vm_Mport(ttot,regi,trade)) * pm_pvp(ttot,trade)
              * ( 1 +  p80_etaXp(trade)
                   * ( (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) - (vm_Xport(ttot,regi,trade) - vm_Mport(ttot,regi,trade)) )
                   / (p80_normalize0(ttot,regi,trade) + 1E-6)
                )
            ) 
    );  

q80_costAdjNash(ttot,regi)$(ttot.val ge cm_startyear)..
vm_costAdjNash(ttot,regi) =e= 0;
     
*** EOF ./modules/80_optimization/testOneRegi/equations.gms
