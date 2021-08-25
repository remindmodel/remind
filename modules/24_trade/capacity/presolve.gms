*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/presolve.gms

pm_Xport0(ttot,regi,tradePe) = vm_Xport.l(ttot,regi,tradePe);

***-------------------------------------------------------------------------------
***                        PREPARING THE TRADE MODEL
***-------------------------------------------------------------------------------

*** get Mports and Xports from REMIND
pm_Xport(ttot,regi,tradeSe) = vm_Xport.l(ttot,regi,tradeSe);
pm_Mport(ttot,regi,tradeSe) = vm_Mport.l(ttot,regi,tradeSe);

pm_Xport_effective(ttot,regi,tradeSe)$( sum(regi2,pm_Xport(ttot,regi2,tradeSe)) )
 = pm_Xport(ttot,regi,tradeSe)
 + sum(regi2,pm_Mport(ttot,regi2,tradeSe) - pm_Xport(ttot,regi2,tradeSe))
 * pm_Xport(ttot,regi,tradeSe) / sum(regi2,pm_Xport(ttot,regi2,tradeSe))
;

pm_XMport_pipeline(regi,regi2,'pegas') = 0.0;
pm_XMport_pipeline('MEA','EUR','pegas') = 0.100;
pm_XMport_pipeline('REF','EUR','pegas') = 0.150;

*** prices
pm_XPortsPrice(t,regi,'pegas') = p_PEPrice(t,regi,'pegas');
pm_XPortsPrice(t,regi,'pecoal') = p_PEPrice(t,regi,'pecoal');
***this will need fixing and has to become something more like this: pm_XPortsPrice(t,regi,tradeSe) = p_PEPrice(t,regi,tradeSe) or pm_SEPrice(t,regi,tradeSe);

*** Setting Xport price bound to avoid unrealists trading prices.
*** Lower bound: avoiding epsilon values (caused by using equation marginals for setting prices) or unrealistic small value for H2 exporting prices -> minimun price = 1$/kg (1$/kg = 0.030769231 $/Kwh = 0.030769231 / (10^12/10^9*8760) T$/TWa = 0.26953846356 T$/TWa) 
***pm_XPortsPrice(t,regi,"seh2") = min(0.26953846356,pm_XPortsPrice(t,regi,"seh2"));



***-------------------------------------------------------------------------------
***                               TRADE MODEL BOUNDS
***-------------------------------------------------------------------------------

*** positive variables
v24_shipment_quan.lo(ttot,all_regi,all_regi,tradeModes) = 0.0;
v24_cap_tradeTransp.lo(ttot,all_regi,all_regi,teTrade) = 0.0;
v24_deltaCap_tradeTransp.lo(ttot,all_regi,all_regi,teTrade) = 0.0;

*** shipments constrained: no self-imports or self-exports
v24_shipment_quan.fx(ttot,regi,regi2,tradeModes)$sameAs(regi,regi2) = 0.0;

*** trade capacity for terminals lives on the diagonal
v24_cap_tradeTransp.fx(ttot,regi,regi2,teTradeXportonly)$(not sameAs(regi,regi2)) = 0.0;
v24_cap_tradeTransp.fx(ttot,regi,regi2,teTradeMportonly)$(not sameAs(regi,regi2)) = 0.0;

*** fix initial capacities for pegas
v24_cap_tradeTransp.fx(ttot,regi,regi2,'gas_pipe')$(pm_ttot_val(ttot) eq cm_startyear) = pm_XMport_pipeline(regi,regi2,'pegas');
v24_cap_tradeTransp.fx(ttot,regi,regi,'lng_liq')$(pm_ttot_val(ttot) eq cm_startyear) = pm_Xport_effective(ttot,regi,'pegas')-sum(regi2,pm_XMport_pipeline(regi,regi2,'pegas'));
v24_cap_tradeTransp.fx(ttot,regi,regi,'lng_gas')$(pm_ttot_val(ttot) eq cm_startyear) = pm_Mport(ttot,regi,'pegas')-sum(regi2,pm_XMport_pipeline(regi2,regi,'pegas'));

*** shipments constrained: trade only allowed between defined regions
v24_shipment_quan.fx(ttot,regi,regi2,tradeModes)$(p24_disallowed(regi,regi2,tradeModes) gt 0.0) = 0.0;



***-------------------------------------------------------------------------------
***                        SOLVING THE TRADE MODEL
***-------------------------------------------------------------------------------

*** switching trade model equations on during trade model solve
s24_switch_trademodel = 1;
vm_tradeBudget_Mporter.lo(ttot,all_regi) = 0.0;
vm_tradeBudget_Mporter.up(ttot,all_regi) = inf;
vm_tradeBudget_Xporter.lo(ttot,all_regi) = 0.0;
vm_tradeBudget_Xporter.up(ttot,all_regi) = inf;

SOLVE m24_tradeTransp USING lp MINIMIZING v24_objvar_opttransp;
display v24_objvar_opttransp.l;

*** saving results to iteration variables
p24_Xport_iter(iteration,t,regi,tradeSe) = vm_Xport.l(t,regi,tradeSe);
p24_Mport_iter(iteration,t,regi,tradeSe) = vm_Mport.l(t,regi,tradeSe);
p24_shipment_quan_iter(iteration,t,regi,regi2,tradeModes) = v24_shipment_quan.l(t,regi,regi2,tradeModes);
p24_cap_tradeTransp_iter(iteration,t,regi,regi2,teTrade) = v24_cap_tradeTransp.l(t,regi,regi2,teTrade);

*** switching trade model equations back off
s24_switch_trademodel = 0;
vm_tradeBudget_Mporter.fx(ttot,all_regi) = 0.0;
vm_tradeBudget_Xporter.fx(ttot,all_regi) = 0.0;

*** EOF ./modules/24_trade/capacity/presolve.gms
