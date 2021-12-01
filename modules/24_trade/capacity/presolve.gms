*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/presolve.gms

pm_Xport0(ttot,regi,tradePe) = vm_Xport.l(ttot,regi,tradePe);

***-------------------------------------------------------------------------------
***                          PREPARING THE TRADE MODEL
***-------------------------------------------------------------------------------
*** get Mports and Xports from REMIND
p24_Xport(ttot,regi,tradeCap) = vm_Xport.l(ttot,regi,tradeCap);
p24_Mport(ttot,regi,tradeCap) = vm_Mport.l(ttot,regi,tradeCap);

*** compute effective Xports to match total Mports
p24_XportEff(ttot,regi,tradeCap)$( sum(regi2,p24_Xport(ttot,regi2,tradeCap)) )
 = p24_Xport(ttot,regi,tradeCap)
 + sum(regi2,p24_Mport(ttot,regi2,tradeCap) - p24_Xport(ttot,regi2,tradeCap))
 * p24_Xport(ttot,regi,tradeCap) / sum(regi2,p24_Xport(ttot,regi2,tradeCap))
;

*** set some pegas pipeline capacity
p24_XMportPipe(regi,regi2,'pegas') = 0.0;
p24_XMportPipe('MEA','EUR','pegas') = 0.100;
p24_XMportPipe('REF','EUR','pegas') = 0.150;

*** prices
pm_XPortsPrice(t,regi,'pegas') = pm_PEPrice(t,regi,'pegas');
pm_XPortsPrice(t,regi,'pecoal') = pm_PEPrice(t,regi,'pecoal');
***this will need fixing and has to become something more like this: pm_XPortsPrice(t,regi,tradeCap) = pm_PEPrice(t,regi,tradeCap) or pm_SEPrice(t,regi,tradeCap);

*** Setting Xport price bound to avoid unrealists trading prices.
*** Lower bound: avoiding epsilon values (caused by using equation marginals for setting prices) or unrealistic small value for H2 exporting prices -> minimun price = 1$/kg (1$/kg = 0.030769231 $/Kwh = 0.030769231 / (10^12/10^9*8760) T$/TWa = 0.26953846356 T$/TWa) 
***pm_XPortsPrice(t,regi,"seh2") = min(0.26953846356,pm_XPortsPrice(t,regi,"seh2"));

***-------------------------------------------------------------------------------
***                              TRADE MODEL BOUNDS
***-------------------------------------------------------------------------------
*** shipments constrained: no self-imports or self-exports
v24_trade.fx(ttot,regi,regi2,tradeModes)$sameAs(regi,regi2) = 0.0;

*** trade capacities for terminals live on the diagonal
v24_capTrade.fx(ttot,regi,regi2,teTradeXport)$(not sameAs(regi,regi2)) = 0.0;
v24_capTrade.fx(ttot,regi,regi2,teTradeMport)$(not sameAs(regi,regi2)) = 0.0;

*** fix initial capacities for pegas
v24_capTrade.fx(ttot,regi,regi2,'gas_pipe')$(pm_ttot_val(ttot) eq cm_startyear) = p24_XMportPipe(regi,regi2,'pegas');
v24_capTrade.fx(ttot,regi,regi,'lng_liq')$(pm_ttot_val(ttot) eq cm_startyear) = p24_XportEff(ttot,regi,'pegas')-sum(regi2,p24_XMportPipe(regi,regi2,'pegas'));
v24_capTrade.fx(ttot,regi,regi,'lng_gas')$(pm_ttot_val(ttot) eq cm_startyear) = p24_Mport(ttot,regi,'pegas')-sum(regi2,p24_XMportPipe(regi2,regi,'pegas'));

*** shipments constrained: trade only allowed between defined regions
v24_trade.fx(ttot,regi,regi2,tradeModes)$(p24_disallowed(regi,regi2,tradeModes) gt 0.0) = 0.0;

***-------------------------------------------------------------------------------
***                             SOLVING THE TRADE MODEL
***-------------------------------------------------------------------------------
*** switching trade model equations and vars on during trade model solve
s24_switchTradeModel = 1;
vm_budgetTradeM.lo(ttot,all_regi) = 0.0;
vm_budgetTradeM.up(ttot,all_regi) = inf;
vm_budgetTradeX.lo(ttot,all_regi) = 0.0;
vm_budgetTradeX.up(ttot,all_regi) = inf;

*** solving the trade model
SOLVE m24_tradeTransp USING lp MINIMIZING v24_tradeCostGlob;
display v24_tradeCostGlob.l;

*** saving results to iteration variables
p24_Xport_iter(iteration,t,regi,tradeCap) = vm_Xport.l(t,regi,tradeCap);
p24_Mport_iter(iteration,t,regi,tradeCap) = vm_Mport.l(t,regi,tradeCap);
p24_shipment_quan_iter(iteration,t,regi,regi2,tradeModes) = v24_trade.l(t,regi,regi2,tradeModes);
p24_cap_tradeTransp_iter(iteration,t,regi,regi2,teTrade) = v24_capTrade.l(t,regi,regi2,teTrade);

*** switching trade model equations and vars back off
s24_switchTradeModel = 0;
vm_budgetTradeM.fx(ttot,all_regi) = 0.0;
vm_budgetTradeX.fx(ttot,all_regi) = 0.0;

*** EOF ./modules/24_trade/capacity/presolve.gms
