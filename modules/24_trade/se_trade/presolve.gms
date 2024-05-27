*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/se_trade/presolve.gms

pm_Xport0(ttot,regi,tradePe) = vm_Xport.l(ttot,regi,tradePe);

vm_costTradeCap.fx(ttot,all_regi,tradeCap) = 0.0;
vm_capacityTradeBalance.fx(ttot,all_regi) = 0.0;

*** Secondary energy trade

*** Temporarily forcing Mports (until all bugs are fixed with automatic trading)
vm_Mport.fx(t,regi,entySe)$(sum(regi2,p24_seTradeCapacity(t,regi2,regi,entySe)) gt 0) = sum(regi2,p24_seTradeCapacity(t,regi2,regi,entySe));
vm_Mport.l(t,regi,entySe)$(sum(regi2,p24_seTradeCapacity(t,regi2,regi,entySe)) gt 0) = sum(regi2,p24_seTradeCapacity(t,regi2,regi,entySe));

*** Xport price
pm_XPortsPrice(t,regi,tradeSe) = pm_SEPrice(t,regi,tradeSe);

display pm_XPortsPrice;

*** Setting Xport price bound to avoid unrealists trading prices.
*** Lower bound: avoiding epsilon values (caused by using equation marginals for setting prices) or unrealistic small values for secondary energy prices
*** - H2 and seliqsyn exporting prices -> minimun price = 1$/kg (1$/kg = 0.0301 $/Kwh = 0.0301 / (10^12/10^9*8760) T$/TWa = 0.264 T$/TWa)
*** - seliqbio exporting prices -> minimun price = 5 US$2005/GJ (5/31.71 = 0.158 T$/TWa)
pm_XPortsPrice(t,regi,"seh2") = max(0.264, pm_XPortsPrice(t,regi,"seh2"));
pm_XPortsPrice(t,regi,"seliqsyn") = max(0.264, pm_XPortsPrice(t,regi,"seliqsyn"));
pm_XPortsPrice(t,regi,"seliqbio") = max(0.158, pm_XPortsPrice(t,regi,"seliqbio"));

display pm_XPortsPrice;

$ontext
*** Mports from where? Mports from regi to regi2, assuming that trade is distributed uniformetly according existent trade capacities
p24_MportsRegi(t,regi,regi2,tradeSe)$(p24_seTradeCapacity(t,regi2,regi,tradeSe)) =
  vm_Mport.l(t,regi,tradeSe)*
 (p24_seTradeCapacity(t,regi2,regi,tradeSe)/sum(regi3,p24_seTradeCapacity(t,regi3,regi,tradeSe)))
;

*** Xports quantitites as a result of Mports
p24_XportsRegi(t,regi,regi2,tradeSe) = p24_MportsRegi(t,regi2,regi,tradeSe);

*** Fixing exports for current iteration based on previous iteration trade results
vm_Xport.fx(t,regi,tradeSe) = sum(regi2, p24_XportsRegi(t,regi,regi2,tradeSe));

*** Mport price. Calculates the secondary energy price seen by the importing country as a weighted average of prices observed in countries with capacity to export (regi2) to the country (regi) and their existent capacity connections with the importing country
pm_MPortsPrice(t,regi,tradeSe)$(sum(regi2,p24_XportsRegi(t,regi2,regi,tradeSe)) gt 0) =
  sum(regi2$p24_seTradeCapacity(t,regi2,regi,tradeSe),
    pm_XPortsPrice(t,regi2,tradeSe)
    *(
      p24_XportsRegi(t,regi2,regi,tradeSe)
      /
      sum(regi3$p24_seTradeCapacity(t,regi3,regi,tradeSe), p24_XportsRegi(t,regi3,regi,tradeSe))
    )
  )
;
display p24_MportsRegi, p24_XportsRegi, 
$offtext

*** Temporarily forcing Xports (until all bugs are fixed with automatic trading)
vm_Xport.fx(t,regi,tradeSe)$(sum(regi2,p24_seTradeCapacity(t,regi,regi2,tradeSe)) gt 0)  = sum(regi2,p24_seTradeCapacity(t,regi,regi2,tradeSe));
vm_Xport.l(t,regi,tradeSe)$(sum(regi2,p24_seTradeCapacity(t,regi,regi2,tradeSe)) gt 0) = sum(regi2,p24_seTradeCapacity(t,regi,regi2,tradeSe));

*** Mport price. Calculates the secondary energy price seen by the importing country as a weighted average of prices observed in countries with capacity to export (regi2) to the country (regi) and their existent capacity connections with the importing country
pm_MPortsPrice(t,regi,tradeSe)$(sum(regi2,p24_seTradeCapacity(t,regi2,regi,tradeSe)) gt 0) =
  sum(regi2$p24_seTradeCapacity(t,regi2,regi,tradeSe),
    pm_XPortsPrice(t,regi2,tradeSe)
    *(
      p24_seTradeCapacity(t,regi,regi2,tradeSe)
      /
      sum(regi3$p24_seTradeCapacity(t,regi3,regi,tradeSe), p24_seTradeCapacity(t,regi3,regi,tradeSe))
    )
  )
;

display  p24_seTradeCapacity, pm_MPortsPrice, pm_SEPrice; 

*** EOF ./modules/24_trade/se_trade/presolve.gms
