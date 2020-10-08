*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/presolve.gms
*** JeS set aerosol energy emissions to level of previous iteration
p15_so2emi(ttot,"so2") = vm_emiAllGlob.l(ttot,"so2");
p15_so2emi(ttot,"bc")  = vm_emiAllGlob.l(ttot,"bc");
p15_so2emi(ttot,"oc")  = vm_emiAllGlob.l(ttot,"oc");
*** EOF ./modules/15_climate/box/presolve.gms
