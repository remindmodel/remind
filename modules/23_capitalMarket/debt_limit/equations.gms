*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/23_capitalMarket/debt_limit/equations.gms

q23_limit_debt_growth(t,regi)..
  vm_cesIO(t,regi,"inco") * p23_debt_growthCoeff(regi)
  =g=
  vm_Mport(t,regi,"good") - vm_Xport(t,regi,"good") 
  + sum(tradePe, (pm_pvp(t,tradePe)/(pm_pvp(t,"good")+0.000000001))*(vm_Mport(t,regi,tradePe)- vm_Xport(t,regi,tradePe))) 
  + (pm_pvp(t,"perm")/(pm_pvp(t,"good")+0.000000001)) * (vm_Mport(t,regi,"perm") - vm_Xport(t,regi,"perm"))
  + sum(tradeSe, pm_MPortsPrice(t,regi,tradeSe) * vm_Mport(t,regi,tradeSe)) - sum(tradeSe, pm_XPortsPrice(t,regi,tradeSe) * vm_Xport(t,regi,tradeSe))
;

q23_limit_surplus_growth(t,regi)..
  -1.0 * vm_cesIO(t,regi,"inco") * p23_debt_growthCoeff(regi)
  =l=
  vm_Mport(t,regi,"good") - vm_Xport(t,regi,"good") 
  + sum(tradePe, (pm_pvp(t,tradePe)/(pm_pvp(t,"good")+0.000000001))*(vm_Mport(t,regi,tradePe)- vm_Xport(t,regi,tradePe))) 
  + (pm_pvp(t,"perm")/(pm_pvp(t,"good")+0.000000001)) * (vm_Mport(t,regi,"perm") - vm_Xport(t,regi,"perm"))
  + sum(tradeSe, pm_MPortsPrice(t,regi,tradeSe) * vm_Mport(t,regi,tradeSe)) - sum(tradeSe, pm_XPortsPrice(t,regi,tradeSe) * vm_Xport(t,regi,tradeSe)) 
;

*** EOF ./modules/23_capitalMarket/debt_limit/equations.gms
