*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/se_trade/equations.gms

q24_tradeBudget_Xporter(ttot,regi)..
    vm_tradeBudget_Xporter(ttot,regi)
  =e=
    sum(tradeSe, pm_XPortsPrice(ttot,regi,tradeSe) * vm_Xport(ttot,regi,tradeSe))
;

q24_tradeBudget_Mporter(ttot,regi)..
    vm_tradeBudget_Mporter(ttot,regi)
  =e=
    sum(tradeSe, pm_MPortsPrice(ttot,regi,tradeSe) * vm_Mport(ttot,regi,tradeSe))
;

*** EOF ./modules/24_trade/se_trade/equations.gms
