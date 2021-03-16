*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/equations.gms

*gl*
*' For Nash solution: intertemporal trade balance must be zero (couple in agricultural trade costs: pvp deflator * net export)
q80_budg_intertemp(regi)..
0 =e= pm_nfa_start(regi) * pm_pvp("2005","good")
  + SUM(ttot$(ttot.val ge 2005),
     pm_ts(ttot)
      * (
        SUM(trade$(NOT tradeSe(trade)),
              (vm_Xport(ttot,regi,trade) - vm_Mport(ttot,regi,trade)) * pm_pvp(ttot,trade)
           * ( 1 +  sm_fadeoutPriceAnticip*p80_etaXp(trade)
                   * ( (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) - (vm_Xport(ttot,regi,trade) - vm_Mport(ttot,regi,trade))
                   - p80_taxrev0(ttot,regi)$(ttot.val gt 2005)$(sameas(trade,"good")) + vm_taxrev(ttot,regi)$(ttot.val gt 2005)$(sameas(trade,"good"))
		     )
                   / (p80_normalize0(ttot,regi,trade) + sm_eps)
              )
        )
	  + pm_pvp(ttot,"good") * pm_NXagr(ttot,regi)
      )
    );


*' quadratic adjustment costs, penalizing deviations from the trade pattern of the last iteration.
q80_costAdjNash(ttot,regi)$( ttot.val ge cm_startyear ) ..
  vm_costAdjNash(ttot,regi) 
  =e= sum(trade$(NOT tradeSe(trade)),
        pm_pvp(ttot,trade) 
      * p80_etaAdj(trade)
      * ( (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) 
        - (vm_Xport(ttot,regi,trade)  - vm_Mport(ttot,regi,trade))
        )
      * ( (pm_Xport0(ttot,regi,trade) - p80_Mport0(ttot,regi,trade)) 
        - (vm_Xport(ttot,regi,trade)  - vm_Mport(ttot,regi,trade))
        )
      / (p80_normalize0(ttot,regi,trade) + sm_eps)
      )
;

*** mlb 20150324
*' link between permit budget and  emission budget
q80_budgetPermRestr(regi)$(cm_emiscen=6) ..
     sum(ttot$(ttot.val lt sm_endBudgetCO2eq and ttot.val ge cm_startyear), pm_ts(ttot)* vm_perm(ttot,regi))
     + sum(ttot$(ttot.val eq sm_endBudgetCO2eq),pm_ts(ttot)/2 * (vm_perm(ttot,regi)))  =l=
     pm_budgetCO2eq(regi) - sum(ttot $((ttot.val ge 2005) and (ttot.val lt cm_startyear)), pm_ts(ttot)* vm_co2eq(ttot,regi));

*** EOF ./modules/80_optimization/nash/equations.gms
