*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/se_trade/postsolve.gms

pm_Xport0(ttot,regi,tradePe) = vm_Xport.l(ttot,regi,tradePe);

display vm_Mport.l, vm_Mport.lo, vm_Mport.up;


$IFTHEN.trade_SE_shareDemand not "%cm_trade_SE_shareDemand%" == "off"
*** save to SE imports to parameter to track over iterations
p24_Mport_iter(t,regi,tradeSe,iteration)=vm_Mport.l(t,regi,tradeSe);
*** save to SE prices to parameter to track over iterations
p24_SEPrice_iter(t,regi,tradeSe,iteration)=pm_SEPrice(t,regi,tradeSe);
*** calculate relative change of SE import quantities to previous iteration to be used as convergence criterion
p24_Mport_iter_relChange(t,regi,tradeSe,iteration)$(p24_Mport_iter(t,regi,tradeSe,iteration-1))=p24_Mport_iter(t,regi,tradeSe,iteration)/p24_Mport_iter(t,regi,tradeSe,iteration-1);
$ENDIF.trade_SE_shareDemand

*** EOF ./modules/24_trade/se_trade/postsolve.gms
