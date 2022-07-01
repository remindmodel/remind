*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/postsolve.gms

pm_Xport0(ttot,regi,tradePe) = vm_Xport.l(ttot,regi,tradePe);

***-------------------------------------------------------------------------------
***                    SAVING RESULTS TO ITERATION VARIABLES
***-------------------------------------------------------------------------------
p24_Xport_iter(iteration,t,regi,tradeCap) = vm_Xport.l(t,regi,tradeCap);
p24_Mport_iter(iteration,t,regi,tradeCap) = vm_Mport.l(t,regi,tradeCap);
p24_trade_iter(iteration,t,regi,regi2,tradeModes) = v24_trade.l(t,regi,regi2,tradeModes);
p24_capTrade_iter(iteration,t,regi,regi2,teTrade) = v24_capTrade.l(t,regi,regi2,teTrade);
p24_XPortsPrice_iter(iteration,t,regi,tradeCap) = pm_PEPrice(t,regi,tradeCap);

*** EOF ./modules/24_trade/capacity/postsolve.gms
