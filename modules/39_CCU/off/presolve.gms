*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/off/presolve.gms

vm_co2CCUshort.l(t,regi,"cco2","ccuco2short",teCCU2rlf(te2,rlf)) = 0;
vm_prodSe.l(t,regi,"seh2","segasyn","h22ch4") = 0;
vm_prodSe.l(t,regi,"seh2","seliqsyn","MeOH") = 0;

*** EOF ./modules/39_CCU/off/presolve.gms
