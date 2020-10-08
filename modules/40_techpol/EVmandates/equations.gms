*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/EVmandates/equations.gms
 q40_EV_share(t,regi)$(t.val ge 2020)..
    vm_deltaCap(t,regi,"apCarElT","1")/
   (1e-6 + sum(teue2rlf(te,rlf)$(sameas(te,"apCarPeT") OR sameas(te,"apCarElT")), vm_deltaCap(t,regi,te,rlf)))!!1e-6 to avoid infeasibility in case of zero sales in 2110
   =g= p40_EV_share(t,regi);

*** EOF ./modules/40_techpol/EVmandates/equations.gms
