*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/se_trade/preloop.gms

***initializing parameters
vm_Mport.l(t,regi,tradeSe) = 0;
vm_Xport.l(t,regi,tradeSe)  = 0;
pm_MPortsPrice(t,regi,tradeSe) = 0;
pm_XPortsPrice(t,regi,tradeSe) = 0;
pm_SEPrice(t,regi,entySe) = 0;

*** EOF ./modules/24_trade/se_trade/preloop.gms
