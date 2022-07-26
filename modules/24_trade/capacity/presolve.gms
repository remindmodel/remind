*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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

*** Xport prices
pm_XPortsPrice(t,regi,tradeCap) = pm_PEPrice(t,regi,tradeCap);
***this will need fixing and has to become something more like this: pm_XPortsPrice(t,regi,tradeCap) = pm_PEPrice(t,regi,tradeCap) or pm_SEPrice(t,regi,tradeCap);

*** Xport quantities
if(iteration.val eq 1,
    p24_Xport(t,regi,tradeCap) = vm_Xport.l(t,regi,tradeCap);
else
    p24_Xport(t,regi,tradeCap) = sum(  (regi2,tradeEnty2Mode(tradeCap,tradeModes))$(not sameAs(regi,regi2)), v24_trade.l(t,regi,regi2,tradeModes)  );
);
vm_Xport.fx(t,regi,tradeCap) = p24_Xport(t,regi,tradeCap);

*** Setting Xport price bound to avoid unrealists trading prices.
*** Lower bound: avoiding epsilon values (caused by using equation marginals for setting prices) or unrealistic small value for H2 exporting prices -> minimun price = 1$/kg (1$/kg = 0.030769231 $/Kwh = 0.030769231 / (10^12/10^9*8760) T$/TWa = 0.26953846356 T$/TWa) 
***pm_XPortsPrice(t,regi,"seh2") = min(0.26953846356,pm_XPortsPrice(t,regi,"seh2"));

*** EOF ./modules/24_trade/capacity/presolve.gms
