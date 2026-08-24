*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  REMIND, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/bounds.gms
*** calculate emission cap in absolute terms

*** In later iterations, recalculate allocation from market emissions

vm_perm.lo(t,regi) = -10;
vm_perm.up(t,regi) = 100;

vm_Xport.fx(t,regi,"perm")$(t.val gt 2100) = 0;
vm_Mport.fx(t,regi,"perm")$(t.val gt 2100) = 0;

*** EOF ./modules/41_emicapregi/JUSTMip/bounds.gms
