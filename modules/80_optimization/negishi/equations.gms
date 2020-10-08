*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi/equations.gms

*** trade balances for resources, goods, permits
q80_balTrade(t,trade(enty))..
    SUM(regi,  vm_Xport(t,regi,trade) - vm_Mport(t,regi,trade)) =e= 0;


*AJS initialize helper eqn. any way to get around this?
q80_budget_helper(t,regi)..
    1
    =g=
    1
;
*** EOF ./modules/80_optimization/negishi/equations.gms
