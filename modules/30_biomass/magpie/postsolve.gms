*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/30_biomass/magpie/postsolve.gms

*** Save values for tracking across Nash iterations
o_v30_pebiolc_costs(iteration,ttot,regi) = v30_pebiolc_costs.l(ttot,regi);
o_vm_fuExtr_pebiolc(iteration,ttot,regi) = vm_fuExtr.l(ttot,regi,"pebiolc","1");
o_vm_pebiolc_price(iteration,ttot,regi)  = vm_pebiolc_price.l(ttot,regi);

*** EOF ./modules/30_biomass/magpie/postsolve.gms
