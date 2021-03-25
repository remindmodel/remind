*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/se_trade/postsolve.gms

pm_Xport0(ttot,regi,tradePe) = vm_Xport.l(ttot,regi,tradePe);

display vm_Mport.l, vm_Mport.lo, vm_Mport.up;

*** EOF ./modules/24_trade/se_trade/postsolve.gms
