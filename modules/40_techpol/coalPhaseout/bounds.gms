*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/coalPhaseout/bounds.gms
vm_deltaCap.up(t,regi,"pc","1")$(t.val gt 2023)        =0.000001;
vm_deltaCap.up(t,regi,"igcc","1")$(t.val gt 2023)      =0.000001;
vm_deltaCap.up(t,regi,"coalchp","1")$(t.val gt 2023)   =0.000001;
vm_deltaCap.up(t,regi,"coalftrec","1")$(t.val ge 2013) =0.000002;
vm_deltaCap.up(t,regi,"coalh2","1")$(t.val ge 2013)    =0.000001;
vm_deltaCap.up(t,regi,"coalgas","1")$(t.val ge 2013)   =0.000001;
vm_deltaCap.up(t,regi,"coalhp","1")$(t.val ge 2013)    =0.000001;

*** EOF ./modules/40_techpol/coalPhaseout/bounds.gms
