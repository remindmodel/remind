*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/spillover/output.gms

o20_ImiGDP_lab(t,regi,"lab")= vm_invImi.L(t,regi,"lab")/vm_cesIO.l(t,regi,"inco");
o20_ImiGDP_E(t,regi,"en")= vm_invImi.L(t,regi,"en")/vm_cesIO.l(t,regi,"inco");
o20_InnoGDP_lab(t,regi,"lab")= vm_invInno.L(t,regi,"lab")/vm_cesIO.l(t,regi,"inco");
o20_InnoGDP_E(t,regi,"en")= vm_invInno.L(t,regi,"en")/vm_cesIO.l(t,regi,"inco");

display vm_EffGr.l, v20_effInno.l, v20_effImi.l, o20_ImiGDP_lab, o20_ImiGDP_E, o20_InnoGDP_lab, o20_InnoGDP_E;
*** EOF ./modules/20_growth/spillover/output.gms
